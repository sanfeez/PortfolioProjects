select *
from PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, total_deaths, new_cases,population
from PortfolioProject..CovidDeaths
order by 1,2

--see percentage of deaths in UK

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%kingdom'
and continent is not null
order by 1,2
 
--Let's Total cases Vs Population

select location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
from PortfolioProject..CovidDeaths
where location like '%kingdom'
order by location, date

--Countries with Highest Infection rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopInfected
from PortfolioProject..CovidDeaths
group by location, population
order by PercentagePopInfected desc

--Countries with Highest Death Count per Population

select location, population, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by TotalDeathCount desc

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

select location, continent, total_deaths
from PortfolioProject..CovidDeaths
where continent is not null

--Let's see Continent with highest death Count per Population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%kingdom'
where continent is not null
order by 1,2

--Global Deaths rate as a Percentage of Total Cases

select sum(new_cases) as total_cases, sum(cast(New_Deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as PercentageDeaths
from PortfolioProject..CovidDeaths
where continent is not null

--this shows Total cases at 150.5million as at the period under coverage with 2.1% death rate.


--Total Population Vs Vaccinations to show the number of people that have been vaccinated in the world

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Total_Vaccinations
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


with PopvsVac (continent,location, date, population, new_vaccinations, total_vaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Total_Vaccinations
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (total_vaccinations/population)*100 as PercentVaccinated
from PopvsVac

--let's put ths in a temp table
drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Total_Vaccinations numeric
)

insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Total_Vaccinations
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

select *, (total_vaccinations/population)*100 as PercentVaccinated
from PercentPopulationVaccinated


--create view to save for visualization

create view PercentPopVac as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Total_Vaccinations
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null