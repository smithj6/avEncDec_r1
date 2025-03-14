/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avMedrioTransposeSourceEG.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Transposes the source ECG datasets from Medrio
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avMedrioTransposeSourceEG(dataIn=, dataOut=);
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

	data AVGML.eg1 (keep=subjid egperf_crf egreasnd_crf visit_crf egtpt_crf egrepnum_crf egspid_crf egdat egtim egdesc egclsig_crf HR PR QRS QT RR QTCF QTCB INTP);
		length egperf_crf egreasnd_crf visit_crf egtpt_crf egclsig_crf HR PR QRS QT RR QTCF QTCB INTP $200.;		
		set &dataIn;
	 
		subjid = strip(subjectid);

		egperf_crf = '';
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=egperf_coded) 
			egperf_crf = strip(egperf_coded);

		egreasnd_crf = '';
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=egreasnd) 
			egreasnd_crf = strip(egreasnd);

		visit_crf = '';
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=visit) 
			visit_crf = strip(visit);

		egtpt_crf = '';
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=egtpt) 
			egtpt_crf = strip(egtpt);

		egspid_crf = .;
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=vargroup1row) 
			egspid_crf = vargroup1row;

		egrepnum_crf = .;
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=egrepnum) 
			egrepnum_crf = input(egrepnum, best.);

		egclsig_crf = '';
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=egclsig_coded) 
			egclsig_crf = strip(egclsig_coded);
	 
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
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=PR_EGORRES) 
			PR = strip(put(PR_EGORRES, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=QRS_EGORRES) 
			QRS = strip(put(QRS_EGORRES, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=QT_EGORRES) 
			QT = strip(put(QT_EGORRES, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=RR_EGORRES) 
			RR = strip(put(RR_EGORRES, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=QTCF_EGORRES) 
			QTCF = strip(put(QTCF_EGORRES, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=QTCB_EGORRES) 
			QTCB = strip(put(QTCB_EGORRES, best.));
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=INTP_EGORRES_CODED) 
			INTP = strip(INTP_EGORRES_CODED);
	 
		proc sort;
			by subjid egperf_crf egreasnd_crf visit_crf egtpt_crf egrepnum_crf egspid_crf egdat egtim egdesc egclsig_crf;
	run;
	 
	proc transpose data=AVGML.eg1 out=&dataOut;
		by subjid egperf_crf egreasnd_crf visit_crf egtpt_crf egrepnum_crf egspid_crf egdat egtim  egdesc egclsig_crf;
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
%mend avMedrioTransposeSourceEG;
