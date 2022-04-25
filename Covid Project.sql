SELECT *
FROM PortfolioProject.dbo.[Covid Death]
WHERE continent is not null 
ORDER BY 3,4


SELECT *
FROM PortfolioProject.dbo.[Covid Vaccination]
ORDER BY 3,4

--Select Data that we are going to be using

SELECT Location, Date, Total_cases, new_cases, Total_deaths, population
FROM PortfolioProject.dbo.[Covid Death]
ORDER BY 1,2

--looking at Total cases vs total deaths
--Show the likelihood of dying if you infect with Covid in USA

SELECT Location, Date, Total_cases,Total_deaths, (Total_deaths/Total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.[Covid Death]
WHERE Location like '%states%'
ORDER BY 1,2


--Looking at the total cases vs population
--Show what precentage of popultion got Covid
SELECT Location, Date, Total_cases,Population, (Total_cases/population)*100 as InfectionRate
FROM PortfolioProject.dbo.[Covid Death]
WHERE Location like '%states%'
ORDER BY 1,2

--Looking at Country with highest infection rate compared to population

SELECT Location, population, MAX(Total_cases) as HighestInfectionCount, MAX((Total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.[Covid Death]
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing country with highest death count per population

SELECT location, MAX( CAST (total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.[Covid Death]
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Golbal Number

SELECT  SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS BIGINT)) as total_deaths, SUM(CAST(new_deaths AS INT))/ SUM(new_cases)*100
FROM PortfolioProject.dbo.[Covid Death]
WHERE continent is not null

ORDER BY 1,2

SELECT *
FROM PortfolioProject.dbo.[Covid Vaccination]

--looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS numberpeoplevaccinated

FROM PortfolioProject.dbo.[Covid Vaccination] vac
JOIN PortfolioProject.dbo.[Covid Death] dea
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Use CTE

WITH Popvsvac (continent, location, date, population, new_vaccinations, numberpeoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location Order by dea.location,
dea.date) as numberpeoplevaccinated
FROM PortfolioProject.dbo.[Covid Vaccination] vac
JOIN PortfolioProject.dbo.[Covid Death] dea
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (numberpeoplevaccinated/population)*100
FROM Popvsvac

--Temp Table
DROP TABLE IF exists #PercentPopulationVaccinated


CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar (225),
Date datetime,
Population numeric,
New_vaccinations numeric,
numberpeoplevaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location Order by dea.location,
dea.date) as numberpeoplevaccinated
FROM PortfolioProject.dbo.[Covid Vaccination] vac
JOIN PortfolioProject.dbo.[Covid Death] dea
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (numberpeoplevaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating view to stor data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location Order by dea.location,
dea.date) as numberpeoplevaccinated
FROM PortfolioProject.dbo.[Covid Vaccination] vac
JOIN PortfolioProject.dbo.[Covid Death] dea
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null


SELECT *
FROM PercentPopulationVaccinated

