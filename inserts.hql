INSERT INTO TABLE date_dim VALUES
(1, '2023-07-14', 'Friday', 14, 7, 2023),
(2, '2024-03-09', 'Saturday', 9, 3, 2024),
(3, '2025-11-08', 'Saturday', 8, 11, 2025);

INSERT INTO TABLE junk_dim VALUES
(1, 3, '10 USD'),
(2, 5, '15 USD'),
(3, 2, '20 USD');

-- 
INSERT INTO TABLE boardgame_dim
SELECT 1, 'Catan', array('Strategy','Trading') UNION ALL
SELECT 2, 'Chess', array('Abstract','Strategy') UNION ALL
SELECT 3, 'Uno', array('Card','Family');

-- Dynamic partitioning on age_category
INSERT INTO TABLE participation_dim PARTITION (age_category)
SELECT 1 AS id, '0-10' AS range_of_participants, 'Kids' AS age_category
UNION ALL
SELECT 2, '20-30', 'Adults'
UNION ALL
SELECT 3, '31-40', 'Adults';


-- Insert for year 2023
INSERT INTO TABLE tournament_organization_fact PARTITION (year=2023)
SELECT 1 AS id, 1 AS board_game_id, 1 AS date_id, 1 AS junk_id, 1 AS participation_id,
       map('Gold',500,'Silver',300,'Bronze',200) AS prize_pool
UNION ALL
SELECT 2, 2, 1, 2, 2, map('Gold',800,'Silver',500,'Bronze',300)
UNION ALL
SELECT 3, 3, 1, 3, 3, map('Gold',200,'Silver',100,'Bronze',50)
UNION ALL
SELECT 4, 1, 1, 2, 3, map('Gold',,'Silver',400,'Bronze',200)
UNION ALL
SELECT 5, 2, 2, 3, 1, map('Gold',900,'Silver',500,'Bronze',250);

-- Insert for year 2024
INSERT INTO TABLE tournament_organization_fact PARTITION (year=2024)
SELECT 6, 3, 2, 1, 2, map('Gold',300,'Silver',200,'Bronze',100)
UNION ALL
SELECT 7, 1, 2, 3, 3, map('Gold',1000,'Silver',600,'Bronze',400)
UNION ALL
SELECT 8, 2, 2, 1, 1, map('Gold',750,'Silver',400,'Bronze',200)
UNION ALL
SELECT 9, 3, 3, 2, 2, map('Gold',600,'Silver',300,'Bronze',150)
UNION ALL
SELECT 10, 1, 3, 3, 1, map('Gold',1100,'Silver',700,'Bronze',500);

-- Insert for year 2025
INSERT INTO TABLE tournament_organization_fact PARTITION (year=2025)
SELECT 11, 2, 3, 1, 3, map('Gold',950,'Silver',550,'Bronze',250)
UNION ALL
SELECT 12, 3, 3, 2, 2, map('Gold',650,'Silver',350,'Bronze',150)
UNION ALL
SELECT 13, 1, 3, 3, 1, map('Gold',1200,'Silver',800,'Bronze',600)
UNION ALL
SELECT 14, 2, 3, 2, 3, map('Gold',700,'Silver',400,'Bronze',200)
UNION ALL
SELECT 15, 3, 3, 1, 2, map('Gold',500,'Silver',300,'Bronze',100);
