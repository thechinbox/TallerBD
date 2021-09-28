/*CREATE TYPE pro AS (
	idprop INTEGER 
);*/

CREATE OR REPLACE FUNCTION PropiedadesDisponibles(tpp varchar, tpo varchar, prov varchar,
									 cst integer, trr integer, pre integer ) RETURNS SETOF pro AS $$
	DECLARE 
		val boolean;
		pro RECORD;
		idpro pro;
		crsPro REFCURSOR;
		param0 FLOAT;
		param1 FLOAT;
		param2 FLOAT;
	BEGIN
		val := true;
		IF (cst IS NULL OR NOT(cst::varchar ~ '^[0-9]+$') ) THEN
			param0 := FLOAT8 '-infinity';
		ELSE
			param0 = cst;
		END IF;
		IF (trr IS NULL OR NOT(trr::varchar ~ '^[0-9]+$') ) THEN
			param1 := FLOAT8 '-infinity';
		ELSE
			param1 = trr;
		END IF;
		IF (pre IS NULL OR NOT(pre::varchar ~ '^[0-9]+$') ) THEN
			param2 := FLOAT8 '+infinity';
		ELSE
			param2 = pre;
		END IF;
		OPEN crsPro FOR 
		(SELECT op.id_propiedad, prop.tipo_propiedad, tipo_operacion, prop.provincia, prop.superficieconstruida, 
		 	prop.superficie, precio FROM operaciones op
		 INNER JOIN propiedades prop ON (op.id_propiedad = prop.id_propiedad 
										 AND prop.superficie >= param0
										 AND prop.superficieconstruida >= param1)
		 WHERE fechaoperacion IS NULL AND precio <= param2
		 ORDER BY op.id_propiedad);
		LOOP
			FETCH NEXT FROM crsPro INTO pro;
				IF( tpo IS NOT NULL AND NOT(tpo = (SELECT tipo_propiedad FROM tipos_propiedades
												   WHERE id_tipo = pro.tipo_propiedad)))THEN
					val := false;
				END IF;
				IF( tpp IS NOT NULL AND NOT(tpp = (SELECT tipo_operacion FROM tipos_operaciones
												   WHERE id_tipooperacion = pro.tipo_operacion)))THEN
					val := false;
				END IF;
				IF( pro IS NOT NULL AND NOT(prov = (SELECT provincia FROM provincias
												   WHERE id_provincia = pro.provincia)))THEN
					val := false;
				END IF;
				IF(val = true)THEN
					idpro.idprop := pro.id_propiedad ;
					RETURN NEXT idpro;
				END IF;
				
				EXIT WHEN NOT FOUND;
				val := true;
		END LOOP;
	END
$$ LANGUAGE plpgsql;

SELECT PropiedadesDisponibles(NULL,NULL,NULL,0,NULL,NULL)
