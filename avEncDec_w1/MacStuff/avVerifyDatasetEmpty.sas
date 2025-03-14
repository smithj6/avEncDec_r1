/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avVerifyDatasetEmpty.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Verify if a dataset is empty
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avVerifyDatasetEmpty(dataIn=);
	%if ^%sysfunc(exist(&dataIn)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] data &dataIn does not exist.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted.;
		%return;
	%end;

	%let dsid=%sysfunc(open(&dataIn));
	%let obsflag=%sysfunc(fetchobs(&dsid, 1));
	%let rc=%sysfunc(close(&dsid));

	%if &obsflag = 0 %then %do; 0 %end;
	%else %if &obsflag = -1 %then %do; 1 %end;
	%else %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Error in checking emptiness for data &dataIn.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted.;
		%return;
	%end;
%mend avVerifyDatasetEmpty;
