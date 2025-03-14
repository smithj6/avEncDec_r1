/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avUpdateTFLSpecDataset.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Creates datasets from TFL specifications
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :  
=======================================================================================*/

%macro avUpdateTFLSpecDataset();
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML is study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%symglobl(mspath) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable mspath is not defined in global scope;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(fileexist(%bquote(&mspath\01_Specifications\03_TFL))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specification folder &mspath\01_Specifications\03_TFL does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(fileexist(&mspath\01_Specifications\03_TFL\avTitleFooter.xlsx))=0 %then %do;
		%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] avTitleFooter.xlsx file does not exist in &mspath\01_Specifications\03_TFL;
		%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] No output specific headers or footers will be added;
	%end;
	%else %do;
		/*======================= Create Superseded folder if required ========================*/
		%if ^%sysfunc(fileexist(&mspath\01_Specifications\03_TFL\Superseded)) %then %do;
			data _null_;
				cdisc=dcreate("Superseded", "&mspath\01_Specifications\03_TFL\");
			run;
		%end;

		proc datasets library=avgml memtype=data kill nolist nowarn;
		quit;

		options validvarname=upcase;


		data _null_;
			length date1 $200.;
			date	= today();
			time	= strip(put(time(), tod8.));
			date1	= catt(strip(put(date, YYMMDDN.)),"_h", scan(time, 1, ":"),"m", scan(time, 2, ":"),"s", scan(time, 3, ":"));

			call symputx("bkdtc", date1);
		run;


		/*=========================== Supersede last avTitleFooter ============================*/
		%sysexec copy "&mspath\01_Specifications\03_TFL\avTitleFooter.xlsx" "&mspath\01_Specifications\03_TFL\Superseded\avTitleFooter_&bkdtc..xlsx";


		/*=================================== Import Titles ===================================*/
		proc import datafile="&mspath\01_Specifications\03_TFL\avTitleFooter.xlsx"
			out		= AVGML.titles_import
			dbms	= xlsx
			replace;
			sheet	= "Titles";
		run;

		data AVGML.titles;
			set AVGML.titles_import;
			where upcase(program_name) ^= '';
		run;

		%avTrimCharVarsToMaxLength(dataIn=AVGML.titles);


		/*=========================== Supersede last Titles dataset ===========================*/
		%sysexec copy "&mspath\01_Specifications\03_TFL\Titles.sas7bdat" "&mspath\01_Specifications\03_TFL\Superseded\Titles_&bkdtc..sas7bdat";


		/*=============================== Create Titles dataset ===============================*/
		proc copy in = AVGML
		    out = &spectf.;
			select Titles;
		run;


		/*=================================== Import Footnotes ===================================*/
		proc import datafile="&mspath\01_Specifications\03_TFL\avTitleFooter.xlsx"
			out		= AVGML.footnotes_import
			dbms	= xlsx
			replace;
			sheet	= "Footnotes";
		run;

		data AVGML.footnotes;
			set AVGML.footnotes_import;
			where upcase(program_name) ^= '';
		run;

		%avTrimCharVarsToMaxLength(dataIn=AVGML.footnotes);


		/*=========================== Supersede last Titles dataset ===========================*/
		%sysexec copy "&mspath\01_Specifications\03_TFL\Footnotes.sas7bdat" "&mspath\01_Specifications\03_TFL\Superseded\Footnotes_&bkdtc..sas7bdat";


		/*=============================== Create Titles dataset ===============================*/
		proc copy in = AVGML
		    out = &spectf.;
			select Footnotes;
		run;

	%end;
%mend avUpdateTFLSpecDataset;
