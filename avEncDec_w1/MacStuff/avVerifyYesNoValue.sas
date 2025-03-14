/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avVerifyYesNoValue.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Verify if a value for a parameter was specified as either Y or N
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avVerifyYesNoValue(parameter=) /minoperator;		         
	%if ^%eval(%upcase(&&&parameter) in Y N) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid selection for &parameter parameter.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Valid values are Y/N case insensitive.;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted.;
		1
		%return;
	%end;
	0
%mend avVerifyYesNoValue;
