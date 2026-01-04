-- adatbázis létrehozása, táblák létrehozása majd adatokkal feltöltése

create table vevo_torzs
(
Partnerkod	varchar(20)	primary key,
Vevo_nev	varchar(50),	
Cim	varchar(100),	
Adoszam	int,	
Orszag	varchar(20)	
)
create table cikktorzs
(
Cikkszam	varchar(20)	primary key,
Cikkcsop	varchar(20),	
Megnevezes	varchar (150)	
)

create table fizetesi_mod
(
Fiz_mod_ID	int	primary key,
fiz_mod_leiras	varchar (15)
)

create table AFA_kodok
(
AFA_ID	int	primary key,
AFA_kulcs	int,	
Leiras	varchar(20)
) 

create table mennyisegek
(
Mennyiseg_ID	int	primary key,
Mennyiseg	varchar (10)
)

create table szamla_tipus
(
Szamla_tipus_ID	int	primary key,
Szamla_tipus	varchar(20)
)


create table szamla
(
Szla_tipus	int	foreign key references szamla_tipus (Szamla_tipus_ID),
Bizonylatszam	varchar(20)	primary key,
Partner_kod	varchar(20)	foreign key references vevo_torzs (Partnerkod),
Kiallitas_datuma	date,	
Teljesites_datuma	date,	
Fizetesi_hatarido	date,	
Fizetesi_mod	int	foreign key references fizetesi_mod (Fiz_mod_ID)
) 

create table szamla_sor
(
Bizonylatszam	varchar(20)	foreign key references szamla (Bizonylatszam),
Szamla_sor_ID	varchar (20)	primary key,
Cikk	varchar(20), 
Mennyiseg int,	
Mennyisegi_egys	int	foreign key references mennyisegek (Mennyiseg_ID),
Afa_kod	int	foreign key references AFA_kodok (AFA_ID),
Egys_ar	float, 	
Netto_osszeg float,	
Afa_osszeg 	float,	
Brutto_osszeg float	
)

insert into fizetesi_mod (Fiz_mod_ID, fiz_mod_leiras)
values (1, 'átutalás')
insert into fizetesi_mod (Fiz_mod_ID, fiz_mod_leiras)
values (2, 'átutalás 8 nap')
insert into fizetesi_mod (Fiz_mod_ID, fiz_mod_leiras)
values (3, 'készpénz'); 

insert into szamla_tipus (Szamla_tipus_ID, Szamla_tipus)
values (1, 'Normál')
insert into szamla_tipus (Szamla_tipus_ID, Szamla_tipus)
values (2, 'Helyesbítõ')
insert into szamla_tipus (Szamla_tipus_ID, Szamla_tipus)
values (3, 'Helyesbített') 
insert into szamla_tipus (Szamla_tipus_ID, Szamla_tipus)
values (4, 'Storno')
insert into szamla_tipus (Szamla_tipus_ID, Szamla_tipus)
values (5, 'Stornozott'); 


insert into AFA_kodok (AFA_ID, AFA_kulcs, Leiras )
values (1, 27, 'Belf. normál')
insert into AFA_kodok (AFA_ID, AFA_kulcs, Leiras )
values (2, 0, 'Export EU');
insert into AFA_kodok (AFA_ID, AFA_kulcs, Leiras )
values (3, 0, 'Belf. ÁFA mentes');
insert into AFA_kodok (AFA_ID, AFA_kulcs, Leiras )
values (4, 0, 'Belf. Csökkentett');


-- a többi tábla feltöltését a SSMS 'edit top 200 rows' segítségével végeztem el közvetéenül excelbõl ---
-- alternatívaként a import data varázslóval is létrehoztam az adatbázist az alap excel táblámból -- 

--- lekérdezések -- 

-- 1. mekkora az árbevételünk havonta?

create view rip1 as
select MONTH(szamla.Kiallitas_datuma) as 'Hónap', sum(szamla_sor.Netto_osszeg) as 'Árbevétel'  
from szamla
join szamla_sor on szamla.Bizonylatszam=szamla_sor.Bizonylatszam
group by MONTH(szamla.Kiallitas_datuma); 

-- 2. mekkora az árbevétel havonta és országokra bontva?
create view rip2 as
select MONTH(szamla.Kiallitas_datuma) as 'Hónap', sum(szamla_sor.Netto_osszeg) as 'Árbevétel', vevo_torzs.Orszag as 'Ország'  
from szamla
join szamla_sor on szamla.Bizonylatszam=szamla_sor.Bizonylatszam
join vevo_torzs on szamla.Partner_kod=vevo_torzs.Partnerkod
group by MONTH(szamla.Kiallitas_datuma), vevo_torzs.Orszag
having sum(szamla_sor.Netto_osszeg)>0 ;
 
 
 --3. MEkkora az árbevétel termékenként?
create view rip3 as
select cikktorzs.Cikkcsop as 'Termék',  sum(szamla_sor.Netto_osszeg) as 'Árbevétel' 
from szamla
join szamla_sor on szamla.Bizonylatszam=szamla_sor.Bizonylatszam
join cikktorzs on szamla_sor.cikk=cikktorzs.Cikkszam
where cikktorzs.cikkcsop not in ('nem termek', '0')
group by cikktorzs.Cikkcsop 

--4. hány értékesítés (=kiállított számla) történt az elmúlt 90 napban és abból mekkora volt az árbevétel termékenként? 
create view rip4 as 
select cikktorzs.Cikkcsop as 'Termék', sum(szamla_sor.Netto_osszeg) as 'Árbevétel', count(szamla.Bizonylatszam) as 'Értékesítés száma' 
from szamla_sor
join szamla on szamla.Bizonylatszam=szamla_sor.Bizonylatszam
join cikktorzs on szamla_sor.cikk=cikktorzs.Cikkszam
where (DATEDIFF(day, szamla.Teljesites_datuma, getdate())) < 90
and cikktorzs.cikkcsop not in ('nem termek', '0')
group by cikktorzs.Cikkcsop 

-- 5 Melyik ügyfélnek hosszabb a fizetési határidje mint az átlag és az mennyi? 

create view rip5 as
select vevo_torzs.Vevo_nev as 'Vevõ', datediff(day, Fizetesi_hatarido, Kiallitas_datuma) as 'Fizetési határidõ'
from szamla
join vevo_torzs on vevo_torzs.Partnerkod=szamla.Partner_kod
where datediff(day, Fizetesi_hatarido, Kiallitas_datuma) >
(select avg(datediff(day, Fizetesi_hatarido, Kiallitas_datuma)) as 'Átlag fizetesi határidõ'  
from szamla
where datediff(day, Fizetesi_hatarido, Kiallitas_datuma)>0)

-- 6. Melyik ügyfél rendelt az elmúlt 120 napban azok közül, akik a korábbi idõszakban már vásároltak? 

create view rip6 as
select Partner_kod as 'partnerkód', vevo_torzs.Vevo_nev as 'Visszatérõ vevõ'  
from szamla
join vevo_torzs on szamla.Partner_kod=vevo_torzs.Partnerkod
where (DATEDIFF(day, szamla.Teljesites_datuma, getdate())) < 120
intersect
select Partner_kod, vevo_torzs.Vevo_nev  
from szamla
join vevo_torzs on szamla.Partner_kod=vevo_torzs.Partnerkod
where (DATEDIFF(day, szamla.Teljesites_datuma, getdate())) > 120
