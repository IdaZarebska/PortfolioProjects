-- Create tables, populate them and check results.
DROP TABLE IF EXISTS elements;
CREATE TABLE elements (
	element_id VARCHAR(10) NOT NULL,
	part_num VARCHAR(20),
	color_id INT,
	PRIMARY KEY (element_id));
	
COPY elements(element_id, part_num, color_id)
FROM 'C:\Users\Ida\Dysk Google\DATA ANALYSIS PROJECTS\LEGO\elements.csv'
DELIMITER ','
CSV HEADER;

SELECT *
FROM elements
LIMIT 10;


DROP TABLE IF EXISTS colors;
CREATE TABLE colors (
	id INT NOT NULL,
	name VARCHAR(200),
	rgb VARCHAR(6),
	is_trans BOOL,
	PRIMARY KEY (id));
	
COPY colors(id, name, rgb, is_trans)
FROM 'C:\Users\Ida\Dysk Google\DATA ANALYSIS PROJECTS\LEGO\colors.csv'
DELIMITER ','
CSV HEADER;

SELECT *
FROM colors
LIMIT 10;


DROP TABLE IF EXISTS inventories;
CREATE TABLE inventories (
	id INT NOT NULL,
	version INT,
	set_num VARCHAR(20),
	PRIMARY KEY(id)
	);
	
COPY inventories(id, version, set_num)
FROM 'C:\Users\Ida\Dysk Google\DATA ANALYSIS PROJECTS\LEGO\inventories.csv'
DELIMITER ','
CSV HEADER;


DROP TABLE IF EXISTS inventory_parts;
CREATE TABLE inventory_parts (
	inventory_id INT,
	part_num VARCHAR(20),
	color_id INT,
	quantity INT,
	is_spare BOOL,
	img_url TEXT);
			
COPY inventory_parts(inventory_id, part_num, color_id, quantity, is_spare, img_url)
FROM 'C:\Users\Ida\Dysk Google\DATA ANALYSIS PROJECTS\LEGO\inventory_parts.csv'
DELIMITER ','
CSV HEADER;

SELECT *
FROM inventory_parts
LIMIT 10;


DROP TABLE IF EXISTS parts;
CREATE TABLE parts (
	part_num VARCHAR(20) NOT NULL,
	name VARCHAR(250),
	part_cat_id INT,
	part_material TEXT,
	PRIMARY KEY (part_num));
	
COPY parts(part_num, name, part_cat_id, part_material)
FROM 'C:\Users\Ida\Dysk Google\DATA ANALYSIS PROJECTS\LEGO\parts.csv'
DELIMITER ','
CSV HEADER;

SELECT *
FROM parts
LIMIT 10;


SELECT COUNT(*),
	part_material
FROM parts
GROUP BY part_material;

DROP TABLE IF EXISTS part_categories;
CREATE TABLE part_categories (
	id INT NOT NULL,
	name VARCHAR(200),
	PRIMARY KEY (id));
	
COPY part_categories(id, name)
FROM 'C:\Users\Ida\Dysk Google\DATA ANALYSIS PROJECTS\LEGO\part_categories.csv'
DELIMITER ','
CSV HEADER;

SELECT *
FROM part_categories
LIMIT 10;


DROP TABLE IF EXISTS part_relationships;
CREATE TABLE part_relationships (
	rel_type VARCHAR(1),
	child_part_num VARCHAR(20),
	parent_part_num VARCHAR(20));
			
COPY part_relationships(rel_type, child_part_num, parent_part_num)
FROM 'C:\Users\Ida\Dysk Google\DATA ANALYSIS PROJECTS\LEGO\part_relationships.csv'
DELIMITER ','
CSV HEADER;

SELECT *
FROM part_relationships
LIMIT 10;


DROP TABLE IF EXISTS inventory_minifigs;
CREATE TABLE inventory_minifigs (
	inventory_id INT,
	fig_num VARCHAR(20),
	quantity INT);
			
COPY inventory_minifigs(inventory_id, fig_num, quantity)
FROM 'C:\Users\Ida\Dysk Google\DATA ANALYSIS PROJECTS\LEGO\inventory_minifigs.csv'
DELIMITER ','
CSV HEADER;

SELECT *
FROM inventory_minifigs
LIMIT 10;


DROP TABLE IF EXISTS minifigs;
CREATE TABLE minifigs (
	fig_num VARCHAR(20) NOT NULL,
	name VARCHAR(256),
	num_parts INT,
	img_url TEXT,
	PRIMARY KEY (fig_num));
	
COPY minifigs(fig_num, name, num_parts, img_url)
FROM 'C:\Users\Ida\Dysk Google\DATA ANALYSIS PROJECTS\LEGO\minifigs.csv'
DELIMITER ','
CSV HEADER;

SELECT *
FROM minifigs
LIMIT 10;


DROP TABLE IF EXISTS inventory_sets;
CREATE TABLE inventory_sets (
	inventory_id INT,
	set_num VARCHAR(20),
	quantity INT);

COPY inventory_sets(inventory_id, set_num, quantity)
FROM 'C:\Users\Ida\Dysk Google\DATA ANALYSIS PROJECTS\LEGO\inventory_sets.csv'
DELIMITER ','
CSV HEADER;

SELECT *
FROM inventory_sets
LIMIT 10;


DROP TABLE IF EXISTS sets;
CREATE TABLE sets (
	set_num VARCHAR(20) NOT NULL,
	name VARCHAR(256),
	year INT,
	theme_id INT,
	num_parts INT,
	img_url TEXT,
	PRIMARY KEY (set_num));
	
COPY sets(set_num, name, year, theme_id, num_parts, img_url)
FROM 'C:\Users\Ida\Dysk Google\DATA ANALYSIS PROJECTS\LEGO\sets.csv'
DELIMITER ','
CSV HEADER;

SELECT *
FROM sets
LIMIT 10;


DROP TABLE IF EXISTS themes;
CREATE TABLE themes (
	id INT NOT NULL,
	name VARCHAR(50),
	parent_id INT,
	PRIMARY KEY (id),
	CONSTRAINT fk_parent_id
		FOREIGN KEY (parent_id)
			REFERENCES themes(id));
			
COPY themes(id, name, parent_id)
FROM 'C:\Users\Ida\Dysk Google\DATA ANALYSIS PROJECTS\LEGO\themes.csv'
DELIMITER ','
CSV HEADER;

SELECT *
FROM themes
LIMIT 10;


-- Add foreign keys.
ALTER TABLE elements
ADD CONSTRAINT fk_part_num
	FOREIGN KEY (part_num)
		REFERENCES parts(part_num)
			ON DELETE RESTRICT,
ADD CONSTRAINT fk_color_id
		FOREIGN KEY (color_id)
			REFERENCES colors(id)
				ON DELETE RESTRICT;

ALTER TABLE part_relationships
ADD	CONSTRAINT fk_child_part_num
		FOREIGN KEY(child_part_num)
			REFERENCES parts(part_num)
				ON DELETE RESTRICT,
ADD	CONSTRAINT fk_parent_part_num
		FOREIGN KEY(parent_part_num)
			REFERENCES parts(part_num)
				ON DELETE RESTRICT;
				
ALTER TABLE parts
ADD CONSTRAINT fk_part_cat_id
	FOREIGN KEY (part_cat_id)
		REFERENCES part_categories(id)
			ON DELETE RESTRICT;
			
ALTER TABLE inventory_parts
ADD CONSTRAINT fk_inventory_id
	FOREIGN KEY (inventory_id)
		REFERENCES inventories(id)
			ON DELETE RESTRICT,
ADD CONSTRAINT fk_part_num
	FOREIGN KEY (part_num)
		REFERENCES parts(part_num)
			ON DELETE RESTRICT,
ADD CONSTRAINT fk_color_id
	FOREIGN KEY (color_id)
		REFERENCES colors(id)
			ON DELETE RESTRICT;
			
			
ALTER TABLE inventory_minifigs
ADD CONSTRAINT fk_fig_num
	FOREIGN KEY (fig_num)
		REFERENCES minifigs(fig_num)
			ON DELETE RESTRICT;
			
ALTER TABLE inventory_sets
ADD CONSTRAINT fk_inventory_id
	FOREIGN KEY (inventory_id)
		REFERENCES inventories(id)
			ON DELETE RESTRICT,
ADD CONSTRAINT fk_set_num
	FOREIGN KEY (set_num)
		REFERENCES sets(set_num)
			ON DELETE RESTRICT;

ALTER TABLE sets
ADD CONSTRAINT fk_theme_id
	FOREIGN KEY (theme_id)
		REFERENCES themes(id)
			ON DELETE RESTRICT;

/* It seems that there is one entry in inventory_minifigs with inventory_id that is not present in inventories.
The same minifigure is also in inventories with id 30055, 30058, 69660.
Since it is only one minifigure, let's just drop this row.*/

-- This query returns an error.
ALTER TABLE inventory_minifigs
ADD CONSTRAINT fk_inventory_id
	FOREIGN KEY (inventory_id)
		REFERENCES inventories(id)
			ON DELETE RESTRICT;

-- Select the row that causes the error.
SELECT *
FROM inventory_minifigs AS im
INNER JOIN minifigs AS m
ON m.fig_num = im.fig_num
WHERE inventory_id NOT IN (SELECT id
						  FROM inventories
						  WHERE inventories.id = im.inventory_id);

-- Search for similar entries.
SELECT *
FROM inventory_minifigs AS im
INNER JOIN minifigs AS m
ON m.fig_num = im.fig_num
WHERE name LIKE '%Stormtrooper, Black Squares on Back of Helmet%'
LIMIT 10;

-- Delete the row that causes the error.
DELETE FROM inventory_minifigs
WHERE inventory_id NOT IN (SELECT id
						  FROM inventories
						  WHERE inventories.id = inventory_minifigs.inventory_id);

-- Add the foreign key.
ALTER TABLE inventory_minifigs
ADD CONSTRAINT fk_inventory_id
	FOREIGN KEY (inventory_id)
		REFERENCES inventories(id)
			ON DELETE RESTRICT;