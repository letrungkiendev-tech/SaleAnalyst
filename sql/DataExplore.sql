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
