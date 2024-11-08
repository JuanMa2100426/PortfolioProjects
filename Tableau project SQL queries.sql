/*

Queries used for Tableau Project

*/

-- 1. 

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
(SUM(new_deaths) / NULLIF(CONVERT(float, SUM(new_cases)), 0)) * 100 as DeathPercentage
FROM PortfolioProject.dbo.coviddeaths
--where location like '%states%' and continent is not null 
WHERE continent is not null 
--group by date
order by 1,2

-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.covidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 
 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc


-- 3.


Select location, population, MAX(total_cases) as HighestighestInfectionCount,
 MAX(CONVERT(float, total_cases) / CONVERT(float, population))* 100 AS PercentPopulationInfectedM
From PortfolioProject.dbo.covidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfectedM desc

-- 4.

Select location, population, date, MAX(total_cases) as HighestighestInfectionCount,
 MAX(CONVERT(float, total_cases) / CONVERT(float, population))* 100 AS PercentPopulationInfectedM
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfectedM desc



-- Queries I originally had, but excluded some because it created too long of video
-- Here only in case you want to check them out

--1.

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3

-- 2.

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/ NULLIF(CONVERT(float, SUM(new_cases)), 0)*100 as DeathPercentage
From PortfolioProject.dbo.covidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/ NULLIF(CONVERT(float, SUM(new_cases)), 0)*100 as DeathPercentage
From PortfolioProject.dbo.covidDeaths
----Where location like '%states%'
where location = 'World'
----Group By date
order by 1,2

-- 3.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.covidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 
 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc

-- 4.

Select location, population, MAX(total_cases) as HighestighestInfectionCount,
 MAX(CONVERT(float, total_cases) / CONVERT(float, population))* 100 AS PercentPopulationInfectedM
From PortfolioProject.dbo.covidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfectedM desc

-- 5.

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where continent is not null 
--order by 1,2

-- took the above query and added population

Select Location, date, population, total_cases, total_deaths
From PortfolioProject.dbo.covidDeaths
--Where location like '%states%'
where continent is not null 
order by 1,2

-- 6. 


WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
FROM PortfolioProject.dbo.coviddeaths dea
JOIN PortfolioProject.dbo.covidvaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3    
)
Select *, (RollingPeopleVaccinated / NULLIF(CONVERT(float, population), 0)) * 100
from PopVsVac

-- 7. 

Select location, population, date, MAX(total_cases) as HighestighestInfectionCount,
 MAX(CONVERT(float, total_cases) / CONVERT(float, population))* 100 AS PercentPopulationInfectedM
From PortfolioProject.dbo.covidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfectedM desc
