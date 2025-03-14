/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avVerifyVariableIsNumeric.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Verify variable type is numeric
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avVerifyVariableIsNumeric(dataIn=
								,varIn=);
	%local dsid
		   varType
		   rc;
	%let dsid=%sysfunc(open(&dataIn));
	%let varType = %sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, &varIn))));
	%let rc=%sysfunc(close(&dsid));
	%if &varType = C %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &varIn is not in the expected type.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expected type is numeric.;
		%put ERROR:4/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted.;
		1
		%return;
	%end;
	0						
%mend avVerifyVariableIsNumeric;
