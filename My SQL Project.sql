Create Database Highcloud_Airline;
Use Highcloud_Airline;

SELECT * FROM maindata;

SET SQL_SAFE_UPDATES = 0;

select count(*) from maindata;

/* Q1. Date Fields */ 

SELECT 
   Year,
   `Month (#)` AS MonthNo,

   -- Safe Date Creation (replace NULL Day with 01)
   STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', IFNULL(Day,1)), '%Y-%m-%d') AS flight_date,

   -- Month Full Name
   MONTHNAME(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', IFNULL(Day,1)), '%Y-%m-%d')) AS MonthFullName,

   -- Quarter
   QUARTER(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', IFNULL(Day,1)), '%Y-%m-%d')) AS Quarter,

   -- YearMonth
   DATE_FORMAT(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', IFNULL(Day,1)), '%Y-%m-%d'), '%Y-%b') AS YearMonth,

   -- Weekday No
   DAYOFWEEK(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', IFNULL(Day,1)), '%Y-%m-%d')) AS WeekdayNo,

   -- Weekday Name
   DAYNAME(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', IFNULL(Day,1)), '%Y-%m-%d')) AS WeekdayName,

   -- Financial Month
   CASE 
      WHEN `Month (#)` >= 4 THEN `Month (#)` - 3
      ELSE `Month (#)` + 9
   END AS FinancialMonth,

   -- Financial Quarter
   CASE 
      WHEN `Month (#)` BETWEEN 4 AND 6 THEN 'Q1'
      WHEN `Month (#)` BETWEEN 7 AND 9 THEN 'Q2'
      WHEN `Month (#)` BETWEEN 10 AND 12 THEN 'Q3'
      ELSE 'Q4'
   END AS FinancialQuarter

FROM maindata;

-- Q2. Find the load Factor percentage on a yearly , Quarterly , Monthly basis --

# Yearly Basis

SELECT 
    `Year`,
    ROUND(SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100, 2) AS LoadFactor_Percent
FROM maindata
WHERE `# Available Seats` > 0
GROUP BY `Year`
ORDER BY `Year`;

# Quarterly Basis

SELECT 
    `Year`,
    QUARTER(STR_TO_DATE(CONCAT(`Year`, '-', `Month (#)`, '-', `Day`), '%Y-%m-%d')) AS Quarter,
    ROUND(SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100, 2) AS LoadFactor_Percent
FROM maindata
WHERE `# Available Seats` > 0
GROUP BY `Year`, Quarter
ORDER BY `Year`, Quarter;

# Monthly Basis

SELECT 
    `Year`,
    `Month (#)` AS MonthNo,
    MONTHNAME(STR_TO_DATE(CONCAT(`Year`, '-', `Month (#)`, '-01'), '%Y-%m-%d')) AS MonthName,
    ROUND(SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100, 2) AS LoadFactor_Percent
FROM maindata
WHERE `# Available Seats` > 0
GROUP BY `Year`, `Month (#)`
ORDER BY `Year`, `Month (#)`;

-- Q3. Find the load Factor percentage on a Carrier Name basis  -- 

SELECT 
    `Carrier Name`,
    ROUND(SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100, 2) AS LoadFactor_Percent
FROM maindata
WHERE `# Available Seats` > 0
GROUP BY `Carrier Name`
ORDER BY LoadFactor_Percent DESC;

-- Q4. Identify Top 10 Carrier Names based passengers preference --

SELECT 
    `Carrier Name`,
    ROUND(SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100, 2) AS LoadFactor_Percent
FROM maindata
WHERE `# Available Seats` > 0
GROUP BY `Carrier Name`
ORDER BY LoadFactor_Percent DESC
LIMIT 10;

-- Q5. Display top Routes ( from-to City) based on Number of Flights --
SHOW COLUMNS FROM maindata; 

SELECT `From - To City`, 
       COUNT(`# Departures Performed`) AS No_Flights
FROM maindata
GROUP BY `From - To City`;




## Q6. Identify the how much load factor is occupied on Weekend vs Weekdays --

SELECT 
    CASE 
        WHEN DAYOFWEEK(
            STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', Day), '%Y-%m-%d')
        ) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type,
    SUM(`# Transported Passengers`) AS Total_Passengers,
    ROUND(100.0 * SUM(`# Transported Passengers`) / SUM(SUM(`# Transported Passengers`)) OVER(), 2) AS Passenger_Percentage
FROM maindata
GROUP BY Day_Type;

# Q7. Identify number of flights based on Distance groups --

SELECT 
    CASE
        WHEN Distance < 500 THEN 'Short Haul (<500 km)'
        WHEN Distance BETWEEN 500 AND 1000 THEN 'Medium Haul (500-1000 km)'
        WHEN Distance BETWEEN 1001 AND 3000 THEN 'Long Haul (1001-3000 km)'
        ELSE 'Ultra Long Haul (>3000 km)'
    END AS Distance_Group,
    COUNT(*) AS NumberOfFlights
FROM maindata
GROUP BY Distance_Group
ORDER BY NumberOfFlights DESC;


