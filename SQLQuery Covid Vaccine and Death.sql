Select * 
from PortfolioProject..CovidDeath
--where continent is not null
order by 3,4

--Select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

--select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeath
order by 1,2

--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
where location like'%Canada%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid
Select location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfection
From PortfolioProject..CovidDeath
where location like'%Canada%'
order by 1,2

--Looking at countries with highest infection rates compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as HighestPercentPopulationInfection
From PortfolioProject..CovidDeath
group by location, population
order by HighestPercentPopulationInfection desc



--Showing the countries with the highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
where continent is not null
group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
where continent is not null
group by continent
order by TotalDeathCount desc

------ second way 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
where continent is null
group by location
order by TotalDeathCount desc

--Showing the continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
where continent is not null
group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS


Select date, SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths , SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
--where location like'%Canada%'
where continent is not null
group by date
order by 1,2

-------

Select  SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths , SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
--where location like'%Canada%'
where continent is not null
--group by date
order by 1,2

--Look at the Vaccination table
Select * 
From PortfolioProject..CovidVaccinations

--Join 2 tables
--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

----

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location 
, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE


With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location 
, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


---TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location 
, dea.Date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location 
, dea.Date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated