
SELECT *
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Total Cases vs Total Deaths

SELECT coviddeaths
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS death_percentage
FROM coviddeaths 
WHERE location = 'Canada'
  AND continent IS NOT NULL
ORDER BY date;

-- Total Cases vs Population

SELECT
    location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 AS percent_population_infected
FROM coviddeaths 
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Countries with Highest Infection Rate

SELECT
    location,
    population,
    MAX(total_cases) AS highest_infection_count,
    MAX((total_cases / population)) * 100 AS percent_population_infected
FROM coviddeaths 
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_population_infected DESC;

-- Countries with Highest Death Count
SELECT
    location,
    MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM coviddeaths 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- Death Count by Continent

SELECT
    continent,
    MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM coviddeaths 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

-- Global Numbers (Daily)

SELECT
    date,
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    (SUM(new_deaths) / SUM(new_cases)) * 100 AS death_percentage
FROM coviddeaths 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- Total Global Numbers

SELECT
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    (SUM(new_deaths) / SUM(new_cases)) * 100 AS death_percentage
FROM coviddeaths 
WHERE continent IS NOT NULL;

-- vaccination table

SELECT *
FROM covidvaccinations
ORDER BY location, date;


-- Join Deaths & Vaccinations Tables

SELECT
    d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations
FROM coviddeaths d
JOIN covidvaccinations v
    ON d.location = v.location
    AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.location, d.date;

-- Rolling People Vaccinated (Window Function)

SELECT
    d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations,
    SUM(v.new_vaccinations) 
        OVER (PARTITION BY d.location ORDER BY d.date) 
        AS rolling_people_vaccinated
FROM coviddeaths d
JOIN covidvaccinations v
    ON d.location = v.location
    AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.location, d.date;

-- Percentage of Population Vaccinated

WITH PopVsVac AS (
    SELECT
        d.continent,
        d.location,
        d.date,
        d.population,
        v.new_vaccinations,
        SUM(v.new_vaccinations)
            OVER (PARTITION BY d.location ORDER BY d.date)
            AS rolling_people_vaccinated
    FROM coviddeaths  d
    JOIN covidvaccinations v
        ON d.location = v.location
        AND d.date = v.date
    WHERE d.continent IS NOT NULL
)
SELECT *,
       (rolling_people_vaccinated / population) * 100 AS percent_vaccinated
FROM PopVsVac;
