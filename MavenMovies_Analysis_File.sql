USE mavenmovies;

-- Pulling list of First Name, last name and email from each customers

SELECT
  first_name,
  last_name,
  email
FROM customer;

-- Pulling the rental durations of films to check what rental durations we have
SELECT distinct
     rental_duration
FROM Film;

-- Pulling out first 100 customers all payment records
SELECT
   payment_id,
   customer_id,
   rental_id,
   amount,
   payment_date
FROM payment
WHERE customer_id <= 100;

-- Pull out payments over 5 Dollars, for same customers, since Jan 1, 2006

SELECT 
    payment_id, 
    customer_id,
    rental_id,
    amount,
    payment_date
FROM payment
WHERE customer_id <= 100 
      AND amount > 5 
      AND payment_date >= '2006-01-01';
      
-- Pull out 42, 53, 60 and 75 customers along with payments over 5 dollars

SELECT 
    payment_id, 
    customer_id,
    rental_id,
    amount,
    payment_date
FROM payment
WHERE customer_id = 42 OR customer_id = 53 OR customer_id = 60 OR customer_id = 75
      OR amount > 5 ;
      
-- Pull a list of films which include behind the scenes special features?
SELECT
    title,
    special_features
FROM film 
WHERE special_features LIKE '%behind the scenes%';

-- Pulling out count of titles sliced by rental duration;

SELECT 
     rental_duration, 
     count(title) AS Films_with_this_rental_duration
FROM film
GROUP BY rental_duration;

-- Looking to know whether Maven Films charge more for rental when they have the replacement costs higher 

SELECT
    replacement_cost,
    COUNT(film_id),
    AVG(rental_rate),
    MIN(rental_rate),
    MAX(rental_rate)
FROM film
GROUP BY replacement_cost
ORDER BY replacement_cost DESC;

-- need the data about of customers who have not rented much from us to understand if there is something we could do better?

SELECT  
     customer_id,
     count(rental_id) AS total_rentals
FROM rental 
GROUP BY customer_id
HAVING count(rental_id) < 15;

-- Look if our longest films also tend to be our most expensive rentals.

SELECT 
    title, 
    length, 
    rental_rate
FROM film 
ORDER BY length DESC;

-- Creating lenth Buckets

SELECT DISTINCT
length, -- Selecting Variable
CASE   -- Defining Case Statemnet and case buckets below 
    WHEN length < 60 THEN 'unde 1 hour'
    WHEN length BETWEEN 60 AND 90 THEN '1-1.5 hours'
    WHEN length > 90 THEN 'over 1.5 hours'
    ELSE 'check logic' -- Catch all logic
    END AS length_bucket  -- Name for the column for above buckets 
FROM Film;

-- Good film to recommend for kids

SELECT DISTINCT 
	title,
    CASE 
        WHEN rental_duration <= 4 THEN 'rental_too_short'
        WHEN rental_rate >= 3.88 THEN 'too_expensive'
        WHEN rating IN ('NC-17', 'R') THEN 'too_adult'
        WHEN length NOT BETWEEN 60 and 90 THEN 'too short or too long'
        WHEN description like '%Shark%' THEN 'Nope has sharks'
        ELSE 'great recommendation for kid'
        END AS fit_to_recommend 
	FROM Film;
    
    -- Which store each customer goes to and whether or not they are active

SELECT * FROM customer;

SELECT 
    customer_id,
    first_name,
    last_name,
CASE
    WHEN store_id = 1 AND active = 1 THEN 'store 1 active'
    WHEN store_id = 1 AND active = 0 THEN 'store 1 inactive'
    WHEN store_id = 2 AND active = 1 THEN 'store 2 active'
    WHEN store_id = 2 AND active = 0 THEN 'store 2 inactive'
    ELSE 'Check your logic for this row'
END AS Customer_Status 
FROM customer;

-- Inventory of each film in both stores
-- Combining Count and Case statements

SELECT 
    film_id, 
    COUNT(CASE WHEN store_id = 1 THEN inventory_id ELSE NULL END) as Store_1_Movie_Inventory,
    COUNT(CASE WHEN store_id = 2 THEN inventory_id ELSE NULL END) as Store_2_Movie_Inventory,
    COUNT(inventory_id) AS total_copies 
FROM inventory 
GROUP BY film_id 
ORDER BY film_id;

-- Find out how many inactive customers are present in each store
SELECT * FROM customer;

SELECT
     store_id,
     COUNT(CASE WHEN active = 1 AND store_id in (1,2) THEN customer_id ELSE NULL END) AS active_customers,
     COUNT(CASE WHEN active = 0 AND store_id in (1,2) THEN customer_id ELSE NULL END) AS inactive_customers
FROM customer
GROUP BY store_id
ORDER BY store_id;

-- MID COURSE PROJECT -- ANSWERING THE BELOW QUESTIONS 
-- SQL CODE FOR LIST OF ALL STAFF MEMBERS, include first name, last name, email, and store identification where they work:

SELECT 
      first_name, 
      last_name,
      email,
      store_id 
FROM staff;
     
-- Seprate counts of inventory held at each of the stores 

SELECT 
     store_id,
     COUNT(CASE WHEN store_id in (1,2) THEN inventory_id ELSE NULL END) as inventory_levels
FROM inventory 
GROUP BY store_id
ORDER BY store_id; 

-- active customers in each store 
SELECT 
     store_id, 
     COUNT(CASE WHEN store_id IN (1,2) AND active = 1 THEN customer_id ELSE NULL END) as No_active_customers
FROM customer
GROUP BY store_id
ORDER BY store_id;

-- count of customers email address
SELECT 
     COUNT(email)
FROM 
	Customer;
    
-- How diverse the film offering 
SELECT
    store_id,
	COUNT(film_id) AS Unique_Film_Titles
FROM inventory
GROUP BY store_id;

SELECT COUNT(category_id) AS Unique_categories FROM category;

-- Replacment cost of films 
SELECT
     MIN(replacement_cost) AS min_cost,
     MAX(replacement_cost) AS max_cost,
     AVG(replacement_cost) AS avg_cost
FROM film;

-- Payment monitoring system 
SELECT 
	 AVG(amount) as avg_payments, 
     MAX(amount) as max_payment
FROM payment;

SELECT 
     customer_id,
     COUNT(rental_id) as No_of_rentals
FROM rental 
GROUP BY customer_id
ORDER BY COUNT(rental_id);
    

-- Pull out a list of each film we have in invetory 
SELECT 
      f.title,
      f.description,
      i.inventory_id,
      i.store_id
FROM film AS F 
	INNER JOIN inventory AS I ON F.film_id = I.film_id;

-- How many actors are associated with each title 

SELECT
      F.film_id,
      F.title,
      COUNT(FA.actor_id) AS no_of_actors
      FROM film AS F
      LEFT JOIN film_actor AS FA ON F.film_id = FA.film_id
      GROUP BY F.film_id, F.title;
      
-- Create a table with list of actors and each title they appear in


SELECT
	A.first_name,
     A.last_name,
     F.title
     FROM film AS F 
     INNER JOIN film_actor AS FA ON F.film_id = FA.film_id 
     INNER JOIN Actor AS A ON FA.actor_id = A.actor_id;
    
-- Pull out distinct titles and descriptions available at store 2

SELECT
    F.title,
    F.description 
    FROM film AS F 
    INNER JOIN inventory as I ON F.film_id = I.film_id 
    and store_id = 2;
      
-- Pull the list of Staff and Advisors on top of each other 
SELECT 
	'STAFF' AS Type,
    first_name,
    last_name 
FROM staff

UNION ALL 

SELECT 
    'Advisor' AS Type,
    first_name, 
    last_name
FROM advisor;
      
      
-- Final Project
-- 1 Managers Name and address of each store
	
    SELECT 
       S.first_name, 
       S.last_name,
       St.store_id,
       A.address,
       C.city,
       A.district,
       Cr.country
       FROM Store AS St 
       LEFT JOIN Staff AS S ON St.manager_staff_id = S.staff_id
       LEFT JOIN address AS A ON St.address_id = A.address_id 
       LEFT JOIN city AS C ON C.city_id = A.city_id 
       LEFT JOIN country AS Cr ON C.country_id = Cr.country_id;

/* 2 Pull out a together of each inventory item that is stocked in store, 
with store number, inventory number, name of the film, film rating,
rental rate and replacement cost */

SELECT
     I.store_id,
     I.inventory_id,
     F.title,
     F.rating,
     F.rental_rate,
     F.replacement_cost
FROM inventory AS I 
     LEFT JOIN film AS F ON I.film_id = F.film_id;


-- 3 From the above data roll up to how many inventory items with each rating at each store?

SELECT
     F.rating,
     I.store_id,
     Count(I.inventory_id) AS inventory_count
FROM inventory AS I 
      LEFT JOIN film AS F ON I.film_id = F.film_id
	GROUP BY F.rating, I.store_id;

/* 4How diversified the inventory is? Get the number of films, as well as average replacement cost 
and the total replacement cost sliced by store and film category */

SELECT 
	 I.store_id,
     C.name,
     COUNT(I.inventory_id) AS films,
     AVG(F.replacement_cost) AS avg_replacementcost_category,
     SUM(F.replacement_cost) AS total_replacementcost_category
FROM inventory AS I 
	LEFT JOIN film AS F ON I.film_id = F.film_id 
    LEFT JOIN film_category AS FC ON F.film_id = FC.film_id 
    LEFT JOIN category AS C ON FC.category_id = C.category_id
GROUP BY I.store_id, C.name ;

-- 5 List of all customer names, which stores they go, whether or not active, full address
SELECT 
	C.first_name, 
    C.last_name, 
    C.store_id,
    C.active,
    A.address,
    A.address2,
    Ct.city,
    A.district,
    Cr.Country
	FROM customer AS C 
    LEFT JOIN Address AS A ON C.address_id = A.address_id 
    LEFT JOIN City AS Ct ON A.city_id = CT.city_id 
    LEFT JOIN Country AS Cr ON CT.country_id = CR.country_id;

-- 6 How much are customers are spending and most valuable customer  

SELECT 
     C.first_name,
     C.last_name,
     COUNT(P.rental_id) AS total_rentals,
     SUM(P.amount) AS total_payments
     FROM customer AS C  
	LEFT JOIN payment AS P ON C.customer_id = P.customer_id
GROUP BY C.first_name, C.last_name
ORDER BY SUM(P.amount) DESC;

-- 7 Pull out the list of investors and advisors in one table 

SELECT 'Advisor' AS Type, first_name, last_name, company_name from investor
UNION ALL
SELECT 'Investor' AS type, first_name, last_name, NUll FROM advisor;

/* Of all the actors with three types of awards, for what % of them do we carry a film */

SELECT * FROM actor_award;

SELECT 
      CASE
          WHEN awards = 'Emmy, Oscar, Tony ' THEN '3 Awards'
          WHEN awards in ('Emmy, Oscar', 'Emmy, Tony', 'Oscar, Tony') THEN '2 Awards'
          ELSE '1 Award'
	 END AS number_of_awards,
	AVG(CASE WHEN actor_id IS NULL THEN 0 ELSE 1 END) AS pct

FROM actor_award
GROUP BY
	CASE
          WHEN awards = 'Emmy, Oscar, Tony ' THEN '3 Awards'
          WHEN awards in ('Emmy, Oscar', 'Emmy, Tony', 'Oscar, Tony') THEN '2 Awards'
          ELSE '1 Award'
	END ;
