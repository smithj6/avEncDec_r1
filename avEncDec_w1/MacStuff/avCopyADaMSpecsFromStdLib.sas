/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avCopyADaMSpecsFromStdLib.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Copies standard ADaM specifications from standards repository
				   All domains identified from SDTM will be included
				   Additional domains can be specified using include param
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  : Added feature: Generate ADaM spec from IG and SDTM spec dynamically if no standard one provided	
Date changed     : 2024-09-09
By				 : Edgar Wong
=======================================================================================*/

%macro avCopyADaMSpecsFromStdLib(ig=, include=, onlyInclude=N)/minoperator;
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML is study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysevalf(%superq(ig)  =, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameter IG is required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%eval(%qupcase(%bquote(&onlyInclude)) in Y N) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid selection for macro parameter onlyInclude (%bquote(&onlyInclude)). Valid selections are Y or N and are case insensitive;
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
	%if ^%sysfunc(fileexist(%bquote(T:\Standard Programs\Prod\v&version\&CRFbuild\01_Specifications\02_ADaM\ADaMIG_v&ig.))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Standard specifications for &CRFbuild., v&version. and ADaMIG v&ig. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(fileexist(%bquote(&mspath.\01_Specifications\02_ADaM))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Study specifications folder &mspath.\01_Specifications\02_ADaM does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	
	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	data AVGML.av_all_specs (keep=fname);
		length fname $200.;
		rc = filename("mydir","&mspath.\01_Specifications\01_SDTM");
		did = dopen("mydir");
		if did > 0
		then do i = 1 to dnum(did);
		  fname = dread(did,i);
		  output;
		end;
		rc = dclose(did);
	run;


	proc sql noprint;
		select count(*) into :N from AVGML.av_all_specs;
	quit;

	%if &n. = 0 %then %do;
		%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No specifications datasets exist in folder &mspath.\01_Specifications\01_SDTM;
		%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Only domains specified in include parameter will be copied;
	%end;

	data AVGML.av_domain_list(keep=domain);
		set AVGML.av_all_specs;
		where index(upcase(fname), 'XLSX');
		length domain $200.;


		/* Delete all trial domains */
		if upcase(fname) in ('TA.XLSX', 'TD.XLSX', 'TE.XLSX', 'TI.XLSX', 'TM.XLSX', 'TS.XLSX', 'TV.XLSX', 'SV.XLSX') then delete;

		/* ADSL will be created from DM and DS */
		if upcase(fname) in ('DM.XLSX', 'DS.XLSX', 'SE.XLSX', 'DD.XLSX', 'RP.XLSX') then fname = 'SL.XLSX';

		domain = cats('AD', scan(upcase(fname), 1, '.'));

		proc sort nodupkey;
			by domain;
	run;


	%if ^%sysevalf(%superq(include)  =, boolean) %then %do;
		data AVGML.av_include;
			col = "&include.";
			output;
		run;

		data AVGML.av_include_split;
			set AVGML.av_include;

			do i=1 by 1 while(scan(col,i,'#') ^= ' ');
				domain=scan(col,i,'#');
				output;
			end;
		run;

		%if &onlyInclude = Y %then %do;
			data AVGML.av_domain_list(keep=domain);
				length domain $200.;
				set AVGML.av_include_split;

				proc sort nodupkey;
					by domain;
			run;
		%end;
		%else %do;
			data AVGML.av_domain_list(keep=domain);
				length domain $200.;
				set AVGML.av_domain_list AVGML.av_include_split;

				proc sort nodupkey;
					by domain;
			run;
		%end;
	%end;

	proc sql noprint;
		select count(*) into :N from AVGML.av_domain_list;
	quit;

	%if &n. = 0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No domains identified;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	data _null_;
		set AVGML.av_domain_list end=eof;
		where strip(domain) ^= '';
		
		call symputx('ds'|| left(put(_n_,best.)),trim(domain));
		if eof then call symputx('dstotal',left(put(_n_,best.)));
	run;

	%do dsnum=1 %to &dstotal;
		%avCopySpecADaM(ig=&ig., domain=&&ds&dsnum..)
	%end;

%mend avCopyADaMSpecsFromStdLib;

%macro avCopySpecADaM(ig=, domain=);

	%if %sysfunc(fileexist(%bquote(&mspath.\01_Specifications\02_ADaM\&domain..xlsx))) %then %do;
		%put WARNING:1[AVANCE %sysfunc(datetime(), e8601dt.)] Study specification for &domain. already exists;
		%put WARNING:2[AVANCE %sysfunc(datetime(), e8601dt.)] Standard specification will not be copied;
		%return;
	%end;

	%if %sysfunc(fileexist(%bquote(T:\Standard Programs\Prod\v&version\&CRFbuild\01_Specifications\02_ADaM\ADaMIG_v&ig.\&domain..xlsx))) %then %do;
		%sysExec copy "T:\Standard Programs\Prod\v&version\&CRFbuild\01_Specifications\02_ADaM\ADaMIG_v&ig.\&domain..xlsx" "&mspath.\01_Specifications\02_ADaM";
	%end;
	%else %do;
		%put NOTE:1[AVANCE %sysfunc(datetime(), e8601dt.)] Standard specifications for &domain. does not exist;
		%put NOTE:2[AVANCE %sysfunc(datetime(), e8601dt.)] Specification will be generated from IG and SDTM spec;
		%avGenerateNonStandardSpecADaM(ig=&ig, domain=&domain)
	%end;

%mend avCopySpecADaM;
