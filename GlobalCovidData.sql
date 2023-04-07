SELECT *
FROM personal.CovidDeaths
LIMIT 12;

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract Covid in your country
SELECT location, date, total_cases,total_deaths, (total_deaths / total_cases)*100 AS death_percentage
FROM personal.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;

-- Looking at total cases vs population
-- This shows what percentage of the population got CovidDeaths
SELECT location, date, total_cases, population, (total_cases / population )*100 AS population_percentage
FROM personal.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;

# Looking at country with highest infection rate compared to population.
SELECT location, population, MAX(total_cases) AS Highest_infection_count, MAX((total_cases / population))*100 AS population_infected_percentage
FROM personal.CovidDeaths
GROUP BY location, population
ORDER BY 4 desc;

# Looking at countries with highest death count per population.
SELECT location, MAX(total_deaths) AS Highest_death_count, MAX((total_deaths / population))*100 AS population_death_percentage
FROM personal.CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 2 desc;

# BREAKING THINGS DOWN BY CONTINENT
-- Showing the continents with the highest death count
SELECT location, MAX(total_deaths) AS Total_death_count, MAX((total_deaths / population))*100 AS population_death_percentage
FROM personal.CovidDeaths
WHERE continent is null AND (location not like '%income%' AND location not like '%world%')
GROUP BY location, population
ORDER BY 2 desc;
-- I am checking if continent is null as the
-- dataset already contained information for the whole continents
-- (but here, the continent column was set to null and
-- the location was set to the name of the actual continent)

-- GLOBAL NUMBERS
-- Total Global Cases
SELECT SUM(new_cases) AS num_cases, SUM(new_deaths) AS num_deaths, ((SUM(new_deaths)/SUM(new_cases))*100) AS deaths_percentage #,total_deaths, (total_deaths / total_cases)*100 AS death_percentage
FROM personal.CovidDeaths
WHERE continent is not null
#GROUP BY date
ORDER BY 1,2;

-- Grouping by date
SELECT date, SUM(new_cases) AS num_cases, SUM(new_deaths) AS num_deaths, ((SUM(new_deaths)/SUM(new_cases))*100) AS deaths_percentage #,total_deaths, (total_deaths / total_cases)*100 AS death_percentage
FROM personal.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 2;

-- Using CTE

WITH PopVsVac (Continent, Location, Date, Population, Vaccinations, cumsum)
    AS (
        SELECT dea.continent,
               dea.location,
               dea.date,
               dea.population,
               vac.new_vaccinations,
               SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cumsum

        FROM personal.CovidDeaths dea
                 JOIN personal.Vaccines vac
                      ON dea.location = vac.location and dea.date = vac.date
        WHERE dea.continent is not null
       -- ORDER BY 2, 3;
)

SELECT *, (cumsum / population) * 100
FROM
PopVsVac;

-- Creating a view for storing data for later visualizations
CREATE VIEW personal.PercentPopulationVaccinated AS
    SELECT dea.continent,
               dea.location,
               dea.date,
               dea.population,
               vac.new_vaccinations,
               SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cumsum

        FROM personal.CovidDeaths dea
                 JOIN personal.Vaccines vac
                      ON dea.location = vac.location and dea.date = vac.date
        WHERE dea.continent is not null
       -- ORDER BY 2, 3;
















