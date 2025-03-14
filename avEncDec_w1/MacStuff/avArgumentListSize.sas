/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avArgumentListSize.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Transposes the source ECG datasets from Medrio
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avArgumentListSize(argumentList=);
	%if %sysevalf(%superq(argumentList)=, boolean) %then %do;
		0
		%return;
	%end;
	%sysfunc(countw(%bquote(&argumentList), #))
%mend avArgumentListSize;
