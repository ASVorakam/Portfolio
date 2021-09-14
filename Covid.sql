-- ������ ������� ��� ���� � https://ourworldindata.org/covid-deaths.
-- ������� �������� � ���� ��������� ������ � �������� COVID-19
-- ������� �������������� ��� ������ �� ��� �������: CovidDeath � CovidVaccinations. 
-- ����: �������� ������������ ������ � ������� SQL, � ��� �� ����������� ��������� ������� ��� ������������.

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY date

-- ������� ������, ������� ����� ������������

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY Location, date

-- ��������� �� ��������� ���� ������� �� ���� ������� ��������� � ���������� �����������

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY Location, date

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like 'United States'
ORDER BY Location, date

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like 'Russia'
ORDER BY Location, date

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like 'Italy'
ORDER BY Location, date


-- ���������� ����������: �� ��� �������������� ����� � �������� ���������� ����� ������ ��������������� ������� ���������,
-- ������ � ����� ������� ���������� ������� ���������� �� ���� ��������� � ������� �������. ���������.

-- ��������� �� ��������� ���� ������� ��������� � ������ ��������� � ���������� �����������

SELECT Location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY Location, date

-- ��������� �� ������ � ���������� ��������� ����������� ��������� 

SELECT Location, population,  MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CovidInfectedPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY CovidInfectedPercentage desc

-- ��������� �� ������ � ���������� ������ ������� �� ������

SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount desc

-- �� �� ����������, �� �� �����������

SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc


-- ��������� ����� �� ���� ����������, ������� � ����������� ��������� ���� ������

SELECT SUM(CAST(new_cases as FLOAT)) as total_cases,
	SUM(CAST(new_deaths as FLOAT)) as total_deaths,
	SUM(CAST(new_deaths as FLOAT))/SUM(CAST(new_cases as FLOAT))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null



-- ��������� �� ������� ��������������� ����� �� ������ ��������� � ������ ��������� ������

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY Location, date

WITH CTE (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.Date) as RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths as dea
	JOIN PortfolioProject..CovidVaccinations as vac
		on dea.location = vac.location
		and dea.date = vac.date
	WHERE dea.continent is not null
)
SELECT *, ROUND((RollingPeopleVaccinated/Population)*100, 2) as PercentageofPeopleVaccinated
from CTE
ORDER BY Location, date

-- �������� ������ ������� ��� ������� ������������ � tableau 

SELECT SUM(CAST(new_cases as FLOAT)) as total_cases,
	SUM(CAST(new_deaths as FLOAT)) as total_deaths,
	SUM(CAST(new_deaths as FLOAT))/SUM(CAST(new_cases as FLOAT))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null

SELECT location, SUM(CAST(new_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

Select location, population, MAX(total_cases) as HighestInfectionCount,
	MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc

Select location, Population, date
	,MAX(total_cases) as HighestInfectionCount
	,MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population, date
order by PercentPopulationInfected desc
