-- Total cases, total deaths, and total world death percentage 
SELECT
  SUM(new_cases) AS total_cases,
  SUM(CAST(new_deaths AS int)) AS total_deaths,
  (SUM(CAST(new_deaths AS int)) / SUM(new_cases)) * 100 AS death_percentage
FROM covid_data_exploration..covid_deaths
WHERE continent IS NOT NULL


-- Total death counts in each continent
SELECT
  continent,
  SUM(CAST(new_deaths AS int)) AS total_deaths
FROM covid_data_exploration..covid_deaths
GROUP BY continent
HAVING continent IS NOT NULL
ORDER BY total_deaths DESC


-- Countries with the highest infection percentage of covid based on population
-- replace the null values in excel
SELECT
  location,
  population,
  MAX(total_cases) AS highest_infection_count,
  (MAX(total_cases) / population) * 100 AS percentage_population_infected
FROM covid_data_exploration..covid_deaths
GROUP BY location,
         population
HAVING location NOT IN ('World', 'Asia', 'Europe', 'North America', 'European Union', 'South America', 'Oceania')
ORDER BY percentage_population_infected DESC


-- Countries with the highest infection of covid based on population by date
-- replace the null values in excel
SELECT
  location,
  population,
  date,
  MAX(total_cases) AS highest_infection_count,
  (MAX(total_cases) / population) * 100 AS percentage_population_infected
FROM covid_data_exploration..covid_deaths
GROUP BY location,
         population,
		 date
HAVING location NOT IN ('World', 'Asia', 'Europe', 'North America', 'European Union', 'South America', 'Oceania')
ORDER BY percentage_population_infected DESC
