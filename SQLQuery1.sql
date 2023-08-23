select *
from PortofolioProject..CovidDeaths$
Where continent is not null
order by 3,4

--select *
--from PortofolioProject..CovidVaccinations$
--order by 3,4

--Select data that we are going to be using 

Select Location,Date, total_cases, new_cases, total_deaths, population
from PortofolioProject..CovidDeaths$
Where continent is not null
order by 1,2




--Looking at Total Cases vs total Deaths
--Shows likelihood of dying if you contract covid in your country

--select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
-- from PortofolioProject..CovidDeaths
-- Where location like '%state%'
-- Order by 1,2
--


-- looking at total cases vs population
-- shows percentage of population
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
 from PortofolioProject..CovidDeaths$

 --ere location like '%state%'
 Where continent is not null
 Order by 1,2

 --Looking at countries with highest infection rate compared to population
 select location, population,Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
 from PortofolioProject..CovidDeaths$
 --Where location like '%state%'
 Where continent is not null
 Group by location,population
 Order by PercentPopulationInfected desc

 
 -- Showing countries with highest Death Count per population
  select location, Max(cast(Total_deaths as int)) as TotalDeathCount
 from PortofolioProject..CovidDeaths$
 --Where location like '%state%'
 Where continent is not null
 Group by location
 Order by TotalDeathCount desc

 -- Break things down by continent

  

 --Showing the continent with the highest death count per population

  select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
 from PortofolioProject..CovidDeaths$
 --Where location like '%state%'
 Where continent is not null
 Group by continent
 Order by TotalDeathCount desc

 -- Global numbers

select date, total_cases, total_deaths, (Cast(Total_deaths as int)/ cast (total_cases as int))*100 as DeathPercentage
 from PortofolioProject..CovidDeaths$
--here location like '%state%'
Where continent is not null
Group by date
Order by 1,2

Select Sum(new_cases) as Total_cases, Sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(New_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths$
--Where location like '%state%'
where continent is not null
--Group by date
order by 1,2


--Looking at total population vs vaccination

Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortofolioProject..CovidDeaths$ dea
join PortofolioProject..CovidVaccinations$ vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3
-- Using CTE to perform Calculation on Partition By in previous query

--Temp table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into  #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths$ dea
Join PortofolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for visualisation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths$ dea
Join PortofolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated