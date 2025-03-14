/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avVerifyByVars.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Verify variables specified in a # seperated list exists in input dataset
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/


%macro avVerifyByVars;
	%local i;
	%do i=1 %to &byVarsSize;
		%let byVar&i=%scan(&byVarsIn, &i, #);
		%if %avVerifyVariableExists(dataIn=&dataIn, varIn=&&byVar&i) %then %do;
			1
			%return;
		%end;
	%end;
	0
%mend avVerifyByVars;
