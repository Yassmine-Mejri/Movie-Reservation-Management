/*CREATION DES TABLEAUX*/
ALTER TABLE EXEMPLAIRE
ADD FOREIGN KEY (NUMFILM) REFERENCES FILM(NUMFILM);

ALTER TABLE LOCATION
ADD FOREIGN KEY (NUM_EXEMPLAIRE) REFERENCES EXEMPLAIRE(NUM_EXEMPLAIRE);


ALTER TABLE LOCATION
ADD FOREIGN KEY (LOGIN) REFERENCES CLIENT(LOGIN);

ALTER TABLE FILM
ADD FOREIGN KEY (REALISATEUR) REFERENCES INDIVIDU(NUM_INDIVIDU);

/*TABLE CLIENT*/
INSERT INTO client VALUES ('YASS1','mejri','yassmine','0000','hlif');
INSERT INTO client VALUES ('DHOU1','bouhlel','dhouha','1111','rades');
INSERT INTO client VALUES ('yassine','bouhlel','dhouha','2222','rades');
INSERT INTO client VALUES ('siwar','mejri','yassmine','0000','hlif');


select* from client;
/*TABLE EXEMPLAIRE*/
INSERT INTO exemplaire VALUES (1,1,1234,'TRUE','NO','NEW');
INSERT INTO exemplaire VALUES (2,2,9876,'FALSE','YES','OLD');

INSERT INTO exemplaire VALUES (3,1,1234,'TRUE','NO','NEW');
INSERT INTO exemplaire VALUES (4,2,9876,'FALSE','YES','OLD');
INSERT INTO exemplaire VALUES (5,2,9876,'FALSE','YES','OLD');
INSERT INTO exemplaire VALUES (6,2,9876,'FALSE','YES','OLD');
INSERT INTO exemplaire VALUES (7,2,9876,'FALSE','YES','OLD');
INSERT INTO exemplaire VALUES (9,1,1234,'TRUE','NO','NEW');

 select*from exemplaire;

/*TABLE LOCATION*/
   alter SESSION set NLS_DATE_FORMAT = 'YYYY-MM-DD ' ;
INSERT INTO location VALUES (1,'2023-01-01','YASS1','2023-01-01','2023-02-01');
INSERT INTO location VALUES (9,'2023-01-01','DHOU1','2023-05-05',null);

INSERT INTO location VALUES (3,'2022-01-01','YASS1','2022-01-01','2022-02-01');

INSERT INTO location VALUES (4,'2022-01-01','DHOU1','2022-05-05','2022-07-05');

INSERT INTO location VALUES (5,'2022-06-01','YASS1','2022-06-01','2022-07-01');
INSERT INTO location VALUES (6,'2022-07-01','YASS1','2022-07-01','2022-08-01');
INSERT INTO location VALUES (7,'2022-07-01','DHOU1','2022-07-01','2022-08-01');
INSERT INTO location VALUES (9,'2023-01-05','DHOU1','2023-02-05','2023-03-05');
INSERT INTO location VALUES (4,'2023-01-05','yassine','2023-02-05','2023-03-05');
INSERT INTO location VALUES (5,'2023-01-05','yassine',null,'2023-03-05');
INSERT INTO location VALUES (6,'2023-01-05','yassine',null,null);

select * from location;

INSERT INTO location VALUES (2,'2023-01-01','siwar','2022-05-05','2022-07-05');

/*TABLE INDIVIDU*/
INSERT INTO individu VALUES (1091, 'Jones', 'Mark');
INSERT INTO individu VALUES (1092, 'Potter', 'John');
INSERT INTO individu VALUES (1093, 'Stone', 'Joe');

select * from individu;

/*TABLE FILM*/
INSERT INTO film VALUES (1, 'Titanic', 1091);
INSERT INTO film VALUES (2, 'Spider Man', 1092);
INSERT INTO film VALUES (3, 'Star Wars', 1093);
INSERT INTO film VALUES (4, 'Me before you', 1091);
INSERT INTO film VALUES (5, 'Notebook', 1091);

select *  from film;










set serveroutput on;

/*QEST: 1*/
create or replace function nbreFilms (NUM_INDIVIDU number) return number
as 
nbrF number;
begin
    select count(*) into nbrF
    from film 
    where realisateur = num_individu;
    return nbrF;
end;
 /*appel fonction*/
declare 
   x number :=&x;
begin
   Dbms_output.put_line(nbreFilms (x));
end;





/*QEST: 2*/
create table TableBonus(login varchar2(50), bonus number(8,2),NbrExLoues number(8));

ALTER TABLE tableBonus
ADD FOREIGN KEY (login) REFERENCES CLIENT(login);

INSERT INTO tablebonus(login,nbrexloues)
select location.login, count(location.num_exemplaire)
from location
where location.date_location between '2022-01-01' and '2022-12-31' 
group by login;

select * from tablebonus;


create or replace procedure  update_tablebonus(n1 number, n2 number)
     is cursor c is select nbrexloues from tablebonus  for update ;
     begin for l in c loop
         if l.nbrexloues < n1 then 
              update  tablebonus set bonus = 0.1 where current of c ;
        elsif l.nbrexloues < n2 then
              update  tablebonus set bonus = 0.2 where current of c ;
        elsif l.nbrexloues >= n2 then
              update tablebonus set bonus = 0.4 where current of c ;
         else 
              update tablebonus set bonus = 0 where current of c;
         end if;
         end loop ;
         End;  
         
 declare
    n1 number:=&n1;
    n2 number:=&n2;
     begin 
      update_tablebonus(n1, n2);
     end ;     
     
     SELECT * from tablebonus;

Select NOM_CLIENT , prenom_client ,bonus
from client c , tablebonus b 
where c.login = b.login ;




/* QEST 3*/

create or replace function pourcentage (n1 number , n2 number) return FLOAT
as 
res FLOAT;
begin
 res:=  (n1/n2)*100  ;
 return round(res,2);
end;
 declare
    n1 number:=&n1;
    n2 number:=&n2;
     begin 
     Dbms_output.put_line( pourcentage(n1, n2));
     end ;  



create or replace function nbrexsupport(n exemplaire.numfilm%type, c exemplaire.code_support%type) return number
as
nbr number;
begin
select count(*) into nbr
from exemplaire 
where numfilm=n and c=any (select code_support from exemplaire )
group by c;
return nbr;
EXCEPTION 
   WHEN no_data_found THEN 
      dbms_output.put_line('unknown Code Support!'); 
      return 0;
   WHEN others THEN 
      dbms_output.put_line('Error!'); 
      return 0;    
end;

 declare
    n number:=&n;
    c number:=&c;
     begin 
     Dbms_output.put_line( nbrexsupport(n, c));
     end ;
    
    
CREATE TABLE statistiques (numfilm number , nbrex number, pctgeDVD float, pctgeVHS float);    
    
  ALTER TABLE statistiques
ADD FOREIGN KEY (numfilm) REFERENCES film(numfilm);   


create or replace procedure  remplirStat as
    n1 number :=&n1;
    n2 number :=&n2;
    n3 number :=&n3;
    n4 number :=&n4;
begin
insert into statistiques (numfilm ,nbrex,pctgeDVD,pctgeVHS)
select numfilm ,nbrexsupport(numfilm,code_support),pourcentage(n1, n2),pourcentage(n3, n4)
from exemplaire;
end;
 
     begin 
 remplirStat;
     end ;
     select* from statistiques;
     
     
     
     
     
     
/* quest 4 */

CREATE PACKAGE  statistic AS 
   FUNCTION NBR_FILM_EXEMPLAIRE return  number;
   FUNCTION POURCENTAGE_exemplaire return  float;
END statistic; 

create or replace function nbr_film_exemplaire return number
as 
nbr number;
begin
select distinct(count(*) )into nbr
from film
where numfilm not in (select  numfilm
                      from exemplaire 
                      where film.numfilm=exemplaire.numfilm);
      
 return nbr;     
end;

begin
 Dbms_output.put_line( nbr_film_exemplaire);
 end;

     
     
create or replace function pourcentage_exemplaire return float
as 
n1 number;
n2 number;
begin 
select count(*)into n1
from exemplaire 
where upper(probleme) = 'NO';

select count(*) into n2
from exemplaire;

return (pourcentage(n1,n2));
end;


begin
 Dbms_output.put_line(pourcentage_exemplaire);
end;




/*QUEST 5*/

create table trace(numlog number,message varchar2(50),PRIMARY KEY (numlog));

CREATE OR REPLACE FUNCTION nbValLog RETURN INTEGER AS 
nbval INTEGER; 
BEGIN 
SELECT COUNT(*) INTO nbval 
FROM TRACE; 
RETURN nbval; 
END;

begin
 Dbms_output.put_line(nbValLog);
 end;
 
 
 /*Déclencheur TRIG_1 */
 CREATE TRIGGER TRIG_1
 BEFORE INSERT ON LOCATION 
 FOR EACH ROW 
BEGIN 
 INSERT INTO TRACE 
 VALUES(nbValLog+1,'Trigger 1'); 
END; 



/*Déclencheur TRIG_2*/
CREATE TRIGGER TRIG_2
 BEFORE INSERT ON LOCATION 
BEGIN 
 INSERT INTO TRACE 
 VALUES(nbValLog+1,'Trigger 2'); 
END; 



/*Déclencheur TRIG_3 */
CREATE TRIGGER TRIG_3
 AFTER INSERT ON LOCATION 
 FOR EACH ROW 
BEGIN 
 INSERT INTO TRACE 
 VALUES(nbValLog+1,'Trigger 3'); 
END;

    
/*Déclencheur TRIG_4*/

CREATE TRIGGER TRIG_4
 AFTER INSERT ON LOCATION 
BEGIN 
 INSERT INTO TRACE 
 VALUES(nbValLog+1,'Trigger 4'); 
END; 

 select* from trace;/*vide*/
 
 select * from location;
 
drop trigger trig_4;
 
 /* Ordre 3,4,2,1 */
 


 

 

  /*QUESTION 6*/

alter session set "_ORACLE_SCRIPT" = true;

-- USER1 SQL
CREATE USER user1 IDENTIFIED BY 1111  
DEFAULT TABLESPACE "SYSTEM"
TEMPORARY TABLESPACE "TEMP"
PASSWORD EXPIRE ;

-- QUOTAS
ALTER USER user1 QUOTA 20M ON SYSTEM;


-- SYSTEM PRIVILEGES
GRANT CREATE TRIGGER TO user1 WITH ADMIN OPTION;
GRANT ALTER ANY TABLE TO user1 WITH ADMIN OPTION;
GRANT CREATE SESSION TO user1 WITH ADMIN OPTION;
GRANT SELECT ANY TABLE TO user1 WITH ADMIN OPTION;
GRANT DELETE ANY TABLE TO user1 WITH ADMIN OPTION;
GRANT CREATE TABLE TO user1 WITH ADMIN OPTION;
GRANT DROP ANY TABLE TO user1 WITH ADMIN OPTION;
GRANT UPDATE ANY TABLE TO user1 WITH ADMIN OPTION;
GRANT GRANT ANY PRIVILEGE TO user1 WITH ADMIN OPTION;
GRANT INSERT ANY TABLE TO user1 WITH ADMIN OPTION;
GRANT CREATE ANY TABLE TO user1 WITH ADMIN OPTION;


select * from user_sys_privs;

grant select on system.location to user1;




-- USER2 SQL
CREATE USER user2 IDENTIFIED BY 2222 
DEFAULT TABLESPACE "SYSTEM"
TEMPORARY TABLESPACE "TEMP" ;

GRANT CREATE SESSION TO user2 WITH ADMIN OPTION;


-- QUOTAS
ALTER USER user2 QUOTA 20M ON "SYSTEM";


grant select on system.location to user2;



create trigger trig_location_delete
before delete on location 
for each row 
declare
dlt number;
begin 
select count(*) into dlt
from user_sys_privs 
where privilege = 'DELETE ANY TABLE';

if dlt=0 then
RAISE_APPLICATION_ERROR(-20001, 'Attention, utilisateur non autorisé !');
end if;
end;

delete from location 
where num_exemplaire=7;
  
  
drop trigger trig_location_delete;





 /*QUESTION 7*/
 
 SELECT * FROM LOCATION;

DROP TRIGGER MODIF_LOCATION;
    
 delete from location 
 where num_exemplaire=  2;
 select* from location;
 
 update location 
 set date_retour=  '2022-06-13 '
 where num_exemplaire=7;
 
 create or replace trigger MODIF_LOCATION
 after delete or update or insert
 on location
 for each row 
 declare 
 ch varchar2(50);
 begin 
 if (:old.date_envoi is null) then
 raise_application_error(-20500, 'ON CONNAIT DATE envoi');
 end if; 
  if (:old.date_retour is not null) then
 raise_application_error(-20500, 'ON CONNAIT DATE retour');
end if; 
 end;
 
 drop trigger modif_location;

CREATE OR REPLACE TRIGGER trig_affiche_message
AFTER INSERT OR UPDATE OR DELETE ON LOCATION
FOR EACH ROW
DECLARE
  message VARCHAR2(200);
BEGIN
    IF (NOT DELETING AND NOT UPDATING) THEN
        message:='La ligne avec le numéro d''exemplaire ' || :OLD.num_Exemplaire || ' a été insérée pour le login ' || :OLD.login || ' le ' || :OLD.date_Location || '.';
        raise_application_error(-20500, message);
    ELSIF (UPDATING) THEN

        message:='La ligne avec le numéro d''exemplaire ' || :OLD.num_Exemplaire || ' a été mise à jour pour le login ' || :OLD.login || ' le ' || :OLD.date_Location || '.';
        raise_application_error(-20500, message);
        message:='Anciennes valeurs : envoi=' || :OLD.date_Envoi || ', retour=' || :OLD.date_Retour;
        raise_application_error(-20500, message);
        message:='Nouvelles valeurs : envoi=' || :NEW.date_Envoi || ', retour=' || :NEW.date_Retour;
        raise_application_error(-20500, message);
    END IF;
 end ;
 
 drop trigger trig_affiche_message;
 
 

 
 
 
 /*QUESTION 8*/
CREATE OR REPLACE TRIGGER trigBonus 
AFTER INSERT ON LOCATION 
FOR EACH ROW 
DECLARE 
nbre TABLEBONUS.nbrExLoues%type; 
BEGIN 
SELECT COUNT(*) INTO nbre FROM LOCATION 
WHERE login = :NEW.login; 
UPDATE TABLEBONUS
SET nbrExLoues = nbre+1 WHERE login = :NEW.login; 
END;

select * from tablebonus;
 
drop trigger trigBonus;

/*Cependant, ce déclencheur présente un problème potentiel.
En effet, lorsqu'il est exécuté, il accède à la table LOCATION elle-même,
ce qui peut entraîner une boucle infinie. En d'autres termes,
chaque fois qu'une nouvelle ligne est insérée dans la table LOCATION,
le déclencheur est activé et exécute une autre instruction INSERT dans la même table,
ce qui déclenche à nouveau le déclencheur, et ainsi de suite.

Ce phénomène est appelé récursivité infinie ou boucle infinie.*/
 
 CREATE OR REPLACE TRIGGER trigBonus1 
AFTER INSERT ON LOCATION 
FOR EACH ROW 
DECLARE 
    nbre TABLEBONUS.nbrExLoues%type; 
BEGIN 
    SELECT COUNT(*) INTO nbre FROM LOCATION 
    WHERE login = :NEW.login
    AND num_exemplaire <> :NEW.num_exemplaire; -- évite de compter la ligne qui vient d'être insérée
    
    UPDATE TABLEBONUS
    SET nbrExLoues = nbre+1 WHERE login = :NEW.login; 
END;
 
 INSERT INTO tablebonus(login,nbrexloues)
select location.login, count(location.num_exemplaire)
from location
where location.date_location between '2023-01-01' and '2023-12-31' 
group by login;
select * from tablebonus;
select* from location;
 drop trigger trigbonus1;
 
 
 
 
 
 
 
 


 