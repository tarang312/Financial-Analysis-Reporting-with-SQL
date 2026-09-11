/*
=================
Create Database 
=================
*/

Use master;

Create Database finance; 

use finance;


--- successfully import all tables ---

select * from dbo.GL
select * from dbo.COA
select * from dbo.Territory
select * from dbo.Calendar


--- GL adjust the amount that value is in bracket that convert into the negative --- 

UPDATE dbo.GL
SET Amount = REPLACE(
                REPLACE(
                  REPLACE(TRIM(Amount), '(', '-'), 
                ')', ''), 
              ',', '')
WHERE Amount LIKE '%,%' 
   OR Amount LIKE '(%' 
   OR Amount LIKE '%)%';

select * from dbo.GL


--- filtering specific column and row ---

select date, Amount from dbo.GL

select * from dbo.GL where Account_key = 10 and Territory_key = 3 and Amount > 100000

select * from dbo.GL where date = '2019-06-30'

select * from dbo.GL where Details = 'Salaries'

select * from dbo.GL where Account_key > 200

select * from dbo.GL where Account_key < 200

select * from dbo.GL where Account_key <> 60

select * from dbo.GL where Account_key between 1 and 30


--- Time intelligence --- 

select *, year(date) as yr, month(date) as mo
from dbo.GL

select * from dbo.GL where year([date]) = 2020 and month([date]) = 8 

select * from dbo.GL where month([date]) = 8 

select * from dbo.Calendar

select [Date], 
datepart(year, [Date]) as 'Yr',
datepart(quarter, [Date]) as 'Qtr',
datepart(month, [Date]) as 'Mo',
datepart(Day, [Date]) as 'Day_of_month',
datepart(dayofyear, [Date]) as 'Day_of_year',
datepart(week, [Date]) as 'Week_no',
datepart(weekday,[Date]) as 'Week_day'
from dbo.Calendar

select * from dbo.GL where Account_key = 210 and datepart(week, [Date]) = 51


--- Sum & Group ---

select sum(Amount) from dbo.GL

SELECT Territory_key, Account_Key, SUM(Amount) AS Amo
FROM dbo.GL
WHERE Account_Key = 210
GROUP BY Territory_key, Account_Key;


--- SubQuery & PIVOT ---

select year, sum(Amount) as Total_Amo from
(select year(Date) as year, Amount from dbo.GL) as Table_1
Group by year
Order by year

select [2018], [2019], [2020] from
(select year(Date) as Year , Amount from dbo.GL) as Table_1
Pivot (sum(Amount) for Year in ([2018], [2019], [2020])) as Table_2

Select Account_Key, [2018], [2019], [2020] from
(select Account_Key, Year(Date) as year, Amount from dbo.GL) as Table_1
Pivot (sum(Amount) for Year in ([2018], [2019], [2020])) as Table_2
Order by Account_Key

Create view mysummary as 
Select Account_Key, [2018], [2019], [2020] from
(select Account_Key, Year(Date) as year, Amount from dbo.GL) as Table_1
Pivot (sum(Amount) for Year in ([2018], [2019], [2020])) as Table_2

select * from mysummary where Account_Key = 121


--- Joining Table --- 

select * from dbo.GL
join dbo.COA on dbo.GL.Account_Key = dbo.COA.Account_Key

select * from dbo.GL
join dbo.Territory on dbo.GL.Territory_key = dbo.Territory.Territory_key

select Date, dbo.GL.Territory_key, Amount, country from dbo.GL
join dbo.Territory on dbo.GL.Territory_key = dbo.Territory.Territory_key

select Date, Amount,Report, SubAccount
from dbo.GL
join dbo.COA on dbo.GL.Account_Key = dbo.COA.Account_Key


--- Right & Left join ---

select Date, dbo.GL.Territory_key, Amount, country from dbo.GL
join dbo.Territory on dbo.GL.Territory_key = dbo.Territory.Territory_key

select Date, dbo.GL.Territory_key, Amount, country from dbo.GL
right join dbo.Territory on dbo.GL.Territory_key = dbo.Territory.Territory_key

select Date, dbo.GL.Territory_key, Amount, country from dbo.GL
Left join dbo.Territory on dbo.GL.Territory_key = dbo.Territory.Territory_key

select Date, dbo.GL.Territory_key, Amount, country from dbo.GL
full join dbo.Territory on dbo.GL.Territory_key = dbo.Territory.Territory_key

select *, Country, Account from dbo.GL
join dbo.Territory on dbo.GL.Territory_key = dbo.Territory.Territory_key
join dbo.COA on dbo.GL.Account_Key = dbo.COA.Account_Key
join dbo.Calendar on dbo.GL.[Date] = dbo.Calendar.[Date]


--- Formatting Number -&- Perparing P&L -- 

select dbo.GL.Account_Key, Report, Class, Account, sum(Amount) as Amo from dbo.GL
join dbo.COA on dbo.GL.Account_Key = dbo.COA.Account_Key
where Report = 'profit and loss' and [Date] between '2020-03-01' and '2020-03-30'
group by Report, Class, Account, dbo.GL.Account_Key
order by dbo.GL.Account_Key

-------------

Select Report, Class, Account, [2018], [2019], [2020]
FROM (
Select GL.Account_key, Report, Class, Account, YEAR(Date) as Year, SUM(Amount) as Amount from GL
JOIN COA ON GL.Account_key = COA.Account_key
Where Report = 'Profit and Loss'
Group by Report, Class, Account, GL.Account_key, YEAR(Date)) as Table1
PIVOT
( SUM(Amount) FOR Year IN ([2018], [2019], [2020])) as Table2

---------------

Select Report, Class, Account, FORMAT([2018], 'N0') as '2018', FORMAT([2019], 'N0') as '2019', FORMAT([2020], 'N0') as '2020'
FROM (
Select GL.Account_key, Report, Class, Account, YEAR(Date) as Year, SUM(Amount) as Amount from GL
JOIN COA ON GL.Account_key = COA.Account_key
Where Report = 'Profit and Loss'
Group by Report, Class, Account, GL.Account_key, YEAR(Date)) as Table1
PIVOT
( SUM(Amount) FOR Year IN ([2018], [2019], [2020])) as Table2

-------------

Select Country, Report, Class, Account, FORMAT([2018], 'N0') as '2018', FORMAT([2019], 'N0') as '2019', FORMAT([2020], 'N0') as '2020'
FROM (
Select Country, GL.Account_key, Report, Class, Account, YEAR(Date) as Year, SUM(Amount) as Amount from GL
JOIN COA ON GL.Account_key = COA.Account_key
JOIN Territory ON GL.Territory_key = Territory.Territory_key
Where Report = 'Profit and Loss' and Country = 'France'
Group by Country, Report, Class, Account, GL.Account_key, YEAR(Date)
) as Table1
PIVOT
( SUM(Amount) FOR Year IN ([2018], [2019], [2020])) as Table2
