/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avMedrioTransposeSourceVS.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Transposes the source Vital Signs datasets from Medrio
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avMedrioTransposeSourceVS(dataIn=, dataOut=);
	%if ^%sysfunc(exist(&dataIn)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] &dataIn does not exist.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted.;
		%return;
	%end;

	%if ^%sysfunc(prxmatch(%str(m/^[A-Za-z_]([A-Za-z_0-9]{1,31})?$/oi), %bquote(&dataOut))) %then %do;
	 	%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] &dataOut is not a valid SAS dataset name;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	proc sql noprint;
		select count(*) into :avVSCount from &dataIn;
	quit;

	%if &avVSCount. = 0 %then %do;
		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No observations found in &dataIn.;
		%put NOTE:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted.;
		%return;
	%end;

	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	data AVGML.vs1(keep=subjid vsspid_crf vsperf_crf vsreasnd_crf visit_crf vstpt_crf vspos_crf vsdat vstim vsclsig_crf vsfast_crf SYSBP DIABP PULSE RESP HR TEMP INTP  HEIGHT WEIGHT BMI);
		set &dataIn;
		length subjid $50. vsperf_crf visit_crf vstpt_crf vsspid_crf vspos_crf vsclsig_crf vsfast_crf SYSBP DIABP PULSE RESP HR TEMP INTP HEIGHT WEIGHT BMI $200. vsreasnd_crf $600.;		
	 
		subjid = strip(subjectid);

		/* Set all variables as '' */
		call missing(vsperf_crf, vsreasnd_crf, visit_crf, vstpt_crf, vspos_crf, vsclsig_crf, vsfast_crf, vsspid_crf);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vsperf_coded) 
			vsperf_crf = strip(vsperf_coded);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vsreasnd) 
			vsreasnd_crf = strip(vsreasnd);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=visit) 
			visit_crf = strip(visit);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vstpt) 
			vstpt_crf = strip(vstpt);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vspos_coded) 
			vspos_crf = strip(vspos_coded);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vsclsig_coded) 
			vsclsig_crf = strip(vsclsig_coded);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vsfast_coded) 
			vsfast_crf = strip(vsfast_coded);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vargroup1row) 
			vsspid_crf = strip(put(vargroup1row, ??best.));


		/* Flag all parameters for deletion as initial value. If parameter is present in source it will be overwritten, in which case it wil not be deleted */
		SYSBP 	= 'DEL';
		DIABP 	= 'DEL';
		PULSE 	= 'DEL';
		RESP 	= 'DEL';
		HR 		= 'DEL';
		TEMP 	= 'DEL';
		INTP 	= 'DEL';

		HEIGHT 	= 'DEL';
		WEIGHT 	= 'DEL';
		BMI 	= 'DEL';
	 
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=sysbp_vsorres) 
			SYSBP = strip(put(sysbp_vsorres, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=diabp_vsorres) 
			DIABP = strip(put(diabp_vsorres, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=pulse_vsorres) 
			PULSE = strip(put(pulse_vsorres, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=resp_vsorres) 
			RESP = strip(put(resp_vsorres, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=hr_vsorres) 
			HR = strip(put(hr_vsorres, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=temp_vsorres) 
			TEMP = strip(put(temp_vsorres, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=intp_vsorres_coded) 
			INTP = strip(intp_vsorres_coded);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=height_vsorres) 
			HEIGHT = strip(put(height_vsorres, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=weight_vsorres) 
			WEIGHT = strip(put(weight_vsorres, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=bmi_vsorres) 
			BMI = strip(put(bmi_vsorres, best.));
	 
		proc sort;
			by subjid vsspid_crf visit_crf vstpt_crf vspos_crf vsdat vstim vsclsig_crf vsfast_crf vsperf_crf vsreasnd_crf;
	run;
	 
	proc transpose data=AVGML.vs1 out=&dataOut;
		by subjid vsspid_crf visit_crf vstpt_crf vspos_crf vsdat vstim vsclsig_crf vsfast_crf vsperf_crf vsreasnd_crf;
		var SYSBP DIABP PULSE RESP HR TEMP INTP  HEIGHT WEIGHT BMI;
	run;
%mend avMedrioTransposeSourceVS;
