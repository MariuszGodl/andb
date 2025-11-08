--1. What age categories are the most popular
SELECT 
    p.age_category as Age_Category,
    COUNT(t.id) AS Num_Tournaments
FROM tournament_organization_fact t
JOIN participation_dim p
ON t.participation_id = p.id
GROUP BY p.age_category
ORDER BY num_tournaments DESC;

-- +---------------+------------------+--+
-- | age_category  | num_tournaments  |
-- +---------------+------------------+--+
-- | Adults        | 10               |
-- | Kids          | 5                |
-- +---------------+------------------+--+

--2. What day of the week the most tournaments

SELECT 
    d.day_of_week AS Day_of_the_week,
    COUNT(t.id) AS Num_Tournaments
FROM tournament_organization_fact t
JOIN date_dim d ON t.date_id = d.id
GROUP BY d.day_of_week;

-- +------------------+------------------+--+
-- | day_of_the_week  | num_tournaments  |
-- +------------------+------------------+--+
-- | Friday           | 4                |
-- | Saturday         | 11               |
-- +------------------+------------------+--+

--3. What year had the most players

--4. Are summer months hold more tournaments in the years (2020 - 2025)

SELECT 
    CASE 
        WHEN d.month IN (7,8,9) THEN 'Summer' 
        ELSE 'Non_summer' 
    END AS month_type,
    CASE 
        WHEN d.month IN (7,8,9) COUNT(t.id)/3
        ELSE COUNT(t.id)/9 
    END AS Avg_monthly_tournaments
FROM 
    tournament_organization_fact t
JOIN 
    date_dim d
ON 
    t.date_id = d.id
WHERE 
    d.year BETWEEN 2021 AND 2025
GROUP BY 
    CASE 
        WHEN d.month IN (7,8,9) THEN 'summer' 
        ELSE 'non_summer' 
    END;


-- +-------------+--------------------------+--+
-- | month_type  | avg_monthly_tournaments  |
-- +-------------+--------------------------+--+
-- | non_summer  | 2.2                      |
-- | summer      | 0.8                      |
-- +-------------+--------------------------+--+


--5. What game categories are the most popular among tournaments for kids

example output
- col, sum of the tournamets
-row , games types 

--6. What game categories are the most popular in 20-30 players tournaments

--7. Are tournaments with bigger prizes more popular

--8. Are cheaper tournaments more popular amongs kids

--9. Is increasing the winning prize for bronze impactful on number players

--10. Are there more bigger groups currently than in prevoius years
