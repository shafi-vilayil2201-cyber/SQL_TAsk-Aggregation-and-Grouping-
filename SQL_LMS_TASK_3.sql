


CREATE TABLE Books (
    BookId INT PRIMARY KEY,
    Title VARCHAR(255),
    Author VARCHAR(255),
    Price DECIMAL(10,2)
);

CREATE TABLE Sales (
    SaleId INT PRIMARY KEY IDENTITY(1,1),
    BookId INT,
    SaleDate DATE,
    SaleAmount DECIMAL(10,2),

    FOREIGN KEY (BookId) REFERENCES Books(BookId)
);


SELECT 
    b.BookId,
    b.Title,
    SUM(s.SaleAmount) AS TotalSales
FROM Sales s
JOIN Books b ON s.BookId = b.BookId
GROUP BY b.BookId, b.Title;


SELECT 
    b.BookId,
    b.Title,
    YEAR(s.SaleDate) AS SaleYear,
    SUM(s.SaleAmount) AS TotalSales
FROM Sales s
JOIN Books b ON s.BookId = b.BookId
GROUP BY b.BookId, b.Title, YEAR(s.SaleDate)
ORDER BY b.BookId, SaleYear;

SELECT 
    b.BookId,
    b.Title,
    SUM(s.SaleAmount) AS TotalSales
FROM Sales s
JOIN Books b ON s.BookId = b.BookId
GROUP BY b.BookId, b.Title
HAVING SUM(s.SaleAmount) > 10000;


CREATE PROCEDURE GetTotalSalesByTitle
    @Title VARCHAR(255)
AS
BEGIN
    SELECT 
        b.Title,
        SUM(s.SaleAmount) AS TotalSales
    FROM Sales s
    JOIN Books b ON s.BookId = b.BookId
    WHERE b.Title = @Title
    GROUP BY b.Title;
END;

EXEC GetTotalSalesByTitle @Title = 'Clean Code';


CREATE FUNCTION GetAverageSaleAmount (@BookId INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @AvgAmount DECIMAL(10,2);

    SELECT @AvgAmount = AVG(SaleAmount)
    FROM Sales
    WHERE BookId = @BookId;

    RETURN @AvgAmount;
END;


SELECT dbo.GetAverageSaleAmount(1) AS AvgSale;


CREATE INDEX idx_sales_bookid ON Sales(BookId);
CREATE INDEX idx_sales_date ON Sales(SaleDate);


INSERT INTO Books (BookId, Title, Author, Price) VALUES
(1, 'Clean Code', 'Robert C. Martin', 500.00),
(2, 'The Pragmatic Programmer', 'Andrew Hunt', 650.00),
(3, 'Design Patterns', 'Erich Gamma', 800.00),
(4, 'Refactoring', 'Martin Fowler', 700.00);

INSERT INTO Sales (BookId, SaleDate, SaleAmount) VALUES
-- Clean Code
(1, '2024-01-10', 500.00),
(1, '2024-03-15', 520.00),
(1, '2025-02-20', 510.00),

-- Pragmatic Programmer
(2, '2024-02-05', 650.00),
(2, '2024-06-18', 670.00),
(2, '2025-01-25', 660.00),

-- Design Patterns
(3, '2024-04-12', 800.00),
(3, '2025-03-08', 820.00),

-- Refactoring
(4, '2024-05-20', 700.00),
(4, '2025-02-11', 720.00),
(4, '2025-04-01', 710.00);