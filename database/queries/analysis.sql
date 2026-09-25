-- Global Economic Intelligence Platform
-- Analytical SQL Queries
--================================================

-- --South Africa GDP by year
-- SELECT c.country_name,i.indicator_name,f.year,f.value
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- WHERE c.country_code='ZAF' AND i.indicator_code='NY.GDP.MKTP.CD'
-- ORDER BY f.year DESC;

-- --South Africa GDP in billions of US dollars
-- SELECT c.country_name,f.year,ROUND(f.value/1000000000.0,2) AS gdp_usd_billions
-- FROM fact_observation AS f
-- JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- WHERE c.country_code='ZAF' AND i.indicator_code='NY.GDP.MKTP.CD'
-- AND f.value is NOT NULL
-- ORDER BY f.year DESC;

-- --GDP Comparison across countries
-- SELECT c.country_name,f.year,ROUND(f.value/1000000000.0,2)AS gdp_usd_billions
-- FROM fact_observation AS f 
-- JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- WHERE i.indicator_code='NY.GDP.MKTP.CD' AND f.value is NOT NULL
-- ORDER BY f.year DESC,f.value DESC;

-- --Observation count by country and indicator
-- SELECT c.country_name,i.indicator_name,COUNT(*) AS observation_count
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- GROUP BY c.country_name,i.indicator_name
-- ORDER BY c.country_name,i.indicator_name;

-- --Data availability by country and indicator
-- SELECT c.country_name,i.indicator_name,COUNT(*) AS observation_count,COUNT(f.value) AS available_values,
-- COUNT(*)-COUNT(f.value) AS missing_values
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- GROUP BY c.country_name,i.indicator_name
-- ORDER BY c.country_name,i.indicator_name;

-- --Inflation summary statistics
-- SELECT c.country_name,
-- COUNT(f.value) AS available_observations,
-- ROUND(AVG(f.value),2) AS average_inflation,
-- ROUND(MIN(f.value),2) AS minimum_inflation,
-- ROUND(MAX(f.value),2) AS maximum_inflation
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- WHERE i.indicator_code='FP.CPI.TOTL.ZG'
-- GROUP BY c.country_name
-- ORDER BY average_inflation;

-- --Average population across all countries and available years
-- SELECT c.country_name,
-- ROUND(AVG(f.value/1000000.0),2) AS average_population_millions
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- WHERE i.indicator_code='SP.POP.TOTL'
-- GROUP BY c.country_name
-- ORDER BY average_population_millions DESC;

-- --Missing value validation
-- SELECT c.country_name,i.indicator_name,f.year,f.value
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- WHERE f.value is NULL
-- ORDER BY c.country_name,i.indicator_name,f.year;

-- --Data completeness summary
-- SELECT c.country_name,i.indicator_name,COUNT(*) AS observation_count,COUNT(f.value) AS available_values,
-- COUNT(*)-COUNT(f.value) AS missing_values,
-- ROUND(COUNT(f.value)*100.0/COUNT(*),2) AS completeness_percentage
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- GROUP BY c.country_name,i.indicator_name
-- ORDER BY c.country_name,i.indicator_name;

-- --Country and Indicator combinations having atleast one Null value
-- SELECT c.country_name,i.indicator_name,COUNT(*)-COUNT(f.value) AS missing_values
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- GROUP BY c.country_name,i.indicator_name HAVING missing_values>0
-- ORDER BY c.country_name, i.indicator_name;

-- --Time-Series coverage validation
-- SELECT c.country_name,i.indicator_name,MIN(f.year) AS first_year,MAX(f.year) AS last_year,
-- MAX(f.year)-MIN(f.year)+1 AS expected_years,COUNT(*) AS actual_observations,
-- (MAX(f.year)-MIN(f.year)+1)-COUNT(*) AS missing_years
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- GROUP BY c.country_name,i.indicator_name
-- ORDER BY c.country_name,i.indicator_name;

-- --Country-indicator series that appear to have one or more missing years
-- SELECT c.country_name,i.indicator_name,(MAX(f.year)-MIN(f.year)+1)-COUNT(*) AS missing_years
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- GROUP BY c.country_name,i.indicator_name HAVING missing_years>0
-- ORDER BY c.country_name,i.indicator_name;

-- --Inflation classification
-- SELECT c.country_name,f.year,ROUND(f.value,2) AS inflation_rate,
-- CASE
-- WHEN f.value<2 THEN 'Very Low'
-- WHEN f.value<5 THEN 'Moderate'
-- WHEN f.value<10 THEN 'High'
-- ELSE 'Very High'
-- END AS inflation_category
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- WHERE i.indicator_code='FP.CPI.TOTL'
-- AND f.value IS NOT NULL
-- ORDER BY f.year DESC,c.country_name;

-- --High inflation classification
-- SELECT c.country_name,
-- SUM(CASE WHEN f.value>=5 THEN 1 ELSE 0 END) AS high_inflation_years_count
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- WHERE i.indicator_code='FP.CPI.TOTL'
-- AND f.value IS NOT NULL
-- GROUP BY c.country_name
-- ORDER BY high_inflation_years_count DESC,c.country_name;

-- --For each country, how many years were Very Low, moderate,high,and very high inflation
-- SELECT c.country_name,
-- SUM(CASE WHEN f.value<2 THEN 1 ELSE 0 END) AS very_low_years
-- SUM(CASE WHEN f.value>=2 AND f.value<5 THEN 1 ELSE 0 END) AS moderate_years
-- SUM(CASE WHEN f.value>=5 AND f.value<10 THEN 1 ELSE 0 END) AS high_years
-- SUM(CASE WHEN f.value>=10 THEN 1 ELSE 0 END) AS very_high_years
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- WHERE i.indicator_code='FP.CPI.TOTL'
-- AND f.value IS NOT NULL
-- GROUP BY c.country_name
-- ORDER BY high_years DESC,c.country_name;

-- --Average inflation using a CTE(Which countries had an avereage rate above 4%)
-- WITH country_inflation AS(
-- SELECT c.country_name, AVG(f.value) AS average_inflation
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- WHERE i.indicator_code='FP.CPI.TOTL'
-- AND f.value IS NOT NULL
-- GROUP BY c.country_name
-- )

-- SELECT country_name,ROUND(average_inflation,2) AS average_inflation
-- FROM country_inflation
-- WHERE average_inflation>4
-- ORDER BY average_inflation DESC;

-- --Average population using a CTE( which countries had an average population above 100)
-- WITH country_population AS(
-- SELECT c.country_name,AVG(f.value/1000000.0) AS average_population_millions
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- WHERE i.indicator_code='SP.POP.TOTL'
-- AND f.value IS NOT NULL
-- GROUP BY c.country_name
-- )
-- SELECT country_name,ROUND(average_population_millions,2) AS average_population_millions
-- FROM country_population
-- WHERE average_population_millions>100
-- ORDER BY average_population_millions DESC;


-- --For every inflation observation,was that country's inflation above or below its own historical average?
-- WITH country_average_inflation AS(
-- SELECT f.country_id,AVG(f.value) AS average_inflation
-- FROM fact_observation AS f JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- WHERE i.indicator_code='FP.CPI.TOTL'
-- AND f.value IS NOT NULL
-- GROUP BY f.country_id
-- )
-- SELECT c.country_name,f.year,ROUND(f.value,2) AS inflation_rate,ROUND(a.average_inflation) AS average_inflation
-- CASE
-- WHEN f.value<a.average_inflation THEN 'Below Average'
-- WHEN f.value>a.average_inflation THEN 'Above Average'
-- ELSE 'Equal to Average'
-- END AS inflation_comparison

-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- JOIN country_average_inflation AS a ON f.country_id=a.country_id

-- WHERE i.indicator_code='FP.CPI.TOTL'
-- AND f.value IS NOT NULL
-- ORDER BY f.year DESC, c.country_name;

-- --For each country, find the latest available GDP observation, show the GDP in billions, and compare it with that country’s average GDP across all available years.
-- WITH country_average_GDP AS(
-- SELECT f.country_id,AVG(f.value/1000000000.0) AS average_gdp_billions
-- FROM fact_observation as f JOIN dim_indicator as i ON f.indicator_id=i.indicator_id
-- WHERE i.indicator_code='NY.GDP.MKTP.CD' AND f.value is NOT NULL
-- GROUP BY f.country_id
-- )
-- latest_gdp_year AS (
-- SELECT f.country_id, MAX(f.year) AS latest_year
-- FROM fact_observation AS f
-- JOIN dim_indicator AS i ON f.indicator_id = i.indicator_id
-- WHERE i.indicator_code = 'NY.GDP.MKTP.CD'
-- AND f.value IS NOT NULL
-- GROUP BY f.country_id
-- )
-- SELECT c.country_name,f.year AS latest_year,ROUND(f.value / 1000000000.0, 2) AS latest_gdp_billions,ROUND(f.value/1000000000.0,2) AS latest_gdp_billions,a.average_gdp_billions,
-- CASE
-- WHEN f.value<a.average_gdp_billions THEN'Below Average'
-- WHEN f.value>a.average_gdp_billions THEN'Above Average'
-- ELSE 'Equal to Average'
-- END AS comparison

-- FROM fact_observation as f JOIN dim_country as c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- JOIN country_average_GDP as a ON f.country_id=a.country_id
-- JOIN latest_gdp_year AS l ON f.country_id = l.country_id
-- AND f.year = l.latest_year
-- WHERE i.indicator_code='NY.GDP.MKTP.CD' AND f.value is NOT NULL
-- ORDER BY c.country_name;

-- --Inflation observations above the overall average(Which inflation observations were higher than the overall average inflation across all countries and years?)
-- SELECT c.country_name,f.year,ROUND(f.value,2) AS inflation_value
-- FROM fact_observation as f JOIN dim_country as c ON f.country_id=c.country_id
-- JOIN dim_indicator as i ON f.indicator_id=i.indicator_id
-- WHERE i.indicator_code='FP.CPI.TOTL'
-- AND f.value IS NOT NULL
-- AND f.value>(SELECT AVG(f2.value)
-- FROM fact_observation as f2 JOIN dim_indicator AS i2 ON f2.indicator_id=i2.indicator_id
-- WHERE i.indicator_code='FP.CPI.TOTL'
-- AND f2.value IS NOT NULL
-- )
-- ORDER BY f.value DESC,f.year DESC;

-- --GDP observations with country average using a window function

-- SELECT c.country_name,f.year,ROUND(f.value/1000000000.0,2) AS gdp_billions,
-- ROUND(AVG(f.value) OVER(PARTITION BY c.country_name),2) AS average_gdp_billions
-- FROM fact_observation as f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- WHERE i.indicator_code='NY.GDP.MKTP.CD' AND f.value is NOT NULL
-- ORDER BY c.country_name,f.year;

-- --inflation observations with country average using a window function
-- SELECT c.country_name,f.year,ROUND(f.value,2) AS inflation_rate,
-- ROUND(AVG(f.value) OVER(PARTITION BY c.country_name),2) AS average_inflation_rate
-- FROM fact_observation as f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- WHERE i.indicator_code='FP.CPI.TOTL' AND f.value IS NOT NULL
-- ORDER BY c.country_name,f.year;

-- --For every GDP observation, show the country's GDP for that year and its GDP from the previous year.
-- SELECT c.country_name,f.year,ROUND(f.value/1000000000.0,2) AS gdp_billions,
-- ROUND(LAG(f.value) OVER(PARTITION BY c.country_name ORDER BY f.year)/1000000000.0,2) AS previous_gdp_billions
-- FROM fact_observation as f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- WHERE i.indicator_code='NY.GDP.MKTP.CD' AND f.value IS NOT NULL
-- ORDER BY c.country_name,f.year;

-- --GDP year-on-year growth(For each country and year, how much did GDP grow or shrink compared with the previous year?)
-- WITH gdp_with_lag AS(SELECT c.country_name,f.year,f.value AS current_gdp,
-- LAG(f.value)OVER(PARTITION BY c.country_name ORDER BY f.year) AS previous_gdp
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- WHERE i.indicator_code='NY.GDP.MKTP.CD' AND f.value IS NOT NULL
-- )
-- SELECT country_name,year,ROUND(current_gdp/1000000000.0,2) AS current_gdp,
-- ROUND(previous_gdp/1000000000.0,2) AS previous_gdp,
-- ROUND(((current_gdp-previous_gdp)/previous_gdp)*100,2) AS yoy_growth_percentage,
-- CASE
-- WHEN previous_year IS NULL THEN 'No Previous Data'
-- WHEN current_gdp>previous_gdp THEN 'Growth'
-- WHEN current_gdp<previous_gdp THEN 'Contraction'
-- ELSE 'No Change'
-- END AS growth_direction
-- FROM gdp_with_lag
-- ORDER BY country_name,year;

-- --GDP ranking by year(For each year, which country had the largest GDP?)
-- SELECT f.year,c.country_name,ROUND(f.value / 1000000000.0, 2) AS gdp_billions,
-- RANK() OVER (
-- PARTITION BY f.year
-- ORDER BY f.value DESC
-- ) AS gdp_rank
-- FROM fact_observation AS f
-- JOIN dim_country AS c ON f.country_id = c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id = i.indicator_id
-- WHERE i.indicator_code = 'NY.GDP.MKTP.CD'
-- AND f.value IS NOT NULL
-- ORDER BY f.year DESC, gdp_rank;

-- --For each year, rank the countries from highest inflation to lowest inflation.
-- SELECT f.year,c.country_name,ROUND(f.value,2) AS inflation_rate,
-- RANK()OVER(PARTITION BY f.year ORDER BY f.value DESC) AS inflation_rank
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- WHERE i.indicator_code='FP.CPI.TOTL' AND f.value IS NOT NULL
-- ORDER BY f.year DESC,inflation_rank;

-- --Find the latest available GDP observation for every country.
-- WITH latest_year_gdp AS(SELECT c.country_name,f.year,f.value,
-- ROW_NUMBER() OVER(PARTITION BY c.country_name ORDER BY f.year DESC) AS year_row_number
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- WHERE i.indicator_code='NY.GDP.MKTP.CD' AND f.value IS NOT NULL
-- )
-- SELECT country_name,year AS latest_year,ROUND(value/1000000000.0,2) AS latest_gdp_billions
-- FROM latest_year_gdp
-- WHERE year_row_number=1
-- ORDER BY latest_year DESC;

-- --Create a 5-year rolling average of GDP for each country
-- SELECT c.country_name,f.year,ROUND(f.value/1000000000.0,2) AS gdp_billions,
-- ROUND(AVG(f.value)OVER(
-- PARTITION BY c.country_name ORDER BY f.year
-- ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)/1000000000,2)AS rolling_5_year_gdp_billions 
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- WHERE i.indicator_code='NY.GDP.MKTP.CD' AND f.value IS NOT NULL
-- ORDER BY c.country_name,f.year;

-- --Is the country's current GDP above or below its recent 5-year trend?
-- WITH gdp_trends AS(
-- SELECT c.country_name,f.year,f.value,
-- AVG(f.value)OVER(
-- PARTITION BY c.country_name ORDER BY f.year
-- ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)AS rolling_5_year_gdp 
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- WHERE i.indicator_code='NY.GDP.MKTP.CD' AND f.value IS NOT NULL
-- )
-- SELECT country_name,year,ROUND(value/1000000000.0,2) AS gdp_billions,ROUND(rolling_5_year_gdp/1000000000.0,2) AS rolling_5_year_gdp_billions,
-- CASE
-- WHEN value>rolling_5_year_gdp THEN 'Above 5-Year Average'
-- WHEN value<rolling_5_year_gdp THEN 'Below 5-Year Average'
-- ELSE 'Equal to 5-Year Average'
-- END AS trend_position
-- FROM gdp_trends
-- ORDER BY country_name,year;

-- --For every inflation observation, show the current year's inflation and the following observation's inflation.
-- SELECT c.country_name,f.year,ROUND(f.value,2) AS inflation_rate,
-- ROUND(LEAD(f.value) OVER(
-- PARTITION BY c.country_name ORDER BY f.year),2) AS next_year_inflation_rate
-- FROM fact_observation as f JOIN dim_country as c ON f.country_id=c.country_id
-- JOIN dim_indicator as i ON f.indicator_id=i.indicator_id
-- WHERE i.indicator_code='FP.CPI.TOTL' AND f.value IS NOT NULL
-- ORDER BY c.country_name,f.year;

-- --Are there any duplicate country-indicator-year observations in fact_observation?
-- SELECT c.country_name,i.indicator_name,f.year,COUNT(*)AS duplicate_count
-- FROM fact_observation as f JOIN dim_country as c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- GROUP BY c.country_name,i.indicator_name,f.year
-- HAVING COUNT(*)>1
-- ORDER BY c.country_name,i.indicator_name,f.year;

-- --Data Validation:Missing Years
-- WITH country_indicator AS(
-- SELECT c.country_name,i.indicator_name,MIN(f.year) AS first_year,MAX(f.year) AS latest_year,
-- COUNT(*) AS actual_observations
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- GROUP BY c.country_name,i.indicator_name
-- )
-- SELECT country_name,indicator_name,first_year,latest_year,(latest_year-first_year+1) AS expected_years,actual_observations,(expected_years-actual_observations) AS missing_years
-- FROM country_indicator
-- WHERE (expected_years-actual_observations) AS missing_years>0
-- ORDER BY country_name,latest_year DESC;

--Are there any impossible negative GDP or population observations?
-- WITH gdp_population_validation AS(
-- SELECT c.country_name,i.indicator_name,f.year,f.value,
-- CASE
-- WHEN i.indicator_code='NY.GDP.MKTP.CD' AND f.value<0 THEN 'Invalid'
-- WHEN i.indicator_code='SP.POP.TOTL' AND f.value<0 THEN 'Invalid'
-- ELSE 'Valid'
-- END AS validation_status
-- FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
-- JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
-- WHERE i.indicator_code IN ('NY.GDP.MKTP.CD','SP.POP.TOTL')
-- AND f.value IS NOT NULL
-- )
-- SELECT country_name,indicator_name,year,value,validation_status
-- FROM gdp_population_validation
-- WHERE validation_status='Invalid'
-- ORDER BY country_name,indicator_name;

-- PRAGMA index_list('fact_observation');
-- UNIQUE(country_id,indicator_id,year)

-- EXPLAIN QUERY PLAN
-- SELECT * FROM fact_observation

-- WHERE country_id=1 AND indicator_id=1 AND year=2024

-- EXPLAIN QUERY PLAN

-- SELECT *
-- FROM fact_observation

-- WHERE country_id = 1;

-- EXPLAIN QUERY PLAN

-- SELECT *
-- FROM fact_observation

-- WHERE country_id = 1
-- AND indicator_id = 1;

-- EXPLAIN QUERY PLAN

-- SELECT *
-- FROM fact_observation

-- WHERE year = 2024;

--SQL CHALLENGE
--Inflation Analysis
--For each country, identify the year in which it experienced its highest recorded inflation rate.country_code

WITH highest_inflation AS(
SELECT c.country_name,f.year,f.value,
ROW_NUMBER() OVER(PARTITION BY c.country_name ORDER BY f.value DESC,f.year DESC) AS value_row_number
FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id

WHERE i.indicator_code='FP.CPI.TOTL.ZG' AND f.value IS NOT NULL
)

SELECT country_name, year, ROUND(value,2) AS inflation_rate

FROM highest_inflation

WHERE value_row_number=1
ORDER BY inflation_rate DESC


--GDP contractions
--For each country, determine how many years GDP declined compared with the previous available year.

WITH previous_year_gdp AS(
SELECT c.country_name,f.year AS current_year, LAG(f.year)OVER(PARTITION BY c.country_name ORDER BY f.year) AS previous_year, f.value AS current_gdp,
LAG(f.value)OVER(PARTITION BY c.country_name ORDER BY f.year) AS previous_gdp,f.country_id
FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
WHERE i.indicator_code='NY.GDP.MKTP.CD' AND f.value IS NOT NULL
)

SELECT c.country_name, COUNT(*) AS total_gdp_observations, SUM(CASE WHEN g.current_year-g.previous_year=1 AND g.current_gdp<g.previous_gdp THEN 1 ELSE 0 END) AS contraction_years,
ROUND(100*SUM(CASE WHEN g.current_year-g.previous_year=1 AND g.current_gdp<g.previous_gdp THEN 1 ELSE 0 END)/NULLIF(SUM(CASE WHEN g.current_year-g.previous_year=1 THEN 1 ELSE 0 END),0),2) AS contraction_percentage
FROM previous_year_gdp AS g JOIN dim_country AS c ON g.country_id=c.country_id
GROUP BY c.country_id,c.country_name
ORDER BY contraction_percentage DESC;

--GDP vs Inflation
--For each country and year, show GDP and inflation side by side, but only for years where both indicators are available

WITH gdp AS(
SELECT c.country_name,f.year AS current_year,f.value AS gdp_value,f.country_id
FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id

WHERE i.indicator_code='NY.GDP.MKTP.CD' AND f.value IS NOT NULL
)
SELECT country_name,current_year,ROUND(gdp_value/1000000000.0,2)AS gdp_billions,ROUND(f.value,2) AS inflation_rate
FROM gdp AS g JOIN fact_observation AS f ON g.current_year=f.year AND g.country_id=f.country_id
JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id

WHERE i.indicator_code='FP.CPI.TOTL.ZG' AND f.value IS NOT NULL
ORDER BY country_name,current_year



--For each country, identify its strongest consecutive GDP growth year and provide economic context for that year.

WITH gdp AS(
SELECT c.country_name,f.country_id,f.year AS current_year,LAG(f.year)OVER(PARTITION BY country_name ORDER BY f.year) AS previous_year,f.value AS current_gdp,
LAG(f.value)OVER(PARTITION BY c.country_name ORDER BY f.year) AS previous_gdp
FROM fact_observation AS f JOIN dim_country AS c ON f.country_id=c.country_id
JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id

WHERE i.indicator_code='NY.GDP.MKTP.CD' AND f.value IS NOT NULL
),
gdp_growth AS(
SELECT country_name,country_id,current_year,previous_year,current_gdp,previous_gdp,100.0*((current_gdp-previous_gdp)/previous_gdp) AS gdp_growth_percentage
FROM gdp 

WHERE (current_year-previous_year=1)AND previous_year IS NOT NULL
),
inflation AS(
SELECT country_name,h.country_id,current_year,previous_year,current_gdp,previous_gdp,gdp_growth_percentage,f.value AS inflation_rate
FROM gdp_growth as h JOIN fact_observation AS f ON  h.current_year=f.year AND h.country_id=f.country_id
JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id
WHERE i.indicator_code='FP.CPI.TOTL.ZG' AND f.value IS NOT NULL
),
population_m AS(
SELECT country_name,t.country_id,current_year,previous_year,current_gdp,previous_gdp,gdp_growth_percentage,inflation_rate,
f.value AS population
FROM inflation as t JOIN fact_observation AS f ON t.current_year=f.year AND t.country_id=f.country_id
JOIN dim_indicator AS i ON f.indicator_id=i.indicator_id

WHERE i.indicator_code='SP.POP.TOTL'AND f.value IS NOT NULL
),
row_number AS(
SELECT country_name,country_id,current_year,previous_year,current_gdp,previous_gdp,gdp_growth_percentage,inflation_rate,population,
ROW_NUMBER()OVER(PARTITION BY country_name ORDER BY gdp_growth_percentage DESC,inflation_rate DESC,population DESC) AS row_number_ranking
FROM population_m
),
highest_growth AS(
SELECT country_name,country_id,current_year,previous_year,current_gdp,previous_gdp,gdp_growth_percentage,inflation_rate,population
FROM row_number
WHERE row_number_ranking=1 AND gdp_growth_percentage>0
)
SELECT country_name,current_year,ROUND(current_gdp/1000000000.0,2)AS gdp_billions,ROUND(previous_gdp/1000000000.0,2)AS previous_gdp_billions,ROUND(gdp_growth_percentage,2)AS gdp_growth_percentage,ROUND(inflation_rate,2) AS inflation_rate,
ROUND(population/1000000.0,2)AS population_millions
FROM highest_growth
ORDER BY gdp_growth_percentage DESC, current_year DESC




