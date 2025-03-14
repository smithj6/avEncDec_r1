/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avVerifyTotalGroups.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Verify if a specified value is a valid treatment combination
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avVerifyTotalGroups;
	%local i;
	%do i=1 %to &totalGroupsSize;
		%let totalGroup&i = %scan(&defineTotalGroups, &i, #);
		%if ^%sysfunc(prxmatch(%str(m/^\d+\s+\d+(\s+\d+)*\s*=\s*\d+$/oi), %superq(totalGroup&i))) %then %do; 
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Pattern &&totalGroup&i is invalid pattern for totals definition;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expecting a pattern in the following form: Treatment ID + Treatment ID = _NEW_ Treatment ID;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted.;
			1
			%return;
		%end;
		%let totalGroup&i.condition = %scan(&&totalGroup&i, 1, =);
		%let totalGroup&i.value = %scan(&&totalGroup&i, 2, =);
	%end;
	0
%mend avVerifyTotalGroups;
