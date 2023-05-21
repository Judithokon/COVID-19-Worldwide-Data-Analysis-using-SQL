/* 
COVID-19 Worldwide Data Exloration

Using - Joins, CTE, Temp Tables, Windows functions, Aggregate functions, creating views, Converting data types
*/


-- 1) What is the Mortality rate - total deaths divided by total cases
SELECT continent, location, date, total_cases, total_deaths, (total_deaths * 1.0 /total_cases) * 100 as mortality_rate
FROM coviddeaths
WHERE Continent is not NULL
order by 1,2

-- 2) What percentage of the population got covid
SELECT continent, location, date, total_cases, population, (total_cases * 1.0 /population) * 100 as PercentPopulationInfected
FROM coviddeaths
WHERE Continent is not NULL
order by 1,2

-- 3) What country has the highest infection rate compared to population
SELECT continent, location, population, Max(total_cases) as highestInfectionCount, MAX((total_cases * 1.0/population)*100) as PercentPopulationInfected
FROM coviddeaths
WHERE Continent is not NULL
Group by continent, location, population
order by 4 desc

-- 4) What country has the highest death rate per population
SELECT continent, location, population, MAX(total_deaths) as hightestDeathCount, MAX((total_deaths * 1.0/population)*100) as PercentPopulationDied
FROM coviddeaths
WHERE Continent is not NULL
Group by continent, location, population
order by 4 desc

-- 5) What country has the highest death count
SELECT continent, location, MAX(total_deaths) as hightestDeathCount
FROM coviddeaths
WHERE CONTINENT IS NOT NULL 
Group by continent, location
order by hightestDeathCount desc

-- 6) What continent has the highest death count
SELECT continent, MAX(total_deaths) as hightestDeathCount
FROM coviddeaths
WHERE CONTINENT IS NOT NULL 
Group by continent
order by hightestDeathCount desc

-- 7) What are the global cases for each day
SELECT date, SUM(new_cases) as total_newcases, sum(new_deaths) as total_newdeaths, 
    case
        WHEN SUM(new_cases) <> 0 THEN SUM(new_deaths)*1.0/SUM(new_cases)*100 
        ELSE NULL
    END AS death_rate
FROM coviddeaths
WHERE Continent is not NULL
GROUP BY DATE
Order by date 


-- 8) What is the rolling count of people vaccinated, meaning after each day what is the total number of vaccinated people
-- using CTE
WITH PopVsVac (continent, location, date, population,  new_vaccinations, RollingCountofPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations AS BIGINT))
OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingCountofPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac 
    ON dea.location = vac.location AND dea.date = vac.date
where dea.continent IS NOT NULL)
SELECT *, (RollingCountofPeopleVaccinated*1.0/population) * 100 AS PercentageofVaccinatedPeople
FROM PopVsVac

-- 9) What is the rolling count of people vaccinated, meaning after each day what is the total number of vaccinated people
-- using TempTable
DROP TABLE IF EXISTS #PercentagePopulationVaccinated

Create Table #PercentagePopulationVaccinated
(continent NVARCHAR(255),
location NVARCHAR(255),
date DATE,
population NUMERIC,
new_vaccinations NUMERIC,
RollingCountofPeopleVaccinated NUMERIC
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations AS BIGINT))
OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingCountofPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac 
    ON dea.location = vac.location AND dea.date = vac.date
where dea.continent IS NOT NULL

SELECT *, (RollingCountofPeopleVaccinated*1.0/population) * 100 AS PercentageofVaccinatedPeople
FROM #PercentagePopulationVaccinated
ORDER BY 2,3

-- 10) Create views to store our results and later use for visualizations 
Create View mortalityrate AS 
SELECT continent, location, date, total_cases, total_deaths, (total_deaths * 1.0 /total_cases) * 100 as mortality_rate
FROM coviddeaths
WHERE Continent is not NULL

Create View PercentagePopulationInfected AS 
SELECT continent, location, date, total_cases, population, (total_cases * 1.0 /population) * 100 as PercentPopulationInfected
FROM coviddeaths
WHERE Continent is not NULL

Create View HighestInfectedCountry AS 
SELECT continent, location, population, Max(total_cases) as highestInfectionCount, MAX((total_cases * 1.0/population)*100) as PercentPopulationInfected
FROM coviddeaths
WHERE Continent is not NULL
Group by continent, location, population

Create View HighestDeathperPopulation AS 
SELECT continent, location, population, MAX(total_deaths) as hightestDeathCount, MAX((total_deaths * 1.0/population)*100) as PercentPopulationDied
FROM coviddeaths
WHERE Continent is not NULL
Group by continent, location, population

Create View hightestDeathCountLocation AS 
SELECT continent, location, MAX(total_deaths) as hightestDeathCount
FROM coviddeaths
WHERE CONTINENT IS NOT NULL 
Group by continent, location

Create View HighestDeathCountContinent AS 
SELECT continent, MAX(total_deaths) as hightestDeathCount
FROM coviddeaths
WHERE CONTINENT IS NOT NULL 
Group by continent

Create View GlobalCasesPerDay AS 
SELECT date, SUM(new_cases) as total_newcases, sum(new_deaths) as total_newdeaths, 
    case
        WHEN SUM(new_cases) <> 0 THEN SUM(new_deaths)*1.0/SUM(new_cases)*100 
        ELSE NULL
    END AS death_rate
FROM coviddeaths
WHERE Continent is not NULL
GROUP BY DATE

Create View RollingCountofPeopleVaccinated AS 
WITH PopVsVac (continent, location, date, population,  new_vaccinations, RollingCountofPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations AS BIGINT))
OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingCountofPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac 
    ON dea.location = vac.location AND dea.date = vac.date
where dea.continent IS NOT NULL)
SELECT *, (RollingCountofPeopleVaccinated*1.0/population) * 100 AS PercentageofVaccinatedPeople
FROM PopVsVac

