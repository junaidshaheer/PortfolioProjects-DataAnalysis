SELECT *
FROM PortfolioProject.dbo.CovidDeaths
Where continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccination
--ORDER BY 3,4

SELECT location, date, total_cases, [ total_deaths], ([ total_deaths]/total_cases)*100 as DeathPercentage 
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%india%'
Order by 1,2

SELECT location, date, total_cases,population, (total_cases/population)*100 as PopulationGotCovid 
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%india%'
Order by 1,2

SELECT location, MAX(total_cases) as HighInfectionRate ,population, MAX((total_cases/population))*100 as MaxPopulationGotCovid 
FROM PortfolioProject.dbo.CovidDeaths
Group by location,population
Order by MaxPopulationGotCovid desc
 
SELECT location, MAX(CAST([ total_deaths] AS INT)) AS TotalCovidDeaths
FROM PortfolioProject.dbo.CovidDeaths
Where continent IS NOT NULL
Group by location
Order by TotalCovidDeaths desc

SELECT continent, MAX(CAST([ total_deaths] AS INT)) AS TotalDeathsPerContinent
FROM PortfolioProject.dbo.CovidDeaths
Where continent IS NOT NULL
Group by continent
Order by TotalDeathsPerContinent desc

Select SUM(new_cases) as TotalNewCases, SUM(CAST(new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as TotalDeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2

SELECT *
FROM PortfolioProject.dbo.CovidVaccination

--JOINING BOTH TABLE BASED ON LOCATION & DATE

SELECT *
FROM PortfolioProject.dbo.CovidDeaths Deaths
JOIN PortfolioProject.dbo.CovidVaccination Vaccination
	on Deaths.location=Vaccination.location
	and Deaths.date=Vaccination.date

	

-- New vaccination per day 

SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccination.new_vaccinations
FROM PortfolioProject.dbo.CovidDeaths Deaths
JOIN PortfolioProject.dbo.CovidVaccination Vaccination
	on Deaths.location=Vaccination.location
	and Deaths.date=Vaccination.date
Where Deaths.continent is not null
order by 2,3


--Percentage Of Population Vaccinated
--Using Temp Table

DROP table if exists #PopulationVaccinatedPercentage
Create table #PopulationVaccinatedPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativePeopleVaccinated numeric
)
Insert into #PopulationVaccinatedPercentage
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccination.new_vaccinations
, SUM(CONVERT(float,Vaccination.new_vaccinations)) OVER (Partition by Deaths.location ORDER BY Deaths.location, Deaths.date) as CumulativePeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths Deaths
JOIN PortfolioProject.dbo.CovidVaccination Vaccination
	on Deaths.location = Vaccination.location
	and Deaths.date = Vaccination.date


Select *, (CumulativePeopleVaccinated/Population)*100
from #PopulationVaccinatedPercentage



--Creating view


CREATE VIEW PopulationVaccinatedPercentage AS

SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccination.new_vaccinations
, SUM(CONVERT(float,Vaccination.new_vaccinations)) OVER (Partition by Deaths.location ORDER BY Deaths.location, Deaths.date) as CumulativePeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths Deaths
JOIN PortfolioProject.dbo.CovidVaccination Vaccination
	on Deaths.location = Vaccination.location
	and Deaths.date = Vaccination.date
Where Deaths.continent is not null

Select *
from PopulationVaccinatedPercentage