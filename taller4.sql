-- Punto 1 --
SELECT CONCAT(personas.nombre , ' tiene ' , COUNT(id_propiedad) , ' propiedades.') FROM propiedades
INNER JOIN personas ON propiedades.dueno = personas.rut
GROUP BY personas.nombre
HAVING count(dueno) > 1;

-- Punto 2 --
SELECT pr.provincia, tpp.tipo_propiedad, top.tipo_operacion, MIN(o.precio)
	FROM operaciones o
INNER JOIN tipos_operaciones top ON top.id_tipooperacion = o.tipo_operacion
INNER JOIN propiedades p ON p.id_propiedad = o.id_propiedad
INNER JOIN provincias pr ON pr.id_provincia = p.provincia
INNER JOIN tipos_propiedades tpp ON tpp.id_tipo = p.tipo_propiedad
WHERE o.comprador IS NULL 
GROUP BY (pr.provincia,tpp.tipo_propiedad,top.tipo_operacion)
ORDER BY pr.provincia;

-- Punto 3 --
SELECT pr.nombre FROM operaciones op
INNER JOIN personas pr ON op.comprador = pr.rut
LEFT JOIN tipos_operaciones too ON op.tipo_operacion = too.id_tipooperacion
WHERE UPPER(too.tipo_operacion) = 'ALQUILER'
EXCEPT
SELECT pr.nombre FROM propiedades prp
INNER JOIN personas pr ON prp.dueno = pr.rut;
