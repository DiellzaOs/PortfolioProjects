select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * from PortfolioProject..CovidVaccinations
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Total cases vs total deaths

select Location, date, total_cases, total_deaths,(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%macedonia%'
order by 1,2

--Total cases vs population

select Location, date, population total_cases,(CONVERT(float, total_cases) / population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
where location like '%macedonia%'
order by 1,2


-- countries with highiestt infection vs population

select Location, Population, MAX(total_cases)as HighiestInfection, Max((CONVERT(float, total_cases)) / population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
--where location like '%macedonia%'
group by Location, Population
order by InfectedPercentage desc

--Highiest death count 

select Location, MAX(cast(Total_deaths as int)) as TotalDeaths
from PortfolioProject..CovidDeaths
where continent is not null 
group by location
order by TotalDeaths desc

-- deaths group by continent

select continent, MAX(cast(Total_deaths as int)) as TotalDeaths
from PortfolioProject..CovidDeaths
where continent is not null 
group by continent
order by TotalDeaths desc

-- global numbers

select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- temp table

DROP Table #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


 -- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select * from PercentPopulationVaccinated