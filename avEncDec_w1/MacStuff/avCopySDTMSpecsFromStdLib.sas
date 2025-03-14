/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avCopySDTMSpecsFromStdLib.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Copies standard SDTM specifications from standards repository
				   All domains identified from aCRF will be included
				   Additional domains can be specified using include param
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avCopySDTMSpecsFromStdLib(ig=, include=, onlyInclude=N);
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
	%if ^%sysfunc(fileexist(%bquote(T:\Standard Programs\Prod\v&version\&CRFbuild\01_Specifications\01_SDTM\SDTMIG_v&ig.))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Standard specifications for &CRFbuild., v&version. and SDTMIG v&ig. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(fileexist(%bquote(&mspath.\01_Specifications\01_SDTM))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Study specifications folder &mspath.\01_Specifications\01_SDTM does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%local pdfSource repPath pdfAnnotationSource N;

	%let pdfSource  = &mspath.\01_Specifications\04_SDTM_aCRF\aCRF.pdf;
	%let repPath 	= &mspath\05_OutputDocs\04_Reports;

	%if ^%sysfunc(fileexist(%bquote(&pdfSource.))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] PDF annotation file &pdfSource. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%let pdfAnnotationSource  = &repPath\imported_pdf_annotations.csv;
	%include "T:\Standard Programs\Prod\Utility\avPDFAnnotationExtractor.sas";

	%if ^%sysfunc(fileexist(%bquote(&pdfAnnotationSource.))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Import of annotations from &pdfsource failed;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	
	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	proc import datafile="&pdfAnnotationSource"
	     dbms=csv
	     out=AVGML.av_crf_import replace;
	     getnames=yes;
	run;

	data AVGML.av_crf (keep=pageno annotation color);
		set AVGML.av_crf_import;

		pageno = page_no;
		annotation = strip(_annotation);
		color = _rgb;

		proc sort;
			by pageno color;
	run;

	proc sql noprint;
		select count(*) into :N from AVGML.av_crf;
	quit;

	%if &n. = 0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No annotations identified in acrf.pdf file &pdfsource;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	
	data AVGML.domain_list (keep=domain pageno color);
		set AVGML.av_crf;
		where index(annotation, '(') and index(annotation, ')');
		length domain $50.;

		domain = strip(scan(annotation, 1, ' '));

		proc sort nodupkey;
			by pageno color domain;
	run;


	%if ^%sysevalf(%superq(include)  =, boolean) %then %do;
		data AVGML.include_;
			col = "&include.";
			output;
		run;

		data AVGML.include;
			set AVGML.include_;

			do i=1 by 1 while(scan(col,i,'#') ^= ' ');
				domain=scan(col,i,'#');
				output;
			end;
		run;

		%if &onlyInclude = Y %then %do;
			data AVGML.domain_list_final(keep=domain);
				length domain $200.;
				set AVGML.include;

				proc sort nodupkey;
					by domain;
			run;
		%end;
		%else %do;
			data AVGML.domain_list_final(keep=domain);
				length domain $200.;
				set AVGML.domain_list AVGML.include;

				proc sort nodupkey;
					by domain;
			run;
		%end;
	%end;

	proc sql noprint;
		select count(*) into :N from AVGML.domain_list_final;
	quit;

	%if &n. = 0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No annotations identified in acrf.pdf or include parameter;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	data _null_;
		set AVGML.domain_list_final;
		where strip(domain) ^= '';
		call execute('%avCopySpecSDTM(domain=' || strip(domain) || ')');
	run;

%mend avCopySDTMSpecsFromStdLib;

%macro avCopySpecSDTM(domain=);
	%if ^%sysfunc(fileexist(%bquote(T:\Standard Programs\Prod\v&version\&CRFbuild\01_Specifications\01_SDTM\SDTMIG_v&ig.\&domain..xlsx))) %then %do;
		%put WARNING:1[AVANCE %sysfunc(datetime(), e8601dt.)] Standard specifications for &domain. does not exist;
		%put WARNING:2[AVANCE %sysfunc(datetime(), e8601dt.)] Standard specification will not be copied;
		%return;
	%end;

	%if %sysfunc(fileexist(%bquote(&mspath.\01_Specifications\01_SDTM\&domain..xlsx))) %then %do;
		%put WARNING:1[AVANCE %sysfunc(datetime(), e8601dt.)] Study specification for &domain. already exists;
		%put WARNING:2[AVANCE %sysfunc(datetime(), e8601dt.)] Standard specification will not be copied;
		%return;
	%end;

	%sysExec copy "T:\Standard Programs\Prod\v&version\&CRFbuild\01_Specifications\01_SDTM\SDTMIG_v&ig.\&domain..xlsx" "&mspath.\01_Specifications\01_SDTM";
%mend avCopySpecSDTM;
