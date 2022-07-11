
Select *
From PortfolioProject.dbo.CovidDeaths
order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--order by 3,4



--Working on CovidDeaths

--Data Selection
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
order by 1,2

--Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
order by 1,2

--DeathPercentage in India
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location = 'India'
order by 1,2

--Total Cases vs Population
Select location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
From PortfolioProject.dbo.CovidDeaths
--Where location = 'India'
order by 1,2

--Country with Highest Infection Rate compared to Population
Select location, population, Max(total_cases) as CasesMaxCount, Max((total_cases/population))*100 as CaseMaxPercentage
From PortfolioProject.dbo.CovidDeaths
Group by location, population
order by CaseMaxPercentage desc

--Highest Death Count per Population
Select location, Max(cast(total_deaths as int)) as DeathsMaxCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by location
order by DeathsMaxCount desc

--Continent with Highest Death Count
Select location, Max(cast(total_deaths as int)) as DeathsMaxCount
From PortfolioProject.dbo.CovidDeaths
Where continent is null
Group by location
order by DeathsMaxCount desc

--Ignores NULL row values from continent column
Select continent, Max(cast(total_deaths as int)) as DeathsMaxCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by continent
order by DeathsMaxCount desc


--Global Numbers

Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by date
order by 1,2

--Total Cases across world
Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--Where continent is not null
order by 1,2


--Working on CovidDeaths and CovidVaccinations
Select *
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

--Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Total Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--Using CTE
With PopVsVac (Continent, Location, Date, Population, New_Vaccincations, RollingVaccination)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingVaccination/Population)*100 as RollingVaccinationPercentage
From PopVsVac


--Temp Table
DROP TABLE if exists #RollingPeopleVaccinationPercentage
CREATE TABLE #RollingPeopleVaccinationPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccincations numeric,
RollingVaccination numeric
)
Insert into #RollingPeopleVaccinationPercentage
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingVaccination/Population)*100 as RollingVaccinationPercentage
From #RollingPeopleVaccinationPercentage



--Creating View to store data for later visualizations

CREATE View RollingPeopleVaccinationPercentage as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Select *
From RollingPeopleVaccinationPercentage