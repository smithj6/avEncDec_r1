/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avAnnExtractDDVisits.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Extracts visits from data dictionary and assigns visits to input forms csv based on data dictionary.
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avAnnExtractDDVisits(pathInFormsCSV=, pathInCRFDataDictionary=, formsSheet=, visitsSheet=, dashboardSheet=, repPath=);
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML is study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysevalf(%superq(pathInFormsCSV)  =, boolean) or 
				  %sysevalf(%superq(pathInCRFDataDictionary)  =, boolean) or 
				  %sysevalf(%superq(formsSheet)  =, boolean) or 
				  %sysevalf(%superq(visitsSheet)  =, boolean) or 
				  %sysevalf(%superq(dashboardSheet)  =, boolean) or 
				  %sysevalf(%superq(repPath)  =, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameters pathInformsCSV, pathInCRFDataDictionary, formsSheet, visitsSheet, dashboardSheet and repPath are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/*=================================== Validate CSV ====================================*/
	%if ^%sysfunc(fileexist(%bquote(&pathInFormsCSV.))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified pathInFormsCSV file &pathInFormsCSV does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(prxmatch(%str(m/^.+\.csv$/oi), %bquote(&pathInFormsCSV))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] File &pathInFormsCSV does not end in .csv extension;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/*=================================== Validate Dict ===================================*/
	%if ^%sysfunc(fileexist(%bquote(&pathInCRFDataDictionary.))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified pathInCRFDataDictionary file &pathInCRFDataDictionary. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(prxmatch(%str(m/^.+\.xlsx$/oi), %bquote(&pathInCRFDataDictionary))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] File &pathInCRFDataDictionary does not end in .xlsx extension;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/*================================== Validate Output ==================================*/
	%if ^%sysfunc(fileexist(%bquote(&repPath.))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified report path &repPath does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(fileexist(%bquote(&repPath.\FormsVisitsCombined.xlsx))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Output file FormsVisitsCombined.xlsx already exists in specified path &repPath;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%local N avTransposeMe;

	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	/*================================== Import Bookmarks =================================*/
	proc import datafile = "&pathInFormsCSV."
		out=AVGML.bookmarks_import
		dbms=csv
		replace;
		getnames=yes;
		guessingrows=300;
	run;

	%if ^%sysfunc(exist(AVGML.bookmarks_import)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Could not import specified file &pathInFormsCSV.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%let dsid = %sysfunc(open(AVGML.bookmarks_import));
	%if ^%sysfunc(varnum(&dsid, FORM)) or ^%sysfunc(varnum(&dsid, PAGENO)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] The variables FORM and PAGENO are required in input file &pathInFormsCSV;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let dsid_=%sysfunc(close(&dsid));
		%return;
	%end;
	%let dsid_=%sysfunc(close(&dsid));

	data AVGML.bookmarks;
		set AVGML.bookmarks_import;

		proc sort nodupkey;
			by form;
	run;

	proc sql noprint;
		select count(*) into :N from AVGML.bookmarks;
	quit;

	%if &N. = 0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No bookmarks found from specified CSV file &pathInFormsCSV;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;


	/*=================================== Import Forms ====================================*/
	proc import datafile = "&pathInCRFDataDictionary."
		out=AVGML.forms_import
		dbms=xlsx
		replace;
		sheet=&formsSheet.;
		getnames=yes;
	run;

	%if ^%sysfunc(exist(AVGML.forms_import)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Could not import specified Forms sheet: &formsSheet;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%let dsid = %sysfunc(open(AVGML.forms_import));
	%if ^%sysfunc(varnum(&dsid, DRAFTFORMNAME)) or ^%sysfunc(varnum(&dsid, OID)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] The columns DRAFTFORMNAME and OID are required in the input sheet &formsSheet;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let dsid_=%sysfunc(close(&dsid));
		%return;
	%end;
	%let dsid_=%sysfunc(close(&dsid));

	data AVGML.forms (keep=form form_id);
		set AVGML.forms_import;
		where draftformname ^= '';

		form = strip(draftformname);
		form_id = strip(oid);

		proc sort nodupkey;
			by form;
	run;


	proc sql noprint;
		select count(*) into :N from AVGML.forms;
	quit;

	%if &N. = 0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No Forms identified from specified file &pathInCRFDataDictionary;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;


	/*=============================== Merge Forms/Bookmarks ===============================*/
	data AVGML.forms_bookmarks(drop=datetime);
		length form $400.;
		merge AVGML.forms(in=a) AVGML.bookmarks(in=b);
		by form;

		/* Used for warning messages */
		datetime=datetime();

		if a and ^b then do;
			put "WARNING:1/[AVANCE " datetime e8601dt. "] Form: (" Form ") in Data Dictionary but not found in Bookmarks";
			put "WARNING:1/[AVANCE " datetime e8601dt. "] Form will be excluded from output file";
		end;
		else if ^a and b then do;
			put "WARNING:1/[AVANCE " datetime e8601dt. "] Form: (" Form ") not in Data Dictionary but found in Bookmarks";
			put "WARNING:1/[AVANCE " datetime e8601dt. "] Form will be excluded from output file";
		end;

		if a and b;

		proc sort;
			by form_id;
	run;


	/*=================================== Import Visits ===================================*/
	proc import datafile = "&pathInCRFDataDictionary."
		out=AVGML.visits_import
		dbms=xlsx
		replace;
		sheet=&visitsSheet.;
		getnames=yes;
	run;

	%if ^%sysfunc(exist(AVGML.visits_import)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Could not import specified Visits sheet: &visitsSheet;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%let dsid = %sysfunc(open(AVGML.visits_import));
	%if ^%sysfunc(varnum(&dsid, FOLDERNAME)) or ^%sysfunc(varnum(&dsid, OID)) or ^%sysfunc(varnum(&dsid, ORDINAL)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] The columns FOLDERNAME, OID and ORDINAL are required in the input sheet &visitsSheet;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let dsid_=%sysfunc(close(&dsid));
		%return;
	%end;
	%let dsid_=%sysfunc(close(&dsid));

	%if %sysfunc(cexist(work.formats.visitCRF.formatc)) = 1 and %sysfunc(cexist(work.formats.visitnumCRF.infmt)) = 1 %then %do;
		data AVGML.visits (keep=visit visit_id visit_sort);
			set AVGML.visits_import;
			length visit_id visit $200.;

			visit_id = strip(oid);

			visit = put(foldername, visitCRF.);
			visit_sort = input(foldername, ??visitnumCRF.);
			if visit_sort = . then visit_sort = input(ordinal, ??best.);

			proc sort;
				by visit_sort;
		run;
	%end;
	%else %do;
		data AVGML.visits (keep=visit visit_id visit_sort);
			set AVGML.visits_import;
			length visit_id visit $200.;

			visit_id = strip(oid);

			visit = strip(foldername);
			visit_sort = input(ordinal, ??best.);

			proc sort;
				by visit_sort;
		run;
	%end;


	proc sql noprint;
		select count(*) into :N from AVGML.visits;
	quit;

	%if &N. = 0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No Visits identified from specified file &pathInCRFDataDictionary.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;


	/*================================== Import Dashboard =================================*/
	proc import datafile = "&pathInCRFDataDictionary."
		out=AVGML.dashboard_import
		dbms=xlsx
		replace;
		sheet="&dashboardSheet.";
		getnames=yes;
	run;

	%if ^%sysfunc(exist(AVGML.dashboard_import)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Could not import specified Dashboard sheet: &dashboardSheet;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%let dsid = %sysfunc(open(AVGML.dashboard_import));
	%if ^%sysfunc(varnum(&dsid, MATRIX__MASTERDASHBOARD)) or ^%sysfunc(varnum(&dsid, COMMON)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] The columns MATRIX__MASTERDASHBOARD and COMMON are required in the input sheet &dashboardSheet;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let dsid_=%sysfunc(close(&dsid));
		%return;
	%end;
	%let dsid_=%sysfunc(close(&dsid));


	data AVGML.dashboard (drop=matrix__masterdashboard subject nv); /* NV (Non Validated) is dropped. In all test cases these forms are not included */
		set AVGML.dashboard_import;

		form_id = strip(matrix__masterdashboard);
		temp_id = 1;

		proc sort;
			by form_id;
	run;


	proc sql noprint;
		select count(*) into :N from AVGML.dashboard;
	quit;

	%if &N. = 0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No Forms and Visits identified from specified file &pathInCRFDataDictionary.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;


	proc sql noprint;
	    select name into :avTransposeMe SEPARATED by ' '
	    from sashelp.vcolumn
	    where libname = 'AVGML' and
	          upcase(memname) = 'DASHBOARD' and
	          upcase(name) ^in ('FORM_ID', 'TEMP_ID');
	quit;

	proc transpose data=AVGML.dashboard out=AVGML.dashboard_t ;
		by form_id;
		id temp_id;
		var &avTransposeMe;
	run;

	proc sql noprint;
		create table AVGML.dashboard_t_visits as
		select 
			a.form_id,
			a._name_ as visit_id,
			a._1 as ticked,
			ifc(_1 ^= '', '[' || strip(b.visit) || ']', strip(b.visit)) as visit,
			b.visit_sort
		from AVGML.dashboard_t as a
		left join AVGML.visits as b on a._name_ = b.visit_id
		order by a.form_id, b.visit_sort;
	quit;


	proc transpose data=AVGML.dashboard_t_visits out=AVGML.dashboard_t_visits_t prefix=vis_;
	  by form_id;
	  var visit;
	run;

	data AVGML.dashboard_t_visits_t_combined(drop=_name_ vis_:);
	  set AVGML.dashboard_t_visits_t;
	  length visits $200.;

	  visits = catx('#', of vis_:);

	  proc sort;
	  	by form_id;
	run;

	data AVGML.final(drop=datetime);
		merge AVGML.forms_bookmarks(in=a) AVGML.dashboard_t_visits_t_combined(in=b);
		by form_id;

		/* Used for warning messages */
		datetime=datetime();

		if a and b;

		if a and ^b then do;
			put "WARNING:1/[AVANCE " datetime e8601dt. "] Form: (" Form ") found in Forms and Bookmarks but not found in Dashboard";
			put "WARNING:1/[AVANCE " datetime e8601dt. "] Form will be excluded from output file";
		end;
		else if ^a and b then do;
			put "WARNING:1/[AVANCE " datetime e8601dt. "] Form: (" Form ") not found in Forms and Bookmarks but found in Dashboard";
			put "WARNING:1/[AVANCE " datetime e8601dt. "] Form will be excluded from output file";
		end;

		if a and b and find(visits, '[') = 0 then do;
			put "WARNING:1/[AVANCE " datetime e8601dt. "] Form: (" Form ") not assigned to any visits";
			put "WARNING:1/[AVANCE " datetime e8601dt. "] Please review and assign Visit manually in output file";
		end;

		proc sort;
			by pageno form;
	run;


	/*================================ Export Final Dataset ===============================*/
	proc export data=AVGML.final
		outfile="&repPath\FormsVisitsCombined"
		dbms=xlsx
		replace;
	run;


	/*================================== Validate Import ==================================*/
	proc import datafile = "&repPath\FormsVisitsCombined"
		out=AVGML.final_import
		dbms=xlsx
		replace;
		getnames=yes;
	run;

	%if ^%sysfunc(exist(AVGML.final_import)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Error occurred exporting FormsVisitsCombined.xlsx;
		%return;
	%end;

	proc sql noprint;
		select count(*) into :N from AVGML.bookmarks_import;
	quit;

	%if &N. = 0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Error occurred exporting FormsVisitsCombined.xlsx;
		%return;
	%end;
	%else %do;
		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] FormsVisitsCombined.xlsx file succesfully created in &repPath;
	%end;

%mend avAnnExtractDDVisits;
