/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avVerifyDatasetExists.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Verify the existance of a dataset
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avVerifyDatasetExists(dataset=);
	%if ^%sysfunc(exist(&dataset)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] data &dataset does not exist.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted.;
		1
		%return;
	%end;
	0
%mend avVerifyDatasetExists;
