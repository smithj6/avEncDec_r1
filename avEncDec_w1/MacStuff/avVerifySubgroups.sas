/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avVerifySubgroups.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Verify if a specified value is a valid sub group with matching sub group formats
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avVerifySubgroups;
	%local i 
		   varType;
	%if &subgroupVarsSize ne &subgroupFormatsSize %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid number of subgroupFormats;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Number of subgroup formats and subgroup variables must match;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted.;
		1
		%return;
	%end;
	%do i=1 %to &subgroupVarsSize;
		%let subgroupVar&i=%scan(&subgroupVarsIn, &i, #);
		%let subgroupFormat&i=%upcase(%scan(&subgroupPreloadfmt, &i, #));
		%if %avVerifyVariableExists(dataIn=&dataIn, varIn=&&subgroupVar&i) %then %do;
			1
			%return;
		%end;
		%let varType=%avVarType(dataIn=&dataIn,varIn=&&subgroupVar&i);
		%if &&subgroupFormat&i ne _NA_ %then %do;
			%if %substr(&&subgroupFormat&i, 1, 1) = $ %then %let subgroupFormat&i=%substr(&&subgroupFormat&i, 2);
			%if %substr(&&subgroupFormat&i, %length(&&subgroupFormat&i)) ne . %then %let subgroupFormat&i=&&subgroupFormat&i...;
			%if %avVerifyCatalogEntryExists(entry=work.formats.&&subgroupFormat&i..format%sysfunc(ifc(&varType eq C, &varType, %str( )))) %then %do;
				1
				%return;
			%end;
			%if &varType = C %then %let subgroupFormat&i=$&&subgroupFormat&i;
		%end;
	%end;
	0
%mend avVerifySubgroups;
