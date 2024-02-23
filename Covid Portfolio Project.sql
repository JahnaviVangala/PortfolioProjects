select *
from PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases,new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--total cases vs total deaths
--likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

--total cases vs population
--shows what percentage of population got covid
select location, date,population, total_cases, (total_cases/population)*100 as infected
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

-- countries with highest infection rate compared to population 
select location,population, max(total_cases) as highestinfectedcount,max((total_cases/population))*100 as infectedpercentage
from PortfolioProject..CovidDeaths
--where location like '%india%'
group by location,population
order by infectedpercentage desc

-- countries with the highest death count per population
select location, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by location
order by totaldeathcount desc


--total death count per continent
select continent, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null and location<>continent
group by continent
order by totaldeathcount desc


-- continents with the highest death count per population
select location,continent,population,total_deaths, max(total_deaths /population)*100 as totaldeathcount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by location,continent,population,total_deaths
order by totaldeathcount desc


--global numbers
select sum(new_cases) as total_cases, sum(cast (new_deaths as int)) as total_deaths,(sum(cast (new_deaths as int))/ sum(new_cases) )*100 as deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
order by 1,2



--total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(Rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--using cte
 
with popvsvac (continent,location, date, population,new_vaccinations, rollingpeoplevaccinated)
as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(Rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(Rollingpeoplevaccinated/population)*100 as rollingpeoplevaccinatedpercentage
from popvsvac


--temp table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(Rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

select *,(Rollingpeoplevaccinated/population)*100 as rollingpeoplevaccinatedpercentage
from #percentpopulationvaccinated




--creating view to store data for later visualization

create view percentpeoplevaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(Rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpeoplevaccinated

create view infectedpercentage as
select location,population, max(total_cases) as highestinfectedcount,max((total_cases/population))*100 as infectedpercentage
from PortfolioProject..CovidDeaths
--where location like '%india%'
group by location,population
--order by infectedpercentage desc
select *
from infectedpercentage

create view InfectedInIndia as
select location, date,population, total_cases, (total_cases/population)*100 as infected
from PortfolioProject..CovidDeaths
where location like '%india%'
--order by 1,2


create view TotalDeathCountPerContinent as
select continent, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null and location<>continent
group by continent
--order by totaldeathcount desc
select *
from TotalDeathCountPerContinent





