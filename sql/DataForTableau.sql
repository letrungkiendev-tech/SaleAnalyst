/*
    COVID-19 Tableau Project Queries
*/


/* =========================================================
   1. GLOBAL COVID-19 SUMMARY
   ========================================================= */

SELECT
    SUM(new_cases) AS TotalCases,
    SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
    ROUND(
        SUM(CAST(new_deaths AS FLOAT))
        / NULLIF(SUM(new_cases), 0) * 100,
        2
    ) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL;



/* =========================================================
   2. TOTAL DEATH COUNT BY CONTINENT
   ========================================================= */

SELECT
    location,
    SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
    AND location NOT IN (
        'World',
        'European Union',
        'International'
    )
GROUP BY location
ORDER BY TotalDeathCount DESC;



/* =========================================================
   3. HIGHEST INFECTION COUNT BY COUNTRY
   ========================================================= */

SELECT
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    ROUND(
        MAX(
            CAST(total_cases AS FLOAT)
            / NULLIF(population, 0)
        ) * 100,
        2
    ) AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY
    location,
    population
ORDER BY PercentPopulationInfected DESC;



/* =========================================================
   4. PERCENTAGE OF POPULATION INFECTED OVER TIME
   ========================================================= */

SELECT
    location,
    population,
    date,
    MAX(total_cases) AS HighestInfectionCount,
    ROUND(
        MAX(
            CAST(total_cases AS FLOAT)
            / NULLIF(population, 0)
        ) * 100,
        2
    ) AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY
    location,
    population,
    date
ORDER BY
    location,
    date;



/* =========================================================
   5. POPULATION VS VACCINATION
   ========================================================= */

WITH PopVsVac AS (
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,

        SUM(
            TRY_CAST(vac.new_vaccinations AS BIGINT)
        ) OVER (
            PARTITION BY dea.location
            ORDER BY dea.date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RollingPeopleVaccinated

    FROM CovidDeaths AS dea
    JOIN CovidVaccinations AS vac
        ON dea.location = vac.location
        AND dea.date = vac.date

    WHERE dea.continent IS NOT NULL
)

SELECT
    continent,
    location,
    date,
    population,
    new_vaccinations,
    RollingPeopleVaccinated,

    ROUND(
        CAST(RollingPeopleVaccinated AS FLOAT)
        / NULLIF(population, 0) * 100,
        2
    ) AS PercentPeopleVaccinated

FROM PopVsVac
ORDER BY
    location,
    date;