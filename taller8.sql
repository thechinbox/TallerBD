/*CREATE TABLE transacciones(
	tabla varchar(25),
	fecha_hora timestamp,
	accion varchar(15),
	usuario varchar(25),
	camposinsertados varchar(200),
	camposmodificados varchar(200)
);

CREATE TABLE ventasxmes(
	mes_ano VARCHAR(7),/*MM-YYYY*/
	vendedor VARCHAR,/*NOMBRE*/
	transaccion VARCHAR,/*Tipo Operacion/NOMBRE */
	cant_tr INTEGER, /*Cantidad Transacciones por mes */
	mtotal_tr INTEGER /*El monto total que suman las transacciones del mes*/
);*/

/*Funcion Punto 1*/
CREATE OR REPLACE FUNCTION tr_pronopr() RETURNS TRIGGER AS $$
	DECLARE	
		newR varchar;
		oldR varchar;
		i integer;
	BEGIN
		i := 1;
		newR := '';
		oldR := '';
		IF (TG_OP = 'UPDATE') THEN 
			WHILE i <= TG_ARGV[0]::INTEGER LOOP
			IF ( SPLIT_PART(NEW::varchar, ',', i) != SPLIT_PART(OLD::varchar, ',', i) ) THEN
				IF (newR = '' AND oldR = '') THEN
					newR := CONCAT(newR, SPLIT_PART(NEW::varchar, ', ', i));
					oldR := CONCAT(oldR, SPLIT_PART(OLD::varchar, ', ', i));
				ELSE
					newR := CONCAT(newR, ' , ', SPLIT_PART(NEW::varchar, ',', i));
					oldR := CONCAT(oldR, ' , ', SPLIT_PART(OLD::varchar, ',', i));
				END IF;
			END IF;
			i := i + 1;
		END LOOP;	
		ELSE 
			newR := NEW::varchar;
			oldR := OLD::varchar;
		END IF;
		INSERT INTO transacciones (tabla,fecha_hora,accion,usuario,camposinsertados,camposmodificados)    
			VALUES (TG_TABLE_NAME, now(), TG_OP, 'nose', newR, oldR);
		return (null);
	END	
$$ LANGUAGE plpgsql;

/*Triggers Punto 1*/
CREATE TRIGGER tr_pro AFTER INSERT OR UPDATE OR DELETE ON propiedades
      FOR EACH ROW EXECUTE PROCEDURE  tr_pronopr(6) ;
	  
CREATE TRIGGER tr_op AFTER INSERT OR UPDATE OR DELETE ON operaciones
      FOR EACH ROW EXECUTE PROCEDURE  tr_pronopr(7) ;

/*Funcion Punto 3*/
CREATE OR REPLACE FUNCTION tr_valsup() RETURNS TRIGGER AS $$
	DECLARE 
	prov varchar;
	tipopr varchar;
	BEGIN
		prov = (SELECT provincia FROM provincias WHERE id_provincia = NEW.provincia);
		tipopr = (SELECT tipo_propiedad FROM tipos_propiedades WHERE id_tipo = NEW.tipo_propiedad);
		
		IF (prov = 'LLEIDA' AND tipopr ='PARKING' AND NEW.superficie < 100) THEN
			RAISE EXCEPTION 'Superficie Menor a 100';
			
		ELSEIF (prov = 'TARAGONA' AND tipopr = 'CASA' AND NEW.superficieconstruida > 3 * NEW.superficie) THEN
				RAISE EXCEPTION 'Superficie Construida Supera el Limite Establecido';
				
		ELSEIF (prov = 'GIRONA' AND tipopr = 'SUELO' AND NEW.superficie < 200) THEN
			RAISE EXCEPTION 'Superficie Menor a 200';

		ELSEIF (prov = 'BARCELONA' AND NEW.superficieconstruida > 2 * NEW.superficie) THEN
			RAISE EXCEPTION 'Superficie Menor a 200';
			
		ELSEIF (tipopr = 'INDUSTRIAL' AND NEW.superficie < 500) THEN
			RAISE EXCEPTION 'Superficie Menor a 500';
		END IF;
	END
$$ LANGUAGE plpgsql;

/*Triggers Punto 3*/
CREATE TRIGGER tr_opVA BEFORE INSERT OR UPDATE ON propiedades
      FOR EACH ROW EXECUTE PROCEDURE  tr_valsup() ;


	  
select * from provincias
select * from propiedades WHERE provincia = 2 AND tipo_propiedad = 2  AND superficie = 180 ORDER BY id_propiedad 
INSERT INTO propiedades(tipo_propiedad, provincia, superficie,dueno)
VALUES (2,2, 180,'24295582-K')