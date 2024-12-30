--TSQL 15

CREATE PROCEDURE MoviesByProductionCompany
    @CompanyId INT  -- input parameter for company ID
AS
BEGIN
SELECT 
        m.movie_id,
        m.title,
        m.release_date,
        m.runtime,
        m.popularity,
        pc.company_name AS ProductionCompany
FROM  movie as m
INNER JOIN movie_company as mc ON m.movie_id = mc.movie_id
INNER JOIN production_company as pc ON mc.company_id = pc.company_id
WHERE pc.company_id = @CompanyId
ORDER BY m.movie_id;
END;
GO


EXEC MoviesByProductionCompany @CompanyId = 5;


--Using Output Parameters in Stored Procedures
create procedure get_average_revenue_by_genre
    @genre_name nvarchar(100),  -- input parameter for genre name
    @average_revenue money output  -- output parameter to hold the average revenue
as begin
    set nocount on; 
    select @average_revenue = avg(m.revenue)
    from movie m
    inner join movie_genres mg on m.movie_id = mg.movie_id
    inner join genre g on mg.genre_id = g.genre_id
    where g.genre_name = @genre_name;
    if @@rowcount = 0
        set @average_revenue = null;
end;
go



declare @avg_revenue money;
exec get_average_revenue_by_genre @genre_name = 'Action', @average_revenue = @avg_revenue output;
select 'The average revenue for Action genre is: ' + cast(@avg_revenue as varchar);


--Executing Stored Procedures with Optional Parameters
create procedure search_movies
    @genre_name nvarchar(100) = null,  -- Optional parameter for genre name
    @release_year int = null          -- Optional parameter for release year
as begin
select 
        m.movie_id,
        m.title,
        m.release_date,
        m.revenue,
        g.genre_name
from movie as m
left join movie_genres as mg on m.movie_id = mg.movie_id
left join genre as g on mg.genre_id = g.genre_id
where (@genre_name is null or g.genre_name = @genre_name)
and (@release_year is null or year(m.release_date) = @release_year)
order by  m.release_date desc;
end;
go

-- Execute with only genre
exec search_movies @genre_name = 'Action';

-- Execute without any parameters
exec search_movies;


-- Error Handling in Stored Procedures with TRY…CATCH
CREATE PROCEDURE AddMovie
    @Title NVARCHAR(255),
    @Budget DECIMAL
AS
BEGIN
DECLARE @ErrorMessage NVARCHAR(4000);
-- Starts the TRY block
BEGIN TRY
        INSERT INTO movie (title, budget)
        VALUES (@Title, @Budget);
        SELECT 'Movie added successfully!' AS Message;
    END TRY
    BEGIN CATCH
        SET @ErrorMessage = ERROR_MESSAGE();
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            @ErrorMessage AS ErrorMessage;
-- Print the error message
        PRINT 'An error occurred: ' + @ErrorMessage;
    END CATCH
END;
GO

EXEC AddMovie @Title = 'New Sci-Fi Movie', @Budget = 1500000;

EXEC AddMovie @Title = 'New Drama Movie', @Budget = -500000;