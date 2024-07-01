--Schemas
CREATE TABLE artists (
    artist_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    birth_year INT NOT NULL
);

CREATE TABLE artworks (
    artwork_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    artist_id INT NOT NULL,
    genre VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    artwork_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id)
);

INSERT INTO artists (artist_id, name, country, birth_year) VALUES
(1, 'Vincent van Gogh', 'Netherlands', 1853),
(2, 'Pablo Picasso', 'Spain', 1881),
(3, 'Leonardo da Vinci', 'Italy', 1452),
(4, 'Claude Monet', 'France', 1840),
(5, 'Salvador Dalí', 'Spain', 1904);

INSERT INTO artworks (artwork_id, title, artist_id, genre, price) VALUES
(1, 'Starry Night', 1, 'Post-Impressionism', 1000000.00),
(2, 'Guernica', 2, 'Cubism', 2000000.00),
(3, 'Mona Lisa', 3, 'Renaissance', 3000000.00),
(4, 'Water Lilies', 4, 'Impressionism', 500000.00),
(5, 'The Persistence of Memory', 5, 'Surrealism', 1500000.00);

INSERT INTO sales (sale_id, artwork_id, sale_date, quantity, total_amount) VALUES
(1, 1, '2024-01-15', 1, 1000000.00),
(2, 2, '2024-02-10', 1, 2000000.00),
(3, 3, '2024-03-05', 1, 3000000.00),
(4, 4, '2024-04-20', 2, 1000000.00);

SELECT * from artists
SELECT * from sales
SELECT * from artworks


-- ### Section 1: 1 mark each

-- 1. Write a query to calculate the price of 'Starry Night' plus 10% tax.
SELECT title,price * 1.1 from artworks 
where title = 'Starry Night';

-- 2. Write a query to display the artist names in uppercase.
SELECT UPPER(name) from artists;

-- 3. Write a query to extract the year from the sale date of 'Guernica'.
select Datepart(year,s.sale_date) from sales s
where s.artwork_id = (select aw.artwork_id from artworks aw
                        where aw.title = 'Guernica');

-- 4. Write a query to find the total amount of sales for the artwork 'Mona Lisa'.
select s.total_amount from sales s
where s.artwork_id = (select aw.artwork_id from artworks aw
                        where aw.title = 'Mona Lisa');

-- ### Section 2: 2 marks each

-- 5. Write a query to find the artists who have sold more artworks than the average number of artworks sold per artist.
SELECT aw.artist_id,count(quantity) from sales s
join artworks aw on aw.artwork_id = s.artwork_id
group by artist_id
having count(quantity) > (select avg(quantity) from sales);

-- 6. Write a query to display artists whose birth year is earlier than the average birth year of artists from their country.
select name,country,birth_year from artists
group by name,country,birth_year
having birth_year < (select avg(birth_year) from artists);


-- 7. Write a query to create a non-clustered index on the `sales` table to improve query performance for queries filtering by `artwork_id`.
CREATE INDEX idx_artwork_id
on sales
BEGIN
    select artwork_id from sales;
end;

-- 8. Write a query to display artists who have artworks in multiple genres.
SELECT a.artist_id,a.name from artists a
where exists(select genre from artworks aw
                GROUP by genre
                having count(distinct(genre)) > 1)

-- 9. Write a query to rank artists by their total sales amount and display the top 3 artists.
with cte
as (
    SELECT a.artist_id, a.name, s.total_amount,
    Rank() over (partition by a.name order by s.total_amount desc) as ranking
    from artists a
    join artworks aw on a.artist_id = aw.artist_id
    join sales s on s.artwork_id = aw.artwork_id
)
select * from cte 
where ranking <= 3;

-- 10. Write a query to find the artists who have created artworks in both 'Cubism' and 'Surrealism' genres.
select name from artists a
join artworks aw on a.artist_id = aw.artist_id
where genre = 'Cubism' and genre = 'Surrealism';

-- 11. Write a query to find the top 2 highest-priced artworks and the total quantity sold for each.
select aw.artwork_id,aw.title,s.quantity,
RANK() over (partition by aw.artwork_id order by aw.price desc) as ranking
from artworks aw
join sales s on aw.artwork_id = s.artwork_id

-- 12. Write a query to find the average price of artworks for each artist.
select a.artist_id, avg(price) as avg_price from artworks aw
join artists a on aw.artist_id = a.artist_id
group by a.artist_id;

-- 13. Write a query to find the artworks that have the highest sale total for each genre.
SELECT aw.genre,sum(s.total_amount) from artworks aw 
join sales s on aw.artwork_id = s.artwork_id
group by genre
order by sum(total_amount) desc

-- 14. Write a query to find the artworks that have been sold in both January and February 2024.
SELECT * from artworks aw
join sales s on aw.artwork_id = s.artwork_id
group by s.sale_date


-- 15. Write a query to display the artists whose average artwork price is higher than every artwork price in the 'Renaissance' genre.
SELECT a.artist_id,a.name, genre from artists a
join sales s on aw.artwork_id = s.artwork_id


-- ### Section 3: 3 Marks Questions

-- 16. Write a query to create a view that shows artists who have created artworks in multiple genres.
GO
create view multitalented
as
select * from artists a
    where exists(select genre from artworks aw
                            GROUP by genre
                            having count(distinct(genre)) > 1);
GO

-- 17. Write a query to find artworks that have a higher price than the average price of artworks by the same artist.
select artwork_id from artworks aw
group by price
having price > (select artist_id,avg(price) from artworks
                group by artist_id)


-- 18. Write a query to find the average price of artworks for each artist and only include artists whose average artwork price is higher than the overall average artwork price.
select artist_id, avg(price) from artworks
group by artist_id
having avg(price) > (select avg(price) from artworks)

-- ### Section 4: 4 Marks Questions

-- 19. Write a query to export the artists and their artworks into XML format.

-- 20. Write a query to convert the artists and their artworks into JSON format.

-- ### Section 5: 5 Marks Questions

-- 21. Create a multi-statement table-valued function (MTVF) to return the total quantity sold for each genre and use it in a query to display the results.

-- 22. Create a scalar function to calculate the average sales amount for artworks in a given genre and write a query to use this function for 'Impressionism'.
CREATE FUNCTION Impressionism(@genre varchar(20))
returns 
BEGIN

end

-- 23. Write a query to create an NTILE distribution of artists based on their total sales, divided into 4 tiles.

-- 24. Create a trigger to log changes to the `artworks` table into an `artworks_log` table, capturing the `artwork_id`, `title`, and a change description.
go
CREATE TRIGGER trg_artworks_log
on artworks
after update
as
BEGIN
    select artwork_id, title, 'change description' into inserted
end
go

-- 25. Create a stored procedure to add a new sale and update the total sales for the artwork. Ensure the quantity is positive, and use transactions to maintain data integrity.
go
create PROCEDURE sp_salesss
as 
BEGIN
    BEGIN TRANSACTION
        BEGIN TRY
            IF(sales.quantity <= 0)
             THROW (5000,'quantity should be negative',1);
            insert into sales (5,5,'2024-04-29',1,3000000);
        END TRY;
        BEGIN CATCH
            RAISERROR
        End CATCH;
    END;
END
GO

-- ### Normalization (5 Marks)

-- 26. **Question:**
--     Given the denormalized table `ecommerce_data` with sample data:

-- | id  | customer_name | customer_email      | product_name | product_category | product_price | order_date | order_quantity | order_total_amount |
-- | --- | ------------- | ------------------- | ------------ | ---------------- | ------------- | ---------- | -------------- | ------------------ |
-- | 1   | Alice Johnson | alice@example.com   | Laptop       | Electronics      | 1200.00       | 2023-01-10 | 1              | 1200.00            |
-- | 2   | Bob Smith     | bob@example.com     | Smartphone   | Electronics      | 800.00        | 2023-01-15 | 2              | 1600.00            |
-- | 3   | Alice Johnson | alice@example.com   | Headphones   | Accessories      | 150.00        | 2023-01-20 | 2              | 300.00             |
-- | 4   | Charlie Brown | charlie@example.com | Desk Chair   | Furniture        | 200.00        | 2023-02-10 | 1              | 200.00             |

-- Normalize this table into 3NF (Third Normal Form). Specify all primary keys, foreign key constraints, unique constraints, not null constraints, and check constraints.
-- Not Null
-- customer_name
-- customer_email
-- product_name
-- product_category
-- product_price
-- order_date
-- order_quantity
-- order_total_amount

-- Unique
-- customer_email
-- product_name, products.product_category (combined)

-- Check
-- product_price >= 0
-- order_quantity > 0
-- order_total_amount >= 0

create table customers
(cid int primary key IDENTITY(1,1),
customer_name varchar(60) not null,
customer_email nvarchar(60) unique not null);

create table products
(product_id int primary key IDENTITY(101,1),
cid int foreign key REFERENCES customers,
product_name varchar(60) unique not null,
product_category varchar(60) unique not null,
product_price DECIMAL(18,2) not null);

create table orderss
(order_id int primary key IDENTITY(3001,1),
product_id int FOREIGN key REFERENCES products,
order_date date not null,
order_quantity int not null,
order_total_amount DECIMAL(18,2) not null);

create table report
(report_id int primary key IDENTITY(201,1),
cid int FOREIGN key REFERENCES customers,
product_id int FOREIGN key REFERENCES customers,
order_id int FOREIGN key REFERENCES customers,)



-- ### ER Diagram (5 Marks)

-- 27. Using the normalized tables from Question 26, create an ER diagram. Include the entities, relationships, primary keys, foreign keys, unique constraints, not null constraints, and check constraints. Indicate the associations using proper ER diagram notation.

