SELECT CONCAT('Hoy es ', TO_CHAR(now(), 'DD/MM/YYYY') );

SELECT operaciones.*, provincias.provincia FROM operaciones
INNER JOIN provincias ON provincias.id_provincia = (
	SELECT provincia FROM propiedades WHERE id_propiedad = operaciones.id_propiedad)
WHERE (vendedor = (SELECT id_vendedor FROM vendedores WHERE UPPER(nombre) = UPPER('Luisa')) AND
	   tipo_operacion = (SELECT id_tipooperacion FROM tipos_operaciones WHERE UPPER(tipo_operacion) = UPPER('Venta')))
ORDER BY (provincias.provincia, fechaoperacion);

SELECT CONCAT('El/La vendedor/a ', v.nombre, ' es supervisado/a por ', 
			  (CASE
			 	WHEN (s.nombre IS NULL) THEN 'Nadie'
			 	ELSE s.nombre END) ) FROM vendedores v
LEFT JOIN vendedores s ON v.id_supervisor = s.id_vendedor;


SELECT CONCAT(vendedores.nombre, ' deberá recibir ',
			  (CASE UPPER((SELECT tipo_operacion as tv FROM tipos_operaciones WHERE id_tipooperacion = operaciones.tipo_operacion))
				WHEN 'VENTA' THEN precio*0.1
				WHEN 'ALQUILER' THEN precio*0.07
				ELSE precio END ),' por la operación de ',
			  	UPPER((SELECT tipo_operacion FROM tipos_operaciones WHERE id_tipooperacion = operaciones.tipo_operacion)),
			  	' del día ', TO_CHAR(fechaoperacion, 'DD/MM/YYYY')) FROM operaciones 
INNER JOIN vendedores ON operaciones.vendedor = vendedores.id_vendedor
WHERE fechaoperacion BETWEEN '01/01/2001' AND '01/01/2021'
ORDER BY id_propiedad;
