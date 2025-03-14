/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avCopyMacroFromStdLib.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Copies standard macro from standards repository
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avCopyMacroFromStdLib(macroList=);
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML is study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysevalf(%superq(macroList)  =, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameter macroList is required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

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
	%if ^%symglobl(mspath) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable mspath is not defined in global scope;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(fileexist(%bquote(T:\Standard Programs\Prod\v&version\&CRFbuild\08_Final Programs\01_Macros))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Standard macros folder for &CRFbuild., v&version. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(fileexist(%bquote(&mspath.\08_Final Programs\01_Macros))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Study macros folder &mspath.\08_Final Programs\01_Macros does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	
	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	data AVGML.av_macros;
		col = "&macroList.";
		output;
	run;

	data AVGML.av_macro_list;
		set AVGML.av_macros;
		length macro $200.;

		do i=1 by 1 while(scan(col,i,'#') ^= ' ');
			macro = cats(tranwrd(scan(col,i,'#'), '.sas', ''), '.sas');
			output;
		end;
	run;


	proc sql noprint;
		select count(*) into :N from AVGML.av_macro_list;
	quit;

	%if &n. = 0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No macros identified from macroList parameter;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	data _null_;
		set AVGML.av_macro_list;
		where strip(macro) ^= '';
		call execute('%avCopyMacro(macro=' || strip(macro) || ')');
	run;

%mend avCopyMacroFromStdLib;

%macro avCopyMacro(macro=);
	%if ^%sysfunc(fileexist(%bquote(T:\Standard Programs\Prod\v&version\&CRFbuild\08_Final Programs\01_Macros\&macro.))) %then %do;
		%put WARNING:1[AVANCE %sysfunc(datetime(), e8601dt.)] Standard macro &macro. does not exist;
		%put WARNING:2[AVANCE %sysfunc(datetime(), e8601dt.)] Standard macro will not be copied;
		%return;
	%end;

	%if %sysfunc(fileexist(%bquote(&mspath.\08_Final Programs\01_Macros\&macro.))) %then %do;
		%put WARNING:1[AVANCE %sysfunc(datetime(), e8601dt.)] Study macro for &macro. already exists;
		%put WARNING:2[AVANCE %sysfunc(datetime(), e8601dt.)] Standard macro will not be copied;
		%return;
	%end;

	%sysExec copy "T:\Standard Programs\Prod\v&version\&CRFbuild\08_Final Programs\01_Macros\&macro." "&mspath.\08_Final Programs\01_Macros";
%mend avCopyMacro;
