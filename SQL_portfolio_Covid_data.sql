Select * 
From sql_project..Covid_Deaths 
order by 3,4


--Select * 
-- From sql_project..Covid_Vaccinations 
-- order by 3,4

--Selecting the data to use for the project

--select * from sql_project..Covid_Deaths

Select Location, date, total_cases, new_cases, total_deaths, population
From sql_project..Covid_Deaths
order by 1,2



-- Looking at total cases vs total deaths (percentage of deaths) This displays the percentage of deaths with respect to the total population
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From sql_project..Covid_Deaths
order by 1,2

--Looking at the percentage of death in the UK, as of 2023-02-26  0.9% of population died of covid. 
--Shows the likelihood of dying if infeceted with covid in the Uk
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From sql_project..Covid_Deaths
where location = 'United Kingdom'
order by 1,2


--Looking at total cases vs population world wide
--Shows the percentage of population infected with covid. 
Select Location, date, population,total_cases , (total_cases/population)*100 as Infected_Population
From sql_project..Covid_Deaths
where location = 'United Kingdom'
order by 1,2

--Looking at the countries with the highest infected rate 

Select Location, population,MAX(total_cases) as HighestInfectedCount , MAX((total_cases/population))*100 as Percent_Infected_Population
From sql_project..Covid_Deaths
where continent is not null
--where location = 'United Kingdom'
group by Location,population
order by Percent_Infected_Population desc


--Looking at countries with highest death count
Select Location,MAX(cast(total_deaths as int)) as Total_Death_Count
From sql_project..Covid_Deaths
where continent is not null
--where location = 'United Kingdom'
group by Location
order by Total_Death_Count desc


--select * from sql_project..Covid_Deaths
--where continent is not null	
--order by 3,4


--Breaking things down by continent.Continents with highest death count
Select continent,MAX(cast(total_deaths as int)) as Total_Death_Count_per_Continent
From sql_project..Covid_Deaths
where continent is not null
--where location = 'United Kingdom'
group by continent
order by Total_Death_Count_per_Continent desc

--Calculating global numbers

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From sql_project..Covid_Deaths
where continent is not null
-- group by date
order by 1,2


--Looking into the covid vaccination table
select * from sql_project..Covid_Deaths

--Joining the two tables
Select *
from sql_project..Covid_Deaths dea
join sql_project..Covid_Vaccinations vac
on dea.location = vac.location
and dea.date = vac.date


--Looking at total population vs vaccination i.e percentage of world popualation that is vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_count_people_vaccinated
from sql_project..Covid_Deaths dea
join sql_project..Covid_Vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Using a CTE 
with PopulationVsVaccination (continent, loation, date, population,new_vaccinations, rolling_count_people_vaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_count_people_vaccinated
from sql_project..Covid_Deaths dea
join sql_project..Covid_Vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select * , (rolling_count_people_vaccinated/population)*100 from PopulationVsVaccination


--Temp table
DROP table if exists #PercentPopVaccinated
create table #PercentPopVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_count_people_vaccinated numeric
)

Insert into #PercentPopVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_count_people_vaccinated
from sql_project..Covid_Deaths dea
join sql_project..Covid_Vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select * , (rolling_count_people_vaccinated/population)*100 from #PercentPopVaccinated



--Creating a view to store data for later visualizations
create view PercentPopVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_count_people_vaccinated
from sql_project..Covid_Deaths dea
join sql_project..Covid_Vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


select * from PercentPopVaccinated


--Need to add more analysis and add comments and add to github.
