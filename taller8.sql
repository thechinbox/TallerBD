CREATE TABLE transacciones(
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
);

/*Triggers Punto 1*/
CREATE TRIGGER tr_pro AFTER INSERT OR UPDATE OR DELETE ON propiedades
      FOR EACH ROW EXECUTE PROCEDURE  tr_pronopr(6) ;
	  
CREATE TRIGGER tr_op AFTER INSERT OR UPDATE OR DELETE ON operaciones
      FOR EACH ROW EXECUTE PROCEDURE  tr_pronopr(7) ;

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

/*Triggers Punto 3*/
CREATE TRIGGER tr_opVA BEFORE INSERT OR UPDATE ON propiedades
      FOR EACH ROW EXECUTE PROCEDURE  tr_pronopr(7) ;
	  
CREATE OR REPLACE FUNCTION tr_valsup() RETURNS TRIGGER AS $$
	BEGIN
		IF (NEW.provincia = 'Lleida' AND NEW.tipo_propiedad = 'Casa') THEN
			
		ELSEIF (NEW.Provincia = 'Taragona' AND NEW.tipo_propiedad = 'Casa') THEN
			
		ELSEIF (NEW.Provincia = 'Girona' AND NEW.tipo_propiedad = 'Suelo') THEN
			
		ELSEIF (NEW.Provincia = 'Barcelona') THEN
		
		ELSEIF (NEW.tipo_propiedad = 'Industrial') THEN
			
		END IF;
	END
$$ LANGUAGE plpgsql;
