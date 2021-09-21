/*Creacion de tabla con valores asociados a las letras de las patentes
CREATE TABLE patentes(
	letras varchar(2),
	valor varchar(3)
);
COPY patentes FROM 'C:\Users\thech\Desktop\BD\taller6\ValoresPatentes.csv' CSV DELIMITER ';' HEADER ENCODING 'Latin1';
*/

/*Funcion para Patentes Antiguas*/
CREATE OR REPLACE FUNCTION DVPATENTE_A(patente varchar) RETURNS char as $$
	DECLARE
		valorL varchar(3);
		dv char;
		cont integer;
		suma integer;
		ri integer;
		rf integer;
	BEGIN
		valorL := (SELECT valor FROM patentes WHERE letras = UPPER(SUBSTRING(patente,1,2)) );
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
			dv := rf;
		END IF;
		
		RETURN(dv);
	END
$$ LANGUAGE plpgsql;

/*Funcion para Patentes Nuevas (Autos y Motos)*/
CREATE OR REPLACE FUNCTION DVPATENTE_N(letras varchar, nums varchar) RETURNS char as $$
	DECLARE
		valorL varchar(3);
		dv char;
		cont integer;
		di integer;
		suma integer;
		ri integer;
		rf integer;
	BEGIN
		valorL := (SELECT valor FROM patentes WHERE letras = UPPER(letras));
		RETURN(dv);
	END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION DVPATENTE(patente varchar) RETURNS char as $$
	DECLARE dv char;
	BEGIN
		IF ( UPPER(patente) ~ '[A-Z]{4}[0-9]{2}') THEN
			dv := DVPATENTE_N(patente);
		
		ELSEIF ( UPPER(patente) ~ '[A-Z]{2}[0-9]{4}') THEN
			dv := DVPATENTE_A(patente);
		
		ELSEIF ( UPPER(patente) ~ '[A-Z]{3}[0-9]{2}') THEN
			dv := DVPATENTE_N(patente);
		ELSE
			dv := '-1';
		END IF;
		
		RETURN(dv);
		
	END
$$ LANGUAGE plpgsql;

select DVPATENTE('BA0000');
