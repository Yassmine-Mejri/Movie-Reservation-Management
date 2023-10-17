show user;
select * from user_sys_privs;

select * from system.location;

 update system.location 
 set date_retour='2023-03-04'
 where num_exemplaire=9;
 
 
 delete from system.location 
where num_exemplaire=9;
  
alter SESSION set NLS_DATE_FORMAT = 'YYYY-MM-DD ' ;

