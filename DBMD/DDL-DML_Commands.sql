--------------------------------------------------

CREATE DATABASE LibraryDatabase;

USE LibraryDatabase;

CREATE SCHEMA Book;

CREATE SCHEMA Person;

-- create Book.Author Table

CREATE TABLE Book.author (
    author_id int,
    author_firstname nvarchar(50) not null,
    author_lastname nvarchar(50) not null
);

-- create Book.publisher Table

CREATE TABLE Book.publisher (
    publisher_id int primary key identity (1,1) not null,
    publisher_name nvarchar(100) null
);

-- create Book.book Table

CREATE TABLE Book.book (
    book_id int primary key not null,
    book_name nvarchar(50) not null,
    author_id int not null,
    publisher_id int not null
);

-- create Person.person Table

CREATE TABLE Person.person (
    ssn bigint primary key not null,
    person_firstname nvarchar(50) null,
    person_lastname nvarchar(50) null
);

-- create Person.person_mail Table 

CREATE TABLE Person.person_mail (
    mail_id int primary key identity (1,1),
    mail nvarchar(max) not null,
    ssn bigint unique not null
);

-- create Person.person_phone Table

CREATE TABLE Person.person_phone (
    phone_number bigint primary key not null,
    ssn bigint not null
);

-- create Person.loan Table 

CREATE TABLE Person.loan (
    ssn bigint not null,
    book_id int not null, 
    primary key (ssn, book_id)
);

-------------------
-- INSERT 

INSERT INTO Person.person (ssn, person_firstname, person_lastname) VALUES (75056659595, 'Zehra', 'Tekin');
-- eger insert into icinde herhangi bir sutun belirtmezsem tum sutunlara veri atanacak seklinde algilar, bu sebeple values bolumunde tum sutunlar icin veri girilmesi gereklidir.

INSERT INTO Person.person_mail (mail, ssn) 
VALUES ('zehtek@gmail.com', 750),
        ('meyet@gmail.com', 150),
        ('metsak@gmail.com', 355);

SELECT * FROM person.person_mail

--------------------
-- SELECT INTO

SELECT * FROM person.person

SELECT * INTO person.person_2 FROM person.person
-- normalde person.person_2 tablomuz yoktu ancak select into ile person tablosundaki verileri cekerek person_2 tablosunu da olusturmus ve ayni verileri icine kaydetmis olduk.
SELECT * FROM person.person_2

--------------------
-- INSERT INTO SELECT 

INSERT INTO person.person VALUES (88232556264, 'Metin', 'Sakin')
SELECT * FROM person.person

INSERT INTO person.person_2 (ssn, person_firstname, person_lastname)
SELECT *
FROM person.person 
WHERE person_firstname LIKE '%M%'

SELECT * FROM person.person_2

--------------------
-- INSERT INTO DEFAULT VALUES

SELECT * FROM book.publisher

INSERT book.publisher 
DEFAULT VALUES
-- Bu komutu calistirdigimizda tabloyu olustururken default olarak sutunlara hangi degerlerin atanmasini istediysek o sekilde doldurur.

--------------------
-- UPDATE

select * from person.person_2
select * from person.person


UPDATE person.person_2 
SET person_lastname = 'default'

UPDATE person.person_2 
SET person_lastname = 'clarusway'
WHERE person_firstname = 'Metin'

UPDATE person.person
SET person_lastname = B.person_lastname 
FROM person.person A, person.person_2 B 
WHERE A.ssn=B.ssn AND B.ssn=88232556264 

UPDATE person.person
SET person_firstname =  (select person_firstname from person.person_2
where ssn=88232556264)

-----------------------
-- DELETE

insert book.publisher values 
('is bankasi kultur'),
('can yayincilik'),
('iletisim yayincilik')


delete from book.publisher
-- tum degerleri siler

delete from book.publisher where publisher_name is null

select * from book.publisher

insert book.publisher values 
('is bankasi kultur')
-- yeni eklenen deger tum degerler delete ile silinmis olsa bile kaldigi index'ten deger 
-- alir.

-----------------

DROP TABLE person.person_2;

truncate table person.person_mail;
truncate table person.person;
truncate table book.publisher;
-- tum verileri siler, yapi ayni kalir.

-----------------------
--- book.author table

ALTER TABLE book.author add constraint pk_author primary key (author_id)
-- burada hata verir cunku author_id null deger alabilir

alter table book.author alter column author_id int not null 
-- yukaridaki durumu duzeltmek icin author_id sutununun yapisinda degisiklik yapiyoruz.
-- bunu calistirip yukaridakini sonra calistirdigimizda author_id primary key olarak atanir.


--- book.book table

ALTER TABLE book.book add constraint fk_author foreign key (author_id) references book.author (author_id)

ALTER TABLE book.book add constraint fk_publisher foreign key (publisher_id) references book.publisher (publisher_id)

--- person.mail

ALTER TABLE person.person_mail add constraint fk_person4 foreign key (ssn) references person.person (ssn)

--- person.phone

ALTER TABLE person.person_phone add constraint fk_person2 foreign key (ssn) references person.person (ssn)

--- person.loan

ALTER TABLE person.loan add constraint fk_person foreign key (ssn) references person.person (ssn)
on update no action 
on delete no action

ALTER TABLE person.loan add constraint fk_book foreign key (book_id) references book.book (book_id)
on update no action 
on delete cascade


--=========================================================
--==========================================================
---------- DATA DEFINITION LANGUAGE (DDL) ------------
-- To Create a Table:

USE SW;
CREATE TABLE EMPLOYEES
(EmployeeNo CHAR(10) NOT NULL UNIQUE,
DepartmentName CHAR(30) NOT NULL DEFAULT “Human Resources”,
FirstName CHAR(25) NOT NULL,
LastName CHAR(25) NOT NULL,
Category CHAR(20) NOT NULL,
HourlyRate CURRENCY NOT NULL,
TimeCard LOGICAL NOT NULL,
HourlySalaried CHAR(1)NOT NULL,
EmpType CHAR(1) NOT NULL,
Terminated LOGICAL NOT NULL,
ExemptCode CHAR(2) NOT NULL,
Supervisor LOGICAL NOT NULL,
SupervisorName CHAR(50) NOT NULL,
BirthDate DATE NOT NULL,
CollegeDegree CHAR(5) NOT NULL,
CONSTRAINT Employee_PK PRIMARY KEY(EmployeeNo)
);

---------------------
-- To Use IDENTITY Constraint:

CREATE TABLE tblHotel
(
HotelNo Int IDENTITY (1,1),
Name Char(50) NOT NULL,
Address Char(50) NULL,
City Char(25) NULL
);

-- UNIQUE Constraint:

CREATE TABLE EMPLOYEES
(
EmployeeNo CHAR(10) NOT NULL UNIQUE
);

-- FOREIGN KEY 

USE HOTEL;
GO
CREATE TABLE tblRoom
(
HotelNo Int NOT NULL,
RoomNo Int NOT NULL,
Type Char(50) NULL,
Price Money NULL,
PRIMARY KEY (HotelNo, RoomNo),
FOREIGN KEY (HotelNo) REFERENCES tblHotel
);

-- CHECK Constraint:

USE HOTEL;
GO
CREATE TABLE tblRoom
(
HotelNo Int NOT NULL,
RoomNo Int NOT NULL,
Type Char(50) NULL,
Price Money NULL,
PRIMARY KEY (HotelNo, RoomNo),
FOREIGN KEY (HotelNo) REFERENCES tblHotel,
CONSTRAINT Valid_Type
CHECK (Type IN (‘Single’, ‘Double’, ‘Suite’, ‘Executive’))
);

--

GO
CREATE TABLE SALESREPS
(
Empl_num Int Not Null,
CHECK (Empl_num BETWEEN 101 and 199),
Name Char (15),
Age Int CHECK (Age >= 21),
Quota Money CHECK (Quota >= 0.0),
HireDate DateTime,
CONSTRAINT QuotaCap CHECK ((HireDate < “01-01-2004”) OR (Quota <=300000))
);

-- DEFAULT Constraint:

USE HOTEL;
ALTER TABLE tblHotel
Add CONSTRAINT df_city DEFAULT ‘Vancouver’ FOR City;

-- User-Defined Types:

CREATE TABLE SINTable
(
EmployeeID INT Primary Key,
EmployeeSIN SIN,
CONSTRAINT CheckSIN
CHECK (EmployeeSIN LIKE
‘[0-9][0-9][0-9] – [0-9][0-9] [0-9] – [0-9][0-9][0-9]‘)
);

-- ALTER TABLE:

USE HOTEL;
GO
ALTER TABLE tblHotel
ADD CONSTRAINT unqName UNIQUE (Name);

--

ALTER TABLE TableName
ADD ColumnName int IDENTITY(seed, increment);

-- DROP TABLE:

DROP TABLE tblHotel;

---------------- DATA MANIPULATION LANGUAGE (DML) -----------------

-- SELECT: 

-- INSERT:

INSERT INTO Authors
VALUES('555-93-4670', 'Martin', 'April', '281 555-5673', '816 Market St.,' , 'Vancouver', 'BC', '73405', 0);

--

INSERT INTO Publishers (PubID, PubName, city, province)
VALUES ('9900', 'Acme Publishing', 'Vancouver', 'BC');

--

INSERT INTO jobs
VALUES ('DBA', 100, 175);

-- INSERT Into an IDENTITY Column:

SET IDENTITY_INSERT jobs ON
INSERT INTO jobs (job_id, job_desc, min_lvl, max_lvl)
VALUES (19, 'DBA2', 100, 175)
SET IDENTITY_INSERT jobs OFF;

-- INSERT with SELECT:

CREATE TABLE dbo.tmpPublishers (
PubID char (4) NOT NULL,
PubName varchar (40) NULL,
city varchar (20) NULL,
province char (2) NULL,
country varchar (30) NULL DEFAULT ('Canada')
);

INSERT tmpPublishers
SELECT * FROM Publishers;

-- In this example, we’re copying a subset of data.

INSERT tmpPublishers (PubID, PubName)
SELECT PubID, PubName
FROM Publishers;

-- In this example, the publishers’ data are copied to the tmpPublishers table and the country column is set to Canada.

INSERT tmpPublishers (PubID, PubName, city, province, country)
SELECT PubID, PubName, city, province, 'Canada'
FROM Publishers;

-- UPDATE:

UPDATE Publishers
SET country = 'Canada';

--

UPDATE roysched
SET royalty = royalty + (royalty * .10)
WHERE royalty BETWEEN 10 and 20;

-- UPDATE Including Subqueries:

UPDATE Employees
SET job_lvl =
   (SELECT max_lvl FROM jobs
    WHERE Employees.job_id = jobs.job_id)
WHERE DATEPART(year, Employees.HireDate) = 1990;

-- DELETE:

DELETE FROM Sales
WHERE TitleID IN
   (SELECT TitleID FROM Books WHERE type = 'mod_cook');
