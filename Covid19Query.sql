CREATE DATABASE Covid19;
SELECT COUNT(*)
FROM CovidDeaths

SELECT COUNT(*)
FROM CovidVaccinations

-- Viewing tables --
SELECT *
FROM CovidDeaths

SELECT *
FROM CovidVaccinations

-- Seeing if there are any duplicates using DISTINCT --
SELECT DISTINCT *
FROM CovidDeaths

SELECT DISTINCT *
FROM CovidVaccinations

-- Viewing new cases logged in as negative numbers --
SELECT *
FROM CovidDeaths
WHERE new_cases < 0

-- Changing negative numbers in new cases to positive numbers --
SELECT continent, location, new_cases,
CASE 
    WHEN new_cases < 0 THEN (new_cases * (-1))
    ELSE (new_cases * 1)
    END AS Updated_NewCases
FROM CovidDeaths
WHERE new_cases < 0

-- When Covid cases were the highest for each country --
SELECT continent, location, MAX(new_cases) AS max_cases
FROM CovidDeaths
WHERE location <> continent AND continent IS NOT NULL
GROUP BY 1, 2
HAVING MAX(new_cases) IS NOT NULL
ORDER BY max_cases DESC

-- Covid cases at the height of the pandemic in the US --
SELECT date, location, new_cases
FROM CovidDeaths
WHERE new_cases = 1369637 AND location LIKE 'United %'

-- Data Exploration --
SELECT date, location, population, total_deaths, new_cases, new_deaths
FROM CovidDeaths
ORDER BY date DESC

SELECT date, continent, location, population, total_deaths, new_cases, new_deaths
FROM CovidDeaths
WHERE location <> continent AND location <> 'World'
ORDER BY population DESC

SELECT CovidDeaths.location, CovidDeaths.population, CovidDeaths.date, CovidDeaths.total_deaths, CovidVaccinations.total_vaccinations, CovidVaccinations.total_boosters
FROM CovidDeaths
JOIN CovidVaccinations
    ON CovidDeaths.location = CovidVaccinations.location

-- The percentage of people who have been fully vaccinated per each country (highest to lowest) --
SELECT CovidDeaths.continent, CovidDeaths.location, 
    SUM(CovidDeaths.population) AS Total_Population, 
    SUM(CovidVaccinations.people_fully_vaccinated) AS Total_FullyVaccinated,
    (SUM(CovidVaccinations.people_fully_vaccinated) / SUM(CovidDeaths.population)) *100 AS Percentage_FullyVaccinated
FROM CovidDeaths
JOIN CovidVaccinations
    ON CovidDeaths.location = CovidVaccinations.location
WHERE CovidDeaths.continent IS NOT NULL
GROUP BY 1, 2
ORDER BY Percentage_FullyVaccinated DESC

-- The percentage of people who have gotten at least one vaccination per each country (highest to lowest) --
SELECT CovidDeaths.continent, CovidDeaths.location, 
    SUM(CovidDeaths.population) AS Total_Population, 
    SUM(CovidVaccinations.total_vaccinations) AS Total_Vaccinated,
    (SUM(CovidVaccinations.total_vaccinations) / SUM(CovidDeaths.population)) *100 AS Percentage_Vaccinated
FROM CovidDeaths
FULL OUTER JOIN CovidVaccinations
    ON CovidDeaths.location = CovidVaccinations.location
WHERE CovidDeaths.continent IS NOT NULL
GROUP BY 1, 2
ORDER BY Percentage_Vaccinated DESC

-- Identifying the percentage of positive Covid-19 tests and classifying them from High to Low --
SELECT CovidDeaths.location, 
    SUM(CovidDeaths.total_cases) AS Total_Cases, 
    SUM(CovidVaccinations.total_tests) AS Total_Tests,
    (SUM(CovidDeaths.total_cases) / SUM(CovidVaccinations.total_tests)) * 100 AS Percent_PositiveTests,
    CASE 
        WHEN (SUM(CovidDeaths.total_cases) / SUM(CovidVaccinations.total_tests)) * 100 > 80 THEN 'Unapplicable'
        WHEN (SUM(CovidDeaths.total_cases) / SUM(CovidVaccinations.total_tests)) * 100 >= 52 THEN 'High'
        WHEN (SUM(CovidDeaths.total_cases) / SUM(CovidVaccinations.total_tests)) * 100 <10 THEN 'Low'
        WHEN (SUM(CovidDeaths.total_cases) / SUM(CovidVaccinations.total_tests)) * 100 < 52 THEN 'Moderate'
        ELSE 'Unapplicable'
        END AS Classification
FROM CovidDeaths
JOIN CovidVaccinations
    ON CovidDeaths.location = CovidVaccinations.location
WHERE CovidDeaths.continent IS NOT NULL
GROUP BY 1
ORDER BY 4 DESC
