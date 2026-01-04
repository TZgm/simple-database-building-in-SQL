
# Számla-Adatbázis Projekt

Ez a projekt egy vevői (kimenő) számlák adatait tároló relációs adatbázis tervezését és implementációját mutatja be. A rendszer a számlafejek és a hozzájuk tartozó számlatételek strukturált tárolására szolgál.

## 📋 Projekt Áttekintés

A feladat célja egy olyan adatbázis létrehozása volt, amely megfelel a relációs adatbázis-kezelés szabályainak, biztosítva az adatintegritást és a hatékony lekérdezhetőséget. Az adatbázis kimenő számlákat kezel, figyelembe véve a jogszabályi előírásokat (számlafej és számlasor elkülönítése).

## 🏗️ Adatbázis Architektúra és Normalizálás

Az adatbázis a tervezés során átesett a normalizálási folyamatokon, amíg el nem érte a **3. normaformát (3NF)**.

### Normalizálási Lépések:

* 
**1NF:** Minden attribútum atomi értékkel rendelkezik.


* **2NF:** Megszüntetésre kerültek a részleges függőségek. Külön táblákba kerültek a vevők (Vevőtörzs), a számlatípusok, a fizetési módok, a cikktörzs és a mennyiségi egységek.


* **3NF:** A tranzitív függőségek kiiktatása. A Számla táblából törlésre kerültek a számított mezők (nettó, ÁFA, bruttó összegek), mivel ezek a számlasorokból származtathatók.



### Adatséma (Csillagséma):

A folyamat végére egy klasszikus **csillagséma** alakult ki, amely 2 ténytáblából (eredménytábla) és 6 dimenziótáblából áll.

| Tábla | Kapcsolódó tábla | Kapcsolat típusa |
| --- | --- | --- |
| Számla | Számla_tipus | N : 1 

 |
| Számla | Számla_sor | 1 : N 

 |
| Számla | Vevő_torzs | N : 1 

 |
| Számla_sor | Cikktörzs | N : 1 

 |

## 🛠️ Technológiai Stack

* 
**Adatbázis-kezelő:** MS SQL Server (Management Studio).


* 
**Adatbetöltés:** T-SQL (Create table, Insert into), Export Wizard (Excel-ből).


* 
**Vizualizáció:** Power BI (SQL View-k beolvasása Power Query segítségével).



## 📊 Lekérdezések és Megjelenítés

A lekérdezések SQL View-k formájában valósultak meg, amelyek közvetlen forrásként szolgáltak a Power BI dashboardhoz. A vizualizáció során a nyers adatokat használtuk fel, további transzformáció nélkül.

## 📝 Megjegyzések

* A cikktörzs és a számlasor közötti idegen kulcs (foreign key) kapcsolat a tesztadatok hibái miatt utólagosan eltávolításra került a stabilitás érdekében.
