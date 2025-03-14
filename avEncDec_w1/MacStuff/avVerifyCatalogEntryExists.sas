/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avVerifyCatalogEntryExists.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Verify the existance of a catalog entry
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avVerifyCatalogEntryExists(entry=);
	%if ^%sysfunc(cexist(&entry)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] The entry &entry was not found.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted.;
		1
		%return;
	%end;
	0
%mend avVerifyCatalogEntryExists;
