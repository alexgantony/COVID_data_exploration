USE covid_data_exploration;

SELECT
  *
FROM covid_data_exploration.dbo.covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;


SELECT
  *
FROM covid_data_exploration.dbo.covid_vaccinations
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- Table to use
SELECT
  location,
  date,
  total_cases,
  new_cases,
  total_deaths,
  population
FROM covid_data_exploration..covid_deaths
WHERE continent IS NOT NULL
ORDER BY location, date;


-- Total Cases vs Total Deaths (India)
-- Death likelihood if you contract COVID in India
SELECT
  location,
  date,
  total_cases,
  total_deaths,
  (total_deaths / total_cases) * 100 AS death_percentage
FROM covid_data_exploration..covid_deaths
WHERE location = 'India'
AND continent IS NOT NULL
ORDER BY location, date;


-- Total Cases vs Population
-- Percentage of population got infected in India
SELECT
  location,
  date,
  total_cases,
  population,
  (total_cases / population) * 100 AS '% got infected'
FROM covid_data_exploration..covid_deaths
WHERE location = 'India'
AND continent IS NOT NULL
ORDER BY location, date;


-- Countries with highest infection rate compared to population
SELECT 
  location, 
  population, 
  max(total_cases) AS highest_infection_count, 
  max(
    (total_cases / population) * 100
  ) AS percent_population_infected 
FROM 
  covid_data_exploration..covid_deaths 
group by 
  location, 
  population 
ORDER BY 
  percent_population_infected desc;


-- Countries with highest death count
SELECT
  location,
  population,
  MAX(
  CAST(total_deaths AS int)
  ) AS total_death_count
FROM covid_data_exploration..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location,
         population
ORDER BY total_death_count DESC;


-- Continents with highest death count
SELECT
  continent,
  MAX(
  CAST(total_deaths AS int)
  ) AS total_death_count
FROM covid_data_exploration..covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;


-- Global Numbers
-- Total cases, total death, and death percentage each day
SELECT
  date,
  SUM(new_cases) AS total_cases,
  SUM(CAST(new_deaths AS int)) AS total_deaths,
  (SUM(CAST(new_deaths AS int)) / SUM(new_cases)) * 100 AS death_percentage
FROM covid_data_exploration..covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- Global Total cases, total death, and death percentage
SELECT
  SUM(new_cases) AS total_cases,
  SUM(CAST(new_deaths AS int)) AS total_deaths,
  (SUM(CAST(new_deaths AS int)) / SUM(new_cases)) * 100 AS death_percentage
FROM covid_data_exploration..covid_deaths
WHERE continent IS NOT NULL;


-- Total population vs. Vaccination with CTE
WITH pop_vs_vac (
  continent, location, date, population, 
  new_vaccinations, cumulative_total_vaccinated
) AS (
  SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(
      CONVERT(int, vac.new_vaccinations)
    ) OVER (
      PARTITION BY dea.location 
      ORDER BY 
        dea.location, 
        dea.date
    ) AS cumulative_total_vaccinated 
  FROM 
    covid_data_exploration..covid_deaths dea 
    JOIN covid_data_exploration..covid_vaccinations vac ON dea.location = vac.location 
    AND dea.date = vac.date 
  WHERE 
    dea.continent IS NOT NULL
    ) 
SELECT 
  *,
  (cumulative_total_vaccinated /population) * 100 as percentage_population_vaccinated
FROM 
  pop_vs_vac;


-- Create View to store data for visualization
CREATE VIEW percent_population_vaccinated
AS
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(
  CONVERT(int, vac.new_vaccinations)
  ) OVER (
  PARTITION BY dea.location
  ORDER BY
  dea.location,
  dea.date
  ) AS cumulative_total_vaccinated
FROM covid_data_exploration..covid_deaths dea
JOIN covid_data_exploration..covid_vaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT
  *
FROM percent_population_vaccinated;