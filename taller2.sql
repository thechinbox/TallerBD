CREATE TABLE Traspaso(
	refer int,
	fa varchar(8),
	tpr varchar(25),
	top varchar(25),
	prov varchar(50),
	super int,
	constr int,
	pv int,
	fv varchar(8),
	vend varchar(50),
	supv varchar(50),
	dp varchar(100),
	rd varchar(10),
	cd varchar(13),
	ed varchar(150),
	ca varchar(100),
	rca varchar(10)
);

COPY Traspaso FROM 'C:\Users\thech\Desktop\BD\TallerBD.csv' CSV DELIMITER ';' HEADER ENCODING 'Latin1'

/*Rellena Provincia*/

INSERT INTO provincias(provincia) 
	SELECT DISTINCT UPPER(prov) FROM Traspaso;
	
/*Rellena Tipo Propiedad*/
INSERT INTO tipos_propiedades(tipo_propiedad) 
	SELECT DISTINCT UPPER(tpr) FROM Traspaso;
	
/*Rellena Tipo Operacion*/

INSERT INTO tipos_operaciones(tipo_operacion) 
	SELECT DISTINCT UPPER(top) FROM Traspaso;

/*Rellena Personas*/

INSERT INTO personas(rut, nombre, celular, email) 
	SELECT DISTINCT rd, dP, cd, ed FROM Traspaso WHERE rd IS NOT NULL;
	
INSERT INTO personas(rut, nombre)
	SELECT DISTINCT rca, ca FROM Traspaso WHERE NOT EXISTS 
		(SELECT rut FROM personas WHERE personas.rut = Traspaso.rca)
			AND rca IS NOT NULL;

/*Rellena Vendedores*/

INSERT INTO vendedores(nombre)
	SELECT DISTINCT vend FROM Traspaso WHERE vend IS NOT NULL;

SELECT DISTINCT Traspaso.vend, vendedores.nombre, vendedores.id_vendedor INTO temporal FROM vendedores
	INNER JOIN Traspaso ON vendedores.nombre = Traspaso.supv;

/*Aqui Borro la tabla que cree para relacionar los vendedores con (el id de) sus respectivos supervisores */
UPDATE vendedores
SET id_supervisor = t.id_vendedor FROM temporal t
WHERE vendedores.nombre = t.vend;

DELETE FROM temporal WHERE vend IS NOT NULL;
DROP TABLE temporal;

/*Relleno Propiedades*/

:c

/*Rellena Operaciones*/
INSERT INTO operaciones(id_propiedad, fechaalta, tipo_operacion, precio, fechaoperacion, 
						vendedor, comprador) 
	SELECT propiedades.id_propiedad, TO_DATE(fa,'dd/mm/yy'), tipos_operaciones.id_tipooperacion, pv, TO_DATE(fv,'dd/mm/yy'), rd, rca, constr, super FROM Traspaso
		INNER JOIN propiedades ON propiedades.dueno = Traspaso.rd 
		INNER JOIN tipos_operaciones ON tipos_operaciones.tipo_operacion = UPPER(Traspaso.top)

		