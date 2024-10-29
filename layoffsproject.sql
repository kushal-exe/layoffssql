                                             --SQL Data exploratory project on recent layoffs--
											 
--1.show total layoffs in each industry(sector).

select industry,sum(total_laid_off)
from layoff_staging02
group by industry
having sum(total_laid_off) is not null
order by 2 desc;

--2.show maximum no layoffs occured in "other" industry.

select industry,max(total_laid_off)
from layoff_staging02
where industry='Other'
group by industry;

--3.show maximum percentage and total laid off.

select max(percentage),max(total_laid_off)
from layoff_staging02;

--4.query to find out records with 100 percent layoff.
select *
from layoff_staging02
where percentage =1
and total_laid_off is not null
order by total_laid_off desc;

--5.pivot the table based on level of fund raised from low, moderate and high.

select funds_raised_millions,(case when funds_raised_millions <=200 then 'Low'
when funds_raised_millions between 201 and 500 then 'Moderate'
when funds_raised_millions is null then 'No funds raised'
else 'High'
end ) as Level_of_fund_raised
from layoff_staging02;

--6.(a)pivot the table based on count of fund raised from low, moderate to high.
select  count( case when funds_raised_millions<=200 THEN funds_raised_millions end) as Low_category,
count(case when funds_raised_millions between 201 and 500 then funds_raised_millions end) as Mod_category,
count(case when funds_raised_millions>500 then funds_raised_millions end) as HIgh_category
from layoff_staging02;

--(b)same operation with use of cte.
with cte as (select *,(case when funds_raised_millions <=200 then 'Low'
when funds_raised_millions between 201 and 500 then 'Moderate'
when funds_raised_millions is null then 'No funds raised'
else 'High'
end ) as Level_of_fund_raised
from layoff_staging02)


select Level_of_fund_raised, count(Level_of_fund_raised)
from cte
group by level_of_fund_raised;

--7.adding a column based on extracted year from date column.

alter table layoff_staging02
add column year_of_layoff int;

update layoff_staging02
set year_of_layoff = extract(year from date_of_layoff)

--8.finding out data from layst years.

select * from layoff_staging02
where  year_of_layoff >= extract(year from current_date)-3;

--9.showing companies with relation to sum of laid off from maximum to minimum.

select company , sum(total_laid_off)
from layoff_staging02
where total_laid_off is not null
group by company
order by 2 
;

--10.showing running total of total laid off happened every month.

with cte as (select left(date_of_layoff::text, 7) as monthly, sum (total_laid_off) laid_off
from layoff_staging02
where left(date_of_layoff::text, 7) is not null
group by 1)

select monthly , sum(laid_off) over (order by monthly) running_total
from cte;

--11.data of companies with sum of layoff every year ordered by maximum layoff.

select company,year_of_layoff, sum(total_laid_off) 
from layoff_staging02
group by company,year_of_layoff
having sum(total_laid_off) is not null
order by 3 desc;

--12.query the data of the years where five or less than 5 different companies did layoff 

with cte as (select company ,year_of_layoff, sum(total_laid_off) as laid_off
from layoff_staging02
where total_laid_off is not null and
year_of_layoff is not null
group by company,year_of_layoff
order by company asc),
cte2 as (
select company, year_of_layoff, laid_off,
dense_rank() over( partition by year_of_layoff order by laid_off desc ) as ranking
from cte
order by year_of_layoff )

select * from cte2
where ranking <=5;

--13.find out the avergage of percentage as per the stage of layoffs
select stage, ROUND(AVG(percentage),2)
from layoff_staging02
group by stage
order by 2 desc;






