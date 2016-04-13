WITH StockIndex AS (
  SELECT company,
         week,
         share_price - FIRST_VALUE(share_price) OVER (
           PARTITION BY company ORDER BY week ASC
           ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
         ) wow_growth
  FROM StockQuotes
),
GrowthWeek AS (
  SELECT company,
         week,
         CASE WHEN wow_growth > AVG(wow_growth) OVER (PARTITION by week)
           THEN 1
           ELSE 0
         END isgrowth
  FROM StockIndex
),
GrowthWeeksCount AS (
  SELECT company,
         week,
         SUM(isgrowth) OVER (
           PARTITION BY company ORDER BY week ASC
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
         ) growth_time
  FROM GrowthWeek
)
SELECT company,
       COUNT(growth_time)
FROM GrowthWeeksCount
WHERE growth_time >= 3
GROUP BY company
