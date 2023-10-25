SELECT *
FROM PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

--SELECT *
--FROM ProtfolioProject..CovidVaccination$
--order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2

-- Total Cases VS Total Deaths

Select location, date, total_cases, total_deaths,population, 
		(CAST(total_deaths AS float)/CAST(total_cases AS float))* 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
where location like '%United Kingdom%'
and continent is not null
order by 1,2

-- Looking at Total Cases VS Population

Select location, date, total_cases, population,
		(CONVERT(float, total_cases)/CAST(population AS float))* 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
where location like '%India%'
order by 1,2

-- Looking at Countires with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount,
		(CONVERT(float, MAX(total_cases))/CAST(population AS float))* 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


-- Showing Countires with Highest Death Count per Percentage

Select location, MAX(Cast(total_deaths as int)) as TotatDeathCount
From PortfolioProject..CovidDeaths$
--where location like '%India%'
Where continent is null
Group by location
order by TotatDeathCount desc

-- Order by Continent 

Select continent, MAX(Cast(total_deaths as int)) as TotatDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
order by TotatDeathCount desc

-- Showing Contintents with Highest Death Count per population

Select continent, MAX(Cast(total_deaths as int)) as TotatDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
order by TotatDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths,
		ISNULL((SUM(Cast(new_deaths as int))/NULLIF(SUM(New_cases), 0))*100, 0) as DeathPercentage
From PortfolioProject..CovidDeaths$
--where location like '%United Kingdom%'
where continent is not null
-- Group by date
order by 1,2

-- Total Population Vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) 
	as RollingPeopleVaccinated
-- ,	(RollingPeopleVaccinated)/population*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	On dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

with PopvsVac(continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) 
	as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated)/population*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	On dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
Select * , ((RollingPeopleVaccinated)/(population*100))
From PopvsVac

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) 
	as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated)/population*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	On dea.location= vac.location
	and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3

Select * , ((RollingPeopleVaccinated)/(population*100))
From #PercentPopulationVaccinated


-- Create View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) 
	as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated)/population*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	On dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3 