/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avTotalGroups.sas
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

%macro avTotalGroups;
	%local i;
	%do i=1 %to &totalGroupsSize;
		if &treatmentVarIn in (&&totalGroup&i.condition) then do;
			_&treatmentVarIn=&treatmentVarIn;
			&treatmentVarIn=&&totalGroup&i.value;
			output;
			&treatmentVarIn=_&treatmentVarIn;
		end;
	%end;
%mend avTotalGroups;
