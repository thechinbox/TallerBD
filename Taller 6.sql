/*Creacion de tabla con valores asociados a las letras de las patentes*/
CREATE TABLE patentes(
	letras varchar(2),
	valor varchar(3)
);
									/*Modificar la Ruta*/
COPY patentes FROM 'C:\Users\thech\Desktop\BD\taller6\ValoresPatentes.csv' CSV DELIMITER ';' HEADER ENCODING 'Latin1';


/*Funcion para Patentes Antiguas-Autos */
CREATE OR REPLACE FUNCTION DVPATENTE_AA(patente varchar) RETURNS char as $$
	DECLARE
		valorL varchar(3);
		dv char;
		cont integer;
		suma integer;
		ri integer;
		rf integer;
	BEGIN
		valorL := (SELECT valor FROM patentes WHERE letras = SUBSTRING(patente,1,2) );
		cont := 0;
		suma := 0;
		WHILE(cont < 4) LOOP
			suma := suma + ((cont + 2) * (SUBSTRING(patente,(6-cont),1)::int));
			cont := cont + 1;
		END LOOP;
		cont := 0;
		WHILE(cont < 2) LOOP
			suma := suma + ((6+cont) * (SUBSTRING(valorL,(3-cont),1))::int);
			cont := cont + 1;
		END LOOP;
		
		suma := suma + (2 * (SUBSTRING(valorL,1,1)::int));
		
		ri := (suma % 11)::int;
		rf := 11-ri;
		
		IF ( rf = 11 ) THEN
			dv := '0';
		ELSEIF ( rf = 10 ) THEN
			dv := 'K';
		ElSE
			dv := rf::char;
		END IF;
		
		RETURN(dv);
	END
$$ LANGUAGE plpgsql;

/*Funcion para Patentes Nuevas-Autos*/
CREATE OR REPLACE FUNCTION DVPATENTE_NA(patente varchar) RETURNS char as $$
	DECLARE
		dv char;
		cont integer;
		suma integer;
	BEGIN
		cont := 0;
		suma := 0;
		WHILE (cont < 4) LOOP
			suma := suma + (7 - cont) * (SELECT valor FROM patentes WHERE letras = SUBSTRING(patente,(1 + cont),1))::int;
			cont := cont + 1;
		END LOOP;
		suma := suma + 3 *  (SUBSTRING(patente,5,1))::int;
		suma := suma + 2 *  (SUBSTRING(patente,6,1))::int;
		suma := (suma % 11);
		
		IF ( suma = 0 ) THEN
			dv := '0';
		ElSE
			suma := 11 - suma ;
			IF(suma = 10) THEN
				dv := 'K';
			ELSE 
				dv := suma::char;
			END IF;
		END IF;
		
		RETURN(dv);
	END
	
$$ LANGUAGE plpgsql;

/*Funcion para Patentes Nuevas/Antiguas-Motos*/
CREATE OR REPLACE FUNCTION DVPATENTE_NAM(patente varchar) RETURNS char as $$
	DECLARE
		dv char;
		cont integer;
		suma integer;
	BEGIN
		IF (LENGTH(patente) = 5) THEN
			patente := concat(SUBSTRING(patente,1,3),'0',SUBSTRING(patente,4,2));
		END IF;
		cont := 0;
		suma := 0;
		WHILE (cont < 3) LOOP
			suma := suma + (7 - cont) * (SELECT valor FROM patentes WHERE letras = SUBSTRING(patente,(1 + cont),1))::int;
			cont := cont + 1;
		END LOOP;
		cont := 0;
		WHILE (cont < 3) LOOP
			suma := suma + (4 - cont) * (SUBSTRING(patente,(4 + cont),1))::int;
			cont := cont + 1;
		END LOOP;
		suma := (suma % 11);
		
		IF ( suma = 0 ) THEN
			dv := '0';
		ElSE
			suma := 11 - suma ;
			IF(suma = 10) THEN
				dv := 'K';
			ELSE 
				dv := suma::char;
			END IF;
		END IF;
		RETURN(dv);
	END
$$ LANGUAGE plpgsql;

/*Funcion Principal*/
CREATE OR REPLACE FUNCTION DVPATENTE(patente varchar) RETURNS char as $$
	DECLARE dv char;
	BEGIN
		IF ( UPPER(patente) ~* '^[A-Z]{4}[0-9]{2}$') THEN
			dv := DVPATENTE_NA(UPPER(patente));
		
		ELSEIF ( UPPER(patente) ~* '^[A-Z]{2}[0-9]{4}$') THEN
			dv := DVPATENTE_AA(UPPER(patente));
		
		ELSEIF ( UPPER(patente) ~* '^[A-Z]{3}[0-9]{2}$') THEN
			dv := DVPATENTE_NAM(UPPER(patente));
			
		ELSEIF ( UPPER(patente) ~* '^[A-Z]{3}[0-9]{3}$') THEN
			dv := DVPATENTE_NAM(UPPER(patente));
		ELSE
			dv := 'N';
		END IF;
		
		RETURN(dv);
		
	END
$$ LANGUAGE plpgsql;

SELECT DVPATENTE('Ingresar la patente aqui');


