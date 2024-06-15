-- Data about COVID Deaths in Colombia
SELECT *
FROM [CovidDeaths]
WHERE [location] = 'Colombia'
ORDER BY [date];

-- Death Rate Over Time
SELECT
    [location],
    [date],
    [population],
    [total_cases],
    [total_deaths],
    ([total_deaths] / CAST([total_cases] AS FLOAT)) * 100 AS DeathRate
FROM [CovidDeaths]
WHERE [location] = 'Colombia'
ORDER BY [date];

-- MAX Death Rate
SELECT TOP 1
    [location],
    [date],
    [population],
    [total_cases],
    [total_deaths],
    ROUND(([total_deaths] / CAST([total_cases] AS FLOAT)) * 100, 2) AS DeathRate
FROM [CovidDeaths]
WHERE [location] = 'Colombia'
ORDER BY DeathRate DESC;

-- Current Death Rate
SELECT TOP 1
    [location],
    [date],
    [population],
    [total_cases],
    [total_deaths],
    CONCAT(ROUND(([total_deaths] / CAST([total_cases] AS FLOAT)) * 100, 2), '%') AS DeathRate
FROM [CovidDeaths]
WHERE [location] = 'Colombia'
ORDER BY [date] DESC;

-- Infection Rate Over Time
SELECT
    [location],
    [date],
    [population],
    [total_cases],
    [total_deaths],
    ROUND(([total_cases] / CAST([population] AS FLOAT)) * 100, 2) AS InfectionRate
FROM [CovidDeaths]
WHERE [location] = 'Colombia'
ORDER BY [date];

-- Current Infection Rate
SELECT TOP 1
    [location],
    [date],
    [population],
    [total_cases],
    [total_deaths],
    ROUND(([total_cases] / CAST([population] AS FLOAT)) * 100, 2) AS InfectionRate
FROM [CovidDeaths]
WHERE [location] = 'Colombia'
ORDER BY [date] DESC;

SELECT 


-- SQL COURSE

-- Data what we are going to use
SELECT 
    Location, 
    date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    population
FROM CovidDeaths
ORDER BY 1, 2;

-- Looking at Total Cases vs Total Deaths - DeathRate
-- Shows likelihood of dying if you contarct COVID in Colombia.
SELECT 
    Location, 
    date, 
    total_cases, 
    total_deaths, 
    (total_deaths/CAST(total_cases AS FLOAT)) * 100 AS DeathRate
FROM CovidDeaths
WHERE Location = 'Colombia'
ORDER BY 2;

-- Looking at the Total Cases vs Population
-- Show what percentage of population got COVID.
SELECT
    Location, 
    date, 
    total_cases, 
    Population, 
    (total_cases/CAST(Population AS FLOAT)) * 100 AS InfectionRate
FROM CovidDeaths
WHERE Location = 'Colombia'
ORDER BY 2 ASC;

-- Countries with higest infection rate
SELECT 
    Location, 
    Population, 
    MAX(total_cases) AS CurrentTotalCases, 
    (MAX(total_cases)/CAST(MAX(Population) AS FLOAT)) * 100 AS InfectionRate
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY InfectionRate DESC;

-- Shows the countries with the highest death count per population
SELECT 
    Location, 
    Population, 
    MAX(total_deaths) AS TotalDeathCount, 
    (MAX(total_deaths)/CAST(MAX(Population) AS FLOAT)) * 100 AS DeathPerPopulation
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY DeathPerPopulation DESC;

-- Shows the countries with the highest death count.
SELECT 
    Location, 
    Population, 
    MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY TotalDeathCount DESC;

-- Break down by contintn
SELECT 
    location,
    MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Shows the continents with the hight count per population
SELECT 
    continent,
    MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- GLOBAL NUMBERS
SELECT 
    date, 
    SUM(new_cases) AS total_cases, 
    SUM(new_deaths) AS total_deaths, 
    SUM(CAST(new_deaths AS FLOAT)) / SUM(NULLIF(new_cases, 0)) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

-- Total Global Death Percentage
SELECT 
    SUM(new_cases) AS total_cases, 
    SUM(new_deaths) AS total_deaths, 
    SUM(CAST(new_deaths AS FLOAT)) / SUM(NULLIF(new_cases, 0)) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL;

-- JOIN

-- Lookin at Total Population vs Vaccination
SELECT
    Dea.continent, 
    Dea.location, 
    Dea.date, 
    Dea.population, 
    Vac.new_vaccinations,
    SUM(Vac.new_vaccinations) OVER (PARTITION BY Vac.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM CovidVacinations Vac
JOIN CovidDeaths Dea
    ON Vac.date = Dea.date
    AND Vac.location = Dea.location
WHERE Vac.continent IS NOT NULL
ORDER BY 2, 3;

-- USE CTE
WITH PopvsVav (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
AS (
    SELECT
        Dea.continent, 
        Dea.location, 
        Dea.date, 
        Dea.population, 
        Vac.new_vaccinations,
        SUM(Vac.new_vaccinations) OVER (PARTITION BY Vac.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
    FROM CovidVacinations Vac
    JOIN CovidDeaths Dea
        ON Vac.date = Dea.date
        AND Vac.location = Dea.location
    WHERE Vac.continent IS NOT NULL
    --ORDER BY 2, 3
)
SELECT * , (RollingPeopleVaccinated / CAST(population AS FLOAT)) * 100
FROM PopvsVav;

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATE,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentagePopulationVaccinated
SELECT
    Dea.continent, 
    Dea.location, 
    Dea.date, 
    Dea.population, 
    Vac.new_vaccinations,
    SUM(Vac.new_vaccinations) OVER (PARTITION BY Vac.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM CovidVacinations Vac
JOIN CovidDeaths Dea
    ON Vac.date = Dea.date
    AND Vac.location = Dea.location
-- WHERE Vac.continent IS NOT NULL
-- ORDER BY 2, 3;

SELECT * , (p.RollingPeopleVaccinated / NULLIF(p.population, 0)) * 100
FROM #PercentagePopulationVaccinated p;

-- Creating a View to Store Date for later Visualizations
CREATE VIEW PercentagePopulationVaccinated AS
SELECT
    Dea.continent, 
    Dea.location, 
    Dea.date, 
    Dea.population, 
    Vac.new_vaccinations,
    SUM(Vac.new_vaccinations) OVER (PARTITION BY Vac.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM CovidVacinations Vac
JOIN CovidDeaths Dea
    ON Vac.date = Dea.date
    AND Vac.location = Dea.location
WHERE Vac.continent IS NOT NULL
-- ORDER BY 2, 3;


SELECT *
FROM PercentagePopulationVaccinated;