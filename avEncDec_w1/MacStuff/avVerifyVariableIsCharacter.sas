/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avVerifyVariableIsCharacter.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Verify variable type is character
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avVerifyVariableIsCharacter(dataIn=
								  ,varIn=);
	%if %avVarType(dataIn=&dataIn,varIn=&varIn) = N %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &varIn is not in the expected type.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expected type is character.;
		%put ERROR:4/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted.;
		1
		%return;
	%end;
	0						
%mend avVerifyVariableIsCharacter;
