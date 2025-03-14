/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avFormatSubgroups.sas
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

%macro avFormatSubgroups;
	%local i;
	%do i=1 %to &subgroupVarsSize;
		%if &&subgroupFormat&i ne _NA_ %then %do;
			&&subgroupVar&i &&subgroupFormat&i
		%end;
	%end;
%mend avFormatSubgroups;
