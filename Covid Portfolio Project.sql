--SELECT * 
--FROM PortfolioProject..CovidVaccinations 

SELECT * 
FROM PortfolioProject..CovidDeaths 


select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--Total Cases vs Total Deaths

select Location,date,total_cases,total_deaths, (total_deaths/total_cases)* 100 as DeathRate
from PortfolioProject..CovidDeaths
where location like '%india%' 
order by 1,2

--Total Cases vs Population
select Location,date,population,total_cases,(total_cases/population)* 100 as ActiveRate
from PortfolioProject..CovidDeaths
--where location like '%india%' 
order by 1,2

--Highest Infection Rate vs population

select Location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))* 100 as PerPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%india%' 
group by Location,population
order by PerPopulationInfected desc

select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%india%' 
where continent is not null
group by Location
order by TotalDeathCount desc

--HighestDeathCount per Population

select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%india%' 
where continent is not null
group by continent
order by TotalDeathCount desc

-------

select Location,date,total_cases,total_deaths, (total_deaths/total_cases)* 100 as DeathRate
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
order by 1,2

SELECT * 
FROM PortfolioProject..CovidDeaths 

select sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercenatge
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

select *
from PortfolioProject..CovidVaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.Location order by dea.Location,dea.date) as total_people_vaccinated

from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with PopvsVac (Continent,Location,date,population,New_Vaccinations,total_people_vaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.Location order by dea.Location,dea.date) as total_people_vaccinated

from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (total_people_vaccinated/population)*100
from PopvsVac

--With Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
total_people_vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as total_people_vaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (total_people_vaccinated/Population)*100
From #PercentPopulationVaccinated

-- VIEW to store data

Create View PercentPopulationVaccination as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


select * 
from PercentPopulationVaccination



