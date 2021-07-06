SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4
 
 -- SELECT *
 -- FROM PortfolioProject..CovidVaccinations
 -- WHERE continent IS NOT NULL
 -- ORDER BY 3,4

 SELECT location, date, total_cases, new_cases, total_deaths, population
 FROM PortfolioProject..CovidDeaths
 WHERE continent IS NOT NULL
 ORDER BY 1,2

 -- Looking at total cases and total deaths ( in Vietnam )
 -- Shows percentage of death
 SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRate
 FROM PortfolioProject..CovidDeaths
 WHERE location LIKE 'Vietnam' AND continent IS NOT NULL
 ORDER BY 1,2

 -- Looking at total cases and population ( in Vietnam )
 -- Shows percentage of being infected 
 SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectionRate
 FROM PortfolioProject..CovidDeaths
 WHERE location LIKE 'Vietnam' AND continent IS NOT NULL
 ORDER BY 1,2
 
 -- Looking at countries with highest infection rate compared to population
 SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectionRate
 FROM PortfolioProject..CovidDeaths 
 WHERE continent IS NOT NULL
 GROUP BY location, population
 ORDER BY InfectionRate DESC

 -- Showing countries with highest death count per population
 SELECT location, population, MAX(cast(total_deaths AS int)) AS TotalDeathCount, MAX((total_deaths/population))*100 AS DeathRate
 FROM PortfolioProject..CovidDeaths 
 WHERE continent IS NOT NULL
 GROUP BY location, population
 ORDER BY TotalDeathCount DESC

 -- Showing continents with highest death count
 SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
 FROM PortfolioProject..CovidDeaths 
 WHERE continent IS NOT NULL
 GROUP BY continent
 ORDER BY TotalDeathCount DESC

 -- Global Numbers
 SELECT SUM(new_cases) AS 'total new cases', SUM(CAST(new_deaths AS INT)) AS 'total new deaths', (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathRate
 FROM PortfolioProject..CovidDeaths
 WHERE continent IS NOT NULL
 --GROUP BY date
 ORDER BY 1,2


 -- Looking at total population vs vaccinations 
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations 
,   SUM(CONVERT(INT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY 
	DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3

 -- USE CTE
 WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated )
 AS 
 (
 SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
     SUM(CONVERT(INT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY 
	 DEA.location, DEA.date) AS RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths DEA
 JOIN PortfolioProject..CovidVaccinations VAC
 ON DEA.location = VAC.location
 AND DEA.date = VAC.date
 WHERE DEA.continent IS NOT NULL
 --ORDER BY 2,3
 )

 SELECT *, (RollingPeopleVaccinated/Population)*100
 FROM PopvsVac

 -- TEMP TABLE

 DROP TABLE IF EXISTS #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Data datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 INSERT INTO #PercentPopulationVaccinated
 SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
     SUM(CONVERT(INT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY 
	 DEA.location, DEA.date) AS RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths DEA
 JOIN PortfolioProject..CovidVaccinations VAC
      ON DEA.location = VAC.location
      AND DEA.date = VAC.date
 WHERE DEA.continent IS NOT NULL
 --ORDER BY 2,3

 SELECT *, (RollingPeopleVaccinated/Population)*100
 FROM #PercentPopulationVaccinated


 -- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

 CREATE VIEW PercentPopulationVaccinated AS 
 SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
     SUM(CONVERT(INT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY 
	 DEA.location, DEA.date) AS RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths DEA
 JOIN PortfolioProject..CovidVaccinations VAC
      ON DEA.location = VAC.location
      AND DEA.date = VAC.date
 WHERE DEA.continent IS NOT NULL
 --ORDER BY 2,3


 SELECT *
 FROM PercentPopulationVaccinated