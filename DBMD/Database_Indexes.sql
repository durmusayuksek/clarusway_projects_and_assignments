--==================================================================================
---------------------------------- DATABASE INDEXES --------------------------------
--==================================================================================

-- Clustered veya non-clustered bir index varsa seek yontemi kullaniliyor
-- Eger index yoksa scan yontemini kullaniyor

-- Scan >> Full Table Scan or Index Scan

-- Full table scan is not the fastest but provides always correct result.
-- Full table scan kucuk tablolarda, index hazirlamanin maliyetli olacagi durumlarda kullanilir.

-- Clustered Index: 
-------------------
-- Esas itibariyle tum sutunlarin primary key'e baglanmasi seklinde belirtebiliriz.
-- SQL Server automatically creates a corresponding clustered index based on columns included in the primary key.
-- Bir tabloda sadece bir tane clustered index olabilir.

create clustered index index_name on schema_name.table_name (column_list);

-- Non-Clustered Index:
-----------------------
-- Sorts and stores data separately from the data rows in the table. It is a copy of selected columns.
-- A table may have one or more nonclustererd indexes.
-- Each non-clustered index may include one or more columns of the table.
-- Besides storing the index key values, the leaf nodes also store row pointers.

create nonclustered index index_name on schema_name.table_name (column_list);

-- Disadvantages of Indexes :
-- INSERT, UPDATE and DELETE becomes slower.
-- Take additional disk space

-- Advantages of Indexes:
-- Much better SELECT performance
-- Quickly retrieve data
-- Used for sorting
-- Unique indexes guarantee

/* Eger bir sutun icin nonclustered index olusturursak, o sutun uzerinden bir arama yaptigimizda nonclustered
index seek islemi yapar. Ancak bu sutun disinda baska bir sutun uzerinden arama yaptigimizda table scan yapar.
Ornegin, first name ve last name uzerinden bir nonclustered index yaptik. Aramaya hem first name hem de last
name uzerinden yaparsak nonclustered index seek islemi yapar ve sonucu cok hizli bulur. Ancak bu iki index 
uzerinden bir nonclustered index hazirlamisken sadece last name uzerinden arama yaparsak nonclustered index
scan ile arama yapar ki bu da oncekine gore daha yavas olur. */

--------

-- To disable indexes

ALTER INDEX index_name ON table_name DISABLE -- burada index yerine ALL yazarsak tum indexler

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

--Bu tablo icin ayri bir database olusturmaniz daha uygun olacaktir.
--Index'in faydalarinin daha belirgin olarak gorulmesi icin bu sekilde bir tablo olusturulmustur.

--Once tablonun catisini olusturuyoruz.

create database website_visitor;

-----

create table website_visitor 
(
visitor_id int,
first_name varchar(50),
last_name varchar(50),
phone_number bigint,
city varchar(50)
);

-----

--Tabloya rastgele veri atiyoruz; konumuz haricindedir; simdilik varligini bilmeniz yeterli.

DECLARE @i int = 1
DECLARE @RAND AS INT
WHILE @i<1000
BEGIN
	SET @RAND = RAND()*81
	INSERT website_visitor
		SELECT @i , 'visitor_name' + cast (@i as varchar(20)), 'visitor_surname' + cast (@i as varchar(20)),
		5326559632 + @i, 'city' + cast(@RAND as varchar(2))
	SET @i +=1
END;

--Tabloyu kontrol ediniz.

SELECT top 10*
FROM
website_visitor

--Istatistikleri (Process ve time) aliyoruz, bunu almak zorunda degilsiniz sadece yapilan islemlerin detayini gormek icin yaptik.

SET STATISTICS IO on
SET STATISTICS TIME on

--Herhangi bir index olmadan visitor_id'ye sart verip tum tabloyu cagiriyoruz.

SELECT *
FROM
website_visitor
where
visitor_id = 100

--Execution plan'a baktiginizda Table Scan yani tum tabloyu teker teker tum degerlere bakarak aradigini goreceksiniz.

--visitor_id uzerinde bir index olusturuyoruz.

Create CLUSTERED INDEX CLS_INX_1 ON website_visitor (visitor_id);

--visitor_id'ye sart verip sadece visitor_id' yi cagiriyoruz.

SELECT visitor_id
FROM
website_visitor
where
visitor_id = 100

--Execution plan'a baktiginizda Clustered index seek yani sadece clustered index'te aranilan
--degeri B-Tree yontemiyle bulup getirdigini goruyoruz.

--visitor_id'ye sart verip tum tabloyu cagiriyoruz.

SELECT *
FROM
website_visitor
where
visitor_id = 100

--Execution plan' a baktiginizda Clustered index seek yaptigini goruyoruz.
--Clustered index tablodaki tum bilgileri leaf node'larda sakladigi icin ayrica bir yere gitmek ihtiyaci olmadan
--primary key bilgisiyle (clustered index) tum bilgileri getiriyor.

------------------------------------------

--Peki farkli bir sutuna sart verirsek;

SELECT first_name
FROM
website_visitor
where
first_name = 'visitor_name17'

--Execution Plan'da gorulecegi uzere Clustered Index Scan yapiyor.
--Dikkat edin seek degil scan. Aradigimiz sutuna ait degeri clustered index'in leaf page'lerinde tutulan bilgilerde ariyor.
--Tabloda arar gibi, index yokmuscasina.

--Yukaridaki gibi devamli sorgu atilan non-key bir attribute soz konusu ise;
--Bu sekildeki sutunlara clustered index tanimlayamayacagimiz icin NONCLUSTERED INDEX tanimlamamiz gerekiyor.

--Non clustered index tanimlayalim ad sutununa;

CREATE NONCLUSTERED INDEX ix_NoN_CLS_1 ON website_visitor (first_name);

--Ad sutununa sart verip kendisini cagiralim:

SELECT first_name
FROM
website_visitor
where
first_name = 'visitor_name17'

--Execution Plan'da gorulecegi uzere ayni yukarida visitor id'de oldugu gibi index seek yontemiyle verileri getirdi.
--Tek fark Non-Clustered indexi kullandi.

--Peki ad sutunundan baska bir sutun daha cagirirsak ne olur?
--Gunluk hayatta da ad ile genellikle soyadi birlikte sorgulanir.

SELECT first_name, last_name
FROM
website_visitor
where
first_name = 'visitor_name17'

--Execution Plan'da gorulecegi uzere burada ad ismine verdigimiz sart icin NonClustered index seek kullandi,
--Sonrasinda soyad bilgisini de getirebilmek icin Clustered index'e Key lookup yapti.
--Yani clustered index'e gidip sorgulanan ad'a ait primary key'e basvurdu
--Sonrasinda farkli yerlerden getirilen bu iki bilgiyi Nested Loops ile birlestirdi.

--Bir sorgunun en performansli hali idealde sorgunun %100 Index Seek yontemi ile getiriliyor olmasidir!

--Bu demek oluyor ki, bu da tam olarak performans istegimizi karsilamadi, daha performansli bir index olusturabilirim.

--Burada yapabilecegim, ad sutunu ile devamli olarak birlikte sorgulama yaptigim sutunlara INCLUDE INDEX olusturma islemidir.

--Bunun calisma mantigi;

--NonClustered index'te leaf page'lerde sadece nonclustered index olusturulan sutunun ve primary key'inin bilgisi tutulmaktaydi.
--Include index olusturuldugunda verilen sutun bilgilerinin bu leaf page'lere eklenmesi ve ad ile birlikte kolayca getirilmesi amaclanmistir.

--Include index'i olusturalim:

CREATE UNIQUE NONCLUSTERED INDEX ix_NoN_CLS_2 ON website_visitor (first_name) include (last_name)

--Ad ve soyadi sutunlarini ad sutununa sart vererek birlikte cagiralim.

SELECT first_name, last_name
FROM
website_visitor
where
first_name = 'visitor_name17'

--Execution plan' da gorulecegi uzere sadece Index Seek ile sonucu getirmis olduk.

--Burada ise:

SELECT last_name
FROM
website_visitor
where
last_name = 'visitor_surname10'

--Soyad sutununa sart verip sadece kendisini cagirdigimizda, 
--Kendisine tanimli ozel bir index olmadigi icin Index seek yapamadi, ad sutununun indexinde tum degerlere teker teker bakarak
--yani scan yontemiyle sonucu getirdi.

--Execution Plan' da gorulecegi uzere bize bir index tavsiyesi veriyor.
