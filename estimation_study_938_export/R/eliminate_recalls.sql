-- Create and populate once per session
CREATE TABLE #recalled_lots (
    lot_number VARCHAR(50)
);

-- Bulk insert from a flat file (one lot number per line)
BULK INSERT #recalled_lots
FROM 'C:\path\to\lot_numbers.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 1
);

-- Add an index for join performance
CREATE INDEX idx_lot ON #recalled_lots(lot_number);

-- Then use #recalled_lots anywhere recalled_lots appeared below
-- TO DO: I belive the va omop drug_exposure table does not include the lot_numbers
-- so this would have to be switched to standard CDW table. Check my notes
SELECT c.person_id
FROM your_cohort_table c
WHERE NOT EXISTS (
    SELECT 1
    FROM drug_exposure de
    INNER JOIN #recalled_lots rl ON de.lot_number = rl.lot_number
    WHERE de.person_id = c.person_id
);

-- scope to arbs
-- ARB RxNorm ingredient concept IDs (standard OMOP concepts)
WITH arb_concepts AS (
    SELECT DISTINCT ca.descendant_concept_id AS drug_concept_id
    FROM concept_ancestor ca
    INNER JOIN concept c ON ca.ancestor_concept_id = c.concept_id
    WHERE c.concept_name IN (
        'losartan', 'valsartan', 'irbesartan', 'candesartan',
        'olmesartan', 'telmisartan', 'azilsartan', 'eprosartan'
    )
    AND c.domain_id = 'Drug'
    AND c.standard_concept = 'S'
),

recalled_lots AS (
    SELECT lot_number FROM #recalled_lots
),

exposed_patients AS (
    SELECT DISTINCT de.person_id
    FROM drug_exposure de
    INNER JOIN recalled_lots rl ON de.lot_number = rl.lot_number
    INNER JOIN arb_concepts ac ON de.drug_concept_id = ac.drug_concept_id
    WHERE de.person_id IN (SELECT person_id FROM your_cohort_table)
)

SELECT c.person_id
FROM your_cohort_table c
WHERE c.person_id NOT IN (SELECT person_id FROM exposed_patients)
;

--use of NOT EXISTS is often more efficient than NOT IN, especially when dealing with large datasets, as it can short-circuit and avoid scanning the entire subquery result set.
SELECT c.person_id
FROM your_cohort_table c
WHERE NOT EXISTS (
    SELECT 1
    FROM drug_exposure de
    INNER JOIN recalled_lots rl ON de.lot_number = rl.lot_number
    WHERE de.person_id = c.person_id
)
;

-- QC check first
SELECT de.lot_number, COUNT(DISTINCT de.person_id) AS n_patients
FROM drug_exposure de
INNER JOIN recalled_lots rl ON de.lot_number = rl.lot_number
GROUP BY de.lot_number
ORDER BY n_patients DESC;