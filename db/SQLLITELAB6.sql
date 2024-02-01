BEGIN TRANSACTION;
INSERT INTO Employees_Projects (employee_id, project_id, role) VALUES (1, 2, 'Manager');
COMMIT;
END TRANSACTION;
SELECT * from Employees_projects;
BEGIN TRANSACTION;
UPDATE Employees_Projects SET role = 'Team Lead' WHERE employee_id = 1 AND project_id = 2;
COMMIT;
END TRANSACTION;
BEGIN TRANSACTION;
DELETE FROM Employees_Projects WHERE employee_id = 1 AND project_id = 2;
COMMIT;
END TRANSACTION;

-----Представление
CREATE VIEW ViewEmp AS
SELECT Employees.employee_name, Projects.project_name
FROM Employees
JOIN Employees_Projects ON Employees.employee_id = Employees_Projects.employee_id
JOIN Projects ON Employees_Projects.project_id = Projects.project_id;
DROP VIEW ViewEmp;

SELECT * from ViewEmp;

------INDEX
CREATE INDEX idx_employee_name ON Employees(employee_name);
CREATE INDEX idx_project_name ON Projects(project_name);

----Триггеры

CREATE TRIGGER check_date
BEFORE INSERT ON Employees
FOR EACH ROW
WHEN NEW.hire_date NOT LIKE '____-__-__'
BEGIN
    SELECT RAISE (ABORT, 'Invalid date format. Use YYYY-MM-DD.');
END;

INSERT INTO Employees(employee_id, employee_name, position, hire_date, email) VALUES (5, 'Kate', 'Manager', '2023-03-02', 'kateross@gmail.com');
COMMIT;
END TRANSACTION;



