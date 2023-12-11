create database Turfirma;

use database Turfirma;
-- �������� ������� Users
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    user_name VARCHAR(50) NOT NULL,
    user_email VARCHAR(50) UNIQUE,
    user_password CHAR(100),
    date_registration DATE
);

-- �������� ������� ������
CREATE TABLE Orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    ticket_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users (user_id),
    FOREIGN KEY (ticket_id) REFERENCES Tickets (ticket_id)
);

-- �������� ������� ������
CREATE TABLE Tickets (
    ticket_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    tour_id INT,
    buy_date DATE,
    ticket_price DECIMAL(10, 2),
    seat_class VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES Users (user_id),
    FOREIGN KEY (tour_id) REFERENCES Tours (tour_id)
);

-- �������� ������� ����
CREATE TABLE Tours (
    tour_id INT IDENTITY(1,1) PRIMARY KEY,
    route_id INT,
    tourstart_datetime DATETIME2 NOT NULL,
    tourend_datetime DATETIME2 NOT NULL,
    FOREIGN KEY (route_id) REFERENCES Routes (route_id)
);

-- �������� ������� ��������
CREATE TABLE Routes (
    route_id INT IDENTITY(1,1) PRIMARY KEY,
    from_id INT,
    to_id INT,
    bus_id INT,
    FOREIGN KEY (from_id) REFERENCES Points (point_id),
    FOREIGN KEY (to_id) REFERENCES Points (point_id),
    FOREIGN KEY (bus_id) REFERENCES Buses (bus_id)
);

-- �������� ������� ����� �����������/��������
CREATE TABLE Points (
    point_id INT IDENTITY(1,1) PRIMARY KEY,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    point_name VARCHAR(50) NOT NULL
);

-- �������� ������� ��������
CREATE TABLE Buses (
    bus_id INT IDENTITY(1,1) PRIMARY KEY,
    bus_number VARCHAR(50) NOT NULL,
    bus_capacity INT NOT NULL
);

-- �������� ������������� tour_info_view
CREATE VIEW tour_info_view AS
SELECT TOP 100 PERCENT
    s.tour_id, r.from_id, r.to_id, s.tourstart_datetime, COUNT(t.ticket_id) AS tickets_sold, b.bus_capacity
FROM Tours s
INNER JOIN Routes r ON s.route_id = r.route_id
INNER JOIN Buses b ON r.bus_id = b.bus_id
LEFT JOIN Tickets t ON s.tour_id = t.tour_id
GROUP BY s.tour_id, r.from_id, r.to_id, s.tourstart_datetime, b.bus_capacity
ORDER BY s.tour_id;


-- �������� ������������� ordered_tickets_view
CREATE VIEW ordered_tickets_view AS
SELECT *
FROM Tickets;

SELECT *
FROM ordered_tickets_view
ORDER BY buy_date;

-- ������ ��� ������� tour_id � ������� Tickets
CREATE INDEX ix_Tickets_tour_id ON Tickets(tour_id);

-- ������ ��� ������� ticket_id � ������� Orders
CREATE INDEX ix_Orders_ticket_id ON Orders(ticket_id);

-- ������ ��� ������� route_id � ������� Tours
CREATE INDEX ix_Tours_route_id ON Tours(route_id);

-- ������ ��� ������� user_id � ������� Tickets
CREATE INDEX ix_Tickets_user_id ON Tickets(user_id);


-- ������� ��� �������� ����������� ��������
CREATE TRIGGER ticket_capacity_trigger
ON Tickets
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @v_capacity INT;
    DECLARE @v_tickets_count INT;

    -- �������� ����������� ��������
    SELECT @v_capacity = B.bus_capacity
    FROM Routes R
    INNER JOIN Tours T ON R.route_id = T.route_id
    INNER JOIN Buses B ON R.bus_id = B.bus_id
    WHERE T.tour_id = (SELECT tour_id FROM INSERTED);

    -- ���������� ���������� ��������� �������
    SELECT @v_tickets_count = COUNT(*)
    FROM Tickets
    WHERE tour_id = (SELECT tour_id FROM INSERTED);

    -- �������� �� �����������
    IF @v_tickets_count >= @v_capacity
    BEGIN
        THROW 51000, 'Cannot add ticket, tour is full.', 1;
    END;
    ELSE
    BEGIN
        -- ������� ����� �������
        INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
        SELECT I.user_id, I.tour_id, I.buy_date, I.ticket_price, I.seat_class
        FROM INSERTED I;
    END;
END;





-- ������� ��� �������� �������
CREATE OR ALTER TRIGGER add_order
ON Tickets
AFTER INSERT
AS
BEGIN
  INSERT INTO Orders (user_id, ticket_id)
  SELECT u.user_id, i.ticket_id
  FROM Users u
  JOIN INSERTED i ON u.user_id = i.user_id;
END;

-- �������� ��������� ��� ���������� ������������
CREATE PROCEDURE add_user
@user_name VARCHAR(50),
@user_email VARCHAR(50),
@user_password CHAR(100),
@date_registration DATE
AS
BEGIN
  INSERT INTO Users (user_name, user_email, user_password, date_registration)
  VALUES (@user_name, @user_email, @user_password, @date_registration);
END;

-- �������� ��������� ��� �������� ������������
CREATE PROCEDURE delete_user
@p_user_id INT
AS
BEGIN
    -- �������� ������� ������������
    DELETE FROM Orders WHERE user_id = @p_user_id;
    
    -- �������� ������� ������������
    DELETE FROM Tickets WHERE user_id = @p_user_id;
    
    -- �������� ������������
    DELETE FROM Users WHERE user_id = @p_user_id;
    
    COMMIT;
END;

-- �������� ������� ��� �������� ��������� �������
CREATE FUNCTION count_sold_tickets
(@start_date DATE, @end_date DATE)
RETURNS INT
AS
BEGIN
  DECLARE @sold_tickets INT;

  SELECT @sold_tickets = COUNT(*)
  FROM Tickets
  WHERE buy_date >= @start_date AND buy_date <= @end_date;

  RETURN @sold_tickets;
END;


-----------------------------------------�� 3-----------------------------------
---���������� ������� ��������
ALTER TABLE Points
ADD point_hierarchy hierarchyid;


---�������� ��������� ��� ����������� ����������� ����� � ��������� ������ ��������
CREATE PROCEDURE GetSubordinatesWithLevel @node hierarchyid
AS
BEGIN
    SELECT
        point_id,
        city,
        country,
        point_name,
        point_hierarchy.ToString() AS HierarchyPath
    FROM
        Points
    WHERE
        point_hierarchy.IsDescendantOf(@node) = 1
    ORDER BY
        point_hierarchy;
END;


---�������� ��������� ��� ���������� ������������ ����
CREATE OR ALTER PROCEDURE AddChildNode
    @ParentNodePath hierarchyid, 
    @NewNodeName NVARCHAR(100),
	@NewCity NVARCHAR(100),
	@NewCountry NVARCHAR(100)
AS
BEGIN
  DECLARE @LastChild hierarchyid;

  DECLARE @NewPointId INT;
  SET @NewPointId = CAST(CAST(CONVERT(uniqueidentifier, NEWID()) AS VARBINARY) AS INT);

    -- Get the last child node under the parent
    SELECT TOP 1 @LastChild = point_hierarchy
    FROM Points
    WHERE point_hierarchy.GetAncestor(1) = @ParentNodePath
    ORDER BY point_hierarchy DESC;

    DECLARE @NewNodePath hierarchyid;
    -- Use the last child as the first parameter to GetDescendant
    SET @NewNodePath = @ParentNodePath.GetDescendant(@LastChild, NULL);

    INSERT INTO Points(point_name, city, country, point_hierarchy)
    VALUES (@NewNodeName,@NewCity, @NewCountry, @NewNodePath);
END;
DECLARE @NodePath hierarchyid;
SET @NodePath = hierarchyid::Parse('/');

EXEC DisplayChildPoints @NodePath;

---�������� ��������� ��� ����������� ����������� �����
CREATE OR ALTER PROCEDURE MoveSubtree  
	@SourceNodePath hierarchyid,
    @DestinationNodePath hierarchyid
AS
BEGIN
    -- ����������� ���� ����������� �����
    UPDATE Points
    SET point_hierarchy = point_hierarchy.GetReparentedValue(@SourceNodePath, @DestinationNodePath)
    WHERE point_hierarchy.IsDescendantOf(@SourceNodePath) = 1;
END;

DECLARE @SourceNodePath hierarchyid;
SET @SourceNodePath = hierarchyid::Parse('/1/'); 

DECLARE @DestinationNodePath hierarchyid;
SET @DestinationNodePath = hierarchyid::Parse('/3/'); 

EXEC MoveSubtree @SourceNodePath, @DestinationNodePath;

DECLARE @NodePath hierarchyid;
SET @NodePath = hierarchyid::Parse('/');
EXEC DisplayChildPoints @NodePath;
Select * from Points;
-- �������� ����
INSERT INTO Points (city, country, point_name, point_hierarchy)
VALUES ('City A', 'Country A', 'Root', hierarchyid::GetRoot());
INSERT INTO Points (city, country, point_name, point_hierarchy)
VALUES ('City B', 'Country B', 'Root', hierarchyid::GetRoot());

Select * from Points;
-- ����� ��������� AddSubordinate ��� ���������� ����������� �����
DECLARE @root hierarchyid;
SELECT @root = point_hierarchy FROM Points WHERE point_id = 1033; -- ����� 1 - ������������� ��������� ����

DECLARE @ParentNodePath hierarchyid;
SET @ParentNodePath = hierarchyid::Parse('/2/2/'); 

EXEC AddChildNode @ParentNodePath, 'Point24','City22','Country';

DECLARE @ParentNodePath hierarchyid;
SET @ParentNodePath = hierarchyid::Parse('/2/1'); 

EXEC AddChildNode @ParentNodePath, 'Point13','City14','Country15';
EXEC AddSubordinate @root, 'City E', 'Country B', 'Child 2';


-- �������� ������������� ���� � ������������ ����� (Child 1 � Child 2)
DECLARE @child1 hierarchyid, @child2 hierarchyid;

SELECT @child1 = point_hierarchy FROM Points WHERE point_id = 2; -- ������������� Child 1
SELECT @child2 = point_hierarchy FROM Points WHERE point_id = 3; -- ������������� Child 2

-- �������� ����������� ���� ��� Child 1
EXEC AddChildNode @child1, 'City C', 'Country A', 'Grandchild 1';
EXEC AddSubordinate @child1, 'City D', 'Country A', 'Grandchild 2';

-- �������� ����������� ���� ��� Child 2
EXEC AddSubordinate @child2, 'City F', 'Country B', 'Grandchild 3';

CREATE OR ALTER PROCEDURE DisplayChildPoints
    @NodePath hierarchyid
AS
BEGIN
    -- ����� ����������� ����� ��� ����������� � ��������� ����
    SELECT
        point_id,
        point_name,
        -- ���������� ����� ToString() � ��������� ������ ��� ����������� ����������� ����
        point_hierarchy.ToString() AS NodePath,
        point_hierarchy.GetLevel() AS NodeLevel
    FROM
        Points
    WHERE
        point_hierarchy.IsDescendantOf(@NodePath) = 1
    ORDER BY point_hierarchy;
END;






ALTER TABLE Points 
add LEVELL as point_hierarchy.GetLevel() persisted;



go

Select * from Points;





------------------�� �4--------------

-- ���������� ������ � ������� Users
INSERT INTO Users (user_name, user_email, user_password, date_registration)
VALUES
('Alice', 'alice@example.com', 'password123', '2023-01-15'),
('Bob', 'bob@example.com', 'pass456', '2023-02-20'),
('Charlie', 'charlie@example.com', 'qwerty', '2023-03-10'),
('David', 'david@example.com', 'davidpass', '2023-04-25'),
('Eve', 'eve@example.com', 'evepass', '2023-05-08'),
('Frank', 'frank@example.com', 'frank123', '2023-06-30'),
('Grace', 'grace@example.com', 'gracepass', '2023-07-17'),
('Henry', 'henry@example.com', 'henrypass', '2023-08-22'),
('Isabel', 'isabel@example.com', 'isapass', '2023-09-05'),
('Jack', 'jack@example.com', 'jackpass', '2023-10-18');

-- ���������� ������ � ������� Orders


-- ���������� ������ � ������� Tickets
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(1, 4, '2023-01-16', 100.00, 'Economy');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(2, 5, '2023-02-21', 150.50, 'Business');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(3, 6, '2023-03-11', 200.25, 'First Class');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(4, 7, '2023-04-26', 180.00, 'Economy');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(5, 8, '2023-05-09', 120.75, 'Economy');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(6, 9, '2023-07-01', 210.50, 'First Class');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(7, 13, '2023-07-18', 95.00, 'Economy');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(8, 13, '2023-08-23', 175.25, 'Business');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(9, 13, '2023-09-06', 130.00, 'Economy');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(10, 4, '2023-10-19', 220.00, 'First Class');

INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(1, 8, '2023-01-16', 100.00, 'Economy');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(2, 8, '2023-02-21', 150.50, 'Business');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(3, 8, '2023-03-11', 200.25, 'First Class');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(4, 9, '2023-04-26', 180.00, 'Economy');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(5, 9, '2023-05-09', 120.75, 'Economy');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(6, 13, '2023-07-01', 210.50, 'First Class');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(7, 22, '2023-07-18', 95.00, 'Economy');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(8, 22, '2023-08-23', 175.25, 'Business');
INSERT INTO Tickets (user_id, tour_id, buy_date, ticket_price, seat_class)
VALUES
(9, 22, '2023-09-06', 130.00, 'Economy');
Select * from Users;
-- ���������� ������ � ������� Tours
INSERT INTO Tours (route_id, tourstart_datetime, tourend_datetime)
VALUES
(13, '2023-01-17 08:00:00', '2023-01-17 16:00:00'),
(14, '2023-02-22 09:00:00', '2023-02-22 17:00:00'),
(15, '2023-03-12 10:00:00', '2023-03-12 18:00:00'),
(16, '2023-04-27 11:00:00', '2023-04-27 19:00:00'),
(17, '2023-05-10 12:00:00', '2023-05-10 20:00:00'),
(21, '2023-06-01 13:00:00', '2023-06-01 21:00:00'),
(22, '2023-07-19 14:00:00', '2023-07-19 22:00:00'),
(23, '2023-08-24 15:00:00', '2023-08-24 23:00:00'),
(24, '2023-09-07 16:00:00', '2023-09-07 00:00:00'),
(25, '2023-10-20 17:00:00', '2023-10-20 01:00:00');
INSERT INTO Tours (route_id, tourstart_datetime, tourend_datetime)
VALUES
(26, '2023-05-11 08:00:00', '2023-05-11 16:00:00'),
(27, '2023-07-21 09:00:00', '2023-07-21 17:00:00'),
(28, '2023-09-14 10:00:00', '2023-09-14 18:00:00'),
(29, '2023-05-25 11:00:00', '2023-05-25 19:00:00'),
(30, '2023-07-17 12:00:00', '2023-07-17 20:00:00'),
(31, '2023-04-08 13:00:00', '2023-04-08 21:00:00'),
(32, '2023-09-13 14:00:00', '2023-09-13 22:00:00'),
(33, '2023-09-12 15:00:00', '2023-09-13 23:00:00'),
(34, '2023-10-12 16:00:00', '2023-10-14 00:00:00'),
(35, '2023-11-20 17:00:00', '2023-11-20 01:00:00');
Select * from Tours;
-- ���������� ������ � ������� Routes
INSERT INTO Routes (from_id, to_id, bus_id)
VALUES
(1, 2, 1),
(2, 3, 2),
(3, 4, 3),
(4, 5, 4),
(5, 6, 5);
INSERT INTO Routes (from_id, to_id, bus_id)
VALUES
(6, 1022, 6),
(1022, 1023, 7),
(1023, 1024, 8),
(1025, 1026, 9),
(1027, 1028, 10);
INSERT INTO Routes (from_id, to_id, bus_id)
VALUES
(6, 1031, 6),
(1022, 1035, 7),
(1023, 1039, 8),
(1025, 1039, 9),
(1027, 1042, 10);
INSERT INTO Routes (from_id, to_id, bus_id)
VALUES
(6, 1046, 6),
(1022, 1046, 7),
(1023, 1044, 8),
(1025, 1039, 9),
(1027, 1039, 10);
Select * from Routes;
-- ���������� ������ � ������� Points
DECLARE @child1 hierarchyid, @child2 hierarchyid;

SELECT @child1 = point_hierarchy FROM Points WHERE point_id = 2; -- ������������� Child 1
SELECT @child2 = point_hierarchy FROM Points WHERE point_id = 3; -- ������������� Child 2
EXEC AddSubordinate @child1, 'City C', 'Country A', 'Grandchild 1';
EXEC AddSubordinate @child1, 'City D', 'Country A', 'Grandchild 2';
EXEC AddSubordinate @child1, 'City E', 'Country A', 'Grandchild 3';
EXEC AddSubordinate @child1, 'City G', 'Country A', 'Grandchild 4';
EXEC AddSubordinate @child1, 'City H', 'Country A', 'Grandchild 5';
Select * from Points;
-- ���������� ����������� ����� ��� Child 2
EXEC AddSubordinate @child2, 'City F', 'Country B', 'Grandchild 6';
EXEC AddSubordinate @child2, 'City I', 'Country B', 'Grandchild 7';
EXEC AddSubordinate @child2, 'City J', 'Country B', 'Grandchild 8';
EXEC AddSubordinate @child2, 'City K', 'Country B', 'Grandchild 9';
EXEC AddSubordinate @child2, 'City L', 'Country B', 'Grandchild 10';


-- ���������� ������ � ������� Buses
INSERT INTO Buses (bus_number, bus_capacity)
VALUES
('Bus 001', 50),
('Bus 002', 40),
('Bus 003', 60),
('Bus 004', 55),
('Bus 005', 45),
('Bus 006', 65),
('Bus 007', 70),
('Bus 008', 30),
('Bus 009', 75),
('Bus 010', 35);




-----------2--------------------------------------
SELECT 
    DATEPART(YEAR, buy_date) AS Year,
    SUM(CASE WHEN DATEPART(MONTH, buy_date) = 1 THEN ticket_price ELSE 0 END) AS 'January',
    SUM(CASE WHEN DATEPART(MONTH, buy_date) = 2 THEN ticket_price ELSE 0 END) AS 'February',
	SUM(CASE WHEN DATEPART(MONTH, buy_date) = 3 THEN ticket_price ELSE 0 END) AS 'March',
    SUM(CASE WHEN DATEPART(MONTH, buy_date) = 4 THEN ticket_price ELSE 0 END) AS 'April',
	SUM(CASE WHEN DATEPART(MONTH, buy_date) = 5 THEN ticket_price ELSE 0 END) AS 'May',
    SUM(CASE WHEN DATEPART(MONTH, buy_date) = 6 THEN ticket_price ELSE 0 END) AS 'June',
	SUM(CASE WHEN DATEPART(MONTH, buy_date) = 7 THEN ticket_price ELSE 0 END) AS 'July',
    SUM(CASE WHEN DATEPART(MONTH, buy_date) = 8 THEN ticket_price ELSE 0 END) AS 'August',
	SUM(CASE WHEN DATEPART(MONTH, buy_date) = 9 THEN ticket_price ELSE 0 END) AS 'September',
    SUM(CASE WHEN DATEPART(MONTH, buy_date) = 10 THEN ticket_price ELSE 0 END) AS 'October',
	SUM(CASE WHEN DATEPART(MONTH, buy_date) = 11 THEN ticket_price ELSE 0 END) AS 'November',
    SUM(CASE WHEN DATEPART(MONTH, buy_date) = 12 THEN ticket_price ELSE 0 END) AS 'December',
    
    SUM(CASE WHEN DATEPART(QUARTER, buy_date) = 1 THEN ticket_price ELSE 0 END) AS 'Quarter 1',
    SUM(CASE WHEN DATEPART(QUARTER, buy_date) = 2 THEN ticket_price ELSE 0 END) AS 'Quarter 2',
	SUM(CASE WHEN DATEPART(QUARTER, buy_date) = 3 THEN ticket_price ELSE 0 END) AS 'Quarter 3',
	SUM(CASE WHEN DATEPART(QUARTER, buy_date) = 4 THEN ticket_price ELSE 0 END) AS 'Quarter 4',
    
    SUM(CASE WHEN ((DATEPART(MONTH, buy_date) + 5) / 6) = 1 THEN ticket_price ELSE 0 END) AS 'Half Year 1',
    SUM(CASE WHEN ((DATEPART(MONTH, buy_date) + 5) / 6) = 2 THEN ticket_price ELSE 0 END) AS 'Half Year 2',
    SUM(ticket_price) AS 'Year'
FROM Tickets
GROUP BY DATEPART(YEAR, buy_date)





------------3---------------------------------
CREATE VIEW ServiceComparison AS
SELECT 
    CAST(DATEPART(YEAR, tourstart_datetime) AS VARCHAR) AS year,
    RIGHT('00' + CAST(DATEPART(MONTH, tourstart_datetime) AS VARCHAR), 2) AS month,
    'Q' + CAST(DATEPART(QUARTER, tourstart_datetime) AS VARCHAR) AS quarter,
    'H' + CAST(((DATEPART(MONTH, tourstart_datetime) + 5) / 6) AS VARCHAR) AS half_year,
    SUM(ticket_price) AS total_sales
FROM Tours t
JOIN Tickets ti ON t.tour_id = ti.tour_id
GROUP BY DATEPART(YEAR, tourstart_datetime), DATEPART(MONTH, tourstart_datetime), DATEPART(QUARTER, tourstart_datetime), ((DATEPART(MONTH, tourstart_datetime) + 5) / 6)



Select * from ServiceComparison;

---------4------------------------------------
DECLARE @PageSize INT = 5, @PageNumber INT = 2;

WITH Results_CTE AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY user_id) AS RowNum,
        user_id,
        user_name,
        user_email
    FROM Users
)
SELECT * 
FROM Results_CTE
WHERE RowNum > (@PageSize * (@PageNumber - 1)) AND RowNum <= (@PageSize * @PageNumber)


-----5-------------------------------------------
WITH DeduplicatedData AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY point_id, point_hierarchy ORDER BY point_id) AS RowNum
    FROM Points
)

DELETE FROM DeduplicatedData
WHERE RowNum > 1; -- ��������� ������ ���������� ������


-----------6------------------------
WITH CountryVisits AS (
    SELECT Points.country, COUNT(*) as visit_count
    FROM Tickets
    JOIN Tours ON Tickets.tour_id = Tours.tour_id
    JOIN Routes ON Tours.route_id = Routes.route_id
    JOIN Points ON Routes.to_id = Points.point_id
    GROUP BY Points.country
),
TopCountries AS (
    SELECT TOP 2 country
    FROM CountryVisits
    ORDER BY visit_count DESC
),
ClientCountryVisits AS (
    SELECT Users.user_id, Points.country, COUNT(*) as visit_count
    FROM Users
    JOIN Tickets ON Users.user_id = Tickets.user_id
    JOIN Tours ON Tickets.tour_id = Tours.tour_id
    JOIN Routes ON Tours.route_id = Routes.route_id
    JOIN Points ON Routes.to_id = Points.point_id
    WHERE Points.country IN (SELECT country FROM TopCountries)
    GROUP BY Users.user_id, Points.country
),
PivotedData AS (
    SELECT user_id,
        MAX(CASE WHEN country = 'Country A' THEN visit_count ELSE 0 END) as 'Country �'

    FROM ClientCountryVisits
    GROUP BY user_id
)
SELECT * FROM PivotedData

--------------7----------
-- �������� ������� Sights
CREATE TABLE Sights (
    sight_id INT IDENTITY(1,1) PRIMARY KEY,
    route_id INT NOT NULL,
    sight_type VARCHAR(50) NOT NULL,
    FOREIGN KEY (route_id) REFERENCES Routes (route_id)
);

SELECT * from Routes;
-- ���������� ������� �������
INSERT INTO Sights (route_id, sight_type)
VALUES (13, '������������'),
       (14, '���������'),
       (14, '������������'),
       (16, '����������'),
       (16, '���������'),
       (16, '����������'),
       (16, '������������'),
       (16, '����������'),
	   (16, '����������'),
       (13, '������������'),
       (21, '���������'),
       (13, '������������'),
       (15, '����������'),
       (22, '���������'),
       (13, '������������'),
       (24, '����������'),
       (25, '���������'),
       (25, '������������'),
       (26, '����������'),
       (26, '���������'),
       (27, '������������'),
       (27, '����������'),
       (27, '���������'),
       (27, '������������'),
       (27, '����������'),
       (15, '���������'),
       (15, '������������');

SELECT sight_type, route_id, COUNT(*) as sight_count
FROM Sights
GROUP BY sight_type, route_id
ORDER BY sight_count DESC
