/*
Queries used for Tableau Project
*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
--Group By date
order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location = 'India'
Where continent is null 
and location not in ('World', 'Upper middle income', 'High income', 'Lower middle income', 'Low income', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as CasesMaxCount,  Max((total_cases/population))*100 as CaseMaxPercentage
From PortfolioProject..CovidDeaths
Group by Location, Population
order by CaseMaxPercentage desc


-- 4.

Select Location, Population,date, MAX(total_cases) as CasesMaxCount,  Max((total_cases/population))*100 as CaseMaxPercentage
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by CaseMaxPercentage desc