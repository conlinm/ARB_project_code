SELECT
(CAST(measurement_concept_id AS BIGINT) * 10000) + (range_group * 1000) + 712 AS covariate_id,
row_id,
1 AS covariate_value
INTO #cov_4
FROM (
SELECT measurement_concept_id,
CASE
WHEN value_as_number < range_low THEN 1
WHEN value_as_number > range_high THEN 3
ELSE 2
END AS range_group,
cohort.row_id AS row_id
FROM #cohort_person cohort
INNER JOIN ORD_Conlin_201708011D.OMOPV5.measurement
ON cohort.subject_id = measurement.person_id
WHERE measurement_date <= DATEADD(DAY, 0, cohort.cohort_start_date)
AND measurement_date >= DATEADD(DAY, -30, cohort.cohort_start_date)
AND measurement_concept_id != 0
AND range_low IS NOT NULL
AND range_high IS NOT NULL
AND measurement_concept_id NOT IN (SELECT id FROM #id_set_1)
) grouped_2
GROUP BY measurement_concept_id,
range_group
,row_id
