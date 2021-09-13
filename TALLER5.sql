--Punto 1--
SELECT to_char(fechaoperacion, 'YYYY-MM'), SUM(precio) FROM operaciones 
WHERE fechaoperacion IS NOT NULL
GROUP BY (to_char(fechaoperacion, 'YYYY-MM'))
HAVING SUM(precio) >= ALL(SELECT SUM(precio) FROM operaciones WHERE fechaoperacion IS NOT NULL GROUP BY (to_char(fechaoperacion, 'YYYY-MM'))) 
