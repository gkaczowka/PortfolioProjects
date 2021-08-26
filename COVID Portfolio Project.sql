-- View the data

SELECT *
FROM PortfolioProject..[Covid-deaths]

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..[Covid-deaths]
ORDER BY 1,2

-- Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) as DeathPercentage
FROM PortfolioProject..[Covid-deaths]
ORDER BY 1,2

-- Total Cases vs Total Deaths in Poland

SELECT Location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) as DeathPercentage
FROM PortfolioProject..[Covid-deaths]
WHERE Location = 'Poland'
ORDER BY 1,2

-- Percentage of population that got Covid

SELECT Location, date, total_cases, population, ROUND((total_cases/population)*100, 2) as PercentPopulationInfected
FROM PortfolioProject..[Covid-deaths]
--WHERE Location = 'Poland'
WHERE continent is not null
ORDER BY 1,2

-- Countires with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(ROUND((total_cases/population)*100, 2)) as PercentPopulationInfected
FROM PortfolioProject..[Covid-deaths]
--WHERE Location = 'Poland
GROUP BY Location, population
ORDER BY 4 DESC

-- Countries with Highest Death Count per population

SELECT Location, max(total_deaths) as HighestDeathCount
FROM PortfolioProject..[Covid-deaths]
WHERE continent != location
GROUP BY Location, population
ORDER BY 2 DESC

-- Continents with Highest Death Count per population

SELECT Location, SUM(total_deaths) as HighestDeathCount
FROM PortfolioProject..[Covid-deaths]
WHERE continent is null AND location != 'World'
GROUP BY Location
ORDER BY 2 DESC


-- Global numbers

SELECT date, SUM(cast(new_cases as float)) as Total_cases, SUM(cast(new_deaths as float)) as Total_deaths, ROUND(SUM(cast(new_deaths as float))/SUM(cast (new_cases as float))*100, 2) as DeathPercentage
FROM PortfolioProject..[Covid-deaths]
--WHERE Location = 'Poland'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Total cases, deaths and death percentage for world

SELECT SUM(cast(new_cases as float)) as Total_cases, SUM(cast(new_deaths as float)) as Total_deaths, ROUND(SUM(cast(new_deaths as float))/SUM(cast (new_cases as float))*100, 2) as DeathPercentage
FROM PortfolioProject..[Covid-deaths]
--WHERE Location = 'Poland'
WHERE continent is not null
ORDER BY 1,2


-- Total Population vs Vaccinations


SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations, sum(cast(b.new_vaccinations as float)) OVER (PARTITION BY a.location ORDER BY a.Location, a.date) as RollingPeopleVaccinated
FROM PortfolioProject..[Covid-deaths] a
JOIN PortfolioProject..[Covid-vaccinations] b
ON a.location = b.location
	AND a.date = b.date
WHERE a.continent is not null
ORDER BY 2,3

-- CTE

WITH PopulationVaccination (Continent, Location, Date, Population,New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations, sum(cast(b.new_vaccinations as float)) OVER (PARTITION BY a.location ORDER BY a.Location, a.date) as RollingPeopleVaccinated
--,MAX(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..[Covid-deaths] a
JOIN PortfolioProject..[Covid-vaccinations] b
ON a.location = b.location
	AND a.date = b.date
WHERE a.continent is not null
--ORDER BY 2,3
)
SELECT *, ROUND((RollingPeopleVaccinated/population)*100, 2) as PercentPopulationVaccinated
FROM PopulationVaccination

-- Date of first vaccination in each country

SELECT a.location, min(a.date)
FROM PortfolioProject..[Covid-deaths] a
JOIN PortfolioProject..[Covid-vaccinations] b
ON a.location = b.location
	AND a.date = b.date
WHERE a.continent is not null AND b.new_vaccinations is not null
GROUP BY a.location
ORDER BY 2

-- Creating View

CREATE VIEW PercentPopulationVaccinated as
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations, sum(cast(b.new_vaccinations as float)) OVER (PARTITION BY a.location ORDER BY a.Location, a.date) as RollingPeopleVaccinated
FROM PortfolioProject..[Covid-deaths] a
JOIN PortfolioProject..[Covid-vaccinations] b
ON a.location = b.location
	AND a.date = b.date
WHERE a.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
