/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avByVars.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Obtains the bigN from a subject level dataset. Typically ADSL
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avByVars;
	%local i;
	%do i=1 %to &byVarsSize;
		&&byVar&i
	%end;
%mend avByVars;
