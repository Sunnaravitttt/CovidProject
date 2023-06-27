--SELECT * FROM dbo.CovidDeaths
--WHERE continent IS NOT NULL
--ORDER BY 3,4

--SELECT * FROM dbo.CovidVaccinations
--ORDER BY 3,4

-- Select data 
--SELECT Location, date, total_cases, new_cases, total_deaths, population FROM dbo.CovidDeaths 
--ORDER BY 1,2

--looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in ur country
--SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage FROM dbo.CovidDeaths 
--WHERE Location LIKE '%Thailand%'
--ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
--SELECT Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage FROM dbo.CovidDeaths 
--WHERE Location LIKE '%Thailand'
--ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population
--SELECT Location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as HighestInfectionPercentage 
--FROM dbo.CovidDeaths
--GROUP BY Location, population
--ORDER BY 3 DESC

--Showing the countries with the highest Death Count per Population
--SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathsCount  
--FROM dbo.CovidDeaths
--WHERE continent IS NOT NULL
--GROUP BY Location
--ORDER BY TotalDeathsCount DESC

--Lets break things down by continent
--SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathsCount  
--FROM dbo.CovidDeaths
--WHERE continent IS NULL
--GROUP BY location
--ORDER BY TotalDeathsCount DESC

--Showing the continents with highest death count per population
--SELECT Location, population, MAX(cast(total_deaths as int)) as TotalDeathsCount  
--FROM dbo.CovidDeaths
--WHERE continent IS NULL
--GROUP BY location, population
--ORDER BY TotalDeathsCount DESC

--Global numbers
 --SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as INT)) as TotalDeaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage  FROM dbo.CovidDeaths
 --WHERE continent IS NOT NULL 
 ----GROUP BY date
 --ORDER BY 1,2

 --Looking at Total Population vs Vaccinations

 --SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 --, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as PeopleVaccinated
 --FROM dbo.CovidDeaths dea 
 --JOIN dbo.CovidVaccinations vac
 --ON dea.Location = vac.Location and dea.date = vac.date
 --WHERE dea.continent IS NOT NULL
 --ORDER BY 2,3

 --SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 --, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
 ----, (RollingPeopleVaccinated/dea.population)*100 as PeopleVaccinated
 --FROM dbo.CovidDeaths dea 
 --JOIN dbo.CovidVaccinations vac
 --ON dea.Location = vac.Location and dea.date = vac.date
 --WHERE dea.continent IS NOT NULL
 --ORDER BY 2,3

 --USE CTE

 --With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
 --as 
 --(
 -- SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 --, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
 ----, (RollingPeopleVaccinated/dea.population)*100 as PeopleVaccinated
 --FROM dbo.CovidDeaths dea 
 --JOIN dbo.CovidVaccinations vac
 --ON dea.Location = vac.Location and dea.date = vac.date
 --WHERE dea.continent IS NOT NULL
 ----ORDER BY 2,3
 --)
 --Select * , (RollingPeopleVaccinated/Population)*100 as X
 --FROM PopvsVac

 --TEMP TABLE
 DROP Table if exists #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccination numeric,
 RollingPeopleVaccinated numeric
 )
 INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/dea.population)*100 as PeopleVaccinated
 FROM dbo.CovidDeaths dea 
 JOIN dbo.CovidVaccinations vac
 ON dea.Location = vac.Location and dea.date = vac.date
 --WHERE dea.continent IS NOT NULL
 --ORDER BY 2,3

 Select * , (RollingPeopleVaccinated/Population)*100 as X
 FROM #PercentPopulationVaccinated

 --Creating View to store data for Visualization

 Create View PercentPopulationVaccinated as
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/dea.population)*100 as PeopleVaccinated
 FROM dbo.CovidDeaths dea 
 JOIN dbo.CovidVaccinations vac
 ON dea.Location = vac.Location and dea.date = vac.date
 WHERE dea.continent IS NOT NULL
 --ORDER BY 2,3
