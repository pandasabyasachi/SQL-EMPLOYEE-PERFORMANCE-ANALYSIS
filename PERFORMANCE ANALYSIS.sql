create database employee_db;
use employee_db;
show tables;
select * from data_science_team;
select * from emp_record_table;
select * from proj_table;


-- 	Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, and DEPARTMENT from the employee record table.

select EMP_ID,FIRST_NAME,LAST_NAME,GENDER,DEPT from emp_record_table;

/* 	Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, and EMP_RATING if the EMP_RATING is: 
		•	less than two
		•	greater than four 
		•	between two and four */

select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING from emp_record_table where EMP_RATING < 2;

select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING from emp_record_table where EMP_RATING >4;

select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING from emp_record_table where EMP_RATING between 2 and 4;

/* 	Write a query to concatenate the FIRST_NAME and the LAST_NAME of employees 
	in the Finance department from the employee table and then give the resultant column alias as NAME.   */

select concat(FIRST_NAME,' ',LAST_NAME) name from emp_record_table where dept ='finance';

/* 	Write a query to list only those employees who have someone reporting to them.
	Also, show the number of reporters (including the President).  */

select  m.EMP_ID managerid,concat(m.FIRST_NAME,' ',m.LAST_NAME) manager_name,m.role, count(e.emp_id) as no_of_reporters 
from emp_record_table e join emp_record_table m on e.MANAGER_ID = m.EMP_ID group by e.manager_id order by count(*) over(partition by m.emp_id) desc;

/* 	Write a query to list down all the employees from the healthcare and finance departments using union. Take data from the employee record table. */

select EMP_ID, concat(FIRST_NAME,' ',FIRST_NAME) EMP_NAME, ROLE,DEPT,SALARY from emp_record_table where dept ='healthcare' union
select EMP_ID, concat(FIRST_NAME,' ',FIRST_NAME) EMP_NAME, ROLE,DEPT,SALARY from emp_record_table where dept ='finance';

/* 	Write a query to list down employee details such as 
	EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPARTMENT, and EMP_RATING grouped by dept.
	Also include the respective employee rating along with the max emp rating for the department. */

select EMP_ID,FIRST_NAME,LAST_NAME,DEPT,EMP_RATING, max(EMP_RATING) 
over(partition by dept) max_rating_of_dept from emp_record_table;

/*	Write a query to calculate the minimum and the maximum salary of the employees in each role. Take data from the employee record table. */

select distinct role, min(salary) over(partition by role) min_salary, max(salary) over(partition by role) max_salary from emp_record_table;

/* 	Write a query to assign ranks to each employee based on their experience. Take data from the employee record table.*/

select EMP_ID,FIRST_NAME,LAST_NAME,ROLE,SALARY,EXP,rank() over(order by exp desc) ranking from emp_record_table;

/* 	Write a query to create a view that displays employees in various countries 
	whose salary is more than six thousand. Take data from the employee record table. */
        
create view highpaid_emp_countrywise as select EMP_ID,concat(FIRST_NAME,' ',LAST_NAME) Emp_name,
ROLE,DEPT,COUNTRY,SALARY from emp_record_table where salary > 6000 order by country;
select * from highpaid_emp_countrywise;

/* 	Write a nested query to find employees with experience of more than ten years. Take data from the employee record table. */

select * from emp_record_table where EMP_ID in (select emp_id from emp_record_table where exp >10); 

/* 	Write a query to create a stored procedure to retrieve the details of the employees 
	whose experience is more than three years. Take data from the employee record table. */

DELIMITER $$
USE `employee_db`$$
CREATE  PROCEDURE `Exp_more_than_three`()
BEGIN
		select * from emp_record_table where exp > 3;
END$$

DELIMITER ;

call Exp_more_than_three();

/* 	Write a query using stored functions in the project table to check whether 
	the job profile assigned to each employee in the data science team matches the organization’s set standard.
	The standard being:
	For an employee with experience less than or equal to 2 years assign 'JUNIOR DATA SCIENTIST',
	For an employee with the experience of 2 to 5 years assign 'ASSOCIATE DATA SCIENTIST',
	For an employee with the experience of 5 to 10 years assign 'SENIOR DATA SCIENTIST',
	For an employee with the experience of 10 to 12 years assign 'LEAD DATA SCIENTIST',
	For an employee with the experience of 12 to 16 years assign 'MANAGER'.  */

DELIMITER $$
USE `employee_db`$$
CREATE FUNCTION EXP_DETAILS (eid char(4))
RETURNS varchar (100) deterministic
BEGIN
	declare ex int;
    declare st varchar(100);
    select exp into ex from data_science_team where emp_id = eid;
    if ex between 12 and 16 then
		set st = 'manager';
    elseif ex >10 then
		set st = 'LEAD DATA SCIENTIST';   
	elseif ex > 5 then
		set st = 'SENIOR DATA SCIENTIST';
	elseif ex > 2 then
		set st = 'ASSOCIATE DATA SCIENTIST';
	else
		set st = 'JUNIOR DATA SCIENTIST';
	end if;
RETURN st;
END$$

DELIMITER ;

select EMP_ID,concat(FIRST_NAME,' ',LAST_NAME) Name,EXP, EXP_DETAILS(emp_id) status from data_science_team order by exp desc;

/* 	Create an index to improve the cost and performance of the query to find the employee 
	whose FIRST_NAME is ‘Eric’ in the employee table after checking the execution plan. */

create index index_fname on emp_record_table(FIRST_NAME(20));
select * from emp_record_table where FIRST_NAME = 'eric';

/* 	Write a query to calculate the bonus for all the employees, based on 
	their ratings and salaries (Use the formula: 5% of salary * employee rating). */

select EMP_ID,FIRST_NAME,LAST_NAME,ROLE,DEPT,EXP,SALARY,EMP_RATING,SALARY*.05*EMP_RATING Bonus from emp_record_table;

/* 	Write a query to calculate the average salary distribution 
	based on the continent and country. Take data from the employee record table. */

select continent,country, avg(salary) over(partition by continent,country) avg_salary from emp_record_table;