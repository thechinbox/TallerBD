CREATE TABLE Traspaso(
	refer int,
	fa varchar(10),
	tpr varchar(25),
	top varchar(25),
	prov varchar(50),
	super int,
	constr int,
	pv int,
	fv varchar(10),
	vend varchar(50),
	supv varchar(50),
	dp varchar(100),
	rd varchar(10),
	cd varchar(13),
	ed varchar(150),
	ca varchar(100),
	rca varchar(10)
);

COPY Traspaso FROM 'C:\Users\thech\Desktop\BD\TallerBD.csv' CSV DELIMITER ';' HEADER ENCODING 'Latin1';

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
	SELECT DISTINCT vend FROM Traspaso WHERE vend IS NOT NULL AND supv IS NULL;
	
INSERT INTO vendedores(nombre, id_supervisor) 
	SELECT DISTINCT vend, vendedores.id_vendedor FROM Traspaso 
		INNER JOIN vendedores ON Traspaso.supv = vendedores.nombre
	WHERE vend IS NOT NULL;
	
/*Relleno Propiedades*/

INSERT INTO propiedades (tipo_propiedad, provincia, superficie, superficieconstruida, dueno)
	SELECT tipos_propiedades.id_tipo, provincias.id_provincia, super, constr, rd FROM Traspaso
		INNER JOIN tipos_propiedades ON UPPER(Traspaso.tpr) = tipos_propiedades.tipo_propiedad
		INNER JOIN provincias ON UPPER(Traspaso.prov) = provincias.provincia;

/*Rellena Operaciones*/

INSERT INTO operaciones(id_propiedad, fechaalta, tipo_operacion, precio, fechaoperacion, 
						vendedor, comprador) 
SELECT propiedades.id_propiedad, TO_DATE(fa,'dd/mm/yy'),tipos_operaciones.id_tipooperacion, pv, 
		TO_DATE(fv,'dd/mm/yy'), vendedores.id_vendedor, rca FROM Traspaso
	INNER JOIN propiedades ON (
		(SELECT id_provincia FROM provincias WHERE UPPER(Traspaso.prov) = provincia) = propiedades.provincia AND
		Traspaso.rd = propiedades.dueno	AND
		Traspaso.super = propiedades.superficie AND
		(SELECT id_tipo FROM tipos_propiedades WHERE UPPER(Traspaso.tpr) = tipo_propiedad) = propiedades.tipo_propiedad
		)
	INNER JOIN tipos_operaciones ON UPPER(Traspaso.top) = tipos_operaciones.tipo_operacion
	INNER JOIN vendedores ON Traspaso.vend = vendedores.nombre;
	
INSERT INTO operaciones(id_propiedad, fechaalta, tipo_operacion, precio, fechaoperacion, comprador) 
SELECT propiedades.id_propiedad, TO_DATE(fa,'dd/mm/yy'),tipos_operaciones.id_tipooperacion, pv, 
		TO_DATE(fv,'dd/mm/yy'), rca FROM Traspaso
	INNER JOIN propiedades ON (
		(SELECT id_provincia FROM provincias WHERE UPPER(Traspaso.prov) = provincia) = propiedades.provincia AND
		Traspaso.rd = propiedades.dueno	AND
		Traspaso.super = propiedades.superficie AND
		(SELECT id_tipo FROM tipos_propiedades WHERE UPPER(Traspaso.tpr) = tipo_propiedad) = propiedades.tipo_propiedad
		)
	INNER JOIN tipos_operaciones ON UPPER(Traspaso.top) = tipos_operaciones.tipo_operacion
	WHERE vend IS NULL;
 
DROP TABLE Traspaso;
	