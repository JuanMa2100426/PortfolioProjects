--Query data to make sure that we import the right tables 
--Is going to be necessary cast or convert a couple column with different datatype 

select*
from PortfolioProject.dbo.coviddeaths
where continent is not null 
order by 3,4

select*
from PortfolioProject.dbo.covidvaccinations

-- select*
-- from PortfolioProject.dbo.covidvaccinations
-- order by 3,4

-- select the data we are gonna be using 

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.coviddeaths
where continent is not null 
order by 1,2

--Looking at Total Cases vs Total Death 
--Shows likelihood of dying if you contract covid in your country 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject.dbo.coviddeaths
order by 1 ,2  

Select location, date, total_cases, total_deaths, (CONVERT(decimal, total_deaths) / NULLIF(CONVERT(decimal, total_cases), 0)) * 100 as DeathPercentage
from PortfolioProject.dbo.coviddeaths
order by 1,2 ASC

Select location, date, total_cases, total_deaths, (CONVERT(decimal, total_deaths) / NULLIF(CONVERT(decimal, total_cases), 0)) * 100 as DeathPercentage
from PortfolioProject.dbo.coviddeaths
where location like '%states%' and continent is not null 
order by 1 ,2 ASC 

--looking at the total cases vs population
-- show what percetage of population got covid 

Select location, date, population, total_cases, (total_cases / population) * 100 AS PercentPopulationInfected 
from PortfolioProject.dbo.coviddeaths 
order by 1 ,2

Select location, date, population, total_cases, (CONVERT(float, total_cases) / CONVERT(float, population))* 100 AS PercentPopulationInfected 
from PortfolioProject.dbo.coviddeaths
where location like '%states%'
order by 1 ,2

--Looking at countries with highest infections rate compare to population 

Select location, population, MAX(total_cases) as HighestighestInfectionCount, MAX((total_cases / population))* 100 AS PercentPopulationInfectedM 
from PortfolioProject.dbo.coviddeaths
-- where location like '%states%'
Group by location, population


Select location, population, MAX(total_cases) as HighestighestInfectionCount, MAX(CONVERT(float, total_cases) / CONVERT(float, population))* 100 AS PercentPopulationInfectedM 
from PortfolioProject.dbo.coviddeaths
-- where location like '%states%'
Group by location, population
order by 4 DESC

--Showing the countries with highest death count per population 

Select location, MAX(total_deaths) as TotalDeathCount 
from PortfolioProject.dbo.coviddeaths
-- where location like '%states%'
where continent is not null 
Group by location 
order by TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT 

Select continent, MAX(total_deaths) as TotalDeathCount 
from PortfolioProject.dbo.coviddeaths
-- where location like '%states%'
where continent is not null 
Group by continent 
order by TotalDeathCount DESC

--this will show you a total numbers 

Select location, MAX(total_deaths) as TotalDeathCount 
from PortfolioProject.dbo.coviddeaths
-- where location like '%states%'
where continent is null 
Group by location
order by TotalDeathCount DESC

--Showing the continent wiht the highest death count per population 

Select continent, MAX(total_deaths) as TotalDeathCount 
from PortfolioProject.dbo.coviddeaths
-- where location like '%states%'
where continent is not null 
Group by continent
order by TotalDeathCount DESC


-- GLOBAL NUMBERS

Select date, sum (new_cases), SUM(new_deaths) 
from PortfolioProject.dbo.coviddeaths
-- where location like '%states%'
where continent is not null 
group by date
order by 1 ,2  


Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
(SUM(new_deaths) / NULLIF(CONVERT(float, SUM(new_cases)), 0)) * 100 as DeathPercentage
FROM PortfolioProject.dbo.coviddeaths
--where location like '%states%' and continent is not null 
WHERE continent is not null 
group by date
order by 1,2

--total number accross the world 

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
(SUM(new_deaths) / NULLIF(CONVERT(float, SUM(new_cases)), 0)) * 100 as DeathPercentage
FROM PortfolioProject.dbo.coviddeaths
--where location like '%states%' and continent is not null 
WHERE continent is not null 
--group by date
order by 1,2


--Looking at total population vs vaccinations 

SELECT*
from PortfolioProject..covidVaccinations

select*
FROM PortfolioProject.dbo.coviddeaths dea
JOIN PortfolioProject.dbo.covidvaccinations vac
ON dea.location = vac.location
and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject.dbo.coviddeaths dea
JOIN PortfolioProject.dbo.covidvaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
FROM PortfolioProject.dbo.coviddeaths dea
JOIN PortfolioProject.dbo.covidvaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


--Use CTE

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

--With TempTable

Drop table if EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent NVARCHAR(50),
location NVARCHAR(50),
date DATE,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric 
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
FROM PortfolioProject.dbo.coviddeaths dea
JOIN PortfolioProject.dbo.covidvaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated / population) * 100
from #PercentPopulationVaccinated


--Creating view to store data for later visualization 

create VIEW PercentPopulationVaccinated as 
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

select *
from PercentPopulationVaccinated