SELECT *
FROM PortofolioProject.dbo.CovidDeaths$
where continent is not null
ORDER BY 3,4

SELECT location, date, population, total_cases, new_cases, total_deaths
FROM PortofolioProject.dbo.CovidDeaths$
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths (percentage people who are dying because of Covid19)
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortofolioProject.dbo.CovidDeaths$
Where location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population (percentage of population who got Covid19)
SELECT location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
FROM PortofolioProject.dbo.CovidDeaths$
-- Where location like '%states%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortofolioProject.dbo.CovidDeaths$
-- Where location like '%states%'
GROUP BY population, location
ORDER BY PercentagePopulationInfected desc


-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortofolioProject.dbo.CovidDeaths$
-- Where location like '%states%'
where continent is not null
GROUP BY continent
ORDER BY HighestDeathCount desc

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortofolioProject.dbo.CovidDeaths$
-- Where location like '%states%'
WHERE continent is not null
-- GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject.dbo.CovidDeaths$ dea
JOIN PortofolioProject.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- GROUP BY date
ORDER BY 2,3

-- USE CTE

With PopvsVac  (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject.dbo.CovidDeaths$ dea
JOIN PortofolioProject.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- GROUP BY date
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject.dbo.CovidDeaths$ dea
JOIN PortofolioProject.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
-- WHERE dea.continent is not null
-- GROUP BY date
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Create View to store data for later visualization

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject.dbo.CovidDeaths$ dea
JOIN PortofolioProject.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- GROUP BY date
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated