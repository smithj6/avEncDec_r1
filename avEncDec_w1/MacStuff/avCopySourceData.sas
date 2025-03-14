/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avCopySourceData.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Copies source data to study folder
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avCopySourceData(sourcePath=, destPath=, repPath=); 
	%if %sysevalf(%superq(sourcePath)  =, boolean) or %sysevalf(%superq(destPath)  =, boolean)%sysevalf(%superq(repPath)  =, boolean)  %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameters Source Path, Destination Path and Report Path are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(fileexist(&sourcePath.))=0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified Source Path &sourcePath. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(fileexist(&destPath.))=0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified Destination Path &destPath. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(fileexist(&repPath.))=0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified Report Path &repPath. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	data _null_;
		date=today();
		time=time();
		repdtc=strip(put(date, date9.))||"_"||compress(strip(put(time, tod5.)), '', 'kd');
		date1=strip(put(date, is8601da.))||"T"||compress(strip(put(time, tod5.)), '', 'kd');
		call symputx("bkdtc", date1);
		call symputx("repdtc", repdtc);
	run;

	options noxwait validvarname=upcase compress=yes;

	/* Assigning Library */
	libname dbpath "&sourcePath" access=readonly;
	libname progpath "&destPath";
	libname reloc "&reppath";

	/******************* Moving all the file to Superseded Location ********************/

	/*DB Data Location*/
	data dbloc;
		length list memname dbmem $200.;
		rc=filename("fileref", "&sourcePath");
		did=dopen("fileref");
		if did>0 then do;
			do i= 1 to dnum(did);
				list=dread(did, i);
				if scan(upcase(list),-1, ".")= "SAS7BDAT" then do;
					memname=upcase(cats("db1_gl_",list));
					dbmem=scan(list, 1,".");
					output;
				end;
			end;
		end;
		rc=dclose(did);
		keep memname dbmem;
	run;

	/*Source Data Location*/
	data sourceloc;
		length list memname $200.;
		rc=filename("fileref", "&destPath");
		did=dopen("fileref");
		if did>0 then do;
			do i= 1 to dnum(did);
				list=dread(did, i);
				if scan(upcase(list),-1, ".")= "SAS7BDAT" then do;
					memname=strip(upcase(list));
					output;
				end;
			end;
		end;
		rc=dclose(did);
		keep memname;
	run;

	proc sort data= sourceloc; by memname; run;
	proc sort data= dbloc; by memname; run;

	data comb;
		merge dbloc(in=a) sourceloc(in=b);
		by memname;
		if a and b;
		loc='&destPath\'||strip(memname);
		loc_s='&destPath\Superseded\&bkdtc\'||strip(lowcase(memname));
	run;

	proc sql noprint;
		select count(*) into: n trimmed from comb;
		%if &n>0 %then %do;
			select loc into: loc1-: loc&n from comb;
			select loc_s into: loc_s1-: loc_s&n from comb;
		%end;
	quit;

	%if &n>0 %then %do;
		data _null_;
			length Spec $200.;
			Spec=dcreate("&bkdtc", "&destPath\Superseded");
		run;

		%do i=1 %to &n;
			%sysexec move "&&loc&i" "&&loc_s&i";
		%end;
	%end;

	/*Copy all the file from DB Location to Program Location */

	data dbpath1;
		set dbloc;
		dbpath=cats("dbpath.", dbmem);
		progpath=cats("progpath.db1_gl_", lowcase(dbmem));
		keep dbpath  progpath;
	run;

	proc sql noprint;
		select count(*) into: n trimmed from dbpath1;
			select dbpath into: dbpath1-: dbpath&n  from dbpath1;
			select progpath into: progpath1-: progpath&n  from dbpath1;
	quit;

	%do i= 1 %to &n;
		%put &&progpath&i;

		data &&progpath&i;
			set &&dbpath&i(encoding=any);
		run;
	%end;


	/* Report part */
	data report1(rename=(memname1=memname));
		length memname1 $200;
		set sashelp.vtable;
		where upcase(libname)='PROGPATH';
		memname1=memname;
		keep memname1 nobs nvar;
	run;

	proc sql ;
		create table report2 as select
			memname as dataset, 
			cats(nvar, "/",nobs ) as DB_&repdtc 
			from report1;
	quit;

	%if %sysfunc(exist(reloc.db_report))=0 %then %do;
		data reloc.db_report;
			set report2;
		run;

		ods excel file="&repPath\DB_Report.xlsx" options(sheet_name='DB_Report');
			proc report data=reloc.db_report
					style(header)=[color=white backgroundcolor=vpab ];

			compute  after _page_/style = {just=left font_weight=bold };
				line @1 "Notes: XX/XX= Variables/Observations";
			endcomp;
			run;

		ods excel close;

		%goto exit;
	%end;

	%if %sysfunc(exist(reloc.db_report))=1 %then %do;
		proc sort data=reloc.db_report out=reloc_db_report;
			by dataset;
		run;

		proc sort data=report2;
			by dataset;
		run;
			
		data reloc.db_report;
			merge reloc_db_report(in=x) report2;
			by dataset;
			if x;
		run;

		ods excel file="&repPath\DB_Report.xlsx" options(sheet_name='DB_Report');
			proc report data=reloc.db_report
					style(header)=[color=white backgroundcolor=vpab ];

			compute  after _page_/style = {just=left font_weight=bold };;
				line @1 "Notes: XX/XX= Variables/Observations";
			endcomp;
			run;

		ods excel close;

		%goto exit;
	%end;

	%exit:;

	libname dbpath clear;
	libname progpath clear;
	libname reloc clear;

%mend avCopySourceData;

/*
%avCopySourceData(sourcePath=Z:\Global Library\MEDRIO\10 Data Mgt\03 Database\10 Data Review Doc\07 Data Exports\01 Input\Test Data\20240605\EDC Download,
				  destPath=&mspath\02_SourceData,
				  repPath=&mspath\05_OutputDocs\04_Reports); 
*/


