SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

-- Base data
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2


-- Total cases vs total deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
FROM PortfolioProject..CovidDeaths$
Where location like '%states%'
ORDER BY 1,2


-- Total cases vs population
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PopPercent
FROM PortfolioProject..CovidDeaths$
Where location like '%states%'
ORDER BY 1,2


-- Countries with highest infection rate 
SELECT Location, population, MAX(total_cases) as HighestInfection, MAX((total_cases)/population)*100 as PopPercent
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY PopPercent DESC


-- Countries with highest death count per pop
SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Continent
SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global numbers
SELECT date, SUM(new_cases) AS Cases, SUM(cast(new_deaths AS INT)) AS Deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercent
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- Total pop vs vaccination    > Partition = making it add by date/location instead of total after everything
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(cast(V.new_vaccinations AS int)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS VaccTally
FROM PortfolioProject..CovidDeaths$ as D
JOIN PortfolioProject..CovidVaccinations$ as V
	ON D.location = V.location AND D.date = V.date
WHERE D.continent IS NOT NULL AND V.new_vaccinations IS NOT NULL
ORDER BY 2,3


-- CTE usage to add the math
WITH PopVSVac (Continent, location, date, population, new_vaccinations, VaccTally)
AS 
(
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(cast(V.new_vaccinations AS int)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS VaccTally
FROM PortfolioProject..CovidDeaths$ as D
JOIN PortfolioProject..CovidVaccinations$ as V
	ON D.location = V.location AND D.date = V.date
WHERE D.continent IS NOT NULL AND V.new_vaccinations IS NOT NULL
)
SELECT *, (VaccTally/population)*100
FROM PopVSVac


-- Same query with Temp table
DROP TABLE IF EXISTS #PercentPopVacc
CREATE TABLE #PercentPopVacc (Continent nvarchar(255), location nvarchar(255), date datetime, population numeric, new_vaccinations numeric, VaccTally numeric)
INSERT INTO #PercentPopVacc
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(cast(V.new_vaccinations AS int)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS VaccTally
FROM PortfolioProject..CovidDeaths$ as D
JOIN PortfolioProject..CovidVaccinations$ as V
	ON D.location = V.location AND D.date = V.date
WHERE D.continent IS NOT NULL AND V.new_vaccinations IS NOT NULL
SELECT *, (VaccTally/population)*100
FROM #PercentPopVacc


-- Creating view to store for visualization
DROP VIEW IF EXISTS PercentPopVacc
CREATE VIEW PercentPopVacc AS
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(cast(V.new_vaccinations AS int)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS VaccTally
FROM PortfolioProject..CovidDeaths$ as D
JOIN PortfolioProject..CovidVaccinations$ as V
	ON D.location = V.location AND D.date = V.date
WHERE D.continent IS NOT NULL AND V.new_vaccinations IS NOT NULL


SELECT *
FROM PercentPopVacc