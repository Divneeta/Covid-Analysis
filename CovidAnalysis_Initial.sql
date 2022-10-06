SELECT * 
FROM PortfolioProject..CovidDeaths
order by location, date;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent <> ''
order by location, date;

--Total Cases vs Total Deaths
--Shows the likelihood of dying of Covid in NZ.
SELECT location, date, total_cases, total_deaths, round	((total_deaths/nullif(total_cases,0))*100,2) as Death_Percentage
FROM PortfolioProject..CovidDeaths
where location = 'New Zealand'
order by location, date;

--Total cases vs population
SELECT location, date, population, total_cases, round((total_cases/nullif(population,0))*100,2) as Active_Cases_Percentage
FROM PortfolioProject..CovidDeaths
where location = 'New Zealand'
order by location, date;

SELECT location, sum(total_cases) as Total_Cases
FROM PortfolioProject..CovidDeaths
Where continent <> ''
Group by location
order by Total_Cases Desc;

--Covid Cases % per country

SELECT location, population, MAX(total_cases) as HighestInfection, round((MAX(total_cases)/nullif(population,0))*100,2) as Active_Cases_Percentage
FROM PortfolioProject..CovidDeaths
Where continent <> ''
Group by location, population
order by Active_Cases_Percentage Desc

--Death Counts per Country
SELECT location, max(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent <> ''
Group by location
order by TotalDeathCount Desc

--Cases and Deaths by location

SELECT location,continent, max(total_cases) as TotalCases, max(total_deaths) as TotalDeaths
FROM PortfolioProject..CovidDeaths
Where continent <> ''
Group by location, continent
order by continent,TotalCases Desc

--BY CONTINENT 

SELECT continent, max(total_cases) as TotalCases, max(total_deaths) as TotalDeaths
FROM PortfolioProject..CovidDeaths
Where continent <> ''
Group by continent
order by TotalCases Desc

--Global Numbers

--cases per day
SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, round((SUM(new_deaths)/nullif(SUM(new_cases),0))*100,2) as Death_Percentage
FROM PortfolioProject..CovidDeaths
Where continent <> ''
Group by date
order by date;

-- Total Cases
SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, round((SUM(new_deaths)/nullif(SUM(new_cases),0))*100,2) as Death_Percentage
FROM PortfolioProject..CovidDeaths
Where continent <> '';

With PopvsVac(continent, location, date, population, new_vaccinations, AggregateVaccinations)
As
(SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as AggregateVaccinations
FROM PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
and dea.date=vac.date
Where dea.continent <> '' 
--and dea.population<> 0
and dea.location = 'New Zealand'
)
Select * , round((cast(AggregateVaccinations as float)/nullif(cast(population as float),0)*100),5) as PercentageVaccinated
From PopvsVac;


--Temp Table Alternative
Drop Table if Exists #PercentPeopleVaccinated
Create Table #PercentPeopleVaccinated
(
continent nvarchar(255), 
location nvarchar(255),
date datetime, 
population numeric, 
new_vaccinations numeric, 
AggregateVaccinations numeric)

Insert Into #PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as AggregateVaccinations
FROM PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
and dea.date=vac.date
Where dea.continent <> '' 
--and dea.population<> 0
--and dea.location = 'New Zealand'

Select * , round((cast(AggregateVaccinations as float)/nullif(cast(population as float),0)*100),5) as PercentageVaccinated
From #PercentPeopleVaccinated;



--Cases, Deaths & Vaccinations by location


--Views

Create View PercentPeopleVaccinated as 
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as AggregateVaccinations
FROM PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
and dea.date=vac.date
Where dea.continent <> '' 
--and dea.population<> 0
--and dea.location = 'New Zealand'
;

select * from PercentPeopleVaccinated;

Create View CasesandDeathDistribution
As
SELECT location,continent, max(total_cases) as TotalCases, max(total_deaths) as TotalDeaths
FROM PortfolioProject..CovidDeaths
Where continent <> ''
Group by location, continent;

Select * from CasesandDeathDistribution;

Create View CasesDeathsVaccinations
As
SELECT  dea.location,dea.continent,dea.population,max(dea.total_cases) as TotalCases, 
max(dea.total_deaths) as TotalDeaths, max(vac.total_vaccinations) as TotalVaccinations,
round((max(cast(vac.total_vaccinations as float))/nullif(cast (population as float),0))*100,5) As PercentPopulationVaccinated 
FROM PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
and dea.date=vac.date
Where dea.continent <> ''
Group by dea.location, dea.continent, dea.population
--order by dea.continent, PercentPopulationVaccinated Desc