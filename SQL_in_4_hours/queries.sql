/*
 *  Author: Danny Lillard
 *  Date: 5/21/2021
 *  Desc: Following the tutorial at: https://www.youtube.com/watch?v=HXV3zeQKqGY to refresh on sql and
 *        fill any gaps in knowledge.
 */

-- find all from a table.
SELECT * FROM employee;

--ordering
SELECT * FROM employee ORDER BY salary DESC;

--order by sex and name
SELECT * FROM employee
ORDER BY sex, last_name, first_name;

--Only select first five highest paid.
SELECT * FROM employee 
ORDER BY salary DESC
LIMIT 5;

-- Only show first name and last.
SELECT last_name, first_name
FROM employee;

-- Renaming columns
SELECT last_name AS surname, first_name AS forename
FROM employee;

-- Find all the different genders.
SELECT DISTINCT sex
FROM employee;

-----------------------------------------------------------------------------
--Functions

--find num of employees
SELECT COUNT(emp_id)
FROM employee;

--find num of employees that are female and born after 1970
SELECT COUNT(emp_id)
FROM employee
WHERE sex = 'F' AND birth_day > '1971-01-01';

--average of emp salaries
SELECT AVG(salary)
FROM employee;

--Find sum of all employees salary.
SELECT SUM(salary)
FROM employee;

--Aggergate: find how many males and females there are.
SELECT COUNT(sex), sex
FROM employee
GROUP BY sex;

--get total sales of each salesman.
SELECT emp_id, SUM(total_sales)
FROM works_with
GROUP BY emp_id;

--How much each client spent, the power of a linking table.
SELECT client_id, SUM(total_sales)
FROM works_with
GROUP BY client_id;

-----------------------------------------------------------------
--Wild cards, value matching.
-- % is any num of charaters, kleen star, _ is a single character.
-- This operation is like regular expressions, I think the time cost is expensive.
-- Find LLC clients
SELECT *
FROM client
WHERE client_name LIKE '%LLC';

-- Find Label supplies
SELECT *
FROM branch_supplier
WHERE supplier_name LIKE '% Label%';

-- Find employees born in October.
SELECT *
FROM employee
WHERE birth_day LIKE '____-10%';

---------------------------------------------------------------
-- Union statments
-- must have same num of columns, must have similar datatype.

-- Grab employee and branch names
SELECT first_name AS All_Names
FROM employee
UNION 
SELECT branch_name
FROM branch;

-- Find all money spent or earned by company.
SELECT employee.salary AS Costs_Earnings
FROM employee
UNION 
SELECT Works_With.total_sales
FROM works_with;

INSERT INTO branch VALUES(4,'Buffalo', NULL, NULL);

--------------------------------------------------------
--Joins

-- Finds all branches and the name of their managers.
-- Example of an inner join.
SELECT branch.branch_id, employee.emp_id, employee.first_name
FROM employee
JOIN branch
ON employee.emp_id = branch.mgr_id;

-- Same query but left JOIN.
SELECT branch.branch_id, employee.emp_id, employee.first_name
FROM employee
LEFT JOIN branch
ON employee.emp_id = branch.mgr_id;

-- Same query but right JOIN.
SELECT branch.branch_id, employee.emp_id, employee.first_name
FROM employee
RIGHT JOIN branch
ON employee.emp_id = branch.mgr_id;

------------------------------------------------------
--Nested queries

--find the names of all employees that have sold more than 30k to a single client.
SELECT employee.first_name, employee.last_name
FROM employee
WHERE employee.emp_id IN (
    SELECT works_with.emp_id
    FROM works_with
    WHERE works_with.total_sales > 30000
);

-- Find all clients who are handled by the branch micheal scott manages.
SELECT *--Client.client_name
FROM client
WHERE client.branch_id IN (
    SELECT Branch.branch_id
    FROM branch
    WHERE branch.mgr_id IN(
        SELECT employee.emp_id
        FROM employee
        WHERE employee.first_name = 'Michael' 
        AND 
        employee.last_name = 'Scott'
    )
);

-----------------------------------------------------
--On delete

--Set NULL: If we delete an element, the foreign keys attatched will be set NULL
DELETE FROM employee
WHERE emp_id = 102;

SELECT * FROM branch;
--Scranton mgr_id will be NULL
--Also supervisor rows will be NULL.

--On Delete cascade: Deletes foreign key connected rows.
DELETE FROM branch 
WHERE branch_id = 2;

SELECT * FROM branch_supplier;

----------------------------------------------------
--Triggers

CREATE TABLE trigger_test(
  message VARCHAR(100)
);

DELIMITER $$
CREATE 
  TRIGGER my_trigger BEFORE INSERT 
  ON employee
  FOR EACH ROW BEGIN 
    INSERT INTO trigger_test VALUES('added new employee');
  END$$
DELIMITER ;

INSERT INTO employee VALUES(207, 'Trigger', 'Test', '1973-07-22', 'M', 65000, 106, 3);

SELECT * FROM trigger_test;

DELIMITER $$
CREATE 
  TRIGGER my_trigger1 BEFORE INSERT 
  ON employee
  FOR EACH ROW BEGIN 
    INSERT INTO trigger_test VALUES(NEW.first_name);
  END$$
DELIMITER ;

INSERT INTO employee VALUES(208, 'Trigger', 'Test1', '1973-07-22', 'M', 65000, 106, 3);

DELIMITER $$
CREATE 
  TRIGGER my_trigger2 BEFORE INSERT 
  ON employee
  FOR EACH ROW BEGIN 
    IF NEW.sex = 'M' THEN
      INSERT INTO trigger_test VALUES('added male');
    ELSEIF NEW.sex = 'F' THEN
      INSERT INTO trigger_test VALUES('added female');
    ELSE
      INSERT INTO trigger_test VALUES('added employee');
    END IF;
  END$$
DELIMITER ;

INSERT INTO employee VALUES(209, 'Trigger', 'Test2', '1973-07-22', 'M', 65000, 106, 3);

INSERT INTO employee VALUES(210, 'Trigger', 'Test3', '1973-07-22', 'F', 65000, 106, 3);

SELECT * FROM trigger_test;