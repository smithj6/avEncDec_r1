/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avStudyDay.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Set --DY/ --STDY/ --ENDY from --DTC/ --STDTC/ --ENDTC
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	Copied from S:\SAS Macro Library. Changed macro name to 'av...'. Added exception handling.
Date changed     :  2024-08-09
By				 :	Edgar Wong 
=======================================================================================*/

%macro avStudyDay(varIn=);

	/* Exception handling: Mandatory Parameters */
	%if %sysevalf(%superq(varIn)=,  boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] parameter varIn is required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/* Exception handling: Parameter Value */
	%if %upcase(%substr(&varIn, %length(&varIn)-2)) ne DTC %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] parameter varIn should have a name ended in DTC, e.g. LBDTC, AESTDTC.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	if input(&varIn, ??yymmdd10.) ^=. and input(rfstdtc, ??yymmdd10.) ^=. then do;
		%substr(&varIn, 1,%length(&varIn)-3)dy = input(&varIn, ??yymmdd10.)-input(rfstdtc, ??yymmdd10.) + 
			(input(&varIn, ??yymmdd10.) >= input(rfstdtc, ??yymmdd10.));
	end;
%mend avStudyDay;
