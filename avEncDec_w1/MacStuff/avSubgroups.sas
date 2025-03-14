/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avSubgroups.sas
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


%macro avSubgroups;
	%local i;
	%do i=1 %to &subgroupVarsSize;
		&&subgroupVar&i
	%end;
%mend avSubgroups;
