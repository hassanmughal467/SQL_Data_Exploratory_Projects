select * from Covid19..Covid19Deaths where continent is not null order by 3,4

--
select Location,date,total_cases,total_deaths,population  from Covid19..Covid19Deaths where continent is not null order by 1,2


-- looking total cases vs total deaths

select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage from Covid19..Covid19Deaths
 where continent is not null  order by 1,2


--Looking Total cases vs population
--Shows what percentage of populatio got Covid

select Location,date,population,total_cases,(total_cases/population)*100 as PopulationInfectedPercentage 
from Covid19..Covid19Deaths  where continent is not null  order by 1,2

--Looking at Countries with higher infection rate compared to population


select Location,population,max(total_cases) as HighestInfectedCount,Max(total_cases/population)*100 as 
PopulationInfectedPercentage from Covid19..Covid19Deaths where continent is not null group by population, Location  order by PopulationInfectedPercentage desc

--Showing Countries with Highest Death	Count per Population

select Location,max(cast(total_deaths as int)) as HighestDeathCount from Covid19..Covid19Deaths where continent is not null 
 group by location order by HighestDeathCount desc

 --Break data down by continents

 --Showing the continents with highest death count per population

 select location,max(cast(total_deaths as int)) as HighestDeathCount from Covid19..Covid19Deaths where continent is null 
 group by location order by HighestDeathCount desc
 
 --Global Numbers

 select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as Total_Death,sum(cast(new_deaths as int)/total_cases)*100
  as Death_Percentage from Covid19..Covid19Deaths
 where continent is not null 
 --group by date 
 order by 1,2

 -- Now Join Tables

 Select * from Covid19..Covid19Deaths Death
 join covid19..covid19Vaccinations Vacc
 on Death.location=Vacc.location
 and Death.date=Vacc.date


  -- Looking at Total Population Vs Vaccinations
 
 Select death.location, death.continent,death.date,death.population,vacc.new_vaccinations from Covid19..Covid19Deaths death
 join covid19..covid19Vaccinations Vacc
 on death.location=Vacc.location
 and death.date=Vacc.date
 where death.continent is not null
order by 1,2

###


 
 Select death.location, death.continent,death.date,death.population,vacc.new_vaccinations,
 sum(Convert(int,Vacc.new_vaccinations)) 
 OVER (partition by death.location order by death.location) as RollingPeopleVaccinated
  from Covid19..Covid19Deaths death
 join covid19..covid19Vaccinations Vacc
 on death.location=Vacc.location
 and death.date=Vacc.date
 where death.continent is not null
order by 1,2 

-- USE CTE

with PopVsVac (Continent,location,date,population,New_vaccinations,RollPeopleVaccinated)
as 
(
Select death.location, death.continent,death.date,death.population,vacc.new_vaccinations,
 sum(Convert(int,Vacc.new_vaccinations)) 
 OVER (partition by death.location order by death.location) as RollingPeopleVaccinated
  from Covid19..Covid19Deaths death
 join covid19..covid19Vaccinations Vacc
 on death.location=Vacc.location
 and death.date=Vacc.date
 where death.continent is not null
--order by 2,3 
)
select * ,(RollPeopleVaccinated/population)*100
From PopVsVac 




-- Temp Table
Create Table #PercentPopulationVaccinated
(continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)
Insert into #PercentPopulationVaccinated
Select death.location, death.continent,death.date,death.population,vacc.new_vaccinations,
 sum(Convert(int,Vacc.new_vaccinations)) 
 OVER (partition by death.location order by death.location) as RollingPeopleVaccinated
  from Covid19..Covid19Deaths death
 join covid19..covid19Vaccinations Vacc
 on death.location=Vacc.location
 and death.date=Vacc.date
where death.continent is not null
--order by 2,3 

select * ,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select death.location, death.continent,death.date,death.population,vacc.new_vaccinations,
 sum(Convert(int,Vacc.new_vaccinations)) 
 OVER (partition by death.location order by death.location) as RollingPeopleVaccinated
  from Covid19..Covid19Deaths death
 join covid19..covid19Vaccinations Vacc
 on death.location=Vacc.location
 and death.date=Vacc.date
where death.continent is not null


