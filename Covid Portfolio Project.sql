
SELECT *
FROM dbo.[Covid deaths]
ORDER BY 3,4

--SELECT *
--FROM dbo.[Covid Vaccination]
--ORDER BY 3,4

--Data we are going to use 

SELECT Location, Date, Total_cases, New_cases, Total_deaths, Population
FROM dbo.[Covid deaths]
WHERE Continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths

SELECT Location, Date, Total_cases, Total_deaths, (Total_deaths/Total_cases)*100 AS Death_percentage
FROM dbo.[Covid deaths]
WHERE Location like 'RWANDA'
ORDER BY 1,2

  --Looking at Total cases vs Population
  --Shows what percentage of population got COVID

SELECT Location, Population, MAX(Total_cases) AS HighestinfectionCount, MAX (Total_cases/Population)*100 AS Percentageinfectedpopulation
FROM dbo.[Covid deaths]
WHERE Continent is not null
GROUP BY Location, Population
ORDER BY Percentageinfectedpopulation DESC

--Showing countries with Highest Death count per Population 

SELECT Location, Max (CAST(total_deaths as Int)) as TotaldeathCount
FROM dbo.[Covid deaths]
--WHERE LOCATION LIKE'RWANDA'
WHERE Continent is not null
GROUP BY Location
ORDER BY TotaldeathCount DESC

-- Checking up continent with high death rate

SELECT Continent, Max(CAST(Total_deaths as Int)) AS TotaldeathCount
FROM dbo.[Covid deaths]
WHERE Continent is not null
Group by Continent
ORDER BY TotaldeathCount DESC

--GLOBAL NUMBERS

SELECT 
    Date,
    SUM(new_cases) AS Totalcases, 
    SUM(CAST(new_deaths AS INT)) AS Totaldeaths, 
    (SUM(CAST(New_deaths AS INT)) / SUM(new_cases) * 100 )AS Deathpercentage 
FROM 
    [dbo].[Covid deaths]
WHERE CONTINENT IS NOT NULL
--GROUP BY 
    --Date 
ORDER BY
    1,2

SELECT *
FROM dbo.[Covid Vaccination]
ORDER BY 3,4

SELECT *
FROM dbo.[Covid deaths] dea
JOIN DBO.[Covid Vaccination] vac
  ON dea.location=vac.location
  AND dea.date=vac.date
  where dea.Location like 'Grenada'

 --Looking at total population vs vaccinations

SELECT dea.continent, dea.location,dea.date,dea.population, vac.New_vaccinations
, SUM(CONVERT(Int,vac.New_vaccinations)) OVER (PARTITION BY dea.LOCATION ORDER BY dea.Date) as RollingPeopleVaccinated
From dbo.[Covid deaths] dea
JOIN dbo.[Covid Vaccination] vac
   ON dea.location= vac.location
   AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

---USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_vaccination, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location,dea.date,dea.population, vac.New_vaccinations
, SUM(CONVERT(Int,vac.New_vaccinations)) OVER (PARTITION BY dea.LOCATION ORDER BY dea.Date) as RollingPeopleVaccinated
From dbo.[Covid deaths] dea
JOIN dbo.[Covid Vaccination] vac
   ON dea.location= vac.location
   AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/ Population)*100
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location,dea.date,dea.population, vac.New_vaccinations
, SUM(CONVERT(Int,vac.New_vaccinations)) OVER (PARTITION BY dea.LOCATION ORDER BY dea.Date) as RollingPeopleVaccinated
From dbo.[Covid deaths] dea
JOIN dbo.[Covid Vaccination] vac
   ON dea.location= vac.location
   AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--CREATING A VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE View PercentpopulationVaccinated as
SELECT dea.continent, dea.location,dea.date,dea.population, vac.New_vaccinations
, SUM(CONVERT(Int,vac.New_vaccinations)) OVER (PARTITION BY dea.LOCATION ORDER BY dea.Date) as RollingPeopleVaccinated
From dbo.[Covid deaths] dea
JOIN dbo.[Covid Vaccination] vac
   ON dea.location= vac.location
   AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentpopulationVaccinated