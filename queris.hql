--1. What age categories are the most popular all time?
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

--2. What day of the week had the most tournaments all time?

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
SELECT 
    p.range_of_participants AS range_of_participants,
    SUM(CASE WHEN d.year = 2022 THEN 1 ELSE 0 END) AS `2022`,
    SUM(CASE WHEN d.year = 2023 THEN 1 ELSE 0 END) AS `2023`,
    SUM(CASE WHEN d.year = 2024 THEN 1 ELSE 0 END) AS `2024`,
    SUM(CASE WHEN d.year = 2025 THEN 1 ELSE 0 END) AS `2025`
FROM tournament_organization_fact t
JOIN participation_dim p ON p.id = t.participation_id
JOIN date_dim d ON d.id = t.date_id
GROUP BY p.range_of_participants
ORDER BY p.range_of_participants;


-- +------------------------+-------+-------+-------+-------+--+
-- | range_of_participants  | 2022  | 2023  | 2024  | 2025  |
-- +------------------------+-------+-------+-------+-------+--+
-- | 0-10                   | 0     | 1     | 2     | 2     |
-- | 20-30                  | 0     | 1     | 1     | 3     |
-- | 31-40                  | 0     | 2     | 1     | 2     |
-- +------------------------+-------+-------+-------+-------+--+


--4. Are summer months hold more tournaments in the years (2020 - 2025)

SELECT
    month_type,
    ROUND(
        CASE 
            WHEN month_type = 'Non_summer' THEN tournament_count / 9.0
            WHEN month_type = 'Summer' THEN tournament_count / 3.0
        END, 
        2
    ) AS avg_monthly_tournaments
FROM (
    SELECT 
        CASE 
            WHEN d.month IN (7,8,9) THEN 'Summer' 
            ELSE 'Non_summer' 
        END AS month_type,
        COUNT(t.id) AS tournament_count 
    FROM tournament_organization_fact t
    JOIN date_dim d
    ON t.date_id = d.id
    WHERE d.year BETWEEN 2021 AND 2025
    GROUP BY 
        CASE 
            WHEN d.month IN (7,8,9) THEN 'Summer' 
            ELSE 'Non_summer' 
        END
) AS subquery;


-- +-------------+--------------------------+--+
-- | month_type  | avg_monthly_tournaments  |
-- +-------------+--------------------------+--+
-- | Non_summer  | 1.22                     |
-- | Summer      | 1.33                     |
-- +-------------+--------------------------+--+



--5. What game categories are the most popular among tournaments for kids all time

SELECT     
    g.game_category_element AS game_category,
    SUM(CASE WHEN p.age_category = 'Kids' THEN 1 ELSE 0 END) AS Kids,
    SUM(CASE WHEN p.age_category = 'Adults' THEN 1 ELSE 0 END) AS Adults
FROM tournament_organization_fact t
JOIN participation_dim p ON p.id = t.participation_id
JOIN (
    SELECT 
        id, 
        g AS game_category_element
    FROM boardgame_dim
    LATERAL VIEW explode(game_category) exploded_table AS g
) g ON g.id = t.board_game_id
GROUP BY g.game_category_element

-- +----------------+-------+---------+--+
-- | game_category  | kids  | adults  |
-- +----------------+-------+---------+--+
-- | Abstract       | 2     | 3       |
-- | Card           | 0     | 5       |
-- | Family         | 0     | 5       |
-- | Strategy       | 5     | 5       |
-- | Trading        | 3     | 2       |
-- +----------------+-------+---------+--+

--6. What game categories are the most popular in 20-30 players tournaments all time?

SELECT g.game_category_element AS game_category,
    COUNT(*) AS tournament_count
FROM tournament_organization_fact AS t
JOIN participation_dim AS p ON t.participation_id = p.id
JOIN (
    SELECT 
        id, 
        g AS game_category_element
    FROM boardgame_dim
    LATERAL VIEW explode(game_category) exploded_table AS g
) g ON g.id = t.board_game_id
WHERE p.range_of_participants = '20-30'
GROUP BY g.game_category_element
ORDER BY tournament_count DESC;

-- +----------------+-------------------+--+
-- | game_category  | tournament_count  |
-- +----------------+-------------------+--+
-- | Family         | 4                 |
-- | Card           | 4                 |
-- | Strategy       | 1                 |
-- | Abstract       | 1                 |
-- +----------------+-------------------+--+

--7. Are tournaments with prizes greater then average are held more often?

WITH avg_table AS (
    SELECT 
        AVG(prize_pool['Gold'] + prize_pool['Silver'] + prize_pool['Bronze']) AS Prize_pool_AVG,
        COUNT(*) AS t_count
    FROM tournament_organization_fact
)
SELECT 
    t_above.Above_the_average AS Above_the_average,
    avg_table.t_count - t_above.Above_the_average AS Below_the_average
FROM avg_table
CROSS JOIN (
    SELECT 
        COUNT(*) AS Above_the_average
    FROM tournament_organization_fact AS t
    CROSS JOIN avg_table
    WHERE prize_pool['Gold'] + prize_pool['Silver'] + prize_pool['Bronze'] > avg_table.Prize_pool_AVG
) AS t_above;

-- +--------------------+--------------------+--+
-- | above_the_average  | below_the_average  |
-- +--------------------+--------------------+--+
-- | 6                  | 9                  |
-- +--------------------+--------------------+--+


--8. Are cheaper tournaments more popular amongs kids

SELECT 
    j.entry_fee,
    COUNT(*) AS kids_participation_count
FROM tournament_organization_fact AS t
JOIN participation_dim AS p ON p.id = t.participation_id
JOIN junk_dim AS j ON j.id = t.junk_id
WHERE p.age_category = 'Kids'
GROUP BY j.entry_fee
ORDER BY j.entry_fee ASC;

-- +--------------+---------------------------+--+
-- | j.entry_fee  | kids_participation_count  |
-- +--------------+---------------------------+--+
-- | 10 USD       | 2                         |
-- | 20 USD       | 3                         |
-- +--------------+---------------------------+--+

--9. Is increasing the winning prize for bronze impactful on number players

SELECT
    CASE
        WHEN t.prize_pool['Bronze'] <= 100 THEN '0-100'
        WHEN t.prize_pool['Bronze'] <= 250 THEN '100-250'
        WHEN t.prize_pool['Bronze'] <= 450 THEN '250-450'
        WHEN t.prize_pool['Bronze'] <= 700 THEN '450-700'
        ELSE '700+'
    END AS bronze_prize_bucket,
    -- CORRECTED: Use backticks for aliases with hyphens and leading numbers
    COUNT(CASE WHEN p.range_of_participants = '0-10' THEN 1 ELSE NULL END) AS `0-10_Participants`,
    COUNT(CASE WHEN p.range_of_participants = '11-19' THEN 1 ELSE NULL END) AS `11-19_Participants`,
    COUNT(CASE WHEN p.range_of_participants = '20-30' THEN 1 ELSE NULL END) AS `20-30_Participants`,
    COUNT(CASE WHEN p.range_of_participants = '31-40' THEN 1 ELSE NULL END) AS `31-40_Participants`,
    COUNT(CASE WHEN p.range_of_participants = '40+' THEN 1 ELSE NULL END) AS `40+_Participants`

FROM
    tournament_organization_fact AS t
JOIN
    participation_dim AS p ON p.id = t.participation_id
GROUP BY
    -- Full expression is still required here
    CASE
        WHEN t.prize_pool['Bronze'] <= 100 THEN '0-100'
        WHEN t.prize_pool['Bronze'] <= 250 THEN '100-250'
        WHEN t.prize_pool['Bronze'] <= 450 THEN '250-450'
        WHEN t.prize_pool['Bronze'] <= 700 THEN '450-700'
        ELSE '700+'
    END
ORDER BY
    -- Sorting logic on the alias remains the same
    CASE bronze_prize_bucket
        WHEN '700+' THEN 5
        WHEN '450-700' THEN 4
        WHEN '250-450' THEN 3
        WHEN '100-250' THEN 2
        WHEN '0-100' THEN 1
    END DESC;

-- +----------------------+--------------------+---------------------+---------------------+---------------------+-------------------+--+
-- | bronze_prize_bucket  | 0-10_participants  | 11-19_participants  | 20-30_participants  | 31-40_participants  | 40+_participants  |
-- +----------------------+--------------------+---------------------+---------------------+---------------------+-------------------+--+
-- | 450-700              | 2                  | 0                   | 0                   | 0                   | 0                 |
-- | 250-450              | 0                  | 0                   | 1                   | 1                   | 0                 |
-- | 100-250              | 3                  | 0                   | 2                   | 3                   | 0                 |
-- | 0-100                | 0                  | 0                   | 2                   | 1                   | 0                 |
-- +----------------------+--------------------+---------------------+---------------------+---------------------+-------------------+--+


--10. Are there more bigger groups currently than in prevoius years

SELECT 
    d.year AS tournament_year,
    COUNT(*) AS tournament_count
FROM tournament_organization_fact AS t
JOIN participation_dim AS p ON p.id = t.participation_id
JOIN date_dim AS d ON d.id = t.date_id
WHERE p.range_of_participants IN ('20-30', '31-40')
GROUP BY d.year
ORDER BY d.year DESC;

-- +------------------+-------------------+--+
-- | tournament_year  | tournament_count  |
-- +------------------+-------------------+--+
-- | 2025             | 5                 |
-- | 2024             | 2                 |
-- | 2023             | 3                 |
-- +------------------+-------------------+--+