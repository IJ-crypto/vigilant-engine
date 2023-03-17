--viewing tables
SELECT *
from PortfolioProject..[death-covid]
order by 3,4


SELECT *
from PortfolioProject..[vaccination-covid]
order by 3,4


--Death rate amongst infected persons
SELECT location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as Percent_Death
from PortfolioProject..[death-covid]
order by 1,2


-- Percentage of infected Person
SELECT location, date, total_cases, total_deaths, (population*100000) as Population, (total_cases/(population*100000))*100 as Percent_Infected
from PortfolioProject..[death-covid]
order by 1,2


--Countries with Highest rate of Infection compared to their Population
SELECT location, MAX(total_cases) as Highest_Infected_Count, (population*100000) as Population, MAX((total_cases/(population*100000)))*100 as Highest_Percent_Infected
from PortfolioProject..[death-covid]
Group by location, population
order by Highest_Percent_Infected


--Amount of deaths per population in each Location
SELECT location, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProject..[death-covid]
Group by location
order by total_death_count desc


--Groupint the data by Continent
SELECT continent, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProject..[death-covid]
Group by continent
order by total_death_count desc


--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as newCases --as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as Death_Percentage
from PortfolioProject..[death-covid]
WHERE continent is not null
Group by date
order by 1,2


select date,SUM(new_cases) as newCases, sum(cast(new_deaths as int)) as new_death_count, sum(cast(new_deaths as int))/SUM(new_cases)*100 as daily_death_percentage
from PortfolioProject..[death-covid]
WHERE continent is not null
Group by date
order by 1,2

--Percentage of new deaths to new cases recorded
select SUM(new_cases) as newCases, sum(cast(new_deaths as int)) as new_death_count, sum(cast(new_deaths as int))/SUM(new_cases)*100 as daily_death_percentage
from PortfolioProject..[death-covid]
WHERE continent is not null
order by 1,2;

--Merging the two tables for analysis 
select * 
from PortfolioProject..[death-covid] dc
join PortfolioProject..[vaccination-covid] vc
	on dc.location = vc.location
	and dc.date = vc.date;

--total population Vaccinated

select dc.continent, dc.location, dc.date, dc.population, vc.new_vaccinations
from PortfolioProject..[death-covid] dc
join PortfolioProject..[vaccination-covid] vc
	on dc.location = vc.location
	and dc.date = vc.date
WHERE dc.continent is not null
order by 1,2,3;


-- Rolling sum of newly vacccinated each day from a particular location
select dc.continent, dc.location, dc.date, dc.population, vc.new_vaccinations,
SUM(CONVERT(int,vc.new_vaccinations)) OVER (Partition by dc.location ORDER by dc.location, dc.date) as Rolling_new_vaccinated
from PortfolioProject..[death-covid] dc
join PortfolioProject..[vaccination-covid] vc
	on dc.location = vc.location
	and dc.date = vc.date
WHERE dc.continent is not null
order by 2,3;

--Rolling percentage of vaccinated people wrt to the population each day from a particular location
--using CTE
WITH PopVsVac (continent, location, date, population, new_vaccinations, Rolling_new_vaccinated)
as
(
select dc.continent, dc.location, dc.date, dc.population, vc.new_vaccinations,
SUM(CONVERT(int,vc.new_vaccinations)) OVER (Partition by dc.location ORDER by dc.location, dc.date) as Rolling_new_vaccinated
from PortfolioProject..[death-covid] dc
join PortfolioProject..[vaccination-covid] vc
	on dc.location = vc.location
	and dc.date = vc.date
WHERE dc.continent is not null
)
SELECT *, (Rolling_new_vaccinated/(population*10000000))*100
FROM PopVsVac

