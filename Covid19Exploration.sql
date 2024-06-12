/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Selecting Data 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Death
-- Shows the likelihood of dying if someone contracts COVID-19 by country
SELECT location, date, total_cases, total_deaths, CAST(total_deaths AS float) / CAST(total_cases AS float) * 100 DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population got COVID-19
SELECT location, date, population, total_cases, CAST(total_cases AS float) / population * 100 PercentPopultionInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) HighestInfectionCount, MAX(CAST(total_cases AS float) / population) * 100 PercentPopultionInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopultionInfected DESC

-- Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- TAKING A LOOK BY CONTINENT

-- Continent with the Highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT date, 
	SUM(CAST(new_cases AS float)) AS TotalNewCases, 
	SUM(CAST(new_deaths AS int)) AS TotalNewDeaths, 
	SUM(CAST(new_deaths AS int))/SUM(CAST(new_cases AS float)) * 100 AS DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--SELECT SUM(CAST(new_cases AS float)) AS TotalNewCases, 
--	   SUM(CAST(new_deaths AS int)) AS TotalNewDeaths, 
--	   SUM(CAST(new_deaths AS int))/SUM(CAST(new_cases AS float)) * 100 AS DeathPercent
--FROM PortfolioProject..CovidDeaths
--WHERE continent IS NOT NULL
--ORDER BY 1,2


-- Total Population vs Vaccinations
SELECT deaths.continent, 
	   deaths.location, 
	   deaths.date, 
	   deaths.population, 
	   vacc.new_vaccinations,
	   SUM(CONVERT(int, vacc.new_vaccinations)) 
	   OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date 
ORDER BY 2,3

SELECT deaths.continent, 
	   deaths.location, 
	   deaths.date, 
	   deaths.population, 
	   vacc.new_vaccinations,
	   SUM(CONVERT(int, vacc.new_vaccinations)) 
	   OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date 
ORDER BY 2,3

-- Use CTE
WITH PopvsVacc(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
SELECT deaths.continent, 
	   deaths.location, 
	   deaths.date, 
	   deaths.population, 
	   vacc.new_vaccinations,
	   SUM(CONVERT(int, vacc.new_vaccinations)) 
	   OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date 
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated / CONVERT(float, Population)) * 100
FROM PopvsVacc


-- TEMP TABLE
--DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, 
	   deaths.location, 
	   deaths.date, 
	   deaths.population, 
	   vacc.new_vaccinations,
	   SUM(CONVERT(int, vacc.new_vaccinations)) 
	   OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date 

SELECT *, (RollingPeopleVaccinated / CONVERT(float, Population)) * 100
FROM #PercentPopulationVaccinated

-- Table to store data for visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT deaths.continent, 
	   deaths.location, 
	   deaths.date, 
	   deaths.population, 
	   vacc.new_vaccinations,
	   SUM(CONVERT(int, vacc.new_vaccinations)) 
	   OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date 