-- SQL SERVER NOTES

-- Pivot Operations

select *
from
(select top 100 order_id, list_price
from sale.order_item) as yeni
pivot (
    avg(list_price)
    for order_id in ([1],[2],[3],[4])
 ) pivottable

---

select * from
(select product_id, model_year, list_price
from product.product) as yeni
pivot (
    avg(list_price)
    for model_year in ([2018], [2019], [2020], [2021])
) as pivottable

---

select category, model_year, sum(total_sales_price) as total
from sale.sales_summary
group by category, model_year;

select * from
(
select category, model_year, total_sales_price
from sale.sales_summary
) as A
PIVOT (
    sum(total_sales_price)
    for model_year in ([2018], [2019], [2020])
) as pivottable

---

set @r1=0, @r2=0, @r3=0, @r4=0;
select min(Doctor), min(Professor), min(Singer), min(Actor)
from(
  select case when Occupation='Doctor' then (@r1:=@r1+1)
            when Occupation='Professor' then (@r2:=@r2+1)
            when Occupation='Singer' then (@r3:=@r3+1)
            when Occupation='Actor' then (@r4:=@r4+1) end as RowNumber,
    case when Occupation='Doctor' then Name end as Doctor,
    case when Occupation='Professor' then Name end as Professor,
    case when Occupation='Singer' then Name end as Singer,
    case when Occupation='Actor' then Name end as Actor
  from OCCUPATIONS
  order by Name
) Temp
group by RowNumber

---

select *
from
(select top 100 product_id, product_name, list_price
from product.product) as yeni
pivot (
    count(list_price)
    for product_id in ([1],[2],[3],[4], [5], [6], [7], [8], [9], [10])
) pivottable

---------------------

-- QUOTENAME(column name, ()) komutu belirttiğimiz column [] veya istenilen bir parantezin icine alır. 
-- Default, yani hicbirsey yazilmazsa [] olur.

---------------------

-- ROLLUP Ornegi

select model_year, avg(list_price) as ort
from product.product
group by model_year with rollup
order by model_year

---

select b.brand_name, c.category_name, p.model_year, sum((p.list_price * (1 - o.discount)) * o.quantity) as sayi
from product.brand b join product.product p on b.brand_id = p.brand_id join product.category c on p.category_id = c.category_id
join sale.order_item o on p.product_id = o.product_id
group by
    rollup(b.brand_name,  c.category_name, p.model_year)
order by b.brand_name,  c.category_name, p.model_year

---

select brand, category, model_year, sum(total_sales_price) as total_price
from sale.sales_summary
group BY
    rollup(brand, category, model_year);

--------------------------

-- SELECT INTO

SELECT	C.brand_name as Brand, D.category_name as Category, B.model_year as Model_Year,
		ROUND (SUM (A.quantity * A.list_price * (1 - A.discount)), 0) total_sales_price
INTO	sale.sales_summary
FROM	sale.order_item A, product.product B, product.brand C, product.category D
WHERE	A.product_id = B.product_id
AND		B.brand_id = C.brand_id
AND		B.category_id = D.category_id
GROUP BY
		C.brand_name, D.category_name, B.model_year

--------------------------

-- GROUPING SETS

select b.brand_name,  c.category_name, p.model_year, sum((p.list_price * (1 - o.discount)) * o.quantity) as sayi
from product.brand b join product.product p on b.brand_id = p.brand_id join product.category c on p.category_id = c.category_id
join sale.order_item o on p.product_id = o.product_id
group BY
    grouping sets (
        (b.brand_name,  c.category_name, p.model_year),
        (b.brand_name,  c.category_name),
        (c.category_name),
        (p.model_year),
        ()
    )
order by sayi desc;

-------------------------

-- CUBE

select brand, category, model_year, sum(total_sales_price) as total_price
from sale.sales_summary
group BY
    cube(brand, category, model_year)
order by brand, category, model_year;

--------------------------

-- Correlated Subqueries

SELECT c.countryname, f.filmname, f.filmruntimeminutes
FROM tb1film AS f INNER JOIN tb1country AS c ON c.countryid=f.filmcountryid
WHERE f.filmruntimeminutes >
    (SELECT AVG(filmruntimeminutes)
    FROM tb1film AS g
    WHERE g.filmcountryid=f.filmcountryid)

---

SELECT YEAR(f.filmreleasedate) as y, f.filmname, f.filmruntimeminutes
FROM tb1film AS f
WHERE f.filmruntimeminutes >
    (SELECT AVG(filmruntimeminutes)
    FROM tb1film AS g
    WHERE YEAR(g.filmreleasedate)=YEAR(f.filmreleasedate)
ORDER BY y

--------------------------

-- Common Table Expressions (CTEs)

WITH temp_table (avg_salary) AS
    (SELECT AVG(salary)
    FROM employees)
    SELECT salary
    FROM employees, temp_table
    WHERE employees.salary > temp_table.avg_salary;

---

WITH temp_table AS 
(
SELECT emp_id, hire_date, term_date
FROM employees
WHERE job_title = "Data Scientist"
)
SELECT d.dept_name, MIN(t1.hire_date) as min_hire_date, MAX(t2.term_date) as max_term_date
FROM departments as d
LEFT JOIN temp_table as t1
ON d.emp_id = t1.emp_id
LEFT JOIN temp_table as t2
ON d.emp_id = t2.emp_id
GROUP BY 1

---

--Recursive CTE
with ctetable
as
( select 0 as num --anchor record (tablo ilk calistirildiginda bu satir calisir ve num olarak 0 alinir)
union all
select num + 1 from ctetable --recursive record (ilk calismadan sonraki tum recurse'larda bu 
#satir calisir ve num +1 olur)
where num < 10 --recursive record'da bir where olmali, yoksa sonsuz dongu olusur
)
select * from ctetable

---

with emp
as
(
    select employee_number, employee_name, manager
    from employee
    where manager is null
union all
    select e.employee_number, e.employee_name, e.manager
    from emp join employee e on emp.employee_number=e.manager
)
select * from emp

---

with emps
as
(
    select employeeid, firstname, lastname, ReportsTo, 1 as lvl,
    cast(',' + cast(employeeid as varchar) + ',' as varchar(250)) empconcat
    from employees
    where reportsto is NULL
union ALL
    select e.employeeid, e.firstname, e.lastname, e.ReportsTo, lvl + 1 as lvl,
    cast(emps.empconcat + ',' + cast(e.employeeid as varchar) + ',' as varchar(250))
    from emps join employees e on emps.employeeid=e.ReportsTo
)
select * from emps

---

with last_cust 
as 
(
    select max(o.order_date) as aaa
    from sale.customer c join sale.orders o on c.customer_id=o.customer_id
    where first_name = 'Sharyn' and last_name = 'Hopkins'
)
select a.first_name, a.last_name, b.order_date, a.city
from sale.customer a join sale.orders b on a.customer_id=b.customer_id
where b.order_date < (select * from last_cust) and a.city = 'San Diego'

---

with new_query as 
(
    select o.order_date
    from sale.orders o join sale.customer c on o.customer_id=c.customer_id
    where c.first_name = 'Abby' and c.last_name = 'Parks'
)
select a.first_name, a.last_name, b.order_date
from sale.customer a join sale.orders b on a.customer_id=b.customer_id
where b.order_date in (select * from new_query)

---

with ccc 
as
(select 0 as num
union all
select num + 2
from ccc
where num < 9
)
select * from ccc

-----------------------

-- COLLATION

--Bazi arkadaslar goruyorum sorguda ‘Jane’ yerine ‘jane’ kullanmis. 
--Default olarak SQL Server case-insensitive oldugu icin problem olmuyor. 
--Ama database olustururken istersek ‘COLLATION’ ile case-sensitive bir database olusturabiliriz.

----------------------

-- ALL

select product_name, model_year, list_price
from product.product
where list_price > all
(select p.list_price
from product.product p join product.category c on p.category_id=c.category_id
where c.category_name='Electric Bikes') and model_year = 2020

----------------------

-- ANY

select product_name, model_year, list_price
from product.product
where list_price > any
(select p.list_price
from product.product p join product.category c on p.category_id=c.category_id
where c.category_name='Electric Bikes') and model_year = 2020

----------------------

-- EXISTS, NOT EXISTS

select c.first_name, c.last_name, o.order_date
from sale.orders o join sale.customer c on o.customer_id=c.customer_id
where exists (select 1 from sale.orders where customer_id = (select customer_id 
from sale.customer where first_name='Abby' and last_name='Parks'))
-- burada Abby Parks diye bir musteri var mi yok mu, varsa ustteki query calisiyor

---

select c.first_name, c.last_name, o.order_date
from sale.orders o join sale.customer c on o.customer_id=c.customer_id
where not exists (select 1 from sale.orders where customer_id = (select customer_id 
from sale.customer where first_name='Abbyy' and last_name='Parks'))
-- Abbyy isimli bir customer olmadigi icin yukaridaki query yine calisiyor

---------------------

-- UNION ALL, UNION, INTERCEPT, EXCEPT

select last_name
from sale.customer
where city = 'Monroe'
union all 
select last_name
from sale.customer
where city = 'Sacramento'
order by last_name

-- intersect soz konusu oldugunda soz konusu sutunlarin distinct olan ve ayni olan row'lar gelir

---

select A.brand_id, B. brand_name
from
(select brand_id
from product.product
where model_year = 2018
intersect
select brand_id
from product.product
where model_year = 2019) as A join product.brand B on A.brand_id=B.brand_id

---

select first_name, last_name
from sale.customer
where customer_id in (
select customer_id
from sale.orders
where order_date between '2018-01-01' and '2018-12-31'
intersect
select customer_id
from sale.orders
where order_date between '2019-01-01' and '2019-12-31'
intersect
select customer_id
from sale.orders
where order_date between '2020-01-01' and '2020-12-31')

---------------------------

-- DATE Functions

CREATE TABLE t_date_time (
    A_time time,
    A_date date,
    A_smalldatetime smalldatetime,
    A_datetime datetime,
    A_datetime2 datetime2,
    A_datetimeoffset datetimeoffset
    )

select * from t_date_time

select getdate()

Insert into t_date_time 
values (getdate(), getdate(), getdate(), getdate(), getdate(), getdate())

select getdate();
select convert(varchar, getdate(), 6);

select convert(date, '25 Oct 21', 6);

---

-- Functions for return date or time parts

select a_date from t_date_time

SELECT  A_date,
        DATENAME(DW, A_date) [DAY],
        DAY (A_date) [DAY2],
        MONTH(A_date),
        YEAR (A_date),
        A_time,
        DATEPART (NANOSECOND, A_time),
        DATEPART (MONTH, A_date)
FROM    t_date_time

---

select a_time, a_date, datediff(minute, a_time, getdate()),
datediff(week, a_date, '2021-11-30')
from t_date_time

---

select getdate(), dateadd(minute, 10, getdate()) burada mevcut zaman 10 dakika ekliyoruz
select eomonth(getdate()) burada su an buludugumuz ayin son gununu bulduruyoruz
select eomonth(getdate(), 2) burada su an bulundugumuz aya 2 ay eklenmis ayin son gununu buluyor.

---

select eomonth(getdate()), eomonth(getdate(), 2)

select getdate(), dateadd(day, -10, getdate())

SELECT ORDER_DATE,
        DATEADD(YEAR, 5, order_date) YEAR_ADD,
        DATEADD(DAY, 10 , order_date) DAY_ADD
FROM sale.orders

---

isdate(expression) - return boolean doner (True ise 1 false ise 0)
select isdate('2012-12-31'), isdate('26-12-2012')

---

select SUM(case when datename(weekday, T1.order_date) = 'Monday' then 1 else 0 end) MONDAY,
SUM(case when datename(weekday, T1.order_date) = 'Tuesday' then 1 else 0 end) TUESDAY,
SUM(case when datename(weekday, T1.order_date) = 'Wednesday' then 1 else 0 end) WEDNESDAY,
SUM(case when datename(weekday, T1.order_date) = 'Thursday' then 1 else 0 end) THURSDAY,
SUM(case when datename(weekday, T1.order_date) = 'Friday' then 1 else 0 end) FRIDAY,
SUM(case when datename(weekday, T1.order_date) = 'Saturday' then 1 else 0 end) SATURDAY,
SUM(case when datename(weekday, T1.order_date) = 'Sunday' then 1 else 0 end) SUNDAY
from
(select *, datediff(day, order_date, shipped_date) as gun
from sale.orders
where datediff(day, order_date, shipped_date) > 2) as T1

------------------------

-- String Functions

select len('clarusway')
select charindex('c', 'clarusway')
select patindex('%ca%', 'claruswcay')
select left('character', 3)
select right('character', 3)
select substring('character', 2, 3)
select substring('character', -2, 4)
select lower('CLARUSWAY')
select upper(substring('clarusway', 1, 1)) + substring('clarusway', 2, len('clarusway'))
select * from string_split('clarusway, mehmet, okula, gitti', ',')
select * from string_split('clarusway mehmet ali okula gitti', ' ')
select trim('123' from '123clarusway12')
--trim(removed_characters, input)
--ltrim(input) ltrim ve rtrim sadece bosluklari
--rtrim(input)

-----------------------

-- ROW_NUMBER, RANK, DENSE_RANK, CUME_DIST, PERCENT_RANK, NTILE

select list_price,
row_number() over(order by list_price) as roww,
rank() over(order by list_price) as rankk,
dense_rank() over(order by list_price) as densee,
cume_dist() over(order by list_price) as cumee,
percent_rank() over(order by list_price) as percentt, -- bulunulan deger oncekilerin belirtilen oranindan buyuk
ntile(16) over(order by list_price) as ntill -- toplam satirlari 16'ya boluyor ve ona gore deger atiyor
from product.product

---

select category_id, list_price,
row_number () over(partition by category_id order by list_price) as [Row_Num],
rank () over(partition by category_id order by list_price) as [Rank_Num],
dense_rank () over(partition by category_id order by list_price) as [Rank_Num]
from product.product

---

select t.customer_id, cume_dist() over(order by t.cumu)
from
	(select o.customer_id, 
	sum(oo.quantity) as cumu
	from sale.customer c join sale.orders o on c.customer_id=o.customer_id
	join sale.order_item oo on oo.order_id=o.order_id
	group by o.customer_id) as t

---

select t.customer_id, ntile(5) over(order by t.cumu)
from
    (select o.customer_id, 
    sum(oo.quantity) as cumu
    from sale.customer c join sale.orders o on c.customer_id=o.customer_id
    join sale.order_item oo on oo.order_id=o.order_id
    group by o.customer_id) as t
order by t.customer_id

