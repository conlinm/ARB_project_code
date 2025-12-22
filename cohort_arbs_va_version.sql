/*
Run this cohort SQL script first, as it will create the necessary cohort table to hold the results!!!

Note that this SQL script is adapted for the VA OMOP instance, and differs from the standard OHDSI Atlas-generated cohort SQL script in several ways, including table names and schema names.
*/

-- Set the vocabulary and cdm database schema names
-- DECLARE @vocabulary_database_schema SYSNAME = 'SRC.OMOPV5_';
-- DECLARE @cdm_database_schema SYSNAME = 'SRC.OMOPV5_';
DECLARE @target_database_schema SYSNAME = 'Dflt.';
DECLARE @target_cohort_table SYSNAME = 'MJC_arb_cohort';
DECLARE @target_cohort_id INT = 1;
--cohort id 1: ARB users with no prior RCCa, CKD, transplant, or genetic risk
-- cohort id 2: control cohort defined in different script



CREATE TABLE #Codesets
(
    codeset_id int NOT NULL,
    concept_id bigint NOT NULL
)
;
/* Populate Codesets Table
Codeset ID Legend:
0: ARB Drugs
2: Exclusion: Prior RCCa Diagnosis
3: Exclusion: Genetic or Familial Risk of RCCa
4: Exclusion: Prior Chronic Kidney Disease Diagnosis
5: Exclusion: Transplant History
6: Hypertension Diagnosis
In each of these code blocks, there is an inner query (I) that gets the specified concept_ids and their descendants, and an outer query (C) that selects distinct concept_ids from that result set to avoid duplicates.
*/
INSERT INTO #Codesets
    (codeset_id, concept_id)
    SELECT 0 as codeset_id, c.concept_id
    FROM (select distinct I.concept_id
        FROM
            ( 
                                          select concept_id
                from Src.OMOPV5_CONCEPT
                where concept_id in (1308842,1317640,1346686,1347384,1351557,1367500,40226742,40235485)
            UNION
                select c.concept_id
                from Src.OMOPV5_CONCEPT c
                    join Src.OMOPV5_CONCEPT_ANCESTOR   ca on c
.concept_id = ca.descendant_concept_id
                        and ca.ancestor_concept_id in
(1308842,1317640,1346686,1347384,1351557,1367500,40226742,40235485)
                        and c.invalid_reason is null

) I
) C
UNION ALL
    --- RCCa
    SELECT 2 as codeset_id, c.concept_id
    FROM (select distinct I.concept_id
        FROM
            ( 
                                          select concept_id
                from Src.OMOPV5_CONCEPT
                where concept_id in (45765451,45773365,37116954)
            UNION
                select c.concept_id
                from Src.OMOPV5_CONCEPT c
                    join Src.OMOPV5_CONCEPT_ANCESTOR   ca on c
.concept_id = ca.descendant_concept_id
                        and ca.ancestor_concept_id in
(45765451,45773365,37116954)
                        and c.invalid_reason is null

) I
) C
UNION ALL
    --- Genetic Risk of RCCa
    SELECT 3 as codeset_id, c.concept_id
    FROM (select distinct I.concept_id
        FROM
            ( 
                                          select concept_id
                from Src.OMOPV5_CONCEPT
                where concept_id in (4263213,380839,37399456,37160584,4110719,35622838,4240212,37396489)
            UNION
                select c.concept_id
                from Src.OMOPV5_CONCEPT c
                    join Src.OMOPV5_CONCEPT_ANCESTOR   ca on c
.concept_id = ca.descendant_concept_id
                        and ca.ancestor_concept_id in
(4263213,380839,4110719)
                        and c.invalid_reason is null

) I
) C
UNION ALL
    --- Chronic Kidney Disease/ESRD
    SELECT 4 as codeset_id, c.concept_id
    FROM (select distinct I.concept_id
        FROM
            ( 
                                          select concept_id
                from Src.OMOPV5_CONCEPT
                where concept_id in (37395652,443611,193782)
            UNION
                select c.concept_id
                from Src.OMOPV5_CONCEPT c
                    join Src.OMOPV5_CONCEPT_ANCESTOR   ca on c
.concept_id = ca.descendant_concept_id
                        and ca.ancestor_concept_id in
(37395652,443611,193782)
                        and c.invalid_reason is null

) I
) C
UNION ALL
    --- Transplant History
    SELECT 5 as codeset_id, c.concept_id
    FROM (select distinct I.concept_id
        FROM
            ( 
                                          select concept_id
                from Src.OMOPV5_CONCEPT
                where concept_id in (42537741)
            UNION
                select c.concept_id
                from Src.OMOPV5_CONCEPT c
                    join Src.OMOPV5_CONCEPT_ANCESTOR   ca on c
.concept_id = ca.descendant_concept_id
                        and ca.ancestor_concept_id in
(42537741)
                        and c.invalid_reason is null

) I
) C
UNION ALL
    SELECT 6 as codeset_id, c.concept_id
    FROM (select distinct I.concept_id
        FROM
            ( 
                                          select concept_id
                from Src.OMOPV5_CONCEPT
                where concept_id in (316866)
            UNION
                select c.concept_id
                from Src.OMOPV5_CONCEPT c
                    join Src.OMOPV5_CONCEPT_ANCESTOR   ca on c
.concept_id = ca.descendant_concept_id
                        and ca.ancestor_concept_id in
(316866)
                        and c.invalid_reason is null

) I
) C;

UPDATE STATISTICS #Codesets;

/* Begin Primary Events: ARB Drug Eras

*/
SELECT event_id, person_id, start_date, end_date, op_start_date, op_end_date, visit_occurrence_id
INTO #qualified_events
FROM
    (
  select pe.event_id, pe.person_id, pe.start_date, pe.end_date, pe.op_start_date, pe.op_end_date, row_number() over (partition by pe.person_id order by pe.start_date ASC) as ordinal, cast(pe.visit_occurrence_id as bigint) as visit_occurrence_id
    FROM (-- Begin Primary Events
select P.ordinal as event_id, P.person_id, P.start_date, P.end_date, op_start_date, op_end_date, cast(P.visit_occurrence_id as bigint) as visit_occurrence_id
        FROM
            (
  select E.person_id, E.start_date, E.end_date,
                row_number() OVER (PARTITION BY E.person_id ORDER BY E.sort_date ASC, E.event_id) ordinal,
                OP.observation_period_start_date as op_start_date, OP.observation_period_end_date as op_end_date, cast(E.visit_occurrence_id as bigint) as visit_occurrence_id
            FROM
                (
  -- Begin Drug Era Criteria
select C.person_id, C.drug_era_id as event_id, C.start_date, C.end_date,
                    CAST(NULL as bigint) as visit_occurrence_id, C.start_date as sort_date
                from
                    (
  select de.person_id, de.drug_era_id, de.drug_concept_id, de.drug_exposure_count, de.gap_days, de.drug_era_start_date as start_date, de.drug_era_end_date as end_date
                    FROM Src.OMOPV5_DRUG_ERA de
                    where de.drug_concept_id in (SELECT concept_id
                    from #Codesets
                    where codeset_id = 0)
) C

                WHERE DATEDIFF(d,C.start_date, C.end_date) > 60 -- minimum era duration of 60 days
-- End Drug Era Criteria

  ) E
                JOIN Src.OMOPV5_observation_period   OP on E.person_id
= OP.person_id and E.start_date >=  OP.observation_period_start_date and E.start_date <= op.observation_period_end_date
            WHERE DATEADD
(day,365,OP.OBSERVATION_PERIOD_START_DATE) <= E.START_DATE AND DATEADD
(day,0,E.START_DATE) <= OP.OBSERVATION_PERIOD_END_DATE -- ensure at least 1 year of observation prior to event
) P
        WHERE P.ordinal = 1
-- End Primary Events
) pe
  
) QE

;

--- Inclusion Rule Inserts

select 0 as inclusion_rule_id, person_id, event_id
INTO #Inclusion_0
FROM
    (
  select pe.person_id, pe.event_id
    FROM #qualified_events pe

        JOIN (
-- Begin Criteria Group
select 0 as index_id, person_id, event_id
        FROM
            (
  select E.person_id, E.event_id
            FROM #qualified_events E
                INNER JOIN
                (
    -- Begin Demographic Criteria
SELECT 0 as index_id, e.person_id, e.event_id
                FROM #qualified_events E
                    JOIN Src.OMOPV5_PERSON   P ON P  .PERSON_ID = E.PERSON_ID
                WHERE YEAR(E.start_date) - P.year_of_birth > 18
                GROUP BY e.person_id, e.event_id
-- End Demographic Criteria

  ) CQ on E  .person_id = CQ.person_id and E.event_id = CQ.event_id
            GROUP BY E.person_id, E.event_id
            HAVING COUNT(index_id) = 1
) G
-- End Criteria Group
) AC on AC.person_id = pe.person_id AND AC.event_id = pe.event_id
) Results
;

select 1 as inclusion_rule_id, person_id, event_id
INTO #Inclusion_1
FROM
    (
  select pe.person_id, pe.event_id
    FROM #qualified_events pe

        JOIN (
-- Begin Criteria Group
select 0 as index_id, person_id, event_id
        FROM
            (
  select E.person_id, E.event_id
            FROM #qualified_events E
                INNER JOIN
                (
    -- Begin Correlated Criteria
select 0 as index_id, p.person_id, p.event_id
                from #qualified_events p
                    LEFT JOIN (
SELECT p.person_id, p.event_id
                    FROM #qualified_events P
                        JOIN (
  -- Begin Condition Occurrence Criteria
SELECT C.person_id, C.condition_occurrence_id as event_id, C.start_date, C.end_date,
                            C.visit_occurrence_id, C.start_date as sort_date
                        FROM
                            (
  SELECT co.person_id, co.condition_occurrence_id, co.condition_concept_id, co.visit_occurrence_id, co.condition_start_date as start_date, COALESCE(co.condition_end_date, DATEADD(day,1,co.condition_start_date)) as end_date
                            FROM Src.OMOPV5_CONDITION_OCCURRENCE co
                                JOIN #Codesets cs on (co.condition_concept_id = cs.concept_id and cs.codeset_id = 2)
) C  


-- End Condition Occurrence Criteria

) A on A.person_id = P.person_id AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE ) cc on p.person_id = cc.person_id and p.event_id = cc.event_id
                GROUP BY p.person_id, p.event_id
                HAVING COUNT(cc.event_id) = 0
-- End Correlated Criteria

  ) CQ on E  .person_id = CQ.person_id and E.event_id = CQ.event_id
            GROUP BY E.person_id, E.event_id
            HAVING COUNT(index_id) = 1
) G
-- End Criteria Group
) AC on AC.person_id = pe.person_id AND AC.event_id = pe.event_id
) Results
;

select 2 as inclusion_rule_id, person_id, event_id
INTO #Inclusion_2
FROM
    (
  select pe.person_id, pe.event_id
    FROM #qualified_events pe

        JOIN (
-- Begin Criteria Group
select 0 as index_id, person_id, event_id
        FROM
            (
  select E.person_id, E.event_id
            FROM #qualified_events E
                INNER JOIN
                (
    -- Begin Correlated Criteria
select 0 as index_id, p.person_id, p.event_id
                from #qualified_events p
                    LEFT JOIN (
SELECT p.person_id, p.event_id
                    FROM #qualified_events P
                        JOIN (
  -- Begin Condition Occurrence Criteria
SELECT C.person_id, C.condition_occurrence_id as event_id, C.start_date, C.end_date,
                            C.visit_occurrence_id, C.start_date as sort_date
                        FROM
                            (
  SELECT co.person_id, co.condition_occurrence_id, co.condition_concept_id, co.visit_occurrence_id, co.condition_start_date as start_date, COALESCE(co.condition_end_date, DATEADD(day,1,co.condition_start_date)) as end_date
                            FROM Src.OMOPV5_CONDITION_OCCURRENCE co
                                JOIN #Codesets cs on (co.condition_concept_id = cs.concept_id and cs.codeset_id = 3)
) C  


-- End Condition Occurrence Criteria

) A on A.person_id = P.person_id AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE ) cc on p.person_id = cc.person_id and p.event_id = cc.event_id
                GROUP BY p.person_id, p.event_id
                HAVING COUNT(cc.event_id) = 0
-- End Correlated Criteria

  ) CQ on E  .person_id = CQ.person_id and E.event_id = CQ.event_id
            GROUP BY E.person_id, E.event_id
            HAVING COUNT(index_id) = 1
) G
-- End Criteria Group
) AC on AC.person_id = pe.person_id AND AC.event_id = pe.event_id
) Results
;

select 3 as inclusion_rule_id, person_id, event_id
INTO #Inclusion_3
FROM
    (
  select pe.person_id, pe.event_id
    FROM #qualified_events pe

        JOIN (
-- Begin Criteria Group
select 0 as index_id, person_id, event_id
        FROM
            (
  select E.person_id, E.event_id
            FROM #qualified_events E
                INNER JOIN
                (
    -- Begin Correlated Criteria
select 0 as index_id, p.person_id, p.event_id
                from #qualified_events p
                    LEFT JOIN (
SELECT p.person_id, p.event_id
                    FROM #qualified_events P
                        JOIN (
  -- Begin Condition Occurrence Criteria
SELECT C.person_id, C.condition_occurrence_id as event_id, C.start_date, C.end_date,
                            C.visit_occurrence_id, C.start_date as sort_date
                        FROM
                            (
  SELECT co.person_id, co.condition_occurrence_id, co.condition_concept_id, co.visit_occurrence_id, co.condition_start_date as start_date, COALESCE(co.condition_end_date, DATEADD(day,1,co.condition_start_date)) as end_date
                            FROM Src.OMOPV5_CONDITION_OCCURRENCE co
                                JOIN #Codesets cs on (co.condition_concept_id = cs.concept_id and cs.codeset_id = 4)
) C  


-- End Condition Occurrence Criteria

) A on A.person_id = P.person_id AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= DATEADD(day,0,P.START_DATE) ) cc on p.person_id = cc.person_id and p.event_id = cc.event_id
                GROUP BY p.person_id, p.event_id
                HAVING COUNT(cc.event_id) = 0
-- End Correlated Criteria

  ) CQ on E  .person_id = CQ.person_id and E.event_id = CQ.event_id
            GROUP BY E.person_id, E.event_id
            HAVING COUNT(index_id) = 1
) G
-- End Criteria Group
) AC on AC.person_id = pe.person_id AND AC.event_id = pe.event_id
) Results
;

select 4 as inclusion_rule_id, person_id, event_id
INTO #Inclusion_4
FROM
    (
  select pe.person_id, pe.event_id
    FROM #qualified_events pe

        JOIN (
-- Begin Criteria Group
select 0 as index_id, person_id, event_id
        FROM
            (
  select E.person_id, E.event_id
            FROM #qualified_events E
                INNER JOIN
                (
    -- Begin Correlated Criteria
select 0 as index_id, p.person_id, p.event_id
                from #qualified_events p
                    LEFT JOIN (
SELECT p.person_id, p.event_id
                    FROM #qualified_events P
                        JOIN (
  -- Begin Condition Occurrence Criteria
SELECT C.person_id, C.condition_occurrence_id as event_id, C.start_date, C.end_date,
                            C.visit_occurrence_id, C.start_date as sort_date
                        FROM
                            (
  SELECT co.person_id, co.condition_occurrence_id, co.condition_concept_id, co.visit_occurrence_id, co.condition_start_date as start_date, COALESCE(co.condition_end_date, DATEADD(day,1,co.condition_start_date)) as end_date
                            FROM Src.OMOPV5_CONDITION_OCCURRENCE co
                                JOIN #Codesets cs on (co.condition_concept_id = cs.concept_id and cs.codeset_id = 5)
) C  


-- End Condition Occurrence Criteria

) A on A.person_id = P.person_id AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= DATEADD(day,0,P.START_DATE) ) cc on p.person_id = cc.person_id and p.event_id = cc.event_id
                GROUP BY p.person_id, p.event_id
                HAVING COUNT(cc.event_id) = 0
-- End Correlated Criteria

  ) CQ on E  .person_id = CQ.person_id and E.event_id = CQ.event_id
            GROUP BY E.person_id, E.event_id
            HAVING COUNT(index_id) = 1
) G
-- End Criteria Group
) AC on AC.person_id = pe.person_id AND AC.event_id = pe.event_id
) Results
;

SELECT inclusion_rule_id, person_id, event_id
INTO #inclusion_events
FROM (                                                            select inclusion_rule_id, person_id, event_id
        from #Inclusion_0
    UNION ALL
        select inclusion_rule_id, person_id, event_id
        from #Inclusion_1
    UNION ALL
        select inclusion_rule_id, person_id, event_id
        from #Inclusion_2
    UNION ALL
        select inclusion_rule_id, person_id, event_id
        from #Inclusion_3
    UNION ALL
        select inclusion_rule_id, person_id, event_id
        from #Inclusion_4) I;
TRUNCATE TABLE #Inclusion_0;
DROP TABLE #Inclusion_0;

TRUNCATE TABLE #Inclusion_1;
DROP TABLE #Inclusion_1;

TRUNCATE TABLE #Inclusion_2;
DROP TABLE #Inclusion_2;

TRUNCATE TABLE #Inclusion_3;
DROP TABLE #Inclusion_3;

TRUNCATE TABLE #Inclusion_4;
DROP TABLE #Inclusion_4;


select event_id, person_id, start_date, end_date, op_start_date, op_end_date
into #included_events
FROM (
  SELECT event_id, person_id, start_date, end_date, op_start_date, op_end_date, row_number() over (partition by person_id order by start_date ASC) as ordinal
    from
        (
    select Q.event_id, Q.person_id, Q.start_date, Q.end_date, Q.op_start_date, Q.op_end_date, SUM(coalesce(POWER(cast(2 as bigint), I.inclusion_rule_id), 0)) as inclusion_rule_mask
        from #qualified_events Q
            LEFT JOIN #inclusion_events I on I.person_id = Q.person_id and I.event_id = Q.event_id
        GROUP BY Q.event_id, Q.person_id, Q.start_date, Q.end_date, Q.op_start_date, Q.op_end_date
  ) MG
    -- matching groups

    -- the matching group with all bits set ( POWER(2,# of inclusion rules) - 1 = inclusion_rule_mask
    WHERE (MG.inclusion_rule_mask = POWER(cast(2 as bigint),5)-1)

) Results
WHERE Results.ordinal = 1
;



-- generate cohort periods into #final_cohort
select person_id, start_date, end_date
INTO #cohort_rows
from ( -- first_ends
	select F.person_id, F.start_date, F.end_date
    FROM (
	                          select I.event_id, I.person_id, I.start_date, CE.end_date, row_number() over (partition by I.person_id, I.event_id order by CE.end_date) as ordinal
        from #included_events I
            join ( -- cohort_ends
-- cohort exit dates
-- By default, cohort exit at the event's op end date
                                                                    select event_id, person_id, op_end_date as end_date
                from #included_events
            UNION ALL
                -- Censor Events
                select i.event_id, i.person_id, MIN(c.start_date) as end_date
                FROM #included_events i
                    JOIN
                    (
-- Begin Condition Occurrence Criteria
SELECT C.person_id, C.condition_occurrence_id as event_id, C.start_date, C.end_date,
                        C.visit_occurrence_id, C.start_date as sort_date
                    FROM
                        (
  SELECT co.person_id, co.condition_occurrence_id, co.condition_concept_id, co.visit_occurrence_id, co.condition_start_date as start_date, COALESCE(co.condition_end_date, DATEADD(day,1,co.condition_start_date)) as end_date
                        FROM Src.OMOPV5_CONDITION_OCCURRENCE co
                            JOIN #Codesets cs on (co.condition_concept_id = cs.concept_id and cs.codeset_id = 2)
) C  


-- End Condition Occurrence Criteria

) C on C.person_id = I.person_id and C.start_date >= I.start_date and C.START_DATE <= I.op_end_date
                GROUP BY i.event_id, i.person_id

            UNION ALL
                select i.event_id, i.person_id, MIN(c.start_date) as end_date
                FROM #included_events i
                    JOIN
                    (
-- Begin Death Criteria
select C.person_id, C.person_id as event_id, C.start_date, c.end_date,
                        CAST(NULL as bigint) as visit_occurrence_id, C.start_date as sort_date
                    from
                        (
  select d.person_id, d.cause_concept_id, d.death_date as start_date, DATEADD(day,1,d.death_date) as end_date
                        FROM Src.OMOPV5_DEATH d

) C  


-- End Death Criteria


) C on C.person_id = I.person_id and C.start_date >= I.start_date and C.START_DATE <= I.op_end_date
                GROUP BY i.event_id, i.person_id


) CE on I.event_id = CE.event_id and I.person_id = CE.person_id and CE.end_date >= I.start_date
	) F
    WHERE F.ordinal = 1
) FE;

select person_id, min(start_date) as start_date, end_date
into #final_cohort
from ( --cteEnds
	SELECT
        c.person_id
		, c.start_date
		, MIN(ed.end_date) AS end_date
    FROM #cohort_rows c
        JOIN ( -- cteEndDates
    SELECT
            person_id
      , DATEADD(day,-1 * 0, event_date)  as end_date
        FROM
            (
      SELECT
                person_id
        , event_date
        , event_type
        , SUM(event_type) OVER (PARTITION BY person_id ORDER BY event_date, event_type ROWS UNBOUNDED PRECEDING) AS interval_status
            FROM
                (
                                                                    SELECT
                        person_id
          , start_date AS event_date
          , -1 AS event_type
                    FROM #cohort_rows

                UNION ALL


                    SELECT
                        person_id
          , DATEADD(day,0,end_date) as end_date
          , 1 AS event_type
                    FROM #cohort_rows
      ) RAWDATA
    ) e
        WHERE interval_status = 0
  ) ed ON c.person_id = ed.person_id AND ed.end_date >= c.start_date
    GROUP BY c.person_id, c.start_date
) e
group by person_id, end_date
;

/* Here I had to deviate from the Atlas script, and created a table in the VA system to hold the cohorts. This is one table that will hold both the ARB and control cohorts, differentiated by cohort_definition_id. */

-- first drop the table if it already exists
DROP TABLE IF EXISTS [Dflt].[MJC_arb_cohort];

CREATE TABLE [Dflt].[MJC_arb_cohort] (
    cohort_definition_id INT NOT NULL,
    subject_id BIGINT NOT NULL,
    cohort_start_date DATE NOT NULL,
    cohort_end_date DATE NOT NULL
)

-- DELETE FROM @target_database_schema.@target_cohort_table where cohort_definition_id = @target_cohort_id;

-- INSERT INTO @target_database_schema.@target_cohort_table


INSERT INTO Dflt.MJC_arb_cohort
(cohort_definition_id, subject_id, cohort_start_date, cohort_end_date)
select @target_cohort_id as cohort_definition_id, person_id, start_date, end_date
FROM #final_cohort CO
;






TRUNCATE TABLE #cohort_rows;
DROP TABLE #cohort_rows;

TRUNCATE TABLE #final_cohort;
DROP TABLE #final_cohort;

TRUNCATE TABLE #inclusion_events;
DROP TABLE #inclusion_events;

TRUNCATE TABLE #qualified_events;
DROP TABLE #qualified_events;

TRUNCATE TABLE #included_events;
DROP TABLE #included_events;

TRUNCATE TABLE #Codesets;
DROP TABLE #Codesets;