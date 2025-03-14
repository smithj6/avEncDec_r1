/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avClassSubgroups.sas
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

%macro avClassSubgroups;
	%local i;
	%do i=1 %to &subgroupVarsSize;
		class &&subgroupVar&i
		%if &&subgroupFormat&i ne _NA_ %then %do;
			/preloadfmt exclusive
		%end;;
	%end;
%mend avClassSubgroups;
