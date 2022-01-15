select * from covid_19_india;

alter table covid_19_india rename column State/Unionterritory to state;

--Data Cleaning

select *,count(*) from covid_19_india group by state;
delete from covid_19_india where state= 'Unassigned';
delete from covid_19_india where state= 'Daman & Diu';
delete from covid_19_india where state= 'Cases being reassigned to states';

update covid_19_india set state= 'Dadra and Nagar Haveli and Daman and Diu'
where state= 'Dadra and Nagar Haveli';

update covid_19_india set state = 'bihar'
where state = 'Bihar****';

update covid_19_india set state= 'Madhya Pradesh'
where state = 'Madhya Pradesh***'

update covid_19_india set state = 'Maharashtra'
where state = 'Maharashtra***'


--DATA ANALYSIS

alter table covid_19_india add column active_case int;
update covid_19_india set active_case= (Confirmed-(Cured+deaths));

#total cases statewise
select state,max(confirmed) as total_case
from covid_19_india
group by state 
order by total_case desc;

#State-wise per day Confirmed Cases

select state,date,confirmed-lag(confirmed,1)over(partition by state order by date) as perday_confirmed
from covid_19_india;

-- State-wise per day Cured Cases

select date,state, cured-lag(cured,1) over (partition by state order by date) as perday_cured
from covid_19_india;

--State-wise per day Deaths Cases

select date,state, deaths-lag(deaths,1) over (partition by state order by date) as perday_death
from covid_19_india;

#State-Wise Maximum Active Cases and when it occurred 

with max_case as(
select date, state, max(active_case) over (partition by state) as max_activecase_inday,
dense_rank()over (partition by state order by active_case desc) as highest_active
from covid_19_india)
select date,state,max_activecase_inday
from max_case
where highest_active=1
order by max_activecase_inday desc;

--Highest active cases at any time for most states appeared in May 2021, except for Maharashtra & Delhi where peak occurred early in april 2021, 
----while for sikkim, manipur, mizoram the peak occurred in jun,aug 2021.


#Calculating the State-wise Mortality Rate

with cte as(
select state,max(deaths) as total_deaths,max(confirmed)as total_case
from covid_19_india
group by state)
select state, round((total_deaths/total_case)*100,2) as deathrate
from cte
order by deathrate desc;
-- Punjab has the highest Patient Mortality Rate in the country followed by Uttarakhandand Maharashtra,
--Dadra and Nagar Haveli and Daman and Diu, and mizoram are among the lowest.

#Calculating the State-wise Cured Ratio

with cte as (
select state,
max(cured) as total_cured,max(confirmed) as total_cases
from covid_19_india
group by state)
select state,round((total_cured/total_cases)*100,2) as cure_rate
from cte
order by cure_rate desc;

--Dadra and Nagar Haveli and Daman and Diu has the highest Patient Cured ratio in the country followed by lakshadweep and Rajasthan
--while Mizoram has the lowest

#Calculating day-wise highest PerDayConfirmed Cases

with cte as (
select *, confirmed-lag(confirmed,1)over(partition by state order by date) as perday_confirmed
from covid_19_india)
select dayname(date) as day,sum(perday_confirmed) as highst_case
from cte 
group by day
order by highst_case desc;
Maximum Total number of cases all over India arose on saturday

 ##Creating View to store data for later visualizations
 
create view covid19_india as
select *,confirmed-lag(confirmed,1,1)over(partition by state order by date) as perday_confirmed,
cured-lag(cured,1) over (partition by state order by date) as perday_cured,
deaths-lag(deaths,1) over (partition by state order by date) as perday_death
from covid_19_india;

















