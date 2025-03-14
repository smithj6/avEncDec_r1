/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avAnnCreateTableOfContents.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Reads global study metatdata and prepares it for avPdfTableOfContents
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avAnnCreateTableOfContents(pathInCRFDataDictionary=
								  ,pathInPdfDocument=
								  ,fileOut=);

	%local i
		   systemOption
		   dsid
		   rc
		   totalSheets
		   sheet1
		   sheet1Column
		   sheet2
		   sheet2Column;
	%if %sysevalf(%superq(pathInCRFDataDictionary)=, boolean) or 
		%sysevalf(%superq(pathInPdfDocument)=, boolean) 	  or 
		%sysevalf(%superq(fileOut)=, boolean) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro parameters pathInCRFDataDictionary, pathInPdfDocument and fileOut;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
	%end;
	%if ^%sysfunc(prxmatch(%str(m/^.+\.xlsx$/oi), %bquote(&pathInCRFDataDictionary))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] File &pathInCRFDataDictionary does not end in .xlsx extenstion;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(fileexist(%bquote(&pathInCRFDataDictionary))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] File &pathInPdfDocument does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(prxmatch(%str(m/^.+\.pdf$/oi), %bquote(&pathInPdfDocument))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] File &pathInPdfDocument does not end in .pdf extenstion;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(fileexist(%bquote(&pathInPdfDocument))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] File &pathInPdfDocument does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(prxmatch(%str(m/^.+\.pdf$/oi), %bquote(&fileOut))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] File &fileOut does not end in .pdf extenstion;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysfunc(fileexist(%bquote(&fileOut))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] File &pathInPdfDocument already exists;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Overwriting is not suppored;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysfunc(libref(avgml)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Assign Library AVGML is study setup file;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%let systemOption = options %sysfunc(getoption(validvarname, keyword));
	%let totalSheets = 2;
	%let sheet1 = Forms;
	%let sheet1Column = Form_name;
	%let sheet2 = Visits;
	%let sheet2Column = Visit;

	options validvarname=v7;

	%do i=1 %to &totalSheets;
		proc import datafile = "&pathInCRFDataDictionary"
			out=avgml.&&sheet&i
			dbms=xlsx
			replace;
			getnames=yes;
			sheet="&&sheet&i";
		run;
		%if &syserr %then %do;
			%put ERROR: 1/[AVANCE %sysfunc(datetime(), e8601dt.)] Import Unsuccsessful, see SAS Log;
			%put ERROR: 2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;
		%let dsid=%sysfunc(open(avgml.&&sheet&i));
		%if ^%sysfunc(varnum(&dsid, &&sheet&i.column)) %then %do;
			%put ERROR: 1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &&sheet&i.column not found in sheet &&sheet&i;
			%put ERROR: 2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let rc=%sysfunc(close(&dsid));
			&systemOption;
			%return;
		%end;
		%if %sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, &&sheet&i.column)))) ne C %then %do;
			%put ERROR: 1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &&sheet&i.column in sheet &&sheet&i is not in the expected type;
			%put ERROR: 2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expected type is character;
			%put ERROR: 3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let rc=%sysfunc(close(&dsid));
			&systemOption;
			%return;
		%end;
		%let rc=%sysfunc(close(&dsid));

		data avgml.&&sheet&i..sorting;
			set avgml.&&sheet&i(where=(^missing(&&sheet&i.column)));
			by &&sheet&i.column notsorted;
			if first.&&sheet&i.column then _ord_+1;
		run;

		proc sort nodupkey data=avgml.&&sheet&i..sorting out=avgml.&&sheet&i..sorted(keep=&&sheet&i.column);
			by _ord_ &&sheet&i.column;
		run;

		proc export data=avgml.&&sheet&i..sorted
			outfile="%sysfunc(pathname(work))\&&sheet&i...csv"
			dbms=CSV
			replace;
		run;
	%end;
	%include "T:\Standard Programs\Prod\Utility\TableOfContents\avPdfTableOfContentsGenerator.sas" /source2;
%mend avAnnCreateTableOfContents;






