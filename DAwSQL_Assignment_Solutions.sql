-- DAwSQL ASSIGNMENT SOLUTIONS 

-- ASSIGNMENT - 1

CREATE TABLE transaction_logs(
    Sender_ID INT NOT NULL,
    Receiver_ID INT NOT NULL,
    Amount INT,
    Transaction_Date DATE NOT NULL
);

INSERT INTO transaction_logs (Sender_ID, Receiver_ID, Amount, Transaction_Date)
VALUES (55,22,500,'2021-05-18');

INSERT INTO transaction_logs (Sender_ID, Receiver_ID, Amount, Transaction_Date)
VALUES (11,33,350,'2021-05-19');

INSERT INTO transaction_logs (Sender_ID, Receiver_ID, Amount, Transaction_Date)
VALUES (22,11,650,'2021-05-19');

INSERT INTO transaction_logs (Sender_ID, Receiver_ID, Amount, Transaction_Date)
VALUES (22,33,900,'2021-05-20');

INSERT INTO transaction_logs (Sender_ID, Receiver_ID, Amount, Transaction_Date)
VALUES (33,11,500,'2021-05-21');

INSERT INTO transaction_logs (Sender_ID, Receiver_ID, Amount, Transaction_Date)
VALUES (33,22,750,'2021-05-21');

INSERT INTO transaction_logs (Sender_ID, Receiver_ID, Amount, Transaction_Date)
VALUES (11,44,300,'2021-05-22');


SELECT COALESCE(A.Sender_ID, B.Receiver_ID) AS Account_Name, COALESCE(A.Debit, 0)+COALESCE(B.Credit, 0) 
AS Net_Change
FROM
(SELECT Sender_id, SUM(0 - Amount) AS Debit
FROM transaction_logs
GROUP BY Sender_id) AS A FULL OUTER JOIN
(SELECT Receiver_ID, SUM(Amount) AS Credit
FROM transaction_logs
GROUP BY Receiver_ID) AS B ON A.Sender_ID = B.Receiver_ID
ORDER BY Net_Change DESC;

---

-- Solution with CTE

with ttt
as
(
    select sender_id, sum(0-amount) as debit
    from transaction_logs
    group by sender_id
),
ccc as
(
    select receiver_id, sum(amount) as credit
    from transaction_logs
    group by receiver_id
)

select coalesce(ttt.sender_id, ccc.receiver_id) as account_id, coalesce(ttt.debit,0)+coalesce(ccc.credit,0) as toplam
from ttt full outer join ccc on ttt.sender_id=ccc.receiver_id

--------------------------

-- ASSIGNMENT - 2

CREATE TABLE actions (
    Visitor_ID INTEGER PRIMARY KEY IDENTITY (FOR SQLITE AUTOINCREMENT),
    Adv_Type VARCHAR (40),
    Action VARCHAR (40)
);

INSERT INTO actions (Adv_Type, Action)
VALUES ('A', 'Left'), ('A', 'Order'), ('B', 'Left'), ('A', 'Order'), ('A', 'Review'), 
        ('A', 'Left'), ('B', 'Left'), ('B', 'Order'), ('B', 'Review'), ('A', 'Review')

SELECT Adv_Type, ROUND(CAST(SUM(Action_V) AS REAL) / COUNT(Action), 2) AS Conversion_Rate
FROM (
SELECT Visitor_ID, Adv_Type, Action, 
CASE
WHEN Action = 'Order' THEN 1
ELSE 0
END AS Action_V
FROM actions) AS new
GROUP BY Adv_Type

-- Question - 1

-- Find customers who ordered both Electric Bikes, Comfort Bicycles and Children Bicycles in the same order.

SELECT first_name, last_name
FROM sale.customer
WHERE customer_id IN 
    (SELECT customer_id
    FROM sale.orders
    WHERE order_id IN
        (SELECT new_table.order_id 
        FROM 
        (SELECT DISTINCT oo.order_id, c.category_id
        FROM product.category c JOIN product.product p ON c.category_id=p.category_id
        JOIN sale.order_item o ON o.product_id=p.product_id JOIN sale.orders oo ON oo.order_id=o.order_id 
        JOIN sale.customer s ON oo.customer_id=s.customer_id
        WHERE c.category_name IN ('Electric Bikes', 'Comfort Bicycles', 'Children Bicycles')) AS new_table
GROUP BY new_table.order_id
HAVING count(new_table.category_id) = 3))
ORDER BY last_name

-- With CTE

WITH A
AS (
    SELECT category_id, category_name
    FROM product.category
    WHERE category_name IN ('Electric Bikes', 'Comfort Bicycles', 'Children Bicycles')
),
B 
AS (
    SELECT product_id, category_id
    FROM product.product
),
C 
AS (
    SELECT order_id, product_id
    FROM sale.order_item
),
D 
AS (
    SELECT customer_id, order_id
    FROM sale. orders
)
SELECT first_name, last_name
FROM sale.customer
WHERE customer_id IN
    (SELECT customer_id
    FROM sale.orders
    WHERE order_id IN
        (SELECT E.order_id
        FROM
        (SELECT DISTINCT C.order_id, A.category_name
        FROM D JOIN C ON D.order_id=C.order_id JOIN B ON C.product_id=B.product_id
        JOIN A ON B.category_id=A.category_id) AS E
        GROUP BY E.order_id
        HAVING count(E.order_id) = 3))

-- Question - 2

-- What is the sales quantity of product according to the brands and sort them highest-lowest?

select b.brand_name, sum(o.quantity) as toplam
from product.brand b join product.product p on b.brand_id=p.brand_id
join sale.order_item o on o.product_id=p.product_id
group by b.brand_name
order by toplam desc

-- Question - 3

-- Select the top 5 most expensive products

select distinct top 5 p.product_name, o.list_price
from product.product p join sale.order_item o on p.product_id=o.product_id
order by o.list_price desc

-- Question - 4

-- What are the categories that each brand has?

select distinct b.brand_name, c.category_name
from product.brand b join product.product p on p.brand_id=b.brand_id
join product.category c on p.category_id=c.category_id

-- Question - 5

-- Select the avg prices according to brands and categories

select b.brand_name, c.category_name, avg(o.list_price) as average
from product.brand b join product.product p on p.brand_id=b.brand_id
join product.category c on p.category_id=c.category_id 
join sale.order_item o on o.product_id=p.product_id
group by b.brand_name, c.category_name
order by average

-- Question - 6

-- Select the annual amount of product produced according to brands

select b.brand_name, p.model_year, sum(o.quantity) as toplam
from product.brand b join product.product p on b.brand_id=p.brand_id 
join sale.order_item o on o.product_id=p.product_id
group by b.brand_name, p.model_year
order by b.brand_name, model_year

---

select b.brand_name, p.model_year, sum(o.quantity * o.list_price * (1 - o.discount)) as toplam
from product.brand b join product.product p on b.brand_id=p.brand_id 
join sale.order_item o on o.product_id=p.product_id
group by b.brand_name, p.model_year
order by b.brand_name, model_year

-- Question - 7

-- Select the store which has the most sales quantity in 2018

select top 1 so.store_id, s.store_name, sum(o.quantity) as toplam
from sale.order_item o join sale.orders so on o.order_id=so.order_id 
join sale.store s on so.store_id=s.store_id
where so.order_date between '2018-01-01' and '2018-12-31'
group by so.store_id, s.store_name
order by toplam desc

-- Question - 8

-- Select the store which has the most sales amount in 2018

select top 1 so.store_id, s.store_name, sum(o.quantity * (1 - o.discount) * o.list_price) as amount
from sale.order_item o join sale.orders so on o.order_id=so.order_id 
join sale.store s on so.store_id=s.store_id
where so.order_date between '2018-01-01' and '2018-12-31'
group by so.store_id, s.store_name
order by amount desc

-- Question - 9

-- Select the personnel which has the most sales amount in 2018

select *
from sale.staff
where staff_id = 
    (select staff_id
    from sale.orders
    where order_id =
        (select new.order_id
        from
        (select top 1 oo.order_id, sum(oo.list_price * (1 - oo.discount) * oo.quantity) as amount
        from sale.staff s join sale.orders o on s.staff_id=o.staff_id
        join sale.order_item oo on oo.order_id=o.order_id
        where o.order_date between '2018-01-01' and '2018-12-31'
        group by oo.order_id
        order by amount desc) as new))
