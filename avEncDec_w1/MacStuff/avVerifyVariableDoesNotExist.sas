/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avVerifyVariableDoesNotExist.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Verify whether a variable does not exist in input dataset
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avVerifyVariableDoesNotExist(dataIn=
							 ,varIn=);
	%local dsid
		   rc;
	%let dsid=%sysfunc(open(&dataIn));
	%if %sysfunc(varnum(&dsid, &varIn)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &varIn already in &dataIn data.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted.;
		%let rc=%sysfunc(close(&dsid));
		1
		%return;
	%end;
	%let rc=%sysfunc(close(&dsid));
	0
%mend avVerifyVariableDoesNotExist;
