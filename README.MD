
# - Did Seguro Popular Reduce Formal Jobs?
### By Enrique Seira, Isaac Meza, Eduardo González-Pier, & Eduardo Alcaraz


This README includes the relevant structure of the project in order to replicate the paper "Did Seguro Popular Reduce Formal Jobs?"

Folders structure of the project is as follows :

- Data Created : Main & final datasets, which are already cleaned and processed for analysis in DoFiles and Rscripts not included here.

	- DiD_DB.dta : Balanced panel at the municipality-quarter level for the event study analysis, difference-in-difference, and IV. Includes census of SP, as well as IMSS aggregated data.
	- DiD_BC.dta : Bosch-Campos dataset.
	- sdemt_enoe.dta : This is the sdemt module of the ENOE. Data is at the individual-quarter level.
	- coe1t_enoe.dta : This is the coe1t module of the ENOE. Data is at the individual-quarter level.
	- luminosity.dta : Luminosity dataset. Observations are at the municipality-quarter level.

	It is important to note that the following datasets are not provided due to confidentiality reasons: 

	- panel_trabajadores.dta : Individual panel data from IMSS.
	- clues.dta : Information of all clinics in Mexico.
	- clues_lat_lon.dta : Geolocalization of clinics in Mexico.

- _aux : Auxiliary datasets

- DoFiles : Analysis of the data and econometrics is done with STATA. Dofiles are stored in this folder. Main dofile is calles 'master.do'

	1) To change the directory, the relevant path has to be modified at the beggining of 
			master.do
		
	2) Each figure and table of the paper is done in a relevant dofile which is called by master.do


- Tables : Location where tables are stored.
- Figures : Location where figures are stored.

- tex : This folder hosts the .tex files of the paper.



For any reference or support contact Isaac Meza (isaacmezalopez@g.harvard.edu)


--------------------------------------------------------------------