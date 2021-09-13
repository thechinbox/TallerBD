--PUNTO 1--
SELECT to_char(fechaoperacion, 'MM-YYYY'), SUM(precio) FROM operaciones 
WHERE fechaoperacion IS NOT NULL
GROUP BY (to_char(fechaoperacion, 'MM-YYYY'))
HAVING SUM(precio) >= ALL(SELECT SUM(precio) FROM operaciones WHERE fechaoperacion IS NOT NULL GROUP BY (to_char(fechaoperacion, 'YYYY-MM'))) 

--PUNTO 2--
SELECT pv.provincia, SUM(op.precio)  FROM operaciones op
INNER JOIN propiedades pr ON op.id_propiedad = pr.id_propiedad
INNER JOIN provincias pv ON pr.provincia = pv.id_provincia
WHERE to_char(fechaoperacion, 'MM-YYYY') 
LIKE (SELECT to_char(fechaoperacion, 'MM-YYYY') FROM operaciones 
		WHERE fechaoperacion IS NOT NULL
		GROUP BY (to_char(fechaoperacion, 'MM-YYYY'))
		HAVING SUM(precio) >= 
	  	ALL(SELECT SUM(precio) FROM operaciones WHERE fechaoperacion IS NOT NULL GROUP BY (to_char(fechaoperacion, 'YYYY-MM'))) 
		)
GROUP BY pv.provincia
HAVING  SUM(op.precio) >= ALL(
	SELECT SUM(op.precio) from operaciones op
	INNER JOIN propiedades pr ON op.id_propiedad = pr.id_propiedad
	INNER JOIN provincias pv ON pr.provincia = pv.id_provincia
	WHERE to_char(fechaoperacion, 'MM-YYYY') 
	LIKE (SELECT to_char(fechaoperacion,'MM-YYYY') FROM operaciones 
		WHERE fechaoperacion IS NOT NULL
		GROUP BY (to_char(fechaoperacion, 'MM-YYYY'))
		HAVING SUM(precio) >= 
	  	ALL(SELECT SUM(precio) FROM operaciones WHERE fechaoperacion IS NOT NULL GROUP BY (to_char(fechaoperacion, 'YYYY-MM'))) 
		)
	GROUP BY pv.provincia
)

--PUNTO 3--
SELECT v.nombre FROM operaciones op
INNER JOIN vendedores v ON op.vendedor = v.id_vendedor
INNER JOIN propiedades pro ON 
(op.id_propiedad = pro.id_propiedad AND
(SELECT id_provincia FROM provincias WHERE provincia =  
	(SELECT pv.provincia FROM operaciones op
	INNER JOIN propiedades pr ON op.id_propiedad = pr.id_propiedad
	INNER JOIN provincias pv ON pr.provincia = pv.id_provincia
	WHERE to_char(fechaoperacion, 'MM-YYYY') 
	LIKE (SELECT to_char(fechaoperacion, 'MM-YYYY') FROM operaciones 
		WHERE fechaoperacion IS NOT NULL
		GROUP BY (to_char(fechaoperacion, 'MM-YYYY'))
		HAVING SUM(precio) >= 
	  	ALL(SELECT SUM(precio) FROM operaciones WHERE fechaoperacion IS NOT NULL GROUP BY (to_char(fechaoperacion, 'YYYY-MM'))) 
		)
	GROUP BY pv.provincia
	HAVING SUM(op.precio) >= ALL(
		SELECT SUM(op.precio) from operaciones op
		INNER JOIN propiedades pr ON op.id_propiedad = pr.id_propiedad
		INNER JOIN provincias pv ON pr.provincia = pv.id_provincia
		WHERE to_char(fechaoperacion, 'MM-YYYY') 
		LIKE (SELECT to_char(fechaoperacion,'MM-YYYY') FROM operaciones 
			WHERE fechaoperacion IS NOT NULL
			GROUP BY (to_char(fechaoperacion, 'MM-YYYY'))
			HAVING SUM(precio) >= 
	  		ALL(SELECT SUM(precio) FROM operaciones WHERE fechaoperacion IS NOT NULL GROUP BY (to_char(fechaoperacion, 'YYYY-MM'))) 
			)	
		GROUP BY pv.provincia
		)
	) 
) = pro.provincia)							   
WHERE to_char(op.fechaoperacion, 'MM-YYYY') 
LIKE (SELECT to_char(fechaoperacion, 'MM-YYYY') FROM operaciones 
		WHERE fechaoperacion IS NOT NULL
		GROUP BY (to_char(fechaoperacion, 'MM-YYYY'))
		HAVING SUM(precio) >= 
	  	ALL(SELECT SUM(precio) FROM operaciones WHERE fechaoperacion IS NOT NULL GROUP BY (to_char(fechaoperacion, 'YYYY-MM'))) 
		)
GROUP BY v.nombre
HAVING SUM(precio) >= ALL(
	SELECT SUM(precio) FROM operaciones op
	INNER JOIN vendedores v ON op.vendedor = v.id_vendedor
	INNER JOIN propiedades pro ON 
	(op.id_propiedad = pro.id_propiedad AND
	(SELECT id_provincia FROM provincias WHERE provincia =  
		(SELECT pv.provincia FROM operaciones op
		INNER JOIN propiedades pr ON op.id_propiedad = pr.id_propiedad
		INNER JOIN provincias pv ON pr.provincia = pv.id_provincia
		WHERE to_char(fechaoperacion, 'MM-YYYY') 
		LIKE (SELECT to_char(fechaoperacion, 'MM-YYYY') FROM operaciones 
			WHERE fechaoperacion IS NOT NULL
			GROUP BY (to_char(fechaoperacion, 'MM-YYYY'))
			HAVING SUM(precio) >= 
	  		ALL(SELECT SUM(precio) FROM operaciones WHERE fechaoperacion IS NOT NULL GROUP BY (to_char(fechaoperacion, 'YYYY-MM'))) 
			)
		GROUP BY pv.provincia
		HAVING SUM(op.precio) >= ALL(
			SELECT SUM(op.precio) from operaciones op
			INNER JOIN propiedades pr ON op.id_propiedad = pr.id_propiedad
			INNER JOIN provincias pv ON pr.provincia = pv.id_provincia
			WHERE to_char(fechaoperacion, 'MM-YYYY') 
			LIKE (SELECT to_char(fechaoperacion,'MM-YYYY') FROM operaciones 
				WHERE fechaoperacion IS NOT NULL
				GROUP BY (to_char(fechaoperacion, 'MM-YYYY'))
				HAVING SUM(precio) >= 
	  			ALL(SELECT SUM(precio) FROM operaciones WHERE fechaoperacion IS NOT NULL GROUP BY (to_char(fechaoperacion, 'YYYY-MM'))) 
				)	
			GROUP BY pv.provincia
			)
		) 
	) = pro.provincia)							   
	WHERE to_char(op.fechaoperacion, 'MM-YYYY') 
	LIKE (SELECT to_char(fechaoperacion, 'MM-YYYY') FROM operaciones 
		WHERE fechaoperacion IS NOT NULL
		GROUP BY (to_char(fechaoperacion, 'MM-YYYY'))
		HAVING SUM(precio) >= 
	  	ALL(SELECT SUM(precio) FROM operaciones WHERE fechaoperacion IS NOT NULL GROUP BY (to_char(fechaoperacion, 'YYYY-MM'))) 
		)
	GROUP BY v.nombre
)

