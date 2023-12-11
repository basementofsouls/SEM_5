
-----ЛР 8------
CREATE OR REPLACE TYPE Клиенты AS OBJECT (
   user_id INT,
    user_name CHAR(50),
    user_email CHAR(50),
    user_password CHAR(100),
    date_registration DATE,
  -- Конструктор
  CONSTRUCTOR FUNCTION Клиенты(self IN OUT NOCOPY Клиенты, id NUMBER, name VARCHAR2, email VARCHAR2) RETURN SELF AS RESULT,
  -- Метод сравнения типа MAP
  MAP MEMBER FUNCTION get_id RETURN NUMBER,
  -- Метод экземпляра функцию
  MEMBER FUNCTION get_name RETURN VARCHAR2,
  -- Метод экземпляра процедуру
  MEMBER PROCEDURE set_name(new_name VARCHAR2)
);
/

-- Создание типа данных Туры
CREATE OR REPLACE TYPE Туры AS OBJECT (
  tour_id INT,
    route_id INT,
    tourstart_datetime TIMESTAMP,
    tourend_datetime TIMESTAMP,
  -- Конструктор
  CONSTRUCTOR FUNCTION Туры(self IN OUT NOCOPY Туры, id NUMBER, destination VARCHAR2, price NUMBER) RETURN SELF AS RESULT,
  -- Метод сравнения типа MAP
  MAP MEMBER FUNCTION get_id RETURN NUMBER,
  -- Метод экземпляра функцию
  MEMBER FUNCTION get_destination RETURN VARCHAR2,
  -- Метод экземпляра процедуру
  MEMBER PROCEDURE set_destination(new_destination VARCHAR2)
);
/

-----3.	Скопировать данные из реляционных таблиц в объектные.
CREATE TABLE Клиенты_obj OF Клиенты;
INSERT INTO Клиенты_obj
SELECT Клиенты(user_id, user_name, user_email, user_password, date_registration) FROM users_;

CREATE TABLE Туры_obj OF Туры;
INSERT INTO Туры_obj
Select Туры(tour_id, route_id,tourstart_datetime,tourend_datetime) FROM Tours;


-------4.	Продемонстрировать применение объектных представлений

-- Создание объектного представления для Клиенты 
CREATE VIEW Клиенты_view OF Клиенты WITH OBJECT IDENTIFIER (user_id) AS 
SELECT * FROM Клиенты_obj;

-- Создание объектного представления для Туры
CREATE OR REPLACE  VIEW Туры_view OF Туры WITH OBJECT IDENTIFIER (tour_id) AS
SELECT * FROM Туры_obj;

-- Выбор всех клиентов из представления
SELECT * FROM Клиенты_view;

-- Выбор всех туров из представления
SELECT * FROM Туры_view;
CREATE OR REPLACE TYPE BODY Клиенты AS 
  CONSTRUCTOR FUNCTION Клиенты(self IN OUT NOCOPY Клиенты, id NUMBER, name VARCHAR2, email VARCHAR2) RETURN SELF AS RESULT IS
  BEGIN
    self.user_id := id;
    self.user_name := name;
    self.user_email := email;
    RETURN;
  END;

  MAP MEMBER FUNCTION get_id RETURN NUMBER IS
  BEGIN
    RETURN self.user_id;
  END;

  MEMBER FUNCTION get_name RETURN VARCHAR2 IS
  BEGIN
    RETURN self.user_name;
  END;

  MEMBER PROCEDURE set_name(new_name VARCHAR2) IS
  BEGIN
    self.user_name := new_name;
  END;
END;
/

set serveroutput on;
DECLARE 
  client Клиенты;
  client_name VARCHAR2(50);
BEGIN
  SELECT VALUE(c) INTO client
  FROM Клиенты_obj c
  WHERE c.user_id = 4; -- Используйте нужный вам ID

  client_name := client.get_name();
  DBMS_OUTPUT.PUT_LINE('Имя клиента: ' || client_name);
END;
/

