/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avAnnCreateTableOfContentsManual.sas
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

%macro avAnnCreateTableOfContentsManual(pathInXLSX=, pathInPdfDocument=, fileOut=);
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML is study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysevalf(%superq(pathInXLSX) =, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameter pathInXLSX is required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/*=================================== Validate XLSX ===================================*/
	%if ^%sysfunc(fileexist(%bquote(&pathInXLSX.))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified pathInXLSX file &pathInXLSX does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(prxmatch(%str(m/^.+\.xlsx$/oi), %bquote(&pathInXLSX))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] File &pathInXLSX does not end in .xlsx extension;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/*================================== Validate PDF In ==================================*/
	%if ^%sysfunc(fileexist(%bquote(&pathInPdfDocument.))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified pathInPdfDocument file &pathInPdfDocument does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(prxmatch(%str(m/^.+\.pdf$/oi), %bquote(&pathInPdfDocument))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] File &pathInPdfDocument does not end in .pdf extension;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;


	/*================================== Validate Output ==================================*/
	%if %sysfunc(fileexist(%bquote(&fileOut.))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified fileOut file &fileOut already exists;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(prxmatch(%str(m/^.+\.pdf$/oi), %bquote(&fileOut))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] File &fileOut does not end in .pdf extension;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%local N;

	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	/*================================= Import Input File =================================*/
	proc import datafile = "&pathInXLSX."
		out=AVGML.forms_import
		dbms=xlsx
		replace;
		sheet=FormsVisitsCombined;
		getnames=yes;
	run;

	%if ^%sysfunc(exist(AVGML.forms_import)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Could not import specified file &pathInXLSX;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%let dsid = %sysfunc(open(AVGML.forms_import));
	%if ^%sysfunc(varnum(&dsid, FORM)) or ^%sysfunc(varnum(&dsid, FORM_ID)) or ^%sysfunc(varnum(&dsid, PAGENO)) or ^%sysfunc(varnum(&dsid, VISITS)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] The variables FORM, FORM_ID, PAGENO and VISITS are required in input file &pathInXLSX;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let dsid_=%sysfunc(close(&dsid));
		%return;
	%end;
	%let dsid_=%sysfunc(close(&dsid));

	proc sql noprint;
		select count(*) into :N from AVGML.forms_import;
	quit;

	%if &n. = 0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No observations identified in input file &pathInXLSX;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;


	/*================================ Create Forms Dataset ===============================*/
	data AVGML.forms(drop=datetime visits temp_visit i);
		set AVGML.forms_import;
		where form ^= '';
		length temp_visit $200. active_visit $2000.;

		do i=1 by 1 while(scan(visits, i, '#') ^= ' ');
			temp_visit = scan(visits, i, '#');
			if find(temp_visit, '[') or find(temp_visit, ']') then do;
				temp_visit = tranwrd(temp_visit, '[', '');
				temp_visit = tranwrd(temp_visit, ']', '');

				active_visit = catx('#', active_visit, temp_visit);
			end;
		end;

		/* Used for warning messages */
		datetime=datetime();

		/* Validate column values */
		if form_id = '' then do;
			put "WARNING:1/[AVANCE " datetime e8601dt. "] Form: (" %sysfunc(compress(form)) ") has missing form_id column";
			put "WARNING:1/[AVANCE " datetime e8601dt. "] Form will be excluded";
			delete;
		end;
		else if pageno = . then do;
			put "WARNING:1/[AVANCE " datetime e8601dt. "] Form: (" %sysfunc(compress(form)) ") has missing pageno column";
			put "WARNING:1/[AVANCE " datetime e8601dt. "] Form will be excluded";
			delete;
		end;
		else if active_visit = '' then do;
			put "WARNING:1/[AVANCE " datetime e8601dt. "] Form: (" %sysfunc(compress(form)) ") has missing visits column";
			put "WARNING:1/[AVANCE " datetime e8601dt. "] Form will be excluded";
			delete;
		end;
	run;

	/*================================ Create Forms Export ================================*/
	proc export data=AVGML.forms
		outfile="%sysfunc(pathname(work))\forms.csv"
		dbms=CSV
		replace;
	run;


	/*=============================== Create Visits Dataset ===============================*/
	data AVGML.visits_unique (keep=visit order);
		set AVGML.forms_import;
		where form ^= '';
		length visit $200.;

		do i=1 by 1 while(scan(visits, i, '#') ^= ' ');
			temp_visit = scan(visits, i, '#');
			temp_visit = tranwrd(temp_visit, '[', '');
			temp_visit = tranwrd(temp_visit, ']', '');

			visit = strip(temp_visit);
			order = i;
			output;
		end;

		proc sort nodupkey;
			by order visit;
	run;

	data AVGML.visits_active (keep=visit);
		set AVGML.forms_import;
		where form ^= '';
		length visit $200.;

		do i=1 by 1 while(scan(visits, i, '#') ^= ' ');
			temp_visit = scan(visits, i, '#');
			if find(temp_visit, '[') or find(temp_visit, ']') then do;
				temp_visit = tranwrd(temp_visit, '[', '');
				temp_visit = tranwrd(temp_visit, ']', '');

				visit = strip(temp_visit);
				output;
			end;
		end;

		proc sort nodupkey;
			by visit;
	run;

	proc sql noprint;
		create table AVGML.visits as
		select 
			a.visit
		from AVGML.visits_unique as a
		left join AVGML.visits_active as b on a.visit = b.visit
		where b.visit ^= ''
		order by a.order;
	quit;
			

	/*================================ Create Visits Export ===============================*/
	proc export data=AVGML.visits(keep=visit)
		outfile="%sysfunc(pathname(work))\visits.csv"
		dbms=CSV
		replace;
	run;


	/*================================ Call Utility Program ===============================*/
	%include "T:\Standard Programs\Prod\Utility\TableOfContentsManual\avPdfTableOfContentsGenerator.sas" /source2;

	%if %sysfunc(fileexist(%bquote(&fileOut.))) %then %do;
		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] &fileOut succesfully created;
	%end;
%mend avAnnCreateTableOfContentsManual;
