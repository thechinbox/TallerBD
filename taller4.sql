SELECT personas.nombre FROM propiedades
INNER JOIN personas ON propiedades.dueno = personas.rut
GROUP BY personas.nombre
HAVING count(dueno) > 1
ORDER BY personas.nombre

SELECT prv.provincia, tpp.tipo_propiedad, too.tipo_operacion, MIN(op.precio)
	FROM provincias prv, tipos_propiedades tpp, operaciones op
INNER JOIN tipos_operaciones too ON op.tipo_operacion = too.id_tipooperacion
GROUP BY (provincia, tipo_propiedad, too.tipo_operacion)

SELECT pr.nombre FROM operaciones op
INNER JOIN personas pr ON op.comprador = pr.rut
LEFT JOIN tipos_operaciones too ON op.tipo_operacion = too.id_tipooperacion
WHERE too.tipo_operacion = 'Alquiler'
EXCEPT
SELECT pr.nombre FROM propiedades prp
INNER JOIN personas pr ON prp.dueno = pr.rut

