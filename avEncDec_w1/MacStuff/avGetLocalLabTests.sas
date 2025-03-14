/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avGetLocalLabTests.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Gets local lab tests from input dataset, performing standard assignments required for multiple datasets
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/


%macro avGetLocalLabTests(dataIn=, subset=, dataOut=, keepVars=, subjectVarIn=, visitVarIn=, codeVarIn=, codeVarOthIn=, valueVarIn=);
	%if ^%sysfunc(exist(&dataIn)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Dataset &dataIn does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(prxmatch(%str(m/^[A-Za-z_]([A-Za-z_0-9]{1,31})?$/oi), %bquote(&dataOut))) %then %do;
	 	%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] &dataOut is not a valid SAS dataset name;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysevalf(%superq(subjectVarIn)  =, boolean) or %sysevalf(%superq(visitVarIn)  =, boolean) or %sysevalf(%superq(codeVarIn)  =, boolean) or %sysevalf(%superq(valueVarIn)  =, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameters subjectVarIn, visitVarIn, codeVarIn and valueVarIn are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%let dsid = %sysfunc(open(&dataIn));
	%if ^%sysfunc(varnum(&dsid, &subjectVarIn)) or ^%sysfunc(varnum(&dsid, &visitVarIn)) or ^%sysfunc(varnum(&dsid, &codeVarIn)) or ^%sysfunc(varnum(&dsid, &valueVarIn)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variables &subjectVarIn., &visitVarIn., &codeVarIn. and &valueVarIn. not present in dataset &dataIn.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let dsid_=%sysfunc(close(&dsid));
		%return;
	%end;

	%if ^%sysevalf(%superq(codeVarOthIn) =, boolean)  %then %do;
		%if ^%sysfunc(varnum(&dsid, &codeVarOthIn)) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &codeVarOthIn. not present in dataset &dataIn.;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let dsid_=%sysfunc(close(&dsid));
			%return;
		%end;
	%end;

	%let byVarCount = %sysfunc(countw(&keepVars, #));
	%do i=1 %to &byVarCount;
		%local tempByVar;
		%let tempByVar = %scan(&keepVars, &i, #);

		%if ^%sysfunc(varnum(&dsid, &tempByVar)) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &tempByVar not present in &dataIn;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let dsid_=%sysfunc(close(&dsid));

			%let dsid_=%sysfunc(close(&dsid));
			%return;
		%end;
	%end;

	%let dsid_=%sysfunc(close(&dsid));


	%let keepVarsReplaced = %sysfunc(tranwrd(&keepVars, #, ));

	data &dataOut. (keep=subjid visit_crf timepoint_crf lbtestcd_crf lborres_crf lborresu_crf lbfast_crf lbnrind_crf lbclsig_crf &keepVarsReplaced.);
		set &dataIn.;
		%if %sysevalf(%superq(subset)^=, boolean) %then %do;
			where &subset.;
		%end;
		length subjid $50. visit_crf timepoint_crf lbtestcd_crf lborres_crf lborresu_crf lbfast_crf lbnrind_crf lbclsig_crf $200.;

		/* Set all variables as '' */
		call missing(subjid, visit_crf, timepoint_crf, lbtestcd_crf, lborres_crf, lborresu_crf, lbfast_crf, lbnrind_crf, lbclsig_crf);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=&subjectVarIn.) 
			subjid = strip(&subjectVarIn.);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=&visitVarIn.) 
			visit_crf = strip(&visitVarIn.);
			

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=&codeVarIn.) 
			lbtestcd_crf = strip(&codeVarIn.);

		%if %sysevalf(%superq(codeVarOthIn)^=, boolean) %then %do;
			%avExecuteIfVarExists(dataIn=&dataIn., varIn=&codeVarOthIn.) 
				if upcase(lbtestcd_crf) in ('', 'OTHER') and &codeVarOthIn. ^= '' then lbtestcd_crf = strip(&codeVarOthIn.);
		%end;

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=&valueVarIn.) 
			lborres_crf = strip(&valueVarIn.);


		/* Assign general columns if applicable */
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=lbtpt) 
			timepoint_crf = strip(lbtpt);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=lborresu_coded) 
			lborresu_crf = strip(lborresu_coded);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=lbfast_coded) 
			lbfast_crf = strip(lbfast_coded);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=lbnrind_coded) 
			lbnrind_crf = strip(lbnrind_coded);

		%avExecuteIfVarExists(dataIn=&dataIn., varIn=lbclsig_coded) 
			lbclsig_crf = strip(lbclsig_coded);
	run;
%mend avGetLocalLabTests;
