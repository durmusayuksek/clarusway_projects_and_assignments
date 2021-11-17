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
