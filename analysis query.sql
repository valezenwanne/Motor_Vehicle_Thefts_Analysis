USE stolen_vehicles_db;


-- Display the first ten records in the stolen_vehicles table
SELECT *
FROM stolen_vehicles 
LIMIT 10;


-- Display the first ten records in the locations table
SELECT *
FROM locations 
LIMIT 10;


-- Display the first ten records in the make_details table
SELECT *
FROM make_details 
LIMIT 10;


-- Analysis------------------------------------------------------------------------------

-- The total population in the country
SELECT
	FORMAT(SUM(population), 'N') as total_population
FROM locations;


-- The total number of regions 
SELECT 
	COUNT(DISTINCT region) AS no_of_regions
FROM locations;


-- Total number of stolen vehicles in the past six months
SELECT
	COUNT(vehicle_id) as total_stolen_vehicles
FROM stolen_vehicles;


-- AVERAGE NUMBER OF CAR STOLEN PER DAY 
SELECT
	ROUND(COUNT(vehicle_id) / DATEDIFF(MAX(date_stolen), MIN(date_stolen)), 0)
		AS avg_car_stolen_per_day
FROM stolen_vehicles;







-- TIME SERIES ANALYSIS -------------------------------------------------------------

-- What month had the highest number of stolen vehicles 
SELECT
	YEAR(date_stolen) AS year,
    MONTH(date_stolen) AS month,
    MONTHNAME(date_stolen) AS month_name,
	COUNT(vehicle_id) AS no_of_stolen_vehicles
FROM stolen_vehicles
GROUP BY 1,2,3
ORDER BY 1,2;


-- What day of week had the highest number of stolen vehicles -----------
SELECT 
	dayname(date_stolen) AS day_of_week,
    count(vehicle_id) AS no_of_stolen_vehicles
FROM stolen_vehicles 
GROUP BY day_of_week
ORDER BY no_of_stolen_vehicles DESC;

-- The number of vehicle types stolen
SELECT
	COUNT(DISTINCT vehicle_type) AS no_of_vehicle_types
FROM stolen_vehicles;



-- VEHICLE TYPE ANALYSIS -----------------------------------------------------------

-- Number of vehicles stolen by types
SELECT 
	vehicle_type,
    COUNT(vehicle_id) AS no_of_vehicles
FROM stolen_vehicles
GROUP BY vehicle_type
ORDER BY 2 DESC;


-- Which type of Vehicle is most often stolen
SELECT 
	vehicle_type,
    COUNT(vehicle_id) AS no_of_vehicles
FROM stolen_vehicles
GROUP BY vehicle_type
ORDER BY 2 DESC
LIMIT 1;


-- Top five most stolen vehicle type
SELECT 
	vehicle_type,
    COUNT(vehicle_id) AS no_of_vehicles
FROM stolen_vehicles
GROUP BY vehicle_type
ORDER BY 2 ASC
LIMIT 5;

-- Which type of vehicle is least often stolen
SELECT 
	vehicle_type,
    COUNT(vehicle_id) AS no_of_vehicles
FROM stolen_vehicles
GROUP BY vehicle_type
HAVING no_of_vehicles = 1;


-- Which vehicle type rank top as stolen by region
WITH cte1 AS (
	SELECT 
		l.region,
		s.vehicle_type,
		COUNT(s.vehicle_id) AS no_of_vehicles
	FROM stolen_vehicles s
		JOIN locations l
			ON s.location_id = l.location_id
	GROUP BY 1, 2
	ORDER BY 1, 3 DESC)
SELECT 
	region, 
    vehicle_type,
    no_of_vehicles
FROM (SELECT 
		region, 
		vehicle_type,
		no_of_vehicles,
		ROW_NUMBER() OVER(PARTITION BY region) AS ranking
FROM cte1) sub
WHERE ranking < 2
ORDER BY no_of_vehicles DESC;


-- LOCATION ANALYSIS -----------------------------------

-- Region with the largest population 
SELECT
	region,
    population
FROM locations
ORDER BY population DESC
LIMIT 1;


-- Region with the least population 
SELECT
	region,
    population
FROM locations
ORDER BY population ASC
LIMIT 1;


-- The five top populated regions
SELECT
	region AS top_5_regions,
    population
FROM locations
ORDER BY 2 DESC
LIMIT 5;


-- The five least populated regions
WITH cte2 AS (
	SELECT
		region,
		population,
        ROW_NUMBER() OVER(ORDER BY population DESC) AS ranking
	FROM locations)
SELECT
	region AS bottom_5_regions,
    population
FROM cte2
WHERE ranking > 11;


-- Which location has the most number of stolen vehicles
SELECT
	l.region,
    COUNT(s.vehicle_id) AS no_of_vehicles_stolen
FROM locations l
	LEFT JOIN stolen_vehicles s 
		ON l.location_id = s.location_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- Top five locations that has the most number of stolen vehicles
SELECT
	l.region,
    COUNT(s.vehicle_id) AS no_of_vehicles_stolen
FROM locations l
	LEFT JOIN stolen_vehicles s 
		ON l.location_id = s.location_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- Which location(region) has the most stolen vehicles. Does it depend on population?
SELECT
	l.region,
    l.population,
    COUNT(s.vehicle_id) AS no_of_stolen_vehicles
FROM locations l
LEFT JOIN stolen_vehicles s 
	ON l.location_id = s.location_id
GROUP BY 1, 2
ORDER BY 3 DESC;


-- Which region has not recorded car theft
SELECT
	l.region,
    COUNT(s.vehicle_id) AS no_of_stolen_vehicles
FROM locations l
	LEFT JOIN stolen_vehicles s 
		ON l.location_id = s.location_id
GROUP BY 1
HAVING no_of_stolen_vehicles = 0;


-- AVERAGE NUMBER OF CAR STOLEN PER DAY IN EACH REGION
SELECT
	l.region,
    ROUND(COUNT(s.vehicle_id) / DATEDIFF(MAX(s.date_stolen), MIN(s.date_stolen)), 0) 
		AS avg_car_stolen_per_day
FROM stolen_vehicles s
	JOIN locations l
		ON s.location_id = l.location_id
GROUP BY 1
ORDER BY 2 DESC;



-- CAR MAKE ANALYSIS -----------------------------------------------------

-- Total number of car makes
SELECT 
	COUNT(DISTINCT make_name) AS no_of_car_make
FROM make_details;


-- Top 10 most stolen car make
SELECT 
	m.make_name,
    COUNT(s.vehicle_id) AS no_of_stolen_vehicles
FROM make_details m
	JOIN stolen_vehicles s 
		ON m.make_id = s.make_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


-- Top five location that had the highest number of Toyota stolen
SELECT
	l.region,
    COUNT(s.vehicle_id) AS no_of_toyota_stolen
FROM locations l
	JOIN stolen_vehicles s 
		ON l.location_id = s.location_id
			JOIN make_details m
				ON m.make_id = s.make_id 
WHERE m.make_name = 'Toyota'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- Which day of the week does that theft of Toyota occur mostly in Auckland
SELECT
	DAYNAME(s.date_stolen) day_stolen,
    COUNT(s.vehicle_id) AS no_of_stolen_vehicles
FROM stolen_vehicles s 
JOIN make_details m 
	ON s.make_id = m.make_id
		JOIN locations l 
			ON s.location_id = l.location_id
WHERE l.region ='Auckland' AND m.make_name ='Toyota'
GROUP BY 1
ORDER BY 2 DESC;



-- AGE OF CAR --------------------------------------------------

-- What is the average age of the vehicles that were stolen
SELECT
    AVG(YEAR(date_stolen) - model_year) AS average_year
FROM stolen_vehicles;


-- Does the average age of the vehicles that were stolen vary by vehicle type
SELECT
	vehicle_type,
    AVG(YEAR(date_stolen) - model_year) AS average_year
FROM stolen_vehicles
GROUP BY 1
ORDER BY 2 DESC;











