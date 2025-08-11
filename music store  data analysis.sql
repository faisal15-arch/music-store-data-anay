--Easy level queries


--Q.1 who is most senior employee on basis of job title
Select * from employee order by levels desc
limit 1

--Q.2 which country has most employees
Select Count(*),billing_country from invoice
group by billing_country order by count desc
limit  1


--Q.3 What are top 3 values of total invoices
Select total from invoice order by total desc limit 3



--Q.4 Which cities has best customers?We like to throw a music festival in
-- a city.we made most the money.Write a query that returns one city that has highest
-- sum of invoice total.
-- return both city_name and sum of all invoices totals


Select  SUM(total) as total_invoice from invoice group by billing_city
 order by billing_city desc limit 1


 --Q.5 who is the best customer?The customer who spent a most money declared 
 -- the best customer .Write a query that returns  the person who spends
 -- the most money.

Select customer.customer_id,customer.first_name,customer.last_name, 
SUM(invoice.total) as total from customer join invoice on customer.customer_id=invoice.customer_id
group by customer.customer_id order by total desc limit 1

 --Intermediate level queries

--Q.6 write the query to return email,first_name,last_name and genre of all rock music listener 
--return your list order alphabatecally by email strting with A
Select distinct email,first_name ,last_name from customer 
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id IN(
Select track_id from track
join genre on track.genre_id=genre.genre_id
where genre.name ilike '%rock%'
)
order by email;


--Q.7 let's invite the artists who have written the most rocks music in
-- our dataset .write a query that returns artist name and total track count of top
-- 10 rock bands
Select artist.artist_id ,artist.name,COUNT(artist.artist_id) as number_of_songs
from track join album on album.album_id =track.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name ilike '%rock%'
group by artist.artist_id 
order by number_of_songs desc
limit 10

--Q.8 return all the tracks that have song length longer than the average song length
--return name and millisecond of each track.order by song length with longest song
--listed first

SELECT name,milliseconds
from track
where milliseconds>(
Select avg(milliseconds) as avg_track_length
from track

)
order by milliseconds desc


--advance

-- Q.9find how many amount spent by each customer on arists? write query to
--return customer_name,artist_name and total spent

WITH best_selling_artist as (

SELECT artist.artist_id as artist_id,artist.name as artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales 
from invoice_line
join track on track.track_id =invoice_line.track_id
join album on album.album_id =track.album_id
join artist on artist.artist_id=album.artist_id
group by 1
order by 3 desc
limit 1
)

Select c.customer_id,c.first_name,c.last_name,bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id=il.track_id
join album alb on alb.album_id=t.album_id
join  best_selling_artist bsa on bsa.artist_id =alb.artist_id
group by 1,2,3,4
order by 5 desc


--Q.10) we want to find most popular music genre for each country
--we determine the most popular genre as genre with highest amount of prices
--write a query that returns each country along with each genre for countries where the maximum
--number of purchases is shared returned all genres

WITH sales_per_country AS (
 SELECT
   customer.country,genre.genre_id,genre.name AS genre_name,COUNT(*) AS purchases_per_genre  
 FROM invoice_line
 JOIN invoice  ON invoice.invoice_id  = invoice_line.invoice_id
 JOIN customer ON customer.customer_id = invoice.customer_id
 JOIN track    ON track.track_id     = invoice_line.track_id
 JOIN genre    ON genre.genre_id     = track.genre_id
 GROUP BY customer.country, genre.genre_id, genre.name
)
SELECT country, genre_id, genre_name, purchases_per_genre
FROM(
 SELECT *,ROW_NUMBER() OVER (PARTITION BY country ORDER BY purchases_per_genre DESC) AS rn
 FROM sales_per_country
) t
WHERE rn = 1
ORDER BY country;




