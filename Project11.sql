select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

--Looking at total death vs total cases
-- shows likelihood of dying by calculating death percentage
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercent
from CovidDeaths
where location like '%india%'
order by 1,2

--Looking at total cases vs total population
select location, date, population, total_cases,(total_cases/population)*100 AS EffectedPercent, (total_deaths/total_cases)*100 AS DeathPercent
from CovidDeaths
where location like '%india%'
order by 1,2

--Looking at countries with highest infection rate compare to population
select location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 AS EffectedPercent
from CovidDeaths
group by location, population
order by EffectedPercent DESC

--Looking at countries with highest death rate per population
select location, MAX(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is not NULL
group by location
order by HighestDeathCount DESC

-- Breaking down by continent
select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is not NULL
group by continent
order by HighestDeathCount DESC


--Looking to total population vs vaccination
select dea.continent,dea.location,dea.date ,population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date),sum(convert(int, vac.new_vaccinations)) over (partition by dea.location)
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location and dea.date = vac .date
where dea.continent is not null
order by 2,3

--using cte

with PopvsVac(continent, location, date, population ,new_vaccination, rollingvaccination)
as
(
select dea.continent,dea.location,dea.date ,population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingvaccination
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location and dea.date = vac .date
where dea.continent is not null
--order by 2,3
)
select *, (rollingvaccination/population)*100
from PopvsVac

--creating view

create view PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date ,population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location and dea.date = vac .date
where dea.continent is not null
--order by 2,3