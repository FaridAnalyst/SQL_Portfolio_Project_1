select *
from PortfolioProject..CovidDeaths
order by 3, 4


--select *
--from PortfolioProject..CovidVaccinations
--order by 3, 4

-- Select Data that we need

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2


-- Looking at total_cases vs total deaths
-- shows likelihood of dying in your country

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where location like '%Uzbekistan%'
order by 1, 2


-- Looking at Total_cases vs Population
-- shows what percentage of population got covid
select location, date, total_cases, population,(total_cases/population)*100 as PercentPopulationInfect
from PortfolioProject..CovidDeaths
where location like '%Uzbekistan%'
order by 1, 2


-- Looking at countries with highest infection rate compared to population
-- death percentage of infected population
select location, population, max(total_cases) as highestInfectionCount,max((total_cases/population))*100 as PercentPopulationInfected, max((total_deaths/total_cases))*100 as 
PercentCasesDeath
from PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

-- shows countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


-- shows continent with highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- global numbers, daily information above all over the world

select date, sum(new_cases) as DailyCases, sum(cast(new_deaths as int)) as DailyDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1, 2


select *
from PortfolioProject..CovidVaccinations
order by location


-- looking at total population vs vaccinations


select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order  by cd.location, cd.date) as RollingPeopleVaccinated  
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
	where cd.continent is not null
	order by location, date



-- use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations , RollingPeopleVaccinated)
as (
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order  by cd.location, cd.date) as RollingPeopleVaccinated  
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
	where cd.continent is not null
	--order by location, date
)

select* ,(RollingPeopleVaccinated/Population)*100
from PopvsVac

-- Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order  by cd.location, cd.date) as RollingPeopleVaccinated  
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
	--where cd.continent is not null
	--order by location, date


select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



-- create view to store data for later visualizations

create view PercentagePopulationVaccinated as 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order  by cd.location, cd.date) as RollingPeopleVaccinated  
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
	where cd.continent is not null
	--order by location, date
