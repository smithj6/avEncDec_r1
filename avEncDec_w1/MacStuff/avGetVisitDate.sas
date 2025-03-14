/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avAssignEpoch.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Get Visit and Date from dataset and assign standard labels for merging
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avGetVisitDate(dataIn=, keepVars=, visVar=, dateVar=, dataOut=);
	%if ^%sysfunc(exist(&dataIn)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Input dataset &dataIn does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysevalf(%superq(keepVars)  =, boolean) or %sysevalf(%superq(visVar)=, boolean) or %sysevalf(%superq(dateVar)=, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameters keepVars, visVar and dateVar are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(prxmatch(%str(m/^[A-Za-z_]([A-Za-z_0-9]{1,31})?$/oi), %bquote(&dataOut))) %then %do;
	 	%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] &dataOut is not a valid SAS dataset name;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%let dsid = %sysfunc(open(&dataIn));
	%if ^%sysfunc(varnum(&dsid, &visVar)) or ^%sysfunc(varnum(&dsid, &dateVar)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variables &visVar. and &dateVar not present in dataset &dataIn.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let dsid_=%sysfunc(close(&dsid));
		%return;
	%end;
	%let dsid_=%sysfunc(close(&dsid));

	data &dataOut (keep=&keepVars visit_crf date_crf);
		set &dataIn (keep=&keepVars &visVar &dateVar rename=(&dateVar = date_crf));
		length visit_crf $200.;
	 
		visit_crf = strip(&visVar);

		/* Remove unscheduled and not done visits. Not required for EPOCH */
		if index(visit_crf, 'Unscheduled') = 0 and date_crf ^= .;

		proc sort;
			by &keepVars visit_crf date_crf;
	run;
%mend avGetVisitDate;
