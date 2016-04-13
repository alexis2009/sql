CREATE VIEW LtreeToNestedView AS
  SELECT ROW_NUMBER() OVER (ORDER BY K.path) AS i,
         K.id,
         K.value,
         K.path,
         COUNT(*)-1 AS child_count
  FROM KeywordLtree K, KeywordLtree K2
  WHERE K.path @> K2.path
  GROUP BY K.id,
           K.value,
           K.path;

SELECT id,
       value,
       2*i - nlevel(path) - 1,  -- 2*(i-1) - nlevel(path) + 1
       2*(i + child_count) - nlevel(path)  -- (2*(i-1) - nlevel(path) + 1) + 2*child_count + 1
FROM LtreeToNestedView;
