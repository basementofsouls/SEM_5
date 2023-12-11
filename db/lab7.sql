-----ЛР7--------
CREATE TABLE Employees (
  employee_id INT PRIMARY KEY,
  employee_name VARCHAR2(150),
  employee_position VARCHAR2(50),
  salary DECIMAL(10, 2),
  total_tours_value DECIMAL(10, 2)
);

INSERT INTO Employees (employee_id, employee_name, employee_position, salary, total_tours_value)
VALUES 
(1, 'Иван Иванов', 'Менеджер', 50000, 100000);
INSERT INTO Employees (employee_id, employee_name, employee_position, salary, total_tours_value)
VALUES 
(2, 'Петр Петров', 'Аналитик', 60000, 120000);
INSERT INTO Employees (employee_id, employee_name, employee_position, salary, total_tours_value)
VALUES 
(3, 'Сергей Сергеев', 'Бухгалтер', 70000, 140000);
INSERT INTO Employees (employee_id, employee_name, employee_position, salary, total_tours_value)
VALUES 
(4, 'Анна Аннова', 'Дизайнер', 55000, 110000);
INSERT INTO Employees (employee_id, employee_name, employee_position, salary, total_tours_value)
VALUES 
(5, 'Ольга Ольгова', 'Маркетолог', 58000, 116000);
INSERT INTO Employees (employee_id, employee_name, employee_position, salary, total_tours_value)
VALUES 
(6, 'Алексей Алексеев', 'Менеджер', 52000, 104000);
INSERT INTO Employees (employee_id, employee_name, employee_position, salary, total_tours_value)
VALUES 
(7, 'Мария Мариева', 'Аналитик', 61000, 122000);
INSERT INTO Employees (employee_id, employee_name, employee_position, salary, total_tours_value)
VALUES 
(8, 'Дмитрий Дмитриев', 'Маркетолог', 72000, 144000);
INSERT INTO Employees (employee_id, employee_name, employee_position, salary, total_tours_value)
VALUES 
(9, 'Екатерина Екатеринова', 'Дизайнер', 56000, 112000);
INSERT INTO Employees (employee_id, employee_name, employee_position, salary, total_tours_value)
VALUES 
(10, 'Николай Николаев', 'Оператор', 59000, 118000);



WITH total_tours AS (
  SELECT SUM(total_tours_value) as total_value
  FROM Employees
)
SELECT *
FROM Employees
MODEL
  DIMENSION BY (employee_id)
  MEASURES (salary, total_tours_value, salary AS next_year_salary, (SELECT total_value FROM total_tours) AS total_value)
  RULES (
    next_year_salary[ANY] = salary[CV()] * (1 + total_tours_value[CV()] / total_value[CV()])
  );

SELECT *
FROM Tickets
MATCH_RECOGNIZE (
  PARTITION BY tour_id
  ORDER BY Buy_date
  MEASURES
    FIRST(UP1.ticket_price) AS start_price,
    LAST(DOWN.ticket_price) AS mid_price,
    LAST(UP2.ticket_price) AS end_price
  ONE ROW PER MATCH
  AFTER MATCH SKIP TO LAST UP2
  PATTERN (UP1+ DOWN+ UP2+)
  DEFINE
    UP1 AS UP1.ticket_price > PREV(UP1.ticket_price),
    DOWN AS DOWN.ticket_price < PREV(DOWN.ticket_price),
    UP2 AS UP2.ticket_price > PREV(UP2.ticket_price)
) MR;

