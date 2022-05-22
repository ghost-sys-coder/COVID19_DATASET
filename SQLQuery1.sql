--USING THE COVID DEATHS TABLE FROM OUR PORTFOLIO PROJECT DATABASE

SELECT *
FROM [Portfolio Project]..COVID_DEATHS
WHERE continent is not null
ORDER BY 3, 4;

--Select the Data that we will be using!
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM [Portfolio Project]..COVID_DEATHS
WHERE continent is not null
ORDER BY 1, 2;

--Total Deaths vs Total Cases
--Shows the Percentage of patients who died relative to the total number of Covid Cases

SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases) * 100) AS Death_Rate
FROM [Portfolio Project]..COVID_DEATHS
WHERE location like '%uganda%'
ORDER BY 1, 2;

-- Total Cases, Total Deaths and Population
--Looks at the rate of total infections, total deaths against the population

SELECT location, date, total_cases, ((total_cases/population) * 100) AS InfectionRate, total_deaths,  ((total_deaths/population) * 100) AS DeathRate, population
FROM [Portfolio Project]..COVID_DEATHS
WHERE continent is not null
ORDER BY 1, 2;


--Looking at Countries with the Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population) * 100) AS HighestinfectionRate
FROM [Portfolio Project]..COVID_DEATHS
--we group by location and population
--WHERE location like '%united%'
WHERE continent is not null
GROUP BY location, population
ORDER BY HighestInfectionCount, HighestinfectionRate DESC;

--Looking at Countries with the Highest Death Rates compared to Population
SELECT location, population, MAX(cast(total_deaths as int)) AS TotalDeathCount, MAX((cast(total_deaths as int)/population) * 100) AS HighestDeathRate
FROM [Portfolio Project]..COVID_DEATHS
WHERE continent is null
GROUP BY location, population
ORDER BY HighestDeathRate DESC;

--BREAKING THE DATA DOWN BY CONTINENT
			--Highest Death Count
SELECT continent, MAX(cast(total_deaths as int)) AS  HighestDeathCount, MAX((cast(total_deaths as int)/population) * 100) AS HighestDeathRate
FROM [Portfolio Project]..COVID_DEATHS
WHERE continent is not NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;

			--Highest Infection Count
SELECT continent, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population) * 100) AS HighestInfectionRate
FROM [Portfolio Project]..COVID_DEATHS
WHERE continent is not Null
GROUP BY continent
ORDER BY HighestInfectionCount DESC;

--BREAKING THE DATA DOWN BY WORLD OR ACCOUNTING FOR THE GLOBAL TOTAL FIGURES
SELECT * 
FROM [Portfolio Project]..COVID_DEATHS;

SELECT date, SUM(new_cases) AS Total_Global_New_Cases, SUM(CAST(new_deaths as int)) AS Total_Global_New_Deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage
FROM [Portfolio Project]..COVID_DEATHS
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date ASC;

--SINGLE WORLD TOTAL VALUE
SELECT SUM(new_cases) as Total_Global_New_Cases, SUM(CAST(new_deaths as int)) as Total_Global_New_Deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage
FROM [Portfolio Project]..COVID_DEATHS
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1 ASC;

--WORKING WITH BOTH TABLES FROM PORFOLIO PROJECT DATABASE  COVID_DEATHS && COVID_VACCINATIONS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations as New_Vaccinations_Per_Day
FROM [Portfolio Project]..COVID_DEATHS AS DEA 
JOIN [Portfolio Project]..COVID_VACCINATIONS AS VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3;

--USING PARTITIONS TO ANALYSE VACCINATIONS BY LOCATION
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations AS VaccinationsPerDay, 
SUM(CONVERT(bigint, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS VACCINATION_TOTALS_BY_COUNTRY
FROM [Portfolio Project]..COVID_DEATHS AS DEA
JOIN [Portfolio Project]..COVID_VACCINATIONS AS VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY DEA.location, DEA.date;

--LOOKING AS TOTAL POPULATION VS VACCINATIONS USING A COMMON TABLE EXPRESSIONS (CTE)
WITH POPVsVAC (continent, location, date, populaton, new_vaccinations, VACCINATION_TOTALS_BY_COUNTRY)
AS (
	SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations AS VaccinationsPerDay, 
SUM(CONVERT(bigint, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS VACCINATION_TOTALS_BY_COUNTRY
FROM [Portfolio Project]..COVID_DEATHS AS DEA
JOIN [Portfolio Project]..COVID_VACCINATIONS AS VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY DEA.location, DEA.date;
)
SELECT *, ((VACCINATION_TOTALS_BY_COUNTRY/populaton) * 100) AS VACCINATION_PERCENTAGE
FROM POPVsVAC;


--CREATING A TEMPORARY TABLE 
DROP TABLE if exists #PERCENTAGE_OF_POPULATION_VACCINATED --THIS IS INCASE THE TABLE ALREADY EXISTS
CREATE TABLE #PERCENTAGE_OF_POPULATION_VACCINATED
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	VACCINATION_TOTALS_BY_COUNTRY numeric
	--VACCINATION_PERCENTAGE numeric

)

INSERT INTO #PERCENTAGE_OF_POPULATION_VACCINATED
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations AS VaccinationsPerDay, 
SUM(CONVERT(bigint, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS VACCINATION_TOTALS_BY_COUNTRY
FROM [Portfolio Project]..COVID_DEATHS AS DEA
JOIN [Portfolio Project]..COVID_VACCINATIONS AS VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY DEA.location, DEA.date

SELECT *, ((new_vaccinations/population) * 100) AS VACCINATION_PERCENTAGE
FROM #PERCENTAGE_OF_POPULATION_VACCINATED;



-- CREATING VIEWS FOR LATER/WORK VISUALIZATIONS IN TABLEAU 
CREATE VIEW PERCENTAGEPOPULATIONVACCINATED AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations AS VaccinationsPerDay, 
SUM(CONVERT(bigint, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS VACCINATION_TOTALS_BY_COUNTRY
FROM [Portfolio Project]..COVID_DEATHS AS DEA
JOIN [Portfolio Project]..COVID_VACCINATIONS AS VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL;

SELECT * 
FROM PERCENTAGEPOPULATIONVACCINATED;
--ORDER BY DEA.location, DEA.date

SELECT 
OBJECT_SCHEMA_NAME(o.object_id) schema_name,o.name
FROM
sys.objects as o
WHERE
o.type = 'V';

DROP VIEW PERCENTAGEPOPULATIONVACCINATED;

