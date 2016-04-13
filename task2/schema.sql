-- CREATE EXTENSION ltree;

DROP TABLE IF EXISTS KeywordSets;
DROP TABLE IF EXISTS KeywordLtree;

CREATE TABLE KeywordLtree(
  id INT PRIMARY KEY,
  value TEXT,
  path ltree
);

CREATE TABLE KeywordSets(
  id INT PRIMARY KEY,
  value TEXT,
  lft INT,
  rgt INT
);

-- Вставка новой вершины в дерево в таблице KeywordLtree
CREATE OR REPLACE FUNCTION InsertKeywordLtree(_id INT, _parent_id INT, _value TEXT)
RETURNS VOID AS $$
BEGIN
INSERT INTO KeywordLtree
SELECT _id AS id, _value AS value, K.path || text2ltree(_id::TEXT) AS path
FROM KeywordLtree K WHERE id = _parent_id;
END;
$$ LANGUAGE plpgsql;


-- Генерация случайного дерева из 50 вершин
CREATE OR REPLACE FUNCTION GenerateData()
RETURNS VOID AS $$
DECLARE
  _id INT;
  _parent_id INT;
  _value TEXT;
BEGIN
INSERT INTO KeywordLtree(id, value, path) VALUES (0, 'root', '');
FOR _id IN 1..49 LOOP
  _parent_id = floor((random()*_id));
  _value = md5(random()::TEXT);
  PERFORM InsertKeywordLtree(_id, _parent_id, _value);
END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT GenerateData();
