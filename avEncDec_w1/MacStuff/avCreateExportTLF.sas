/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avCreateExportTLF.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Create TLF delivery folder and copy all rtf output
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avCreateExportTLF(repPath=, version=Draft, delivery=)/minoperator;
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML is study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%symglobl(client) or ^%symglobl(studyno) or ^%symglobl(mspath) or ^%symglobl(tflpdfpath) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable client, studyno, tflpath and tflpdfpath are not defined in global scope;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(fileexist(&tflpath.))=0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified path &tflpath. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(fileexist(&tflpdfpath.))=0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified path &tflpdfpath. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysevalf(%superq(repPath)  =, boolean) or %sysevalf(%superq(version)  =, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameters repPath and version are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(fileexist(&repPath.))=0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified path &repPath. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%local sponsor bkdtc output_path N single_output single_output_compressed;

	/* Derive sponsor name from global "client" variable */
	%let sponsor = %scan(&client, 2, \);

	/* Derive export folder name */
	data _null_;
		length date1 $200.;
		date=today();
		time=strip(put(time(), tod8.));

		/* Update delivery folder name here if required to change */
		date1= catx('_', cats(strip(put(year(date), best.)), strip(put(month(date), best.)), strip(put(day(date), best.))), 'TFLs', "&version", "&sponsor", "&studyno.");
		*date1= catx('_', 'TLF', "&version", "&studyno.", catt(strip(put(date, is8601da.))," h", scan(time, 1, ":"),"m", scan(time, 2, ":"),"s", scan(time, 3, ":")));
		call symputx("bkdtc", date1);
	run;

	%if %sysfunc(fileexist(&repPath.\&bkdtc.))^=0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Output path &repPath.\&bkdtc. already exists;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(fileexist(&mspath\01_Specifications\03_TFL\titles.sas7bdat))=0 %then %do;
		%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Titles.sas7bdat file does not exist in &mspath\01_Specifications\03_TFL;
		%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
	%end;
	%else %do;
		proc datasets library=avgml memtype=data kill nolist nowarn;
		quit;

		/*============================ Get programs from XLSX =============================*/
		data AVGML.av_all_output_sheet (keep=program_name delivery);
			set &spectf..titles;
			where program_name ^= '';

			program_name = lowcase(program_name);
			delivery = lowcase(delivery);

			proc sort;
					by program_name;
		run;

		/* Filter if Delivery is specified, otherwise all will be used */
		%if ^%sysevalf(%superq(delivery)  =, boolean)  %then %do;
			/* Get deliveries specified from parameter */
			data AVGML.av_delivery;
				col = "&delivery.";
				output;
			run;

			data AVGML.av_delivery_seperated;
				set AVGML.av_delivery;

				do i=1 by 1 while(scan(col,i,'#') ^= ' ');
					delivery = lowcase(scan(col,i,'#'));
					output;
				end;
			run;

			proc sql;
				create table AVGML.av_all_output_sheet_checked as
				select 
					a.*,
					(select count(*) from AVGML.av_delivery_seperated as b where b.delivery = a.delivery) as specified
				from AVGML.av_all_output_sheet as a;
			quit;

			data AVGML.av_all_output_sheet;
				set AVGML.av_all_output_sheet_checked;
				where specified > 0;

				proc sort nodupkey;
					by program_name;
			run;
		%end;

		proc sql noprint;
			select count(*) into :N from AVGML.av_all_output_sheet;
		quit;

		%if &n. = 0 %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No outputs identified from Titles.sas7bdat in &mspath\01_Specifications\03_TFL;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;

		/*============================ Get programs from folder ===========================*/

		%let output_path = &mspath.\05_OutputDocs\01_RTF;

		data AVGML.av_folder (keep=output_name);
			length output_name $200.;
			rc = filename("mydir","&output_path");
			did = dopen("mydir");
			if did > 0
			then do i = 1 to dnum(did);
			  output_name = dread(did,i);
			  output;
			end;
			rc = dclose(did);
		run;

		data AVGML.av_all_output_folder;
			set AVGML.av_folder;
			where index(upcase(output_name), "SUPERSEDED") = 0; /* Exclude superseded folder */

			program_name = lowcase(scan(output_name, 1, ' '));

			proc sort;
				by program_name;
		run;


		proc sql noprint;
			select count(*) into :N from AVGML.av_all_output_folder;
		quit;

		%if &n. = 0 %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No outputs identified from folder location &mspath.\05_OutputDocs\01_RTF;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;

		data AVGML.av_all_output_merged;
			merge AVGML.av_all_output_folder(in=a) AVGML.av_all_output_sheet(in=b);
			by program_name;

			if a and b;
		run;

		data AVGML.av_all_output_merged_counted;
			set AVGML.av_all_output_merged;
			
			count = _n_;
		run;

		proc sql noprint;
			select count(*) into :N from AVGML.av_all_output_merged_counted;
		quit;

		%if &n. = 0 %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No outputs present in both avTitleFooter.xlsx and &mspath.\05_OutputDocs\01_RTF;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;
			

		/*============================ Creare delivery folder =============================*/
		data _null_;
			length delivery $200.;
			delivery = dcreate("&bkdtc.", "&repPath.");
		run;


		/*========================== Copy output if folder exist ==========================*/
		%if %sysfunc(fileexist(&repPath.\&bkdtc.))=0 %then %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] TLF path &repPath.\&bkdtc. not created successfully;
			%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] No TLF output will be copied to this location;
			%return;
		%end;
		%else %do;
			%let i = 1;
			%begin:
				proc sql noprint;
					select tranwrd(output_name, '.rtf', '') into :single_output from AVGML.av_all_output_merged_counted where count = &i;
				quit;

				%let single_output_compressed = %sysfunc(strip(&single_output));

				%sysexec copy "&tflpath.\&single_output_compressed..rtf" "&repPath.\&bkdtc.";
				%sysexec copy "&tflpdfpath.\&single_output_compressed..pdf" "&repPath.\&bkdtc.";
			
				%let i = %eval(&i + 1);
				%if &i <= &n %then %goto begin;
		%end;
	%end;
%mend avCreateExportTLF;
