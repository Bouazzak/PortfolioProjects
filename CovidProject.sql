SELECT *
FROM portfolioproject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--select *
--from portfolioproject..CovidVaccinations
--ORDER BY 3,4

-- Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 AS DeathPercentage
FROM portfolioproject..CovidDeaths
WHERE LOCATION like '%kingdom%'
ORDER BY 1,2


-- Looking at total cases vs population
-- Shows what percentage of population got covid


SELECT Location, date, population, total_cases, (Total_cases/population)*100 AS PercentPopulationInfected
FROM portfolioproject..CovidDeaths
WHERE LOCATION like '%kingdom%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population 

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((Total_cases/population))*100 AS PercentPopulationInfected
FROM portfolioproject..CovidDeaths
--WHERE LOCATION like '%kingdom%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC


--Showing countries with highest death count per population

SELECT Location, MAX(cast (total_deaths AS INT)) AS TotalDeathCount
FROM portfolioproject..CovidDeaths
--WHERE LOCATION like '%kingdom%'
WHERE continent is not null
GROUP BY Location, population
ORDER BY TotalDeathCount DESC


-- Showing continents with the highest death count 

SELECT continent, MAX(cast (total_deaths AS INT)) AS TotalDeathCount
FROM portfolioproject..CovidDeaths
--WHERE LOCATION like '%kingdom%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM portfolioproject..CovidDeaths
--WHERE LOCATION like '%kingdom%'
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2


-- Looking at total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM popvsvac 


-- Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated 


-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


CREATE VIEW DeathCountContinents AS
SELECT continent, MAX(cast (total_deaths AS INT)) AS TotalDeathCount
FROM portfolioproject..CovidDeaths
--WHERE LOCATION like '%kingdom%'
WHERE continent is not null
GROUP BY continent
--ORDER BY TotalDeathCount DESC

CREATE VIEW HighestDeathCountPerPopulation AS
SELECT Location, MAX(cast (total_deaths AS INT)) AS TotalDeathCount
FROM portfolioproject..CovidDeaths
--WHERE LOCATION like '%kingdom%'
WHERE continent is not null
GROUP BY Location, population
--ORDER BY TotalDeathCount DESC

CREATE VIEW HighestInfectionsVSPopulation AS
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((Total_cases/population))*100 AS PercentPopulationInfected
FROM portfolioproject..CovidDeaths
--WHERE LOCATION like '%kingdom%'
GROUP BY Location, population
--ORDER BY PercentPopulationInfected DESC







