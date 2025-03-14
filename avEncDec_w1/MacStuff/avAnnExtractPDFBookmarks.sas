/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avAnnExtractPDFBookmarks.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Extracts bookmarks by utilizing the utility program avPDFBookmarkExtractor.
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avAnnExtractPDFBookmarks(pdfIn=, repPath=);
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML is study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysevalf(%superq(pdfIn)  =, boolean) or %sysevalf(%superq(repPath)  =, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameters pdfIn and repPath are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/*=================================== Validate PDF ====================================*/
	%if ^%sysfunc(fileexist(%bquote(&pdfIn.))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified pdfIn file &pdfIn does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(prxmatch(%str(m/^.+\.pdf$/oi), %bquote(&pdfIn))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] File &pdfIn does not end in .pdf extension;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/*================================== Validate Output ==================================*/
	%if ^%sysfunc(fileexist(%bquote(&repPath.))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified report path &repPath does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(fileexist(%bquote(&repPath.\Bookmarks.csv))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Output file Bookmarks.csv already exists in specified path &repPath;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	%local pdfBookmarkSource pdfBookmarkSourceOutput N;

	/* Assign variables required by avPDFBookmarkExtractor.sas */
	%let pdfBookmarkSource 			= &pdfIn;
	%let pdfBookmarkSourceOutput 	= &repPath.\Bookmarks.csv;


	/*================================== Perform Import ===================================*/
	%include "T:\Standard Programs\Prod\Utility\TableOfContentsManual\avPDFBookmarkExtractor.sas";


	/*================================== Validate Import ==================================*/
	proc import datafile = "&pdfBookmarkSourceOutput."
		out=AVGML.bookmarks_import
		dbms=csv
		replace;
		getnames=yes;
	run;

	%if ^%sysfunc(exist(AVGML.bookmarks_import)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Error occurred extracting bookmarks from specified PDF file &pdfIn;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Check that input pdf contains bookmarks with at least one child level;
		%return;
	%end;

	proc sql noprint;
		select count(*) into :N from AVGML.bookmarks_import;
	quit;

	%if &N. = 0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No bookmarks extracted from specified PDF file &pdfIn;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Check that input pdf contains bookmarks with at least one child level;
		%return;
	%end;
	%else %do;
		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Bookmarks.csv file succesfully exported to &repPath;
	%end;
%mend avAnnExtractPDFBookmarks;
