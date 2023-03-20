-- 1. WHAT IS THE AVERAGE NUMBER OF LEGO SETS RELEASED PER YEAR?
SELECT ROUND(AVG(number_of_sets), 0) AS avg_number_of_sets
  FROM 
      (SELECT year,
              COUNT(*) AS number_of_sets
        FROM sets
      GROUP BY year) AS count_per_year;

-- Calculate summary statistics of the number of sets.
SELECT ROUND(AVG(number_of_sets), 0) AS avg_number_of_sets,
       STDDEV(number_of_sets) AS std_deviation_sets,
       MIN(number_of_sets) AS min_number_of_sets,
       MAX(number_of_sets) AS max_number_of_sets,
       MAX(number_of_sets) - MIN(number_of_sets) AS difference_in_number_of_sets
  FROM 
      (SELECT year,
              COUNT(*) AS number_of_sets
        FROM sets
      GROUP BY year) AS count_per_year;

-- Select year with the minimum number of sets released.
SELECT MIN(number_of_sets) AS min_number_of_sets,
       year
  FROM 
      (SELECT year,
              COUNT(*) AS number_of_sets
        FROM sets
      GROUP BY year) AS count_per_year
 GROUP BY year
 ORDER BY min_number_of_sets ASC
 LIMIT 1;

-- Select year with the maximum number of sets released.
SELECT MAX(number_of_sets) AS max_number_of_sets,
       year
  FROM 
      (SELECT year,
              COUNT(*) AS number_of_sets
        FROM sets
      GROUP BY year) AS count_per_year
 GROUP BY year
 ORDER BY max_number_of_sets DESC
 LIMIT 1;


-- 2. WHAT IS THE AVERAGE NUMBER OF LEGO PARTS PER YEAR?
SELECT ROUND(AVG(avg_number_of_parts), 0) AS avg_parts
  FROM 
      (SELECT year,
              AVG(num_parts) AS avg_number_of_parts
         FROM sets
        GROUP BY year) AS avg_per_year;

-- Select the average number of parts per year.
SELECT year,
       AVG(num_parts) AS avg_number_of_parts
  FROM sets
 GROUP BY year;

-- Select year with minimum number of parts per set on average.
SELECT MIN(avg_number_of_parts) AS min_number_of_parts,
       year
FROM (SELECT year,
             AVG(num_parts) AS avg_number_of_parts
        FROM sets
       GROUP BY year) AS avg_per_year
 GROUP BY year
 ORDER BY min_number_of_parts
 LIMIT 1;

-- Select year with maximum number of parts per set on average.
SELECT MAX(avg_number_of_parts) AS max_number_of_parts,
       year
FROM (SELECT year,
             AVG(num_parts) AS avg_number_of_parts
        FROM sets
       GROUP BY year) AS avg_per_year
 GROUP BY year
 ORDER BY max_number_of_parts DESC
 LIMIT 1;
 
 
-- 3. WHAT ARE THE 5 MOST POPULAR COLOURS USED IN LEGO PARTS?
SELECT name,
       SUM(quantity)
  FROM inventory_parts AS ip
 INNER JOIN colors AS c
    ON ip.color_id = c.id
 GROUP BY name
 ORDER BY sum DESC
 LIMIT 5;
 
 
-- 4. WHAT PROPORTION OF LEGO PARTS ARE TRANSPARENT?
WITH trans_quantity AS 
    (SELECT color_id, inventory_id, part_num, is_spare,
            quantity AS trans
       FROM inventory_parts
      WHERE color_id IN (
          SELECT id
            FROM colors
           WHERE is_trans = True
                AND color_id = id))
SELECT SUM(t.trans) / SUM(SUM(p.quantity)) OVER() AS transparent_ratio
  FROM trans_quantity AS t
  FULL JOIN inventory_parts AS p
         ON t.color_id = p.color_id 
            AND t.inventory_id = p.inventory_id 
            AND t.part_num = p.part_num 
            AND t.is_spare = p.is_spare;


-- 5.WHAT ARE THE MOST POPULAR AND THE RAREST LEGO BRICKS?
SELECT p.part_num,
       SUM(quantity)
FROM part_categories AS pc
INNER JOIN parts AS p
ON pc.id = p.part_cat_id
LEFT JOIN inventory_parts AS ip
ON p.part_num = ip.part_num
GROUP BY p.part_num
HAVING SUM(quantity) IS NOT NULL
ORDER BY SUM(quantity) DESC;

SELECT DISTINCT name,
       SUM(quantity)
FROM inventory_parts AS ip
INNER JOIN parts AS p
ON ip.part_num = p.part_num
GROUP BY name
ORDER BY sum
LIMIT 5;

-- Select parts with quantity = 1.
SELECT DISTINCT name,
       SUM(quantity)
  FROM inventory_parts AS ip
 INNER JOIN parts AS p
       ON ip.part_num = p.part_num
 GROUP BY name
HAVING SUM(quantity) = 1
 ORDER BY sum;

-- Calculate the ratio of parts with quantity = 1 and all parts.
WITH all_parts AS (
	SELECT DISTINCT name,
           SUM(quantity) AS sum
      FROM inventory_parts AS ip
     INNER JOIN parts AS p
           ON ip.part_num = p.part_num
     GROUP BY name
     ORDER BY sum
	),
small_quantity_parts AS (
   SELECT DISTINCT name,
          SUM(quantity) AS sum
     FROM inventory_parts AS ip
    INNER JOIN parts AS p
          ON ip.part_num = p.part_num
    GROUP BY name
   HAVING SUM(quantity) = 1
    ORDER BY sum
	)

SELECT COUNT(sqp.name)::NUMERIC / COUNT(ap.name)::NUMERIC AS ratio
  FROM all_parts AS ap
  FULL JOIN small_quantity_parts AS sqp
       ON ap.name=sqp.name;


-- 6. WHAT ARE THE MOST POPULAR AND THE RAREST CATEGORIES OF PARTS?
-- Select the most popular categories of parts.
SELECT pc.name,
       SUM(quantity)
  FROM part_categories AS pc
 INNER JOIN parts AS p
       ON pc.id = p.part_cat_id
 INNER JOIN inventory_parts AS ip
    ON p.part_num = ip.part_num
 GROUP BY pc.name
 ORDER BY SUM(quantity) DESC
 LIMIT 5;

-- SELECT the least popular categories of parts.
SELECT pc.name,
       SUM(quantity)
  FROM part_categories AS pc
 INNER JOIN parts AS p
       ON pc.id = p.part_cat_id
 INNER JOIN inventory_parts AS ip
       ON p.part_num = ip.part_num
 GROUP BY pc.name
HAVING SUM(quantity) IS NOT NULL
 ORDER BY SUM(quantity) ASC
 LIMIT 5;


-- 7. WHAT ARE THE MOST POPULAR AND THE RAREST MINIFIGURES?
SELECT m.name,
       SUM(quantity)
  FROM inventory_minifigs AS im
 INNER JOIN minifigs AS m
    ON im.fig_num = m.fig_num
 GROUP BY m.name
 ORDER BY SUM(quantity) DESC
 LIMIT 5;

-- Select first 5 rows of the rarest minifigures.
SELECT m.name,
       SUM(quantity)
  FROM inventory_minifigs AS im
 INNER JOIN minifigs AS m
    ON im.fig_num = m.fig_num
 GROUP BY m.name
 ORDER BY SUM(quantity) ASC
 LIMIT 5;

-- Calculate the number of minifigures with quantity = 1.
WITH minifigs_number AS (
	SELECT m.name,
           SUM(quantity)
      FROM inventory_minifigs AS im
     INNER JOIN minifigs AS m
           ON im.fig_num = m.fig_num
     GROUP BY m.name
    HAVING SUM(quantity) = 1)

SELECT COUNT(*)
  FROM minifigs_number;


-- 8. WHAT THEMES WERE DISCONTINUED AFTER A YEAR?
SELECT
	t.name,
	MIN(year),
	MAX(year)
  FROM sets AS s
 INNER JOIN themes AS t
       ON s.theme_id = t.id
 GROUP BY t.name
HAVING MIN(year) = MAX(year)
 ORDER BY MIN(year) ASC;

-- Select year with the highest number of one-year themes.
WITH one_year_themes AS (SELECT
	t.name AS theme,
	MIN(year) AS starting_year,
	MAX(year) AS ending_year
  FROM sets AS s
 INNER JOIN themes AS t
       ON s.theme_id = t.id
 GROUP BY theme
HAVING MIN(year) = MAX(year)
	)
						
SELECT 
	starting_year,
	COUNT(theme) AS number_of_themes
  FROM one_year_themes
 GROUP BY starting_year
 ORDER BY number_of_themes DESC
 LIMIT 1;


-- 9. WHAT IS THE MOST POPULAR THEME?
-- Select the theme with the highest number of sets.
SELECT
	t.name,
	COUNT(set_num)
  FROM sets AS s
 INNER JOIN themes AS t
       ON s.theme_id = t.id
 GROUP BY t.name
 ORDER BY COUNT(set_num) DESC;

-- vs. the number of sets per theme in 2022.
SELECT
	t.name,
	COUNT(set_num)
  FROM sets AS s
 INNER JOIN themes AS t
       ON s.theme_id = t.id
 WHERE year = 2022
 GROUP BY t.name
 ORDER BY COUNT(set_num) DESC;


-- 10. WHAT THEME HAS BEEN AROUND FOR THE LONGEST PERIOD OF TIME?
SELECT
	t.name,
	MIN(year) AS starting_year,
	MAX(year) AS ending_year,
	MAX(year) - MIN(year) AS duration
  FROM sets AS s
 INNER JOIN themes AS t
       ON s.theme_id = t.id
 GROUP BY t.name
 ORDER BY duration DESC;