/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avVerifyLibraryExists.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Verify the existance of a library
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avVerifyLibraryExists(library=);
	%if %sysfunc(libref(&library)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library &library is not assigned.; 
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Assign Library &library is study setup file.;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted.;
		1
		%return;
	%end;
	0
%mend avVerifyLibraryExists;
