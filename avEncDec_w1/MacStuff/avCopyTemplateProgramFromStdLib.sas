/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avCopyTemplateProgramFromStandardLib.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Copies predefined template programs from the standards repository
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	Update standard lib path from S:\ to T:\. Update setup.sas to avSetup.sas.
Date changed     :  2024-06-14
By			     :  Edgar Wong
Purpose/Changes  :	Update standard lib path from S:\ to T:\. Fix log path from mspath to &mspath.
Date changed     :  2024-06-06
By			     :  Edgar Wong
=======================================================================================*/

%macro avCopyTemplateProgramFromStdLib(standard=
									  ,domain=
									  ,copyBlankTemplate=N)/minoperator;

 	%local programLocation 
		   logLocation 
		   fileToCopy
		   powershellCmd
		   systemOption
		   folderId1
		   folderId2
		   i
		   temp
           nFiles;

	%if %sysevalf(%superq(standard)=         , boolean) or 
		%sysevalf(%superq(domain)=           , boolean) or
		%sysevalf(%superq(copyBlankTemplate)=, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameters standard and domain are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%let domain=%qlowcase(%bquote(&domain));
	%let copyBlankTemplate=%qupcase(%bquote(&copyBlankTemplate));
	%let standard=%qupcase(%bquote(&standard));
	%if ^%eval(&copyBlankTemplate in Y N) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid selection for macro parameter copyBlankTemplate (&copyBlankTemplate);
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Valid selections are Y or N and are case insensitive;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%symglobl(mspath) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable mspath is not defined in global scope;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if &copyBlankTemplate=N %then %do;
		%if ^%symglobl(version) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable version is not defined in global scope;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;
		%if ^%symglobl(CRFBuild) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable CRFbuild is not defined in global scope;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;
		%if %sysevalf(%superq(version)=, boolean) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable version is required;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;
		%if %sysevalf(%superq(CRFBuild)=, boolean) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable CRFBuild is required;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;
	%end;
	%else %do;
		%local version CRFBuild;
		%let version=1.0;
		%let CRFBuild=Medrio;
	%end;
	%if %sysevalf(%superq(mspath)=, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable mspath is required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(fileexist(%bquote(&mspath))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] %bquote(&mspath) does not refer to a valid directory on the system;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%eval(&standard in SDTM ADAM) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid selection for macro parameter standard (&standard);
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Valid selections are SDTM or ADaM and are case insensitive;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(prxmatch(%str(m/^\w+(#\w+)*$/oi), &domain)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid selection for macro parameter domain;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Separate muliple entries with a hash tag e.g. ae#su;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(fileexist(%bquote(T:\Standard Programs\Prod\v&version))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] v&version does not refer to a valid directory in the standards library;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(fileexist(%bquote(T:\Standard Programs\Prod\v&version\&CRFbuild))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] &CRFbuild does not refer to a valid CRF build directory in the standards library;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%let systemOption = %sysfunc(getoption(quotelenmax));

	options noquotelenmax;

	%let i=1;
	%let nFiles=%sysfunc(countw(&domain, #));
	%let temp=&domain;

	%begin:
	%let domain=%scan(&temp, &i, #);
	%let folderId1=%sysfunc(ifc(%index(&domain, _), Validation, Production));
	%let folderId2=0%sysfunc(whichc(&standard, SDTM, ADAM))_&standard;
	%let programLocation=&msPath\08_Final Programs\02_CDISC\&folderId1\&folderId2\&domain..sas;
	%let logLocation=&msPath\08_Final Programs\02_CDISC\&folderId1\&folderId2\logs\&domain..log;
	%if %sysfunc(fileexist(&programLocation)) %then %do; 
		%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] %upcase(&domain.) Program already exists in the location;
		%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Skipping item(&domain);
		%goto skip;
	%end;
	%if &copyBlankTemplate=Y %then %let fileToCopy = _blank_;
	%else %if ^%sysfunc(fileexist(T:\Standard Programs\Prod\v&version\&CRFbuild\08_Final Programs\02_CDISC\&folderId1\&folderId2\&domain..sas)) %then %do;
		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No standard template program exists for &domain;
		%put NOTE:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Copying blank template instead;
		%let fileToCopy = _blank_;
	%end;
	%else %let fileToCopy = &domain;
	%let powershellCmd=;
	%if &folderId1=Validation %then %do;
		%let powershellCmd = $fileContents = $fileContents -replace %str(%')[%]avUpdateSpecDataset\(lib=%upcase(&folderId2)\, domain=&domain\)%str(;)%str(%'), ''%str(;);
	%end;
	%sysexec powershell -Command "$fileContents = gc %str(%')T:\Standard Programs\Prod\v&version\&CRFbuild\08_Final Programs\02_CDISC\&folderId1\&folderId2\&fileToCopy..sas%str(%');
								  $fileContents = $fileContents -creplace '<Milestone>',%str(%')&Mspath%str(%');
								  $fileContents = $fileContents -creplace '<Study Number>',%str(%')&studyno%str(%');
								  $fileContents = $fileContents -creplace '<Sponsor>',%str(%')%scan(&Client, 2, \)%str(%');
								  $fileContents = $fileContents -creplace '<Program>',%str(%')&domain%str(%');
								  $fileContents = $fileContents -creplace '<Current Date>',%str(%')%left(%sysfunc(today(),date9.))%str(%');
								  $fileContents = $fileContents -creplace '<User>',%str(%')&sysuserid%str(%');
								  $fileContents = $fileContents -creplace '<Log Path>',%str(%')&logLocation%str(%');
								  $fileContents = $fileContents -creplace %str(%')^%nrstr(%%)include.+T:\\Standard Programs\\Prod\\v&version\\&CRFbuild\\08_Final Programs\\01_Macros\\avSetup\.sas.+%str(;)$%str(%'),'';
								  &powershellCmd
								  echo $fileContents | Out-File -encoding ASCII %str(%')&programLocation%str(%');";
	%skip:
	%let i=%eval(&i + 1);
	%if &i <= &nFiles %then %goto begin;

	options &systemOption;
%mend avCopyTemplateProgramFromStdLib;
