
-----�� 8------
CREATE OR REPLACE TYPE ������� AS OBJECT (
   user_id INT,
    user_name CHAR(50),
    user_email CHAR(50),
    user_password CHAR(100),
    date_registration DATE,
  -- �����������
  CONSTRUCTOR FUNCTION �������(self IN OUT NOCOPY �������, id NUMBER, name VARCHAR2, email VARCHAR2) RETURN SELF AS RESULT,
  -- ����� ��������� ���� MAP
  MAP MEMBER FUNCTION get_id RETURN NUMBER,
  -- ����� ���������� �������
  MEMBER FUNCTION get_name RETURN VARCHAR2,
  -- ����� ���������� ���������
  MEMBER PROCEDURE set_name(new_name VARCHAR2)
);
/

-- �������� ���� ������ ����
CREATE OR REPLACE TYPE ���� AS OBJECT (
  tour_id INT,
    route_id INT,
    tourstart_datetime TIMESTAMP,
    tourend_datetime TIMESTAMP,
  -- �����������
  CONSTRUCTOR FUNCTION ����(self IN OUT NOCOPY ����, id NUMBER, destination VARCHAR2, price NUMBER) RETURN SELF AS RESULT,
  -- ����� ��������� ���� MAP
  MAP MEMBER FUNCTION get_id RETURN NUMBER,
  -- ����� ���������� �������
  MEMBER FUNCTION get_destination RETURN VARCHAR2,
  -- ����� ���������� ���������
  MEMBER PROCEDURE set_destination(new_destination VARCHAR2)
);
/

-----3.	����������� ������ �� ����������� ������ � ���������.
CREATE TABLE �������_obj OF �������;
INSERT INTO �������_obj
SELECT �������(user_id, user_name, user_email, user_password, date_registration) FROM users_;

CREATE TABLE ����_obj OF ����;
INSERT INTO ����_obj
Select ����(tour_id, route_id,tourstart_datetime,tourend_datetime) FROM Tours;


-------4.	������������������ ���������� ��������� �������������

-- �������� ���������� ������������� ��� ������� 
CREATE VIEW �������_view OF ������� WITH OBJECT IDENTIFIER (user_id) AS 
SELECT * FROM �������_obj;

-- �������� ���������� ������������� ��� ����
CREATE OR REPLACE  VIEW ����_view OF ���� WITH OBJECT IDENTIFIER (tour_id) AS
SELECT * FROM ����_obj;

-- ����� ���� �������� �� �������������
SELECT * FROM �������_view;

-- ����� ���� ����� �� �������������
SELECT * FROM ����_view;
CREATE OR REPLACE TYPE BODY ������� AS 
  CONSTRUCTOR FUNCTION �������(self IN OUT NOCOPY �������, id NUMBER, name VARCHAR2, email VARCHAR2) RETURN SELF AS RESULT IS
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
  client �������;
  client_name VARCHAR2(50);
BEGIN
  SELECT VALUE(c) INTO client
  FROM �������_obj c
  WHERE c.user_id = 4; -- ����������� ������ ��� ID

  client_name := client.get_name();
  DBMS_OUTPUT.PUT_LINE('��� �������: ' || client_name);
END;
/

