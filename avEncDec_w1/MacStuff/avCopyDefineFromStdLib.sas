/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avCopyDefineFromStdLib.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Copies standard define programs from standards repository
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avCopyDefineFromStdLib();
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
	%if ^%sysfunc(fileexist(%bquote(T:\Standard Programs\Prod\v&version\&CRFbuild\06_Define\SDTM))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] SDTM Define folder for &CRFbuild., v&version. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(fileexist(%bquote(T:\Standard Programs\Prod\v&version\&CRFbuild\06_Define\ADAM))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] ADaM Define folder for &CRFbuild., v&version. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(fileexist(%bquote(&mspath.\06_Define))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Study Define folder &mspath.\06_Define does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysfunc(fileexist(%bquote(&mspath.\06_Define\SDTM\avDefineMacroCallSDTM.sas))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] avDefineMacroCallSDTM.sas in &mspath.\06_Define\SDTM already exists;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysfunc(fileexist(%bquote(&mspath.\06_Define\SDTM\avDefineSDTM.sas))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] avDefineSDTM.sas in &mspath.\06_Define\SDTM already exists;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysfunc(fileexist(%bquote(&mspath.\06_Define\ADAM\avDefineMacroCallADaM.sas))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] avDefineMacroCallADaM.sas in &mspath.\06_Define\ADAM already exists;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysfunc(fileexist(%bquote(&mspath.\06_Define\ADAM\avDefineADaM.sas))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] avDefineADaM.sas in &mspath.\06_Define\ADAM already exists;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	
	data _null_;
		Framework_sdtm=dcreate("SDTM", "&mspath.\06_Define");
			Framework_sdtm_e=dcreate("EXPORT", "&mspath.\06_Define\SDTM");
			Framework_sdtm_m=dcreate("META", "&mspath.\06_Define\SDTM");
			Framework_sdtm_o=dcreate("OUTPUT", "&mspath.\06_Define\SDTM");
			Framework_sdtm_q=dcreate("QC", "&mspath.\06_Define\SDTM");

		Framework_adam=dcreate("ADAM", "&mspath.\06_Define");
			Framework_adam_e=dcreate("EXPORT", "&mspath.\06_Define\ADAM");
			Framework_adam_m=dcreate("META", "&mspath.\06_Define\ADAM");
			Framework_adam_o=dcreate("OUTPUT", "&mspath.\06_Define\ADAM");
			Framework_adam_q=dcreate("QC", "&mspath.\06_Define\ADAM");
	run;

	%sysexec copy "T:\Standard Programs\Prod\v&version\&CRFbuild\06_Define\SDTM" "&mspath.\06_Define\SDTM";
	%sysexec powershell -Command "$fileContents = gc %str(%')T:\Standard Programs\Prod\v&version\&CRFbuild\06_Define\SDTM\avDefineSDTM.sas%str(%');
								  $fileContents = $fileContents -creplace '<Milestone>',%str(%')&mspath.%str(%');
								  echo $fileContents | Out-File -encoding ASCII %str(%')&mspath.\06_Define\SDTM\avDefineSDTM.sas%str(%');";
	%sysexec copy "T:\Standard Programs\Prod\v&version\&CRFbuild\06_Define\ADAM" "&mspath.\06_Define\ADAM";
	%sysexec powershell -Command "$fileContents = gc %str(%')T:\Standard Programs\Prod\v&version\&CRFbuild\06_Define\ADAM\avDefineADaM.sas%str(%');
								  $fileContents = $fileContents -creplace '<Milestone>',%str(%')&mspath.%str(%');
								  echo $fileContents | Out-File -encoding ASCII %str(%')&mspath.\06_Define\ADAM\avDefineADaM.sas%str(%');";

%mend avCopyDefineFromStdLib;
