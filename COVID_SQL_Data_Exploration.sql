Select * from PortfolioProject..['owid-covid-data-mod$'] 
where continent is not null
order by 3, 4

Select * from PortfolioProject..['owid-covid-data$'] order by 3, 4

-- Selecting the data that we will use

Select Location, date, total_cases, new_cases, total_deaths, population from PortfolioProject..['owid-covid-data-mod$'] order by 1, 2

-- Looking at Total Cases vs Total Deaths, and filtering it by Country
-- Trying to show Likelihood of dying if you contract COVID in India

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..['owid-covid-data-mod$'] 
where Location like '%India%' 
order by 1, 2

-- Looking at Total Cases vs Population, again filtered by Country

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentageOfPopulation 
from PortfolioProject..['owid-covid-data-mod$']
where Location like '%India%' 
order by 1, 2

-- Looking at Countries with Highest Infection Rates compared to population

Select Location, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentageOfPopulationInfected
from PortfolioProject..['owid-covid-data-mod$']
where continent is not null
Group by Location, Population
order by PercentageOfPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as HighestDeathCount 
from PortfolioProject..['owid-covid-data-mod$']
where continent is not null
Group by Location, Population
order by HighestDeathCount desc

-- Breaking things down by Continent
-- Continents with Max Deaths

Select location, MAX(cast(total_deaths as int)) as HighestDeathCount 
from PortfolioProject..['owid-covid-data-mod$']
where continent is null 
and location not like '%income%' 
and location not like '%World%' 
Group by location
order by HighestDeathCount desc

-- Getting the MAX death figure in a country per continent

Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount 
from PortfolioProject..['owid-covid-data-mod$']
where continent is not null and location not like '%income%'
Group by continent
order by HighestDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
(SUM(cast(new_deaths as int))/SUM(new_cases)) * 100 as DeathPercentage
from PortfolioProject..['owid-covid-data-mod$'] 
where continent is not null 

-- Vaccination Table

Select *
from PortfolioProject..['owid-covid-data$']


-- Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..['owid-covid-data-mod$'] dea
join PortfolioProject..['owid-covid-data$'] vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- USE CTE

with PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..['owid-covid-data-mod$'] dea
join PortfolioProject..['owid-covid-data$'] vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac
order by 2,3

-- Above an be carried out using Temp Tables as well

-- Creating View to store data for later visualizations

Drop view if exists PercentagePopulationVaccinated

Create view PercentagePopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..['owid-covid-data-mod$'] dea
join PortfolioProject..['owid-covid-data$'] vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null

Select * from PercentagePopulationVaccinated
