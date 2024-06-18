-- Data about COVID Deaths in Colombia
SELECT *
FROM [CovidDeaths]
WHERE [location] = 'Colombia'
ORDER BY [date];

-- What is the Death Rate over time in Colombia?
SELECT
    [location],
    [date],
    [population],
    [total_cases],
    [total_deaths],
    ([total_deaths] / CAST([total_cases] AS FLOAT)) * 100 AS [DeathRate]
FROM [CovidDeaths]
WHERE [location] = 'Colombia' AND [total_cases] IS NOT NULL
ORDER BY [date];

-- What was the maximum Death Rate over time in Colombia?
SELECT TOP 1
    [location],
    [date],
    [population],
    [total_cases],
    [total_deaths],
    ROUND(([total_deaths] / CAST([total_cases] AS FLOAT)) * 100, 4) AS [DeathRate]
FROM [CovidDeaths]
WHERE [location] = 'Colombia'
ORDER BY DeathRate DESC;

-- What is the current Death Rate in Colombia?
SELECT TOP 1
    [location],
    [date],
    [population],
    [total_cases],
    [total_deaths],
    ROUND(([total_deaths] / CAST([total_cases] AS FLOAT)) * 100, 4) AS [DeathRate]
FROM [CovidDeaths]
WHERE [location] = 'Colombia'
ORDER BY [date] DESC;

-- What is the Infection Rate over time in Colombia?
SELECT
    [location],
    [date],
    [population],
    [total_cases],
    [total_deaths],
    ROUND(([total_cases] / CAST([population] AS FLOAT)) * 100, 4) AS [InfectionRate]
FROM [CovidDeaths]
WHERE [location] = 'Colombia'
ORDER BY [date];

-- What is the current Infection Rate in Colombia?
SELECT TOP 1
    [location],
    [date],
    [population],
    [total_cases],
    [total_deaths],
    ROUND(([total_cases] / CAST([population] AS FLOAT)) * 100, 4) AS [InfectionRate]
FROM [CovidDeaths]
WHERE [location] = 'Colombia'
ORDER BY [date] DESC;

-- What percentage do Colombian deaths represent in the world?"
WITH [TotalDeathsColombiaWorld] AS (
    SELECT MAX([total_deaths]) AS [TotalDeathsWorld], 
        (
            SELECT MAX([total_deaths])
            FROM [CovidDeaths]
            WHERE [location] = 'Colombia'
        ) AS [TotalDeathsColombia]
    FROM [CovidDeaths]
    WHERE [location] = 'World'
)
SELECT 
    *, 
    ROUND(([TotalDeathsColombia] / CAST([TotalDeathsWorld] AS FLOAT)) * 100, 4) AS [PercentageColombianDeaths]
FROM [TotalDeathsColombiaWorld];

-- What percentage do Colombian deaths represent in South America?"
WITH [TotalDeathsColombiaWorld] AS (
    SELECT MAX([total_deaths]) AS [TotalDeathsSouthAmerica], 
        (
            SELECT MAX([total_deaths])
            FROM [CovidDeaths]
            WHERE [location] = 'Colombia'
        ) AS [TotalDeathsColombia]
    FROM [CovidDeaths]
    WHERE [location] = 'South America'
)
SELECT 
    *, 
    ROUND(([TotalDeathsColombia] / CAST([TotalDeathsSouthAmerica] AS FLOAT)) * 100, 4) AS [PercentageColombianDeaths]
FROM [TotalDeathsColombiaWorld];

-- Data about COVID Vaccination in Colombia
SELECT *
FROM [CovidVaccinations]
WHERE [location] = 'Colombia'
ORDER BY [date];

-- What is the percentage of people vaccinated in Colombia?
WITH PopulationAndPeopleVaccinated AS (
SELECT
    MAX([Dea].[location]) AS [location],
    MAX([Dea].[date]) as [date],
    MAX([Dea].[population]) AS [population],
    MAX([Vac].[people_vaccinated]) AS [people_vaccinated]
FROM [CovidVaccinations] AS [Vac]
JOIN [CovidDeaths] AS [Dea]
    ON [Vac].[location] = [Dea].[location]
    AND [Vac].[date] = [Dea].[date]
WHERE [Vac].[location] = 'Colombia'
)
SELECT 
    *,
    ROUND(([people_vaccinated] / CAST([population] AS FLOAT)) * 100, 4) AS PercentagePeopleVaccinated 
FROM PopulationAndPeopleVaccinated;

-- What is the percentage of people vaccinated over time in Colombia?
SELECT
    [Dea].[location] AS [location],
    [Dea].[date] as [date],
    [Dea].[population] AS [population],
    [Vac].[people_vaccinated] AS [people_vaccinated],
    MAX(([Vac].[people_vaccinated] / CAST([Dea].[population] AS FLOAT)) * 100) OVER (PARTITION BY [Dea].[date]) AS PercentagePeopleVaccinated
FROM [CovidVaccinations] AS [Vac]
JOIN [CovidDeaths] AS [Dea]
    ON [Vac].[location] = [Dea].[location]
    AND [Vac].[date] = [Dea].[date]
WHERE [Vac].[location] = 'Colombia' 
-- AND [Vac].[people_vaccinated] IS NOT NULL
ORDER BY [Vac].[date]
