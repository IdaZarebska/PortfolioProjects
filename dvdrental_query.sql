/*1. FILM
Which film is the most popular? 
Why (release_year, rental_rate, rating, category, replacement_cost)? 
Which film is the most popular grouped by stores?
Which film is the least popular? Why?
Which film is the most popular grouped by stores?
Which actor stares in the highest number of films?
Which actor stares in the best/worst films?*/
SELECT *
  FROM film
 LIMIT 10;
 
/*There are 1000 records.*/
SELECT count(*)
  FROM film;

/*There are no null values in the film table.*/
SELECT *
FROM film
WHERE title IS NULL
      OR description IS NULL
	  OR language_id IS NULL
	  OR release_year IS NULL
	  OR rental_duration IS NULL
	  OR rental_rate IS NULL
	  OR length IS NULL
	  OR replacement_cost IS NULL
	  OR rating IS NULL
	  OR special_features IS NULL
	  OR fulltext IS NULL
LIMIT 10;

/*There are 200 actors in the actor table.*/
SELECT COUNT(*)
  FROM actor;

/*There are no missing values in the actor table.*/
SELECT *
  FROM actor
 WHERE first_name IS NULL
       OR last_name IS NULL
LIMIT 10;

/*There are 6 languages in the language table:
English, Italian, Japanese, Mandarin, French and German.*/
SELECT COUNT(*)
  FROM language;

SELECT *
  FROM language;

/*There are 16 categories in the category table:
action, animation, children, classics, comady,
documentary, drama, family, foreign, games, horror,
music, new, sci-fi, sports, and travel.*/
SELECT COUNT(*)
  FROM category;

SELECT *
  FROM category

/*All the film were released in 2006.*/
SELECT min(release_year),
	   max(release_year)
  FROM film;

/*Short titles prevail, with the mean of 14 characters per title.*/
SELECT avg(length(title)), 
       min(length(title)), 
	   max(length(title))
  FROM film;

/*Although there are 6 different languages listed in the language table,
only one of them is actually listed in the film table: English
(language_id = 1).*/
SELECT DISTINCT COUNT(language_id)
  FROM film;
  
SELECT DISTINCT name
  FROM language
 WHERE language_id = 1;

/*On average, a film can be rented for 5 days, 
with 3 days minimum and 7 days maximum.*/
SELECT avg(rental_duration), 
       min(rental_duration), 
	   max(rental_duration),
	   percentile_disc(.5) WITHIN GROUP (ORDER BY rental_duration) AS median,
	   stddev(rental_duration)
  FROM film;

/*On average, rental_rate is 3, 
with 0.99 minimum and 4.99 maximum*/
SELECT avg(rental_rate), 
       min(rental_rate), 
	   max(rental_rate),
	   percentile_disc(.5) WITHIN GROUP (ORDER BY rental_rate) AS median,
	   stddev(rental_rate)
  FROM film;

/*On average, films are 115 minutes long.
The longest film has 185 minutes, the shortest 46 minutes.*/
SELECT avg(length), 
       min(length), 
	   max(length),
	   percentile_disc(.5) WITHIN GROUP (ORDER BY length) AS median,
	   stddev(length)
  FROM film;

/*Replacement cost amounts to 20 on average,
with 9.99 minimum and 29.99 maximum.
The median is 19.99, and the standard deviation 6.*/
SELECT avg(replacement_cost), 
       min(replacement_cost), 
	   max(replacement_cost),
	   percentile_disc(.5) WITHIN GROUP (ORDER BY replacement_cost) AS median,
	   stddev(replacement_cost)
  FROM film;

/*There are 5 distinct rating categories:
G, PG, PG-13, R, and NC-17.
The most popular is PG-13, and the least popular is G.*/
SELECT DISTINCT rating, count(rating)
  FROM film
 GROUP BY rating;

/*There seems to be no correlation between the length of the film
and the number of days you are allowed to rent it for.*/
SELECT corr(length, rental_duration)
  FROM film;

/*There is also no correlation between the replacement cost and
the rental duration allowed.*/
SELECT corr(replacement_cost, rental_duration)
  FROM film;

/*Finally, there is no correlation between the replacement cost
and the length of the film.*/
SELECT corr(replacement_cost, length)
  FROM film;
  
SELECT *
  FROM category;

/*The category with the highest number of films is
Sports, with 74 films.
The category with the lowest number of films is
Music, with 51 films.*/
SELECT c.name, COUNT(*) AS films_in_category
  FROM film AS f
       LEFT JOIN film_category AS fc
	   ON fc.film_id = f.film_id
	   LEFT JOIN category AS c
	   ON c.category_id = fc.category_id
 GROUP BY c.name
ORDER BY COUNT(*) DESC;

/*The category with the highest average rental rate is
Games, with the average rental rate of 3.25.
The category with the lowest average rental rate is 
Action, with the average rental rate of 2.47.*/
SELECT c.name, 
       AVG(rental_rate) AS avg_rental_rate
  FROM film AS f
       LEFT JOIN film_category AS fc
	   ON fc.film_id = f.film_id
	   LEFT JOIN category AS c
	   ON c.category_id = fc.category_id
 GROUP BY c.name
 ORDER BY avg_rental_rate DESC;

/*Films with the Travel category can be rented
for the longest period of time (5.35 days),
while films with the Sports category can be rented
for the shortest period of time (4.71 days).*/
SELECT c.name, 
       AVG(rental_duration) AS avg_rental_duration
  FROM film AS f
       LEFT JOIN film_category AS fc
	   ON fc.film_id = f.film_id
	   LEFT JOIN category AS c
	   ON c.category_id = fc.category_id
 GROUP BY c.name
 ORDER BY avg_rental_duration DESC;

/*The longest films are from the Sports category (128.2 minutes on average),
the shortests films are from the Sci-Fi category (108.2 minutes on average).*/
SELECT c.name, 
       AVG(length) AS avg_length
  FROM film AS f
       LEFT JOIN film_category AS fc
	   ON fc.film_id = f.film_id
	   LEFT JOIN category AS c
	   ON c.category_id = fc.category_id
 GROUP BY c.name
 ORDER BY avg_length DESC;

/*The average replacement cost is the highest for
Sci-Fi movies (21.53) and the lowest for
Foreign movies (18.65).*/
SELECT c.name, 
       AVG(replacement_cost) AS avg_replacement_cost
  FROM film AS f
       LEFT JOIN film_category AS fc
	   ON fc.film_id = f.film_id
	   LEFT JOIN category AS c
	   ON c.category_id = fc.category_id
 GROUP BY c.name
 ORDER BY avg_replacement_cost DESC;

/*The most popular rating of all films is PG-13 (223 films),
the least popular is G (178 films).
The category-rating combination with the highest number of films is
Drama and PG-13 (22 films).
The category-rating combination with the lowest number of films is
Music and G (2 films).
It is not always the case, however, that the PG-13 rating has the highest number of films
and the G rating has the lowest number of films
(e.g. for Action: the highest number of films have the R rating(14 films),
the least number of films have the PG rating (9).*/
SELECT c.name, 
       f.rating, 
	   COUNT(*)
  FROM film AS f
       LEFT JOIN film_category AS fc
	   ON fc.film_id = f.film_id
	   LEFT JOIN category AS c
	   ON c.category_id = fc.category_id
 GROUP BY CUBE (c.name, f.rating)
 ORDER BY COUNT(*) DESC;

SELECT c.name, 
       f.rating, 
	   COUNT(*)
  FROM film AS f
       LEFT JOIN film_category AS fc
	   ON fc.film_id = f.film_id
	   LEFT JOIN category AS c
	   ON c.category_id = fc.category_id
 GROUP BY CUBE (c.name, f.rating)
 ORDER BY c.name;

/*The actor with the highest number of films is Susan Davis (54 films).
The actor with the lowest number of films is Emily Dee (14 films).
There are 3 films with no actor specified.
The previous query showed that there are 200 actors in total; 
however, two of them have the same first and last name: Susan Davis.
Because of that, the first query returns only 200 rows, 
including one row with three films with no actor specified:
Drumline Cyclone, Flight Lies, Slacker Liaisons.
Hence, the query must include the actor's id.*/
SELECT a.first_name, 
       a.last_name,
	   COUNT(*)
  FROM film AS f
       FULL JOIN film_actor AS fa
	   ON fa.film_id = f.film_id
	   FULL JOIN actor AS a
	   ON a.actor_id = fa.actor_id
 GROUP BY a.last_name, a.first_name
 ORDER BY COUNT(*) DESC;

SELECT a.actor_id,
       a.first_name, 
       a.last_name,
	   COUNT(*)
  FROM film AS f
       FULL JOIN film_actor AS fa
	   ON fa.film_id = f.film_id
	   FULL JOIN actor AS a
	   ON a.actor_id = fa.actor_id
 GROUP BY a.actor_id, a.last_name, a.first_name
 ORDER BY COUNT(*) DESC;

SELECT f.title
  FROM actor AS a
       FULL JOIN film_actor AS fa
	   ON fa.actor_id = a.actor_id
	   FULL JOIN film AS f
	   ON f.film_id = fa.film_id
 WHERE a.last_name IS NULL;

/*On average, there are about 5 actors specified for each film,
with the maximum of 15 and the minimum of 1.*/ 
WITH actor_per_film AS(
     SELECT f.title, 
            COUNT(*) AS count
       FROM actor AS a
            FULL JOIN film_actor AS fa
	        ON fa.actor_id = a.actor_id
	        FULL JOIN film AS f
	        ON f.film_id = fa.film_id
      GROUP BY f.title
) 
SELECT avg(count) AS avg_count,
       min(count) AS min_count,
	   max(count) AS max_count
  FROM actor_per_film;

/*5 actors are specified most often per film (195 films have 5 actors specified).
Only 1 film has 15 actor specified.*/
WITH actor_per_film AS(
     SELECT f.title, 
            COUNT(*) AS count
       FROM actor AS a
            FULL JOIN film_actor AS fa
	        ON fa.actor_id = a.actor_id
	        FULL JOIN film AS f
	        ON f.film_id = fa.film_id
      GROUP BY f.title
) 
SELECT count,
       count(count) AS no_counts
  FROM actor_per_film
 GROUP BY count
 ORDER BY no_counts DESC;
 
/*There are two stores with approximately the same number of films.
42 films are not listed in any of the stores.*/
SELECT i.store_id
       COUNT(*) AS no_films_per_store
  FROM film AS f
       LEFT JOIN inventory AS i
	   USING(film_id)
 GROUP BY i.store_id
 ORDER BY no_films_per_store DESC;

/*The highest number of the same title in a store is 4.*/
SELECT i.store_id,
       f.title,
       COUNT(*) AS no_titles_per_store
  FROM film AS f
       LEFT JOIN inventory AS i
	   USING(film_id)
 GROUP BY i.store_id, f.title
 ORDER BY no_films_per_store DESC;

/*On averate, there are 3 copies of each title in both stores.
There are only single copies of films not listed in any store.*/
WITH title_per_store AS (
     SELECT i.store_id,
            f.title,
            COUNT(*) AS no_titles_per_store
       FROM film AS f
            LEFT JOIN inventory AS i
	        USING(film_id)
      GROUP BY i.store_id, f.title
      ORDER BY no_titles_per_store DESC
)
SELECT store_id,
       AVG(no_titles_per_store)
  FROM title_per_store
 GROUP BY store_id;

/*There is no difference in average replacement cost between the two stores.
The film not listed in any stores, however, are on average cheaper to replace.*/
SELECT i.store_id,
       AVG(replacement_cost) AS avg_replacement_cost_per_store
  FROM film AS f
       LEFT JOIN inventory AS i
	   USING(film_id)
 GROUP BY i.store_id;
 
/*The mean rental duration is almost the same for both stores.
Films not listed in any of the stores can be rented for longer (5.3 days on average).*/ 
SELECT i.store_id,
       AVG(rental_duration) AS avg_rental_duration_per_store
  FROM film AS f
       LEFT JOIN inventory AS i
	   USING(film_id)
 GROUP BY i.store_id;
/*For store with the id=2, the most popular films are in the Sports category.
For store_id=1, it is Action.*/ 
SELECT c.name,
	   i.store_id,
	   COUNT(*)
  FROM film AS f
       LEFT JOIN inventory AS i
	   ON f.film_id = i.film_id
	   LEFT JOIN film_category AS fc
	   ON f.film_id = fc.film_id
	   LEFT JOIN category AS c
	   ON c.category_id = fc.category_id
 GROUP BY ROLLUP (c.name, i.store_id)
 ORDER BY count DESC;