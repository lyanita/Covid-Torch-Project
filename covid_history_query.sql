# Author: Anita Ly
# Date: February 15, 2021
# Description: The following queries load data from a csv file, and calculates metrics on test results, case increase averages and positivity rates

CREATE TABLE `covid_state_history` (
    `date` VARCHAR(45) DEFAULT NULL,
    `state` VARCHAR(45) DEFAULT NULL,
    `dateQuality` VARCHAR(45) DEFAULT NULL,
    `death` VARCHAR(45) DEFAULT NULL,
    `deathConfirmed` VARCHAR(45) DEFAULT NULL,
    `deathIncrease` VARCHAR(45) DEFAULT NULL,
    `deathProbable` VARCHAR(45) DEFAULT NULL,
    `hospitalized` VARCHAR(45) DEFAULT NULL,
    `hospitalizedCumulative` VARCHAR(45) DEFAULT NULL,
    `hospitalizedCurrently` VARCHAR(45) DEFAULT NULL,
    `hospitalizedIncrease` VARCHAR(45) DEFAULT NULL,
    `inlcuCumulative` VARCHAR(45) DEFAULT NULL,
    `inlcuCurrently` VARCHAR(45) DEFAULT NULL,
    `negative` VARCHAR(45) DEFAULT NULL,
    `negativeIncrease` VARCHAR(45) DEFAULT NULL,
    `negativeTestsAntibody` VARCHAR(45) DEFAULT NULL,
    `negativeTestsPeopleAntibody` VARCHAR(45) DEFAULT NULL,
    `negativeTestsViral` VARCHAR(45) DEFAULT NULL,
    `onVentilatorCumulative` VARCHAR(45) DEFAULT NULL,
    `onVentilatorCurrently` VARCHAR(45) DEFAULT NULL,
    `positive` VARCHAR(45) DEFAULT NULL,
    `positiveCasesViral` VARCHAR(45) DEFAULT NULL,
    `positiveIncrease` VARCHAR(45) DEFAULT NULL,
    `positiveScore` VARCHAR(45) DEFAULT NULL,
    `positiveTestsAnitbody` VARCHAR(45) DEFAULT NULL,
    `positiveTestsAntigen` VARCHAR(45) DEFAULT NULL,
    `positiveTestsPeopleAnitbody` VARCHAR(45) DEFAULT NULL,
    `positiveTestPeopleAntigen` VARCHAR(45) DEFAULT NULL,
    `positiveTestsViral` VARCHAR(45) DEFAULT NULL,
    `recovered` VARCHAR(45) DEFAULT NULL,
    `totalTestEncountersViral` VARCHAR(45) DEFAULT NULL,
    `totalTestEncountersViralIncrease` VARCHAR(45) DEFAULT NULL,
    `totalTestResults` VARCHAR(45) DEFAULT NULL,
    `totalTestResultsIncrease` VARCHAR(45) DEFAULT NULL,
    `totalTestsAntibody` VARCHAR(45) DEFAULT NULL,
    `totalTestsAntigen` VARCHAR(45) DEFAULT NULL,
    `totalTestsPeopleAntibody` VARCHAR(45) DEFAULT NULL,
    `totalTestsPeopleAntigen` VARCHAR(45) DEFAULT NULL,
    `totalTestPeopleViral` VARCHAR(45) DEFAULT NULL,
    `totalTestsPeopleViralIncrease` VARCHAR(45) DEFAULT NULL,
    `totalTestsViral` VARCHAR(45) DEFAULT NULL,
    `totalTestsViralIncrease` VARCHAR(45) DEFAULT NULL
)  ENGINE=INNODB DEFAULT CHARSET=UTF8;
;

-- Load csv file into table
LOAD DATA INFILE "all-states-history.csv" INTO TABLE covid_state_history 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES #ignore header as created table contains header
;

-- Check number of records
SELECT COUNT(*) FROM covid_state_history
;
-- Check column field names
SHOW COLUMNS in covid_state_history
;

-- Determine the total number of tests performed as of yesterday (assuming today is Feb 9, 2021, which is the date of data pull) in the US
CREATE TABLE test_prev_date AS SELECT SUBDATE(MAX(date), 1) AS date, totalTestResults FROM covid_state_history
;
SELECT 'date', 'totalTestResults'
UNION ALL
SELECT * FROM test_prev_date
INTO OUTFILE 'test_prev_date.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
;

-- Calculate the 7-day rolling average of new cases per day rolling over the last 30 days
CREATE TABLE case_increase_average AS
SELECT 
	date, 
    caseIncreaseAverage 
FROM 
	(SELECT 
		date, 
        AVG(positiveIncrease) OVER(ORDER BY date ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as caseIncreaseAverage 
	FROM
		(SELECT 
        date, 
        SUM(positiveIncrease) as positiveIncrease 
	FROM covid_state_history
	GROUP BY date
    ) A
) B
WHERE date BETWEEN SUBDATE((SELECT MAX(date) from covid_state_history), 30) AND (SELECT MAX(date) from covid_state_history)
ORDER BY date DESC
;
-- Export table to CSV
SELECT 'date', 'caseIncreaseAverage'
UNION ALL
SELECT * FROM case_increase_average
INTO OUTFILE 'case_increase_average.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
;

-- Calculate the 10 states with the highest test positivity rate (positive tests / tests performed) for tests performed in the last 30 days
CREATE TABLE positivity_rate_state AS 
(SELECT 
    state,
    (SUM(positive) / SUM(totalTestResults)) AS positivityRate
FROM
    covid_state_history
WHERE
    date BETWEEN SUBDATE((SELECT MAX(date) FROM covid_state_history), 30) AND (SELECT MAX(date) FROM covid_state_history)
GROUP BY state
ORDER BY positivityRate DESC
LIMIT 10) # Sort by descending order, then limit 10 provides top 10 positivity rates by state
;
-- Export table to CSV
SELECT 'state', 'positiveityRate'
UNION ALL
SELECT * FROM positivity_rate_state
INTO OUTFILE 'positivity_rate_state.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
