/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avCopyAcrfFromStdLib.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Copies standard annotated CRF from standards repository
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avCopyAcrfFromStdLib();
	%if ^%symglobl(version) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable version is not defined in global scope;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%symglobl(CRFbuild) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable CRF Build is not defined in global scope;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(fileexist(%bquote(T:\Standard Programs\Prod\v&version\&CRFbuild\01_Specifications\04_SDTM_aCRF))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Standard aCRF for &CRFbuild., v&version. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(fileexist(%bquote(&mspath.\01_Specifications\04_SDTM_aCRF))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Study aCRF folder &mspath.\01_Specifications\04_SDTM_aCRF does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysfunc(fileexist(%bquote(&mspath.\01_Specifications\04_SDTM_aCRF\aCRF.pdf))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] aCRF.pdf in &mspath.\01_Specifications\04_SDTM_aCRF already exists;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysfunc(fileexist(%bquote(&mspath.\01_Specifications\04_SDTM_aCRF\aCRF.xlsx))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] aCRF.xlsx in &mspath.\01_Specifications\04_SDTM_aCRF already exists;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%sysexec copy "T:\Standard Programs\Prod\v&version\&CRFbuild\01_Specifications\04_SDTM_aCRF\*.*" "&mspath.\01_Specifications\04_SDTM_aCRF";

%mend avCopyAcrfFromStdLib;
