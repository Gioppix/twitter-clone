WITH RECURSIVE R AS (SELECT 10 AS n
    UNION ALL
    SELECT n-1 from R where n > 0)
SELECT n FROM R
