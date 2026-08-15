select *
from CovidDeaths
where continent is not null
order by 3,4

-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
-- show likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%vietnam%'
order by 1,2

-- looking at total cases vs population
-- shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulation
from CovidDeaths
where location like '%state%'
order by 1,2

-- looking at countries with highest infection rate compard to populationselect location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
select location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as PercentPopulation
from CovidDeaths
group by location, population
order by PercentPopulation desc

-- showing countries with highest death count per population

select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- showing continents with the highest death count per population

select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

-- looking at total population vs vaccinations
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/d.population)*100
from CovidVaccinations as v
join CovidDeaths as d
on d.location = v.location and d.date = v.date
where d.continent is not null
order by 2,3

-- USE CTE

with popvsvac (Continent, Location, Date, Population, New_Vaccinantions, RollingPeopleVaccinated)
as (
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/d.population)*100
from CovidVaccinations as v
join CovidDeaths as d
on d.location = v.location and d.date = v.date
where d.continent is not null
) 
select *, (RollingPeopleVaccinated/Population) * 100
from popvsvac

-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/d.population)*100
from CovidVaccinations as v
join CovidDeaths as d
on d.location = v.location and d.date = v.date
where d.continent is not null

select *, (RollingPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated

-- creating view to store data for later visulizations

create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/d.population)*100
from CovidVaccinations as v
join CovidDeaths as d
on d.location = v.location and d.date = v.date
where d.continent is not null

select *
from PercentPopulationVaccinated