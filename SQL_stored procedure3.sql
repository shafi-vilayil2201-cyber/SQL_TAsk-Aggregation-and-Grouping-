
--Stored Procedure — Get All Book Titles
CREATE PROCEDURE GetAllBookTitles
AS
BEGIN
    SELECT Title
    FROM Books;
END;

EXEC GetAllBookTitles;

--Stored Procedure — Get Books by Specific Author

CREATE PROCEDURE GetBooksByAuthor
    @AuthorName VARCHAR(255)
AS
BEGIN
    SELECT 
        BookId,
        Title,
        Author,
        Price
    FROM Books
    WHERE Author = @AuthorName;
END;

EXEC GetBooksByAuthor @AuthorName = 'Martin Fowler';

--Function — Return Number of Books by Author
CREATE FUNCTION GetBookCountByAuthor
(
    @AuthorName VARCHAR(255)
)
RETURNS INT
AS
BEGIN
    DECLARE @BookCount INT;

    SELECT @BookCount = COUNT(*)
    FROM Books
    WHERE Author = @AuthorName;

    RETURN @BookCount;
END;

SELECT dbo.GetBookCountByAuthor('Robert C. Martin') AS TotalBooks;

