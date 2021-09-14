-- Данный датасет был взят с https://ourworldindata.org/covid-deaths.
-- Датасет содержит в себе всемирные данные о пандемии COVID-19
-- Датасет предварительно был разбит на две таблицы: CovidDeath и CovidVaccinations. 
-- Цель: провести исследование данных с помощью SQL, а так же подготовить различные табилцы для визуализации.

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY date

-- Выберем данные, которые будем использовать

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY Location, date

-- Посмотрим на отношение всех смертей ко всем случаям заражения в процентном соотношении

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


-- Интересное примечание: Из трёх представленных стран с примерно одинаковой датой первых зафиксированных случаев заражения,
-- только в одной процент смертности заметно отличается от двух остальных в меньшую сторону. Любопытно.

-- Посмотрим на отношение всех случаев заражения к общему населению в процентном соотношении

SELECT Location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY Location, date

-- Посмотрим на страны с наибольшим процентом зараженного населения 

SELECT Location, population,  MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CovidInfectedPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY CovidInfectedPercentage desc

-- Посмотрим на страны с наибольшим числом смертей от вируса

SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount desc

-- Та же статистика, но по континентам

SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc


-- Всемирные цифры по всем зараженным, умершим и процентному отношению этих данных

SELECT SUM(CAST(new_cases as FLOAT)) as total_cases,
	SUM(CAST(new_deaths as FLOAT)) as total_deaths,
	SUM(CAST(new_deaths as FLOAT))/SUM(CAST(new_cases as FLOAT))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null



-- Посмотрим на процент вакцинированных людей от общего населения в каждой отдельной стране

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

-- Отдельно Выведу таблицы для удобной визуализации в tableau 

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
