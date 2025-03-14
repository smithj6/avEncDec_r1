/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avSpecCRFCompare.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Creates a summary report by comparing CRF annotations with specification annotations
				   Currently using CRF annotations from aCRF.xlsx file
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avSpecCRFCompare(type=, repPath=, addPages=)/minoperator;
	%if %sysevalf(%superq(addPages)=, boolean) %then %do;
		%let addPages = 0;
	%end;

	%if ^%eval(%qupcase(%bquote(&type)) in PDF XLSX) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid selection for macro parameter type (%bquote(&type)). Valid selections are PDF or XLSX and are case insensitive;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;


	%if %sysevalf(%superq(type)  =, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameter Type is required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	
	%if &type = XLSX %then %do;
		%let xlsxSource  = &mspath.\01_Specifications\04_SDTM_aCRF\aCRF.xlsx;

		%if ^%sysfunc(fileexist(%bquote(&xlsxSource.))) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Excel annotation file &xlsxSource. does not exist;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;
	%end;
	%else %if  &type = PDF %then %do;
		%let pdfSource  = &mspath.\01_Specifications\04_SDTM_aCRF\aCRF.pdf;

		%if ^%sysfunc(fileexist(%bquote(&pdfSource.))) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] PDF annotation file &pdfSource. does not exist;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;
	%end;
	%else %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid selection for parameter Type (%bquote(&type)). Valid selections are XLSX or PDF and are case insensitive;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(fileexist(&repPath.))=0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Report Path &repPath. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;


	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	/*============================== Get All Spec Annotations =============================*/
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
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No specifications exist in folder &mspath.\01_Specifications\01_SDTM;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	data AVGML.av_all_spec_domains(keep=domain);
		set AVGML.av_all_specs;
		where index(upcase(fname), 'XLSX');
		length domain $200.;

		domain = strip(scan(upcase(fname), 1, '.'));

		proc sort nodupkey;
			by domain;
	run;

	%macro avGetDomain(domain=, count=);
		%if %sysfunc(exist(&speclib..&domain)) %then %do;
			data AVGML.av_spec_main&count(keep=domain variable__name variable_label origin source);
				set &speclib..&domain (rename=(origin=origin_));
				where upcase(include_y_n_) = 'Y';
				length domain origin $50.;

				domain = "&domain";
				origin = strip(origin_);
			run;
		%end;

		%if %sysfunc(exist(&speclib..supp&domain._vlm)) %then %do;
			data AVGML.av_spec_supp&count(keep=domain variable__name variable_label origin source);
				set &speclib..supp&domain._vlm (rename=(origin=origin_));
				where VARIABLE__NAME ^= '';
				length domain origin $50.;

				domain = cats('SUPP', "&domain");
				origin = strip(origin_);
			run;
		%end;
	%mend avGetDomain;


	data _null_;
		set AVGML.av_all_spec_domains;
		call execute('%avGetDomain(domain=' || strip(domain) || ',count=' || strip(put(_n_, best.)) || ');');
	run;

	data AVGML.av_all_specs_ds;
		length variable__name variable_label $200.;
		set AVGML.av_spec_main: AVGML.av_spec_supp:;
		where source = 'CRF';
	run;

	data AVGML.av_spec_annotations_pre;
		set AVGML.av_all_specs_ds;
		length annotation annotation_desc $200.;

		annotation = strip(upcase(variable__name));
		annotation_desc = strip(variable_label);

		if index(origin, ',') then do;
			do i = 1 to countw(origin, ',');
				pageno = input(strip(scan(origin, i, ',')), best.);
				output;
			end;
		end;
		else if origin ^= '' then do;
			pageno = input(origin, best.);
			output;
		end;
		else output;
	run;

	proc sql noprint;
		select count(*) into :N from AVGML.av_spec_annotations_pre;
	quit;

	%if &n. = 0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No annotations found from specification datasets in folder &mspath.05_OutputDocs\05_Specifications;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	data AVGML.av_spec_annotations_pre_sorted (keep=domain annotation annotation_desc pageno);
		set AVGML.av_spec_annotations_pre;

		proc sort;
			by domain annotation pageno;
	run;

	proc transpose data=AVGML.av_spec_annotations_pre_sorted out=AVGML.av_spec_annotations_pre_sorted_t;
		by domain annotation;
		var pageno;
	run;

	data AVGML.av_spec_annotations_final (drop=col: _name:);
		set AVGML.av_spec_annotations_pre_sorted_t;
		length pageno $200.;

		pageno = catx(', ', of col:);
	run;
	/*============================== Get All Spec Annotations =============================*/


	%if &type = PDF %then %do;
		%let pdfAnnotationSource  = &repPath\imported_pdf_annotations.csv;

		%include "T:\Standard Programs\Prod\Utility\avPDFAnnotationExtractor.sas";

		%if ^%sysfunc(fileexist(%bquote(&pdfAnnotationSource.))) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Import of annotations from &pdfsource failed;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;


		/*============================== Get All CRF Annotations ==============================*/
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

		data AVGML.av_crf_domains (keep=pageno domain color);
			set AVGML.av_crf;
			where index(annotation, '(') and index(annotation, ')');
			length domain $50.;

			domain = strip(scan(annotation, 1, ' '));

			proc sort nodupkey;
				by pageno color domain;
		run;

		data AVGML.av_crf_crf_domains;
			merge AVGML.av_crf(in=a) AVGML.av_crf_domains(in=b);
			by pageno color;

			/* Excludes notes as the color does not match the domain */
			if a and b;
		run;


		data AVGML.av_crf_crf_domains_calc1;
			set AVGML.av_crf_crf_domains;

			annotation = upcase(annotation);

			/* Excludes not submitted annotations */
			if index(annotation, 'NOT SUBMITTED') then delete;

			/* Excludes the domain annotation. Assuming domain format is SV (Subject Visits) */
			if index(annotation, '(') and index(annotation, ')') then delete;


			/* Update annotation for specific annotations.  */
			if index(annotation, 'RACE = MULTIPLE') then annotation = 'RACEX';
			if index(annotation, 'RACEOTH IN SUPPDM') then do;
				annotation = 'RACEOTH';
				domain = 'SUPPDM';
			end;

			/* Update annotation when keyword '\' or '/ is present. Assuming format is 'DSTERM / DSDECOD = INFORMED CONSENT OBTAINED'  */
			if index(upcase(annotation), 'PROPHYLAXIS/OTHER') = 0 then do; /* Add exceptions where \ or / was used and multiple variables are not indicated */
				if index(upcase(annotation), '\') or index(upcase(annotation), '/') then do;
					annotation_temp = strip(annotation);
					annotation_temp = tranwrd(annotation_temp, '/', '\');

					do i = 1 to countw(annotation_temp, '\');
						annotation = strip(scan(annotation_temp, i, '\'));
						output;
					end;
				end;
				else do;
					output;
				end;
			end;
			else do;
				output;
			end;
		run;

		data AVGML.av_crf_crf_domains_calc2;
			set AVGML.av_crf_crf_domains_calc1;

			/* Update annotation when keyword 'SUPP' is specified. Assuming format is 'DSPRTVRS in SUPPDS' */
			if index(annotation, 'SUPP') then do;
				domain = cats('SUPP', domain); 
				annotation = scan(annotation, 1, ' ');
			end;


			/* Update annotation when keyword 'when' is present. Assuming format is 'RPREASND when RPSTAT = NOT DONE'  */
			if index(annotation, 'WHEN') then annotation = scan(annotation, 1, ' ');


			/* Update annotation when keyword '=' is present. Assuming format is 'DSCAT = PROTOCOL MILESTONE'  */
			if index(annotation, '=') then annotation = scan(annotation, 1, '=');
		run;


		data AVGML.av_crf_annotations_sorted (keep=domain annotation pageno);
			length domain $50. annotation $200.;
			format domain $50. annotation $200.;
			set AVGML.av_crf_crf_domains_calc2;

			proc sort nodupkey;
				by domain annotation pageno;
		run;
		/*============================== Get All CRF Annotations ==============================*/
	%end;
	%else %if &type = XLSX %then %do;
		proc import datafile="&xlsxSource"
		     dbms=excelcs
		     out=AVGML.av_crf replace;
		     SHEET='Job 1 - Print'; 
		run;

		proc sql noprint;
			select count(*) into :N from AVGML.av_crf;
		quit;

		%if &n. = 0 %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No domains specified in Excel annotation file &specSource.;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;

		data AVGML.av_crf_annotations_calc1;
			set AVGML.av_crf;

			annotation = upcase(annotation);

			/* Excludes not submitted annotations */
			if index(annotation, 'NOT SUBMITTED') then delete;
			if index(upcase(annotation), 'NOTE:') then delete;

			/* Excludes the domain annotation. Assuming domain format is SV (Subject Visits) */
			if index(annotation, '(') and index(annotation, ')') then delete;


			/* Update annotation for specific annotations.  */
			if index(annotation, 'RACE = MULTIPLE') then annotation = 'RACEX';
			if index(annotation, 'RACEOTH IN SUPPDM') then do;
				annotation = 'RACEOTH';
				domain = 'SUPPDM';
			end;

			/* Update annotation when keyword '\' or '/ is present. Assuming format is 'DSTERM / DSDECOD = INFORMED CONSENT OBTAINED'  */
			if index(upcase(annotation), '\') or index(upcase(annotation), '/') then do;
				annotation_temp = strip(annotation);
				annotation_temp = tranwrd(annotation_temp, '/', '\');

				do i = 1 to countw(annotation_temp, '\');
					annotation = strip(scan(annotation_temp, i, '\'));
					output;
				end;
			end;
			else do;
				output;
			end;		
		run;

		data AVGML.av_crf_annotations_calc2;
			set AVGML.av_crf_annotations_calc1;

			/* Update annotation when keyword 'SUPP' is specified. Assuming format is 'DSPRTVRS in SUPPDS' */
			if index(annotation, 'SUPP') then do;
				domain = cats('SUPP', domain); 
				annotation = scan(annotation, 1, ' ');
			end;


			/* Update annotation when keyword 'when' is present. Assuming format is 'RPREASND when RPSTAT = NOT DONE'  */
			if index(annotation, 'WHEN') then annotation = scan(annotation, 1, ' ');


			/* Update annotation when keyword '=' is present. Assuming format is 'DSCAT = PROTOCOL MILESTONE'  */
			if index(annotation, '=') then annotation = scan(annotation, 1, '=');
		run;


		data AVGML.av_crf_annotations_sorted (keep=domain annotation pageno);
			length domain $50. annotation $200.;
			format domain $50. annotation $200.;
			set AVGML.av_crf_annotations_calc2;


			pageno = pageno + &addPages;

			proc sort nodupkey;
				by domain annotation pageno;
		run;
	%end;



	proc transpose data=AVGML.av_crf_annotations_sorted out=AVGML.av_crf_annotations_sorted_t;
		by domain annotation;
		var pageno;
	run;

	data AVGML.av_crf_annotations_final (drop=col: _name:);
		set AVGML.av_crf_annotations_sorted_t;
		length pageno $200.;

		pageno = catx(', ', of col:);
	run;
	


	/*============================= Create Datasets for report ============================*/
	data AVGML.av_report_spec_and_crf;
		merge AVGML.av_spec_annotations_final(in=a) AVGML.av_crf_annotations_final(in=b);
		by domain annotation pageno;
		length pageno_ $200.;

		if a and b;

		pageno_ = strip(pageno);
		if pageno_ = '' then pageno_ = '-';
	run;

	data AVGML.av_report_spec_and_crf_mis_page;
		merge AVGML.av_spec_annotations_final(in=a rename=(pageno=specpageno)) AVGML.av_crf_annotations_final(in=b);
		by domain annotation;
		length specpageno_ pageno_ $200.;

		if a and b;

		specpageno_ = strip(specpageno);
		if specpageno_ = '' then specpageno_ = '-';

		pageno_ = strip(pageno);
		if specpageno_ = '' then pageno_ = '-';

		if specpageno_ ^= pageno_;
	run;

	data AVGML.av_report_spec_not_crf;
		merge AVGML.av_spec_annotations_final(in=a) AVGML.av_crf_annotations_final(in=b drop=pageno);
		by domain annotation;
		length pageno_ $200.;

		if a and ^b;

		pageno_ = strip(pageno);
		if pageno_ = '' then pageno_ = '-';
	run;

	data AVGML.av_report_crf_not_spec;
		merge AVGML.av_spec_annotations_final(in=a drop=pageno) AVGML.av_crf_annotations_final(in=b);
		by domain annotation;
		length pageno_ $200.;

		if ^a and b;

		pageno_ = strip(pageno);
		if pageno_ = '' then pageno_ = '-';
	run;
	/*============================= Create Datasets for report ============================*/


	/*================================ Create XLSX Report =================================*/
	%if &type = PDF %then %do;
		%let report_source = &pdfsource;
	%end;
	%else %if &type = XLSX %then %do;
		%let report_source = &xlsxSource;
	%end;

	data AVGML.av_report_coverpage;
		length flag legend $300.;
		label legend = "Sheet Legend";
		flag = 'Spec and CRF'; 				legend = "Annotation exist in Specifications and aCRF with matching domain, annotation and page number"; 			output;
		flag = 'Spec and CRF Page'; 		legend = "Annotation exist in Specifications and aCRF with matching domain, annotation with page number mismatch"; 	output;
		flag = 'Spec Only'; 				legend = "Annotation exist in Specifications with no matching annotation in aCRF"; 									output;
		flag = 'CRF Only'; 					legend = "Annotation exist in CRF with no matching annotation in Specifcations"; 									output;
	run;

	%let systemOption = %sysfunc(getoption(validvarname, keyword));
	options validvarname=v7;

	title;
	footnote;

	ods escapechar='!';
	ods excel file="&repPath.\Specification_Annotation_Compare_Report_%left(%sysfunc(today(),date9.)).xlsx" options(sheet_name="Cover Page" embedded_footnotes='on' embedded_titles='on' frozen_headers="on" sheet_interval="none") style=BarrettsBlue;
		title1 j=c "Avance Clinical Pty.Ltd.";
		title2 j=c "Specification and aCRF Compare Summary";
		title3 j=c "aCRF: &report_source.";
		title4 j=c "Report Generated by: %sysfunc(tranwrd(%bquote(&sysuserid), ., %str(, ))) On: %left(%sysfunc(today(), date9.))";

		proc report data=AVGML.av_report_coverpage style(report)=[width=100%] nowd headline headskip missing;
			column legend flag;
			define legend/ style(column)=[just=l cellwidth=100%];
			define flag/noprint;
			compute flag;
				if 		flag = "Spec and CRF" 		then call define(_row_, "style", "style=[backgroundcolor=lightgreen]");
				else if flag = "Spec and CRF Page" 	then call define(_row_, "style", "style=[backgroundcolor=lightyellow]");
				else if flag = "Spec Only" 			then call define(_row_, "style", "style=[backgroundcolor=lightred]");
				else if flag = "CRF Only"   		then call define(_row_, "style", "style=[backgroundcolor=lightred]");
			endcomp;
		run;
		title;

		ods excel options(sheet_name="Spec and aCRF" sheet_interval="proc" tab_color="lightgreen");
		proc report data=AVGML.av_report_spec_and_crf style(report)=[width=100%] nowd headline headskip missing;
			column domain annotation annotation_desc pageno_;

			define domain 			/ "Domain" 			style(column)=[cellwidth=10%];
			define annotation 		/ "Annotation" 		style(column)=[cellwidth=20%];
			define annotation_desc 	/ "Description" 	style(column)=[cellwidth=30%];
			define pageno_ 			/ "Page Num" 		style(column)=[cellwidth=20%];
		run;

		ods excel options(sheet_name="Page Number Mismatch" sheet_interval="proc" tab_color="lightyellow");
		proc report data=AVGML.av_report_spec_and_crf_mis_page style(report)=[width=100%] nowd headline headskip missing;
			column domain annotation annotation_desc specpageno_ pageno_;

			define domain 			/ "Domain" 		 	style(column)=[cellwidth=10%];
			define annotation 		/ "Annotation" 	 	style(column)=[cellwidth=20%];
			define annotation_desc 	/ "Description"  	style(column)=[cellwidth=30%];
			define specpageno_ 		/ "Spec Page Num" 	style(column)=[cellwidth=15%];
			define pageno_ 			/ "aCRF Page Num" 	style(column)=[cellwidth=15%];
		run;

		ods excel options(sheet_name="Spec Only" sheet_interval="proc" tab_color="lightred");
		proc report data=AVGML.av_report_spec_not_crf style(report)=[width=100%] nowd headline headskip missing;
			column domain annotation annotation_desc pageno_;

			define domain 			/ "Domain" 		 	style(column)=[cellwidth=10%];
			define annotation 		/ "Annotation" 		style(column)=[cellwidth=20%];
			define annotation_desc 	/ "Description" 	style(column)=[cellwidth=30%];
			define pageno_ 			/ "Spec Page Num" 	style(column)=[cellwidth=20%];
		run;

		ods excel options(sheet_name="aCRF Only" sheet_interval="proc" tab_color="lightred");
		proc report data=AVGML.av_report_crf_not_spec style(report)=[width=100%] nowd headline headskip missing;
			column domain annotation pageno_;

			define domain 			/ "Domain" 		 	style(column)=[cellwidth=10%];
			define annotation 		/ "Annotation" 		style(column)=[cellwidth=50%];
			define pageno_ 			/ "aCRF Page Num" 	style(column)=[cellwidth=20%];
		run;

	ods excel close;

	options &systemOption;
	/*================================ Create XLSX Report =================================*/
%mend avSpecCRFCompare;

