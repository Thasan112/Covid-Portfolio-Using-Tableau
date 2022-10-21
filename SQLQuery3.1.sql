Select* 
From Portfolioproject..coviddeaths
Where continent is not null

Select*
From Portfolioproject..covidvaccinations

Select* 
From Portfolioproject..coviddeaths
order by 3,4;

--Select*
--From Portfolioproject..covidvaccinations
--order by 3,4

Select location,date,total_cases,new_cases,total_deaths,population
From Portfolioproject..coviddeaths
order by 1,2

--Total cases vs Total deaths
--Likelihood of dying if you contract covid in your country
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
From Portfolioproject..coviddeaths
Where location like '%states%'
AND  continent is not null
order by 1,2

--Looking at total case vs Population
 --What percentage of population got covid
Select location,date,total_cases,population,(total_cases/population)*100 as percentagePoulationinfected
From Portfolioproject..coviddeaths
--Where location like '%states%'
order by 1,2

--Looking for countries for highest infection rates compared to its population size
Select location,population,Max(total_cases)AS Highestinfectioncount,Max(total_cases/population)*100 as percentagepolationinfected
From Portfolioproject..coviddeaths
--Where location like '%states%'
Group by location,population
order by  percentagepolationinfected desc

--looking for countries with highest death count per population
Select location,Max(cast(total_deaths as INT) )AS Totaldeathcount	
From Portfolioproject..coviddeaths
--Where location like '%states%'
Where continent is not null
Group by location
order by Totaldeathcount desc

--Let's break things by continents
--Showing continents with highest death counts
Select continent ,Max(cast(total_deaths as INT) )AS Totaldeathcount	
From Portfolioproject..coviddeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by Totaldeathcount desc

--Global numbers
Select sum(new_cases)AS total_cases,Sum(cast(new_deaths as int))AS total_deaths,
Sum(cast(new_deaths as int))/Sum(new_cases)*100 as deathpercentage
From Portfolioproject..coviddeaths
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2

--Vaccinations
--Looking for totalpopulations vs Vaccination
Select dea.continent,dea.location,dea.date,population,
vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))
OVER (partition by dea.location order by dea.location,dea.date)as
Rollingpeoplevaccinated
--(Rollingpeoplevaccinated/population)*100
From Portfolioproject..coviddeaths dea
JOIN Portfolioproject..covidvaccinations vac
ON dea.location= vac.location AND
dea.date= vac.date
Where dea.continent is not null
order by 2,3

---USE CTE

WITH PopvsVac (Continent,location,date,new_vaccinations,Population,Rollingpeoplevaccinated)
AS
(
Select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))
OVER (partition by dea.location order by dea.location,dea.date)as
Rollingpeoplevaccinated
--(Rollingpeoplevaccinated/population)*100
From Portfolioproject..coviddeaths dea
JOIN Portfolioproject..covidvaccinations vac
ON dea.location= vac.location 
AND dea.date= vac.date
Where dea.continent is not null
--order by 2,3
)
Select *,(Rollingpeoplevaccinated/population)*100
From PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS percentpopulationvaccinated

 CREATE TABLE percentpopulationvaccinated	
(
continent nvarchar(255),
location   nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
INSERT INTO percentpopulationvaccinated
Select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))OVER (partition by dea.location order by dea.location,dea.date)as
Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
From Portfolioproject..coviddeaths dea
JOIN Portfolioproject..covidvaccinations vac
ON dea.location= vac.location 
AND dea.date= vac.date
Where dea.continent is not null
--order by 2,3

Select *,(Rollingpeoplevaccinated/population)*100
From percentpopulationvaccinated

-- Creating view to store data
Create view percentpopulationvaccinated3 as
Select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))OVER (partition by dea.location order by dea.location,dea.date)as
Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
From Portfolioproject..coviddeaths dea
JOIN Portfolioproject..covidvaccinations vac
ON dea.location= vac.location 
AND dea.date= vac.date
Where dea.continent is not null
--order by 2,3

-- final views
Select * From percentpopulationvaccinated3