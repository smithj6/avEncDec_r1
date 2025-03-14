/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avVerifyVariableExists.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Verify the existance of a variable within a dataset
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avVerifyVariableExists(dataIn=
							 ,varIn=);
	%local dsid
		   rc;
	%if %avVerifyValidVarName(varName=&varIn) %then %do;
		1
		%return;
	%end;
	%let dsid=%sysfunc(open(&dataIn));
	%if ^%sysfunc(varnum(&dsid, &varIn)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &varIn not in &dataIn data.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted.;
		%let rc=%sysfunc(close(&dsid));
		1
		%return;
	%end;
	%let rc=%sysfunc(close(&dsid));
	0
%mend avVerifyVariableExists;
