CREATE TABLE Authors (

    AuthorId INT PRIMARY KEY,

    AuthorName VARCHAR(255)

);

CREATE TABLE Books (

    BookId INT PRIMARY KEY,

    Title VARCHAR(255),

    AuthorId INT,

    FOREIGN KEY (AuthorId)

    REFERENCES Authors(AuthorId)

);


CREATE TABLE BookCopies (

    CopyId INT PRIMARY KEY,

    BookId INT,

    AvailableStatus BIT DEFAULT 1,

    FOREIGN KEY (BookId)

    REFERENCES Books(BookId)

);

CREATE TABLE Users (
    UserId INT PRIMARY KEY,
    UserName VARCHAR(255)
);


CREATE TABLE Borrowing (
    BorrowId INT PRIMARY KEY IDENTITY(1,1),
    UserId INT,
    CopyId INT,
    BorrowDate DATE DEFAULT GETDATE(),
    ReturnDate DATE NULL,

    FOREIGN KEY (UserId)
    REFERENCES Users(UserId),

    FOREIGN KEY (CopyId)
    REFERENCES BookCopies(CopyId)
);

INSERT INTO Authors (AuthorId, AuthorName)
VALUES
(1, 'Robert C. Martin'),
(2, 'Martin Fowler');

INSERT INTO BookCopies (CopyId, BookId, AvailableStatus)
VALUES
(101, 1, 1),
(102, 1, 1),
(201, 2, 1);


INSERT INTO Users (UserId, UserName)
VALUES
(1, 'Shafi'),
(2, 'Rahul');

SELECT * FROM INFORMATION_SCHEMA.TABLES;

--Stored Procedure — Checkout Book

CREATE OR ALTER PROCEDURE CheckoutBook
    @UserId INT,
    @CopyId INT
AS
BEGIN

    IF EXISTS (
        SELECT 1
        FROM BookCopies
        WHERE CopyId = @CopyId
        AND AvailableStatus = 1
    )
    BEGIN

        INSERT INTO Borrowing (
            UserId,
            CopyId,
            BorrowDate
        )
        VALUES (
            @UserId,
            @CopyId,
            GETDATE()
        );

        UPDATE BookCopies
        SET AvailableStatus = 0
        WHERE CopyId = @CopyId;

        PRINT 'Book checked out successfully';

    END
    ELSE
    BEGIN
        PRINT 'Book is not available';
    END

END;


--Execute Checkout
EXEC CheckoutBook
    @UserId = 1,
    @CopyId = 101;

--Stored Procedure — Return Book
CREATE OR ALTER PROCEDURE ReturnBook
    @UserId INT,
    @CopyId INT
AS
BEGIN

    UPDATE Borrowing
    SET ReturnDate = GETDATE()
    WHERE UserId = @UserId
    AND CopyId = @CopyId
    AND ReturnDate IS NULL;

    UPDATE BookCopies
    SET AvailableStatus = 1
    WHERE CopyId = @CopyId;

    PRINT 'Book returned successfully';

END;



EXEC ReturnBook
    @UserId = 1,
    @CopyId = 101;



--Function — Number of Books by Author
CREATE OR ALTER FUNCTION GetBookCountByAuthor
(
    @AuthorId INT
)
RETURNS INT
AS
BEGIN

    DECLARE @BookCount INT;

    SELECT @BookCount = COUNT(*)
    FROM Books
    WHERE AuthorId = @AuthorId;

    RETURN @BookCount;

END;


SELECT dbo.GetBookCountByAuthor(1) AS TotalBooks;


CREATE OR ALTER FUNCTION GetOverdueBorrowings()
RETURNS TABLE
AS
RETURN
(
    SELECT
        b.BorrowId,
        u.UserName,
        bk.Title,
        b.BorrowDate
    FROM Borrowing b

    INNER JOIN Users u
        ON b.UserId = u.UserId

    INNER JOIN BookCopies bc
        ON b.CopyId = bc.CopyId

    INNER JOIN Books bk
        ON bc.BookId = bk.BookId

    WHERE b.ReturnDate IS NULL
    AND DATEDIFF(DAY, b.BorrowDate, GETDATE()) > 7
);


--

SELECT * FROM dbo.GetOverdueBorrowings();