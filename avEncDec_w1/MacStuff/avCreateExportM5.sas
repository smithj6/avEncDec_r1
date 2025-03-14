/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avCreateExportM5.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Create CDISC delivery in m5 format and copy all required output where applicable
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avCreateExportM5(repPath=);
	%if ^%symglobl(studyno) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable studyno is not defined in global scope;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

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

	%if %sysevalf(%superq(repPath)  =, boolean)  %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameter repPath is required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(fileexist(&repPath.))=0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified path &repPath. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%local bkdtc;

	data _null_;
		length date1 $200.;
		date=today();
		time=strip(put(time(), tod8.));
		date1= catx('_', 'CDISC', "&studyno.", catt(strip(put(date, is8601da.))," h", scan(time, 1, ":"),"m", scan(time, 2, ":"),"s", scan(time, 3, ":")));
		call symputx("bkdtc", date1);
	run;

	%if %sysfunc(fileexist(&repPath.\&bkdtc.))^=0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Output path &repPath.\&bkdtc. already exists;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/*============================= Creare m5 folder structure ============================*/
	data _null_;
		length delivery m5 datasets prot analysis adam datasets programs tabulations sdtm $200.;
		delivery = dcreate("&bkdtc.", "&repPath.");
			m5 = dcreate("m5", "&repPath.\&bkdtc.");
				datasets = dcreate("datasets", "&repPath.\&bkdtc.\m5");
					prot = dcreate("&studyno.", "&repPath.\&bkdtc.\m5\datasets");
						analysis = dcreate("analysis", "&repPath.\&bkdtc.\m5\datasets\&studyno.");
							adam = dcreate("adam", "&repPath.\&bkdtc.\m5\datasets\&studyno.\analysis");
								datasets = dcreate("datasets", "&repPath.\&bkdtc.\m5\datasets\&studyno.\analysis\adam");
								programs = dcreate("programs", "&repPath.\&bkdtc.\m5\datasets\&studyno.\analysis\adam");

						tabulations	= dcreate("tabulations", "&repPath.\&bkdtc.\m5\datasets\&studyno.");
							sdtm = dcreate("sdtm", "&repPath.\&bkdtc.\m5\datasets\&studyno.\tabulations");
	run;


	/*============================== Copy SDTM related output =============================*/
	%if %sysfunc(fileexist(&repPath.\&bkdtc.\m5\datasets\&studyno.\tabulations\sdtm))=0 %then %do;
		%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] SDTM path &repPath.\&bkdtc.\m5\datasets\&studyno.\tabulations\sdtm not created successfully;
		%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] No SDTM output will be copied to this location;
		%goto ADAM;
	%end;
	%else %do;
		/* Copy aCRF.pdf */
		%if %sysfunc(fileexist(&mspath.\01_Specifications\04_SDTM_aCRF\aCRF.pdf))^=0 %then %do;
			%sysexec copy "&mspath.\01_Specifications\04_SDTM_aCRF\aCRF.pdf" "&repPath.\&bkdtc.\m5\datasets\&studyno.\tabulations\sdtm";
		%end;
		%else %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No aCRF.pdf file found in &mspath.\01_Specifications\04_SDTM_aCRF;
			%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] aCRF.pdf not copied;
		%end;


		/* Copy csdrg.docx */
		%if %sysfunc(fileexist(&mspath.\06_Define\SDTM\OUTPUT\csdrg.docx))^=0 %then %do;
			%sysexec copy "&mspath.\06_Define\SDTM\OUTPUT\csdrg.docx" "&repPath.\&bkdtc.\m5\datasets\&studyno.\tabulations\sdtm";
		%end;
		%else %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No csdrg.docx file found in &mspath.\06_Define\SDTM\OUTPUT;
			%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] csdrg.docx not copied;
		%end;


		/* Copy csdrg.pdf */
		%if %sysfunc(fileexist(&mspath.\06_Define\SDTM\OUTPUT\csdrg.pdf))^=0 %then %do;
			%sysexec copy "&mspath.\06_Define\SDTM\OUTPUT\csdrg.pdf" "&repPath.\&bkdtc.\m5\datasets\&studyno.\tabulations\sdtm";
		%end;
		%else %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No csdrg.pdf file found in &mspath.\06_Define\SDTM\OUTPUT;
			%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] csdrg.pdf not copied;
		%end;


		/* Copy define.xml */
		%if %sysfunc(fileexist(&mspath.\06_Define\SDTM\OUTPUT\define.xml))^=0 %then %do;
			%sysexec copy "&mspath.\06_Define\SDTM\OUTPUT\define.xml" "&repPath.\&bkdtc.\m5\datasets\&studyno.\tabulations\sdtm";
			%sysexec copy "&mspath.\06_Define\SDTM\OUTPUT\*.xsl*" "&repPath.\&bkdtc.\m5\datasets\&studyno.\tabulations\sdtm";
		%end;
		%else %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No define.xml file found in &mspath.\06_Define\SDTM\OUTPUT;
			%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] define.xml not copied;
		%end;


		/* Copy all xpt SDTM files */
		%sysexec copy "&mspath.\03_Production\01_SDTM\01_XPT\*.xpt*" "&repPath.\&bkdtc.\m5\datasets\&studyno.\tabulations\sdtm";
	%end;


	%ADAM:
	/*============================== Copy ADaM related output =============================*/
	%if %sysfunc(fileexist(&repPath.\&bkdtc.\m5\datasets\&studyno.\analysis\adam\datasets))=0 %then %do;
		%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] ADaM path &repPath.\&bkdtc.\m5\datasets\&studyno.\analysis\adam\datasets not created successfully;
		%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] No ADaM output will be copied to this location;
		%goto PROGRAM;
	%end;
	%else %do;
		/* Copy adrg.docx */
		%if %sysfunc(fileexist(&mspath.\06_Define\ADAM\OUTPUT\adrg.docx))^=0 %then %do;
			%sysexec copy "&mspath.\06_Define\ADAM\OUTPUT\adrg.docx" "&repPath.\&bkdtc.\m5\datasets\&studyno.\analysis\adam\datasets";
		%end;
		%else %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No adrg.docx file found in &mspath.\06_Define\ADAM\OUTPUT;
			%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] adrg.docx not copied;
		%end;

		/* Copy adrg.pdf */
		%if %sysfunc(fileexist(&mspath.\06_Define\ADAM\OUTPUT\adrg.pdf))^=0 %then %do;
			%sysexec copy "&mspath.\06_Define\ADAM\OUTPUT\adrg.pdf" "&repPath.\&bkdtc.\m5\datasets\&studyno.\analysis\adam\datasets";
		%end;
		%else %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No adrg.pdf file found in &mspath.\06_Define\ADAM\OUTPUT;
			%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] adrg.pdf not copied;
		%end;


		/* Copy define.xml */
		%if %sysfunc(fileexist(&mspath.\06_Define\ADAM\OUTPUT\define.xml))^=0 %then %do;
			%sysexec copy "&mspath.\06_Define\ADAM\OUTPUT\define.xml" "&repPath.\&bkdtc.\m5\datasets\&studyno.\adam\datasets";
			%sysexec copy "&mspath.\06_Define\ADAM\OUTPUT\*.xsl*" "&repPath.\&bkdtc.\m5\datasets\&studyno.\adam\datasets";
		%end;
		%else %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No define.xml file found in &mspath.\06_Define\ADAM\OUTPUT;
			%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] define.xml not copied;
		%end;


		/* Copy all xpt ADaM files */
		%sysexec copy "&mspath.\03_Production\02_ADaM\01_XPT\*.xpt*" "&repPath.\&bkdtc.\m5\datasets\&studyno.\analysis\adam\datasets";
	%end;


	%PROGRAM:
	/*============================ Copy ADaM related programs =============================*/
	%if %sysfunc(fileexist(&repPath.\&bkdtc.\m5\datasets\&studyno.\analysis\adam\programs))=0 %then %do;
		%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] ADaM path &repPath.\&bkdtc.\m5\datasets\&studyno.\analysis\adam\programs not created successfully;
		%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] No ADaM output will be copied to this location;
		%return;
	%end;
	%else %do;
		/* Copy all ADaM sas programs */
		%sysexec copy "&mspath.\08_Final Programs\02_CDISC\Production\02_ADaM\*.sas*" "&repPath.\&bkdtc.\m5\datasets\&studyno.\analysis\adam\programs";

		/* Copy all Listing sas programs */
		%sysexec copy "&mspath.\08_Final Programs\\03_TFL\Production\Listings\*.sas*" "&repPath.\&bkdtc.\m5\datasets\&studyno.\analysis\adam\programs";

		/* Copy all Table sas programs */
		%sysexec copy "&mspath.\08_Final Programs\\03_TFL\Production\Tables\*.sas*" "&repPath.\&bkdtc.\m5\datasets\&studyno.\analysis\adam\programs";

		/* Copy all Figure sas programs */
		%sysexec copy "&mspath.\08_Final Programs\\03_TFL\Production\Figures\*.sas*" "&repPath.\&bkdtc.\m5\datasets\&studyno.\analysis\adam\programs";


		/*============================== Rename sas files to txt ==============================*/
		%local program_path program_count single_program full_program_name full_program_name_new;

		%let program_path = &repPath.\&bkdtc.\m5\datasets\&studyno.\analysis\adam\programs;

		proc datasets library=avgml memtype=data kill nolist nowarn;
		quit;

		data AVGML.av_all_programs (keep=pname);
			length pname $200.;
			rc = filename("mydir","&program_path");
			did = dopen("mydir");
			if did > 0
			then do i = 1 to dnum(did);
			  pname = dread(did,i);
			  output;
			end;
			rc = dclose(did);
		run;

		data AVGML.av_all_programs_count;
			set AVGML.av_all_programs;

			pname = scan(pname, 1, '.');
			count = _n_;
		run;

		proc sql noprint;
			select count(*) into :program_count from AVGML.av_all_programs_count;
		quit;

		%if &program_count. = 0 %then %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No sas programs found in &program_path.;
			%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] No sas programs renamed;
			%goto skip;
		%end;


		%let i = 1;
		%begin:
			proc sql noprint;
				select pname into :single_program from AVGML.av_all_programs_count where count = &i;
			quit;

			%let full_program_name = &program_path\%sysfunc(compress(&single_program.)).sas;
			%let full_program_name_new = %sysfunc(compress(&single_program.)).txt;

			%sysexec powershell -Command "Rename-Item -Path %str(%')&full_program_name.%str(%') -NewName %str(%')&full_program_name_new.%str(%')";
		
			%let i = %eval(&i + 1);
			%if &i <= &program_count %then %goto begin;

		%skip:
	%end;

%mend avCreateExportM5;

/*
%avCreateExportM5(repPath=&mspath\05_OutputDocs\04_Reports);
*/
