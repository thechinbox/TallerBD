SELECT CONCAT(personas.nombre, 'tiene' , COUNT(id_propiedad) , ' propiedades.') FROM propiedades
INNER JOIN personas ON propiedades.dueno = personas.rut
GROUP BY personas.nombre
HAVING count(dueno) > 1

SELECT prv.provincia, tpp.tipo_propiedad, too.tipo_operacion, MIN(op.precio)
	FROM provincias prv, tipos_propiedades tpp, operaciones op
INNER JOIN tipos_operaciones too ON op.tipo_operacion = too.id_tipooperacion
LEFT JOIN propiedades pro ON op.id_propiedad = pro.id_propiedad
WHERE pro.id_propiedad IS NULL
GROUP BY (prv.provincia, tpp.tipo_propiedad, too.tipo_operacion)

SELECT pr.nombre FROM operaciones op
INNER JOIN personas pr ON op.comprador = pr.rut
LEFT JOIN tipos_operaciones too ON op.tipo_operacion = too.id_tipooperacion
WHERE UPPER(too.tipo_operacion) like 'ALQUILER'
EXCEPT
SELECT pr.nombre FROM propiedades prp
INNER JOIN personas pr ON prp.dueno = pr.rut