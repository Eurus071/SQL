USE master;
GO

declare @InputDate date='2025-03-14'

;with cte as(
   SELECT DATEFROMPARTS(YEAR(@InputDate), MONTH(@InputDate), 1) as [date],
   DATENAME(weekday, DATEFROMPARTS(YEAR(@InputDate), MONTH(@InputDate), 1)) as weekname,
   DATEPART(weekday, DATEFROMPARTS(YEAR(@InputDate), MONTH(@InputDate), 1)) as weeknum,
   1 as weeknumber
   
 UNION all

 SELECT DATEADD (day, 1, [date]),
DATENAME (weekday, DATEADD(day, 1, [date])),
DATEPART(weekday, DATEADD (day, 1, [date])), 
case
 WHEN DATEPART(weekday, DATEADD (day, 1, [date]))> weeknum then weeknumber else weeknumber+1
 
 
END


FROM cte
WHERE [date]<EOMONTH(@Inputdate)

)
select
 MAX(case when weekname='Sunday' then day(date) end) as Sunday,
 MAX(case when weekname='Monday' then day(date) end) as Monday,
 MAX(case when weekname='Tuesday' then day(date) end) as Tuesday,
 MAX(case when weekname='Wednesday' then day(date) end) as Wednesday,
 MAX(case when weekname='Thursday' then day(date) end) as Thursday,
 MAX(case when weekname='Friday' then day(date) end) as Friday,
 MAX(case when weekname='Saturday' then day(date) end) as Saturday
FROM
cte
GROUP BY weeknumber;
