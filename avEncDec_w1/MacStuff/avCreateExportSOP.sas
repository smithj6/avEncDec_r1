/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avCreateExportSOP.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Create export folders for SDTM, ADaM and TFL as required by SOP by copying files to required locations
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avCreateExportSOP(analysisPath=, type=Final)/minoperator;
	/*============================= Validate Global Variables =============================*/
	%if ^%symglobl(mspath) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable msPath is not defined in global scope;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(fileexist(&mspath.))=0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified path &mspath. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/*============================= Validate Macro Parameters =============================*/
	%if %sysevalf(%superq(analysisPath)  =, boolean)  %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameter analysisPath is required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(fileexist(&analysisPath.))=0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified path &analysisPath. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;


	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	options noxwait;

	%local bkdtc n_source n_dest type_formatted loc_raw loc_program loc_dataset loc_output;

	%let type_formatted = %sysfunc(propcase(&type.));

	%if &type_formatted = Interim %then %do;
		%let loc_raw = 03 Interim Raw Datasets;
		%let loc_program = 04 Interim Programs;
		%let loc_dataset = 05 Interim Datasets;
		%let loc_output = 06 Interim Output;
	%end;
	%else %if &type_formatted = Final %then %do;
		%let loc_raw = 07 Final Raw Datasets;
		%let loc_program = 08 Final Programs;
		%let loc_dataset = 09 Final Datasets;
		%let loc_output = 10 Final Output;
	%end;
	%else %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid selection for macro parameter type (%bquote(&type)). Valid selections are Interim or Final;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;


	/*============================ Validate Individual Folders ============================*/
	%if %sysfunc(fileexist(&analysisPath.\&loc_raw.))=0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified path &analysisPath.\&loc_raw. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(fileexist(&analysisPath.\&loc_program.))=0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified path &analysisPath.\&loc_program. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(fileexist(&analysisPath.\&loc_dataset.))=0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified path &analysisPath.\&loc_dataset. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(fileexist(&analysisPath.\&loc_output.))=0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified path &analysisPath.\&loc_output. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;


	data _null_;
		length date1 $200.;
		date=today();
		time=strip(put(time(), tod8.));
		date1= catt(strip(put(date, is8601da.))," h", scan(time, 1, ":"),"m", scan(time, 2, ":"),"s", scan(time, 3, ":"));
		call symputx("bkdtc", date1);
	run;


	/*================================== Copy Source Data =================================*/
	%avCreateExportSOPCopy(sourceFolder=02_SourceData, destFolder=&loc_raw., fileType=SAS7BDAT, bkdtc=&bkdtc.);



	/*================================= Copy SDTM Programs ================================*/
	%if ^%sysfunc(fileexist(&analysisPath.\&loc_program.\SDTM)) %then %do;
		data _null_;
			length sdtm $200.;
			sdtm = dcreate("SDTM", "&analysisPath.\&loc_program.");
		run;
	%end;

	%avCreateExportSOPCopy(sourceFolder=08_Final Programs\02_CDISC\Production\01_SDTM, destFolder=&loc_program.\SDTM, fileType=SAS, bkdtc=&bkdtc.);



	/*================================== Copy SDTM Specs ==================================*/
	%if ^%sysfunc(fileexist(&analysisPath.\&loc_program.\SDTM\Specifications)) %then %do;
		data _null_;
			length tfl $200.;
			specs = dcreate("Specifications", "&analysisPath.\&loc_program.\SDTM");
		run;
	%end;

	%avCreateExportSOPCopy(sourceFolder=01_Specifications\01_SDTM, destFolder=&loc_program.\SDTM\Specifications, fileType=XLSX, bkdtc=&bkdtc.);



	/*================================= Copy ADaM Programs ================================*/
	%if ^%sysfunc(fileexist(&analysisPath.\&loc_program.\ADaM)) %then %do;
		data _null_;
			length adam $200.;
			adam = dcreate("ADaM", "&analysisPath.\&loc_program.");
		run;
	%end;

	%avCreateExportSOPCopy(sourceFolder=08_Final Programs\02_CDISC\Production\02_ADaM, destFolder=&loc_program.\ADaM, fileType=SAS, bkdtc=&bkdtc.);



	/*================================== Copy ADaM Specs ==================================*/
	%if ^%sysfunc(fileexist(&analysisPath.\&loc_program.\ADaM\Specifications)) %then %do;
		data _null_;
			length tfl $200.;
			specs = dcreate("Specifications", "&analysisPath.\&loc_program.\ADaM");
		run;
	%end;

	%avCreateExportSOPCopy(sourceFolder=01_Specifications\02_ADaM, destFolder=&loc_program.\ADaM\Specifications, fileType=XLSX, bkdtc=&bkdtc.);



	/*================================ Copy Table Programs ================================*/
	%if ^%sysfunc(fileexist(&analysisPath.\&loc_program.\Tables)) %then %do;
		data _null_;
			length tables $200.;
			tables = dcreate("Tables", "&analysisPath.\&loc_program.");
		run;
	%end;

	%avCreateExportSOPCopy(sourceFolder=08_Final Programs\03_TFL\Production\Tables, destFolder=&loc_program.\Tables, fileType=SAS, bkdtc=&bkdtc.);



	/*=============================== Copy Listing Programs ===============================*/
	%if ^%sysfunc(fileexist(&analysisPath.\&loc_program.\Listings)) %then %do;
		data _null_;
			length listings $200.;
			listings = dcreate("Listings", "&analysisPath.\&loc_program.");
		run;
	%end;

	%avCreateExportSOPCopy(sourceFolder=08_Final Programs\03_TFL\Production\Listings, destFolder=&loc_program.\Listings, fileType=SAS, bkdtc=&bkdtc.);



	/*================================ Copy Figure Programs ===============================*/
	%if ^%sysfunc(fileexist(&analysisPath.\&loc_program.\Figures)) %then %do;
		data _null_;
			length figures $200.;
			figures = dcreate("Figures", "&analysisPath.\&loc_program.");
		run;
	%end;

	%avCreateExportSOPCopy(sourceFolder=08_Final Programs\03_TFL\Production\Figures, destFolder=&loc_program.\Figures, fileType=SAS, bkdtc=&bkdtc.);


	
	/*================================= Copy SDTM Datasets ================================*/
	%if ^%sysfunc(fileexist(&analysisPath.\&loc_dataset.\SDTM)) %then %do;
		data _null_;
			length sdtm $200.;
			sdtm = dcreate("SDTM", "&analysisPath.\&loc_dataset.");
		run;
	%end;

	%avCreateExportSOPCopy(sourceFolder=03_Production\01_SDTM, destFolder=&loc_dataset.\SDTM, fileType=SAS7BDAT, bkdtc=&bkdtc.);



	/*================================= Copy ADaM Datasets ================================*/
	%if ^%sysfunc(fileexist(&analysisPath.\&loc_dataset.\ADaM)) %then %do;
		data _null_;
			length adam $200.;
			adam = dcreate("ADaM", "&analysisPath.\&loc_dataset.");
		run;
	%end;

	%avCreateExportSOPCopy(sourceFolder=03_Production\02_ADaM, destFolder=&loc_dataset.\ADaM, fileType=SAS7BDAT, bkdtc=&bkdtc.);



	/*================================= Copy TFL Datasets =================================*/
	%if ^%sysfunc(fileexist(&analysisPath.\&loc_dataset.\TFL)) %then %do;
		data _null_;
			length tfl $200.;
			tfl = dcreate("TFL", "&analysisPath.\&loc_dataset.");
		run;
	%end;

	%avCreateExportSOPCopy(sourceFolder=03_Production\03_TFL, destFolder=&loc_dataset.\TFL, fileType=SAS7BDAT, bkdtc=&bkdtc.);



	/*================================== Copy TFL Output ==================================*/
	%avCreateExportSOPCopy(sourceFolder=05_OutputDocs\01_RTF, destFolder=&loc_output., fileType=RTF, bkdtc=&bkdtc.);
	%avCreateExportSOPCopy(sourceFolder=05_OutputDocs\07_PDF, destFolder=&loc_output., fileType=PDF, bkdtc=&bkdtc.);
%mend avCreateExportSOP;


%macro avCreateExportSOPCopy(sourceFolder=, destFolder=, fileType=, bkdtc=);
	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	data AVGML.source_files;
		length list dbmem $200.;
		rc=filename("fileref", "&mspath.\&sourceFolder.");
		did = dopen("fileref");
		if did>0 then do;
			do i= 1 to dnum(did);
				list=dread(did, i);
				if scan(upcase(list),-1, ".")= "&fileType." then do;
					dbmem = scan(list, 1,".");
					output;
				end;
			end;
		end;
		rc=dclose(did);
		keep dbmem;
	run;

	proc sql noprint;
		select count(*) into: n_source trimmed from AVGML.source_files;
	quit;

	%if &n_source > 0 %then %do;
		data AVGML.dest_files;
			length list dbmem $200.;
			rc=filename("fileref", "&analysisPath.\&destFolder.");
			did = dopen("fileref");
			if did>0 then do;
				do i= 1 to dnum(did);
					list=dread(did, i);
					if scan(upcase(list),-1, ".")= "&fileType." then do;
						dbmem = scan(list, 1,".");
						output;
					end;
				end;
			end;
			rc=dclose(did);
			keep dbmem;
		run;

		proc sql noprint;
			select count(*) into: n_dest trimmed from AVGML.dest_files;
		quit;

		%if &n_dest > 0 %then %do;
			/* Create Superseded folder if it does not exist */
			%if ^%sysfunc(fileexist(&analysisPath.\&destFolder.\Superseded)) %then %do;
				data _null_;
					length superseded $200.;
					superseded = dcreate("Superseded", "&analysisPath.\&destFolder.");
				run;
			%end;

			/* Create date/time folder in Superseded folder */
			data _null_;
				length delivery $200.;
				delivery = dcreate("&bkdtc.", "&analysisPath.\&destFolder.\Superseded");
			run;

			/* Copy existing sop files to Superseded date/time folder */
			%sysexec move "&analysisPath.\&destFolder.\*.&fileType." "&analysisPath.\&destFolder.\Superseded\&bkdtc.";
		%end;

		/* Copy files to SOP folder */
		%sysexec copy "&mspath.\&sourceFolder.\*.&fileType." "&analysisPath.\&destFolder.";
	%end;
%mend avCreateExportSOPCopy;
