/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avRaveTransposeSourceEG.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Transposes the source ECG datasets from Rave
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avRaveTransposeSourceEG(dataIn=, dataOut=);
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
		select count(*) into :avEGCount from &dataIn;
	quit;

	%if &avEGCount. = 0 %then %do;
		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No observations found in &dataIn.;
		%put NOTE:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted.;
		%return;
	%end;

	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	data AVGML.eg1 (keep=subjid egperf_crf egreasnd_crf visit_crf egtpt_crf egrepnum_crf egspid_crf egdat_int egtim egdesc egclsig_crf HR PR QRS QT RR QTCF QTCB INTP);
		length visit_crf egtpt_crf egperf_crf egclsig_crf egreasnd_crf HR PR QRS QT RR QTCF QTCB INTP $200.;		
		set &dataIn;
	 
		subjid = strip(subject);


		visit_crf = '';
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=instancename) 
			visit_crf = strip(instancename);


		egperf_crf = '';
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=egperf_std) 
			egperf_crf = strip(egperf_std);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=egperf_coded) 
			egperf_crf = strip(egperf_coded);

		%avExecuteIfVarExists(datain=&datain., varin=egperf_l_std) 
			egperf_crf = strip(egperf_l_std);


		egreasnd_crf = '';
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=egreasnd) 
			egreasnd_crf = strip(egreasnd);


		%avExecuteIfVarExists(datain=&datain., varin=egdat_l_int) 
			egdat_int = egdat_l_int;

		%avExecuteIfVarExists(datain=&datain., varin=egtim_l) 
			egtim = egtim_l;


		%avExecuteIfVarExists(datain=&datain., varin=egdesc_l) 
			egdesc = egdesc_l;


		egtpt_crf = '';
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=egtpt_t) 
			egtpt_crf = strip(egtpt_t);

		egspid_crf = .;
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=recordposition) 
			egspid_crf = recordposition;


		egrepnum_crf = .;
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=egrepnum) 
			egrepnum_crf = input(egrepnum, best.);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=egrepnum_l) 
			egrepnum_crf = input(egrepnum_l, best.);


		egclsig_crf = '';
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=egclsig_std) 
			egclsig_crf = strip(egclsig_std);

	 
		/* Flag all parameters for deletion as initial value. If parameter is present in source it will be overwritten, in which case it wil not be deleted */
		HR 		= 'DEL';
		PR 		= 'DEL';
		QRS 	= 'DEL';
		QT 		= 'DEL';
		RR 		= 'DEL';
		QTCF 	= 'DEL';
		QTCB 	= 'DEL';
		INTP 	= 'DEL';

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=HR_EGORRES) 
			HR = strip(put(HR_EGORRES, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=HR_EGORRES_L) 
			HR = strip(put(HR_EGORRES_L, best.));

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=PR_EGORRES) 
			PR = strip(put(PR_EGORRES, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=PR_EGORRES_L) 
			PR = strip(put(PR_EGORRES_L, best.));

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=QRS_EGORRES) 
			QRS = strip(put(QRS_EGORRES, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=QRS_EGORRES_L) 
			QRS = strip(put(QRS_EGORRES_L, best.));

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=QT_EGORRES) 
			QT = strip(put(QT_EGORRES, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=QT_EGORRES_L) 
			QT = strip(put(QT_EGORRES_L, best.));

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=RR_EGORRES) 
			RR = strip(put(RR_EGORRES, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=RR_EGORRES_L) 
			RR = strip(put(RR_EGORRES_L, best.));

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=QTCF_EGORRES) 
			QTCF = strip(put(QTCF_EGORRES, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=QTCF_EGORRES_L) 
			QTCF = strip(put(QTCF_EGORRES_L, best.));

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=QTCB_EGORRES) 
			QTCB = strip(put(QTCB_EGORRES, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=QTCB_EGORRES_L) 
			QTCB = strip(put(QTCB_EGORRES_L, best.));

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=INTP_EGORRES_CODED) 
			INTP = strip(INTP_EGORRES_CODED);
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=INTP_EGORRES_CODED_L) 
			INTP = strip(INTP_EGORRES_CODED_L);
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=INTP_EGORRES_L_STD) 
			INTP = strip(INTP_EGORRES_L_STD);
	 
		proc sort;
			by subjid egperf_crf egreasnd_crf visit_crf egtpt_crf egrepnum_crf egspid_crf egdat_int egtim egdesc egclsig_crf;
	run;
	 
	proc transpose data=AVGML.eg1 out=&dataOut;
		by subjid egperf_crf egreasnd_crf visit_crf egtpt_crf egrepnum_crf egspid_crf egdat_int egtim  egdesc egclsig_crf;
		var HR PR QRS QT RR QTCF QTCB INTP;
	run;

	data AVGML.duplicates_check;
		set &dataOut;

		/* Used for warning messages */
		datetime=datetime();

		duplicate = 0;

		%avExecuteIfVarExists(dataIn=work.&dataOut, varIn=col2) 
			duplicate = 1;

		if duplicate = 1 then do;
			put "WARNING:1/[AVANCE " datetime e8601dt. "] Duplicate observations with no unique repeat id for: " subjid ", at:" visit_crf;
		end;
	run;
%mend avRaveTransposeSourceEG;
