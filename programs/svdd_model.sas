/*******************************************************************************************/
/**** 		 	Select Vector Data Description (SVDD) for Anaomaly detection 			****/
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

proc svdd data=mycas.hvac_train ;
    id AHU Datetime;
    input &model_var. /level=interval;
    kernel rbf / bw=94;
    savestate rstore=mycas.hvac_svdd;
 run;

/*** Phase 2: Score to get distance value to monitor anomaly ***/

 proc astore;
    score data=mycas.hvac_score
    out=mycas.hvac_svdd_out
    rstore=mycas.hvac_svdd;
	download rstore=mycas.hvac_svdd store='<your path>/hvac_svdd';
 quit;


