/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avRaveTransposeSourceVS.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Transposes the source Vital Signs datasets from Rave
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avRaveTransposeSourceVS(dataIn=, dataOut=);
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML is study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

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

	data AVGML.vs1(keep=subjid vsspid_crf vsperf_crf vsreasnd_crf visit_crf vstpt_crf vspos_crf vsdate_crf vstim_crf vsclsig_crf vsfast_crf SYSBP DIABP PULSE RESP HR TEMP INTP  HEIGHT WEIGHT BMI);
		set &dataIn;
		length subjid $50. vsperf_crf visit_crf vstpt_crf vspos_crf vsclsig_crf vsfast_crf vsspid_crf vstim_crf SYSBP DIABP PULSE RESP HR TEMP INTP HEIGHT WEIGHT BMI $200. vsreasnd_crf $600.;
		format vsdate_crf datetime22.3;	
	 
		subjid = strip(subject);

		/* Set all variables as '' */
		call missing(vstim_crf, vsperf_crf, vsreasnd_crf, visit_crf, vstpt_crf, vspos_crf, vsclsig_crf, vsfast_crf, vsspid_crf);

		/* Check all known labels of dates */
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vsdat_int) 
			vsdate_crf = vsdat_int;
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vsdat_l_int) 
			vsdate_crf = vsdat_l_int;
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vsdat_h_int) 
			vsdate_crf = vsdat_h_int;
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vsdat_w_int) 
			vsdate_crf = vsdat_w_int;
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vsdat_t_int) 
			vsdate_crf = vsdat_t_int;

		/* Check all known labels of time */
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vstim) 
			vstim_crf = vstim;
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vstim_l) 
			vstim_crf = vstim_l;
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vstim_h) 
			vstim_crf = vstim_h;
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vstim_w) 
			vstim_crf = vstim_w;
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vstim_t) 
			vstim_crf = vstim_t;

		
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vsperf_std) 
			vsperf_crf = strip(vsperf_std);


		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vsreasnd) 
			vsreasnd_crf = strip(vsreasnd);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=instancename) 
			visit_crf = strip(instancename);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vstpt_l) 
			vstpt_crf = strip(vstpt_l);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vspos_std) 
			vspos_crf = strip(vspos_std);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vsclsig_std) 
			vsclsig_crf = strip(vsclsig_std);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vsfast_std) 
			vsfast_crf = strip(vsfast_std);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=recordposition) 
			vsspid_crf = strip(put(recordposition, ??best.));

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
			SYSBP = strip(put(sysbp_vsorres, ??best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=diabp_vsorres) 
			DIABP = strip(put(diabp_vsorres, ??best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=pulse_vsorres) 
			PULSE = strip(put(pulse_vsorres, ??best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=resp_vsorres) 
			RESP = strip(put(resp_vsorres, ??best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=hr_vsorres) 
			HR = strip(put(hr_vsorres, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=temp_vsorres) 
			TEMP = strip(put(temp_vsorres, ??best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=intp_vsorres_std) 
			INTP = strip(intp_vsorres_std);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=height_vsorres) 
			HEIGHT = strip(put(height_vsorres, ??best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=weight_vsorres) 
			WEIGHT = strip(put(weight_vsorres, ??best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=bmi_vsorres) 
			BMI = strip(put(bmi_vsorres, ??best.));
	 
		proc sort;
			by subjid vsspid_crf visit_crf vstpt_crf vspos_crf vsdate_crf vstim_crf vsclsig_crf vsfast_crf vsperf_crf vsreasnd_crf;
	run;
	 
	proc transpose data=AVGML.vs1 out=&dataOut;
		by subjid vsspid_crf visit_crf vstpt_crf vspos_crf vsdate_crf vstim_crf vsclsig_crf vsfast_crf vsperf_crf vsreasnd_crf;
		var SYSBP DIABP PULSE RESP HR TEMP INTP  HEIGHT WEIGHT BMI;
	run;
%mend avRaveTransposeSourceVS;
