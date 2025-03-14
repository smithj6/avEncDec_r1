/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avVerifyIntegerValue.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Verify if a value of a parameter is integer
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avVerifyIntegerValue(parameter=);		         
	%if %sysfunc(notdigit(&&&parameter)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid value for &parameter parameter.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Valid value is a positive integer.;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted.;
		1
		%return;
	%end;
	0
%mend avVerifyIntegerValue;
