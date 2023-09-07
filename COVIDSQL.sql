SELECT * FROM sqlport.dbo.coviddeath$
WHERE continent is not null;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM sqlport.dbo.coviddeath$
WHERE continent is not null;

SELECT location, date, total_cases,
CASE 
  WHEN total_cases = 0 THEN NULL
  ELSE (total_deaths/total_cases)*100
END as DeathPercent
FROM sqlport.dbo.coviddeath$
WHERE continent is not null
ORDER BY location, date;

--shows the likelihood of dying if you contract covid in your country

SELECT location, date, population, total_cases,
CASE 
  WHEN total_cases = 0 THEN NULL
  ELSE (total_deaths/total_cases)*100
END as DeathPercent
FROM sqlport.dbo.coviddeath$
WHERE location like '%states%'
--WHERE continent is not null
ORDER BY location, date;

SELECT location, date, population, total_cases, (total_cases/population)*100 as Peopleaffected
FROM sqlport.dbo.coviddeath$
ORDER BY LOCATION, DATE;
--WHERE LOCATION = 'pakistan';

--lOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE.
SELECT location, population, MAX(total_cases) as HIghestinfectioncount, MAX((total_cases/population))*100 as percentPeopleaffected
FROM sqlport.dbo.coviddeath$
GROUP BY location, population
ORDER BY percentPeopleaffected desc;

SELECT location, MAX(total_deaths) as HighestDeathCount
FROM sqlport.dbo.coviddeath$
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount desc;

SELECT location, MAX(total_deaths) as HighestDeathCount
FROM sqlport.dbo.coviddeath$
WHERE continent is null
GROUP BY location
ORDER BY HighestDeathCount desc;

SELECT continent, MAX(total_deaths) as HighestDeathCount
FROM sqlport.dbo.coviddeath$
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount desc;

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalNewDeath, 
CASE
  WHEN SUM(new_cases) = 0 THEN NULL
  ELSE SUM(new_deaths)/SUM(new_cases)*100
END AS DeathPercentage
FROM sqlport.dbo.coviddeath$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalNewDeath, 
CASE
  WHEN SUM(new_cases) = 0 THEN NULL
  ELSE SUM(new_deaths)/SUM(new_cases)*100
END AS DeathPercentage
FROM sqlport.dbo.coviddeath$
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;


SELECT * FROM sqlport.dbo.covidvacination$
WHERE continent is not null;

--USE CTE

with popvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) over (Partition by dea.location order by  dea.location, dea.date)
as RollingPeopleVaccinated
--(peoplevaccinated/population)*100
FROM sqlport.dbo.coviddeath$ dea
JOIN sqlport.dbo.covidvacination$  vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM popvsVac;

---TEMP TABLE

Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric

)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) over (Partition by dea.location order by  dea.location, dea.date)
as RollingPeopleVaccinated
--(peoplevaccinated/population)*100
FROM sqlport.dbo.coviddeath$ dea
JOIN sqlport.dbo.covidvacination$  vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #PercentagePopulationVaccinated;

Creating views for later visualizations

create View PercentageVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) over (Partition by dea.location order by  dea.location, dea.date)
as RollingPeopleVaccinated
--(peoplevaccinated/population)*100
FROM sqlport.dbo.coviddeath$ dea
JOIN sqlport.dbo.covidvacination$  vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order BY 2,3

SELECT * 
FROM PercentageVaccinated
