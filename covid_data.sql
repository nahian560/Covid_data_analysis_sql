SELECT * 
FROM `covid-info-project-365314.covid_data_analysis_01.CovidDeaths` 
order by 3, 4 ;


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `covid-info-project-365314.covid_data_analysis_01.CovidDeaths` 
order by 1, 2 ;

-- Total covid cases vs total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM `covid-info-project-365314.covid_data_analysis_01.CovidDeaths` 
where location = "Bangladesh"
order by 1, 2 ;

-- Total covid cases vs Population

SELECT location, date, total_cases, population, (total_cases/population)*100 as cases_percentage
FROM `covid-info-project-365314.covid_data_analysis_01.CovidDeaths` 
--where location = "Bangladesh"
order by 1, 2 ;

-- Countries with highest infection rates

SELECT location, population, MAX(total_cases) as total_cases, MAX((total_cases/population)*100) as max_infection_rate
FROM `covid-info-project-365314.covid_data_analysis_01.CovidDeaths` 
where population is not null and total_cases is not null
GROUP BY population, location
order by 4 desc;

-- Countries by death counts

SELECT location, MAX(total_deaths) as total_death
FROM `covid-info-project-365314.covid_data_analysis_01.CovidDeaths` 
Where continent is not null
GROUP BY location
order by 2 desc;

-- Continent by death counts

SELECT continent, MAX(total_deaths) as total_death
FROM `covid-info-project-365314.covid_data_analysis_01.CovidDeaths` 
Where continent is not null
GROUP BY continent
order by 2 desc;

-- Golbal Numbers

SELECT date, SUM(new_cases) as new_cases, SUM(new_deaths) as new_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as death_percentage
FROM `covid-info-project-365314.covid_data_analysis_01.CovidDeaths` 
Where continent is not null
GROUP BY date
order by 1, 2;



SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as death_percentage
FROM `covid-info-project-365314.covid_data_analysis_01.CovidDeaths` 
Where continent is not null
--GROUP BY date
;

-- Population vs Vaccination
--Create CTE

WITH POPvsVAC 
AS (

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) Over (partition by dea.location order by dea.location, dea.date) as people_vaccinated_cumulative
FROM `covid-info-project-365314.covid_data_analysis_01.CovidDeaths` as dea
JOIN `covid-info-project-365314.covid_data_analysis_01.CovidVaccination` as vac
ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null

)

SELECT *, (people_vaccinated_cumulative/population)*100 as vaccination_rate
from POPvsVAC;


-- ERRORS

WITH ERR
AS (

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) Over (partition by dea.location order by dea.location, dea.date) as people_vaccinated_cumulative, total_vaccinations, people_fully_vaccinated
FROM `covid-info-project-365314.covid_data_analysis_01.CovidDeaths` as dea
JOIN `covid-info-project-365314.covid_data_analysis_01.CovidVaccination` as vac
ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null

)

SELECT location, population, MAX(people_vaccinated_cumulative) as total_vaccinations, MAX(people_vaccinated_cumulative/population) as vac_per_1, MAX(total_vaccinations) as total_vac, MAX(people_fully_vaccinated) as ful_vac, MAX(total_vaccinations/population) as vac_per_2, MAX(people_fully_vaccinated/population) as ful_vac_per
FROM ERR
WHERE population <= people_vaccinated_cumulative
GROUP BY location, population
ORDER BY 8 desc
