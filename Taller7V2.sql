/*Tipo busqueda para los datos de las propiedades */
CREATE TYPE busqueda AS(
	id integer,
	tp varchar,
	top varchar,
	pr varchar,
	mC float,
	mT float,
	pM int
);

/*Tipo Ganancias para las ganancias por comision asociadas a un vendedor/supervisor */
CREATE TYPE ganancias AS (
	vendedor varchar,
	ganancias integer
);



/*Funcion para obtener las propiedades disponibles con los parametros correspondientes*/
CREATE OR REPLACE FUNCTION PropiedadesDisponibles(tpp varchar(50), tpo varchar(50), prov varchar(50),
									 cst integer, trr integer, pre integer ) RETURNS SETOF busqueda AS $$
	DECLARE 
		val boolean;
		pro RECORD;
		datos busqueda;
		crsPro REFCURSOR;
	BEGIN
		val := true;
		OPEN crsPro FOR 
		(SELECT op.id_propiedad AS idp, UPPER(tp.tipo_Propiedad) as tpro, UPPER(top.tipo_operacion) AS top, UPPER(pr.provincia) AS prv,
			prop.superficieconstruida AS supcons,prop.superficie AS sup, op.precio AS price FROM operaciones op
			INNER JOIN propiedades prop ON prop.id_propiedad = op.id_propiedad
			INNER JOIN tipos_operaciones top ON top.id_tipooperacion = op.tipo_operacion
			INNER JOIN tipos_propiedades tp ON tp.id_tipo = prop.tipo_propiedad
			INNER JOIN provincias pr ON pr.id_provincia = prop.provincia
			WHERE op.comprador IS NULL);
		LOOP
			FETCH NEXT FROM crsPro INTO pro;
				EXIT WHEN NOT FOUND;
				IF( tpp IS NOT NULL AND NOT(UPPER(tpp) = pro.tpro))THEN
					val := false;
				ELSEIF( tpo IS NOT NULL AND NOT(UPPER(tpo) = pro.top))THEN
					val := false;
				ELSEIF(prov IS NOT NULL AND NOT(UPPER(prov) = pro.prv))THEN
					val := false;
				ELSEIF(cst IS NOT NULL AND NOT(pro.supcons >= cst))THEN
					val := false;
				ELSEIF(trr IS NOT NULL AND NOT(pro.sup >= trr))THEN
					val := false;
				ELSEIF(pre IS NOT NULL AND NOT(pro.price <= cst))THEN
					val := false;
				END IF;
				IF(val = true)THEN
					datos := pro;
					RETURN NEXT datos;
				END IF;	
				val:= true;
		END LOOP;
	END

$$ LANGUAGE plpgsql;

/*Funcion para obtener la comision a pagar a un vendedor/supervisor en un periodo de fechas correspondiente */
CREATE OR REPLACE FUNCTION ComisionesAPagar(fechai varchar(10), fechaf varchar(10)) RETURNS SETOF ganancias AS $$
	DECLARE
		crsf REFCURSOR;
		crsS REFCURSOR;
		crsV REFCURSOR;
		aux RECORD;
		aux2 RECORD;
		coms ganancias;
		suma INTEGER;
	BEGIN 
		IF (fechai IS NULL OR NOT(fechai ~ '^(([0-2][1-9]|3[0-1])-([0-9][1-9]|1[1-2])-(19[0-9]{2}|20([0-1][0-9]|2[0-1])))$')) THEN
			OPEN crsf FOR (SELECT TO_CHAR(fechaoperacion, 'dd-mm-yyyy') FROM operaciones ORDER BY fechaoperacion ASC);
			fechai := null;
			FETCH FIRST FROM crsf INTO fechai;
		END IF;
		IF (fechaf IS NULL OR NOT(fechaf ~ '^(([0-2][1-9]|3[0-1])-([0-9][1-9]|1[1-2])-(19[0-9]{2}|20([0-1][0-9]|2[0-1])))$')) THEN
			fechaf := TO_CHAR(now(), 'dd-mm-yyyy');
		END IF;
		OPEN crsV SCROLL FOR 
			(SELECT vns.nombre as vendn, sup.nombre as supn, 
				SUM (CASE
                	WHEN op.tipo_operacion = (SELECT id_tipooperacion FROM tipos_operaciones top WHERE UPPER(top.tipo_operacion) = 'ALQUILER') THEN precio*0.08
                	ELSE precio*0.04
   				END) as sumav, 
				SUM (CASE
                	WHEN op.tipo_operacion = (SELECT id_tipooperacion FROM tipos_operaciones top WHERE UPPER(top.tipo_operacion) = 'ALQUILER') THEN precio*0.01
                	ELSE precio*0.02
        		END) as sumas FROM operaciones op
	 		INNER JOIN vendedores vns ON op.vendedor = vns.id_vendedor
	 		INNER JOIN vendedores sup ON sup.id_vendedor = (SELECT id_supervisor FROM vendedores WHERE id_vendedor = op.vendedor)
	 		WHERE op.fechaoperacion BETWEEN TO_DATE(fechai, 'DD-MM-YYYY') AND TO_DATE(fechaf, 'DD-MM-YYYY')
			GROUP BY vns.nombre, sup.nombre);
	 
		OPEN crsS FOR 
			(SELECT sup.nombre,
				SUM (CASE
                	WHEN op.tipo_operacion = (SELECT id_tipooperacion FROM tipos_operaciones top WHERE UPPER(top.tipo_operacion) = 'ALQUILER') THEN precio * 0.09
                	ELSE precio*0.06
   				END) FROM operaciones op
			INNER JOIN vendedores sup ON (op.vendedor = sup.id_vendedor AND 
										(SELECT id_supervisor FROM vendedores WHERE id_vendedor = sup.id_vendedor  ) IS NULL)
	 		WHERE op.fechaoperacion BETWEEN TO_DATE(fechai, 'DD-MM-YYYY') AND TO_DATE(fechaf, 'DD-MM-YYYY')
			GROUP BY sup.nombre);
	 
		LOOP
			FETCH NEXT FROM crsV INTO aux;
				EXIT WHEN NOT FOUND;
				coms.vendedor := aux.vendn;
				coms.ganancias := aux.sumav;
				RETURN NEXT coms;
		END LOOP;
		aux := null;
		LOOP
			FETCH NEXT FROM crsS INTO aux;
				EXIT WHEN NOT FOUND;
				coms.vendedor := aux.nombre;
				suma := aux.sum;
				FETCH FIRST FROM crsV INTO aux2;
					IF (aux2.supn = aux.nombre)THEN 
					suma := suma + aux2.sumas;
				END IF;
				LOOP FETCH NEXT FROM crsV INTO aux2;
					EXIT WHEN NOT FOUND;
					IF (aux2.supn = aux.nombre)THEN 
						suma := suma + aux2.sumas;
					END IF;
				END LOOP;
				coms.ganancias := suma;
				RETURN NEXT coms;
				suma:= 0;
		END LOOP;
	
	END
$$ LANGUAGE plpgsql;

/*Select para obtener las propiedades*/
SELECT PropiedadesDisponibles('Tipo propiedad', 'Tipo operacion','Provincia',
							  construido, superficie, precio);

/*Select para obtener la comision a recibir por parte de los trabajadores*/
SELECT ComisionesAPagar('Fecha Inicial en Formato dd-mm-aaaa','Fecha Final en Formato dd-mm-aaaa');

