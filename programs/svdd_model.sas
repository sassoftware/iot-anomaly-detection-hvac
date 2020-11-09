/*******************************************************************************************/
/**** 		 					1. Connect to CAS and Load Data				 			****/
/*******************************************************************************************/

%let cashost=<CAS host>;
%let casport=<CAS port>;
options cashost="&cashost." casport=&casport. ;
CAS casauto SESSOPTS=(CASLIB=casuser TIMEOUT=99 LOCALE="en_US");
libname mycas CAS ;

proc casutil;
	load file="<your path>/ahu_train.csv" 
	outcaslib="casuser" casout="ahu_train";
run;

proc casutil;
	load file="<your path>/ahu_scr.csv" 
	outcaslib="casuser" casout="ahu_scr";
run;


/*******************************************************************************************/
/**** 		 	2. Select Vector Data Description (SVDD) for Anaomaly detection 		****/
/*******************************************************************************************/

%let model_var=SUPPL_FAN_SP
DIS_AIR_TEMP
DUCT_PRESS_ACTV
MIXED_AIR_TEMP
RTRN_AIR_TEMP
MAX_CO2_VAL
CHW_VALVE
CHW_VALVE_POSIT;

/*** Phase 1: Model Training ***/
/* Train SVDD model using normal operations data */

proc svdd data=mycas.ahu_train ;
    id AHU ;
    input &model_var. /level=interval;
    kernel rbf / bw=94;
    savestate rstore=mycas.svdd_ahu;
 run;

/*** Phase 2: Score to get distance value to monitor anomaly ***/

 proc astore;
    score data=mycas.ahu_scr
    out=mycas.ahu_svdd_out
    rstore=mycas.svdd_ahu;
	download rstore=mycas.svdd_ahu store='<your path>/svdd_ahu.astore';
 quit;


