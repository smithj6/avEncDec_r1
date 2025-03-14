/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avUpdateSpecDataset.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Creates datasets from specifications
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :  
=======================================================================================*/

%macro avUpdateSpecDataset(lib=, domain= );
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

	%if ^%symglobl(speclib) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable speclib is not defined in global scope;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysevalf(%superq(lib)  =, boolean) or %sysevalf(%superq(domain)  =, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameters Library and Domain are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(fileexist(%bquote(&mspath\01_Specifications\&lib))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Study  folder &mspath\01_Specifications\&lib does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	options validvarname=upcase;

	data AVGML._list;
		length list_ domain dlm_ path $200.;
		rc=filename("fileref", "&mspath\01_Specifications\&lib");
		did=dopen("fileref");
		if did>0 then do;
			do i= 1 to dnum(did);
				list_=dread(did, i);
				path= catx("\", "&mspath\01_Specifications\&lib",list_) ;
				dlm_=upcase(scan(list_, -1, "."));
				domain=upcase(scan(list_, 1, "."));
				output;
			end;
		end;
		rc=dclose(did);
	run;

	data AVGML._dm1;
		set AVGML._list;
		where domain = %upcase("&domain") ;
	run;

	%let n=0;
	%let spec=;

	proc sql noprint;
		select count(domain) into: n trimmed from AVGML._dm1 where upcase(dlm_) in ("XLS" "XLSX") ;

		%if &n > 0 %then %do;
			select path into: spec trimmed from AVGML._dm1 where upcase(dlm_) in ("XLS" "XLSX");
		%end;
	quit;

	/*============================= Set datetime variables ============================*/
	data _null_;
		length date1 $200.;
		date	= today();
		time	= strip(put(time(), tod8.));
		date1	= catt(strip(put(date, YYMMDDN.)),"_h", scan(time, 1, ":"),"m", scan(time, 2, ":"),"s", scan(time, 3, ":"));

		call symputx("bkdtc", date1);
	run;


	/*======================= Create Superseded folder if required ========================*/
	%if ^%sysfunc(fileexist(&mspath.\01_Specifications\&lib.\Superseded)) %then %do;
		data _null_;
			cdisc=dcreate("Superseded", "&mspath.\01_Specifications\&lib.");
		run;
	%end;


	/*=============================== Supersede program ===============================*/
	%if &n =0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specification &domain..xlsx not found in &mspath\01_Specifications\&lib.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%else %do;
		%sysexec copy "&mspath.\01_Specifications\&lib.\&domain..xlsx" "&mspath.\01_Specifications\&lib.\Superseded\&domain. &bkdtc..xlsx";
	%end;


	/* Removed since global variable speclib already exists */
	/*
	data _null_;
		set sashelp.vslib end=last;
		where index(upcase(path), "01_SPECIFICATIONS") > 0;
		if last then call symputx('speclib', strip(libname));
	run;
	*/

	libname myxls xlsx "&Spec" ;

	proc copy in=myxls out=&speclib;
	run;

	libname myxls clear;

	data AVGML.&domain;
		set &speclib..&domain;
	run;

	/* Rename columns not correctly mapped */
	%if %sysfunc(upcase(&lib)) = 01_SDTM %then %do;
		data AVGML.domain;
			set &speclib..&domain;
		run;

		%let dsid = %sysfunc(open(AVGML.domain));
		%if %sysfunc(varnum(&dsid, VAR4)) %then %do;
			data AVGML.&domain(rename=(VAR4=CONTROLLED_TERMS_CODELIST_OR_F));
				set AVGML.&domain;
			run;
		%end;

		%if %sysfunc(varnum(&dsid, VAR12)) %then %do;
			data AVGML.&domain(rename=(var12=INCLUDE_Y_N_));
				set AVGML.&domain;
			run;
		%end;
		%let dsid_=%sysfunc(close(&dsid));

		proc copy in=AVGML out=&speclib;
			select &domain;
		run;

		/* EW 2024-10-08: for VLM */
		%if %sysfunc(exist(&speclib..&domain._vlm)) %then %do;
			data AVGML.&domain._vlm;
				set &speclib..&domain._vlm;
			run;

			data AVGML.domain_vlm;
				set &speclib..&domain._vlm;
			run;

			%let dsid = %sysfunc(open(AVGML.domain_vlm));

			%let prevnum = %sysfunc(varnum(&dsid, VARIABLE_NAME));
			%let varname = %sysfunc(varname(&dsid, %eval(&prevnum+1)));

			%if %substr(&varname,1,3) = VAR %then %do;
				data AVGML.&domain._vlm(rename=(&varname=CONTROLLED_TERMS_CODELIST_OR_F));
					set AVGML.&domain._vlm;
				run;
			%end;

			%let dsid_=%sysfunc(close(&dsid));

			proc copy in=AVGML out=&speclib;
				select &domain._vlm;
			run;
		%end;
		/* EW 2024-10-08 END */

	%end;
	%else %if %sysfunc(upcase(&lib)) = 02_ADAM %then %do;
		data AVGML.domain;
			set &speclib..&domain;
		run;

		%let dsid = %sysfunc(open(AVGML.domain));
		%if %sysfunc(varnum(&dsid, VAR5)) %then %do;
			data AVGML.&domain(rename=(VAR5=CONTROLLED_TERMS_CODELIST_OR_F));
				set AVGML.&domain;
			run;
		%end;

		%if %sysfunc(varnum(&dsid, VAR12)) %then %do;
			data AVGML.&domain(rename=(var12=INCLUDE_Y_N_));
				set AVGML.&domain;
			run;
		%end;
		%let dsid_=%sysfunc(close(&dsid));

		/* EW 2024-10-08: for VLM */
		%if %sysfunc(exist(&speclib..&domain._vlm)) %then %do;
			data AVGML.&domain._vlm;
				set &speclib..&domain._vlm;
			run;

			data AVGML.domain_vlm;
				set &speclib..&domain._vlm;
			run;

			%let dsid = %sysfunc(open(AVGML.domain_vlm));

			%let prevnum = %sysfunc(varnum(&dsid, VARIABLE));
			%let varname = %sysfunc(varname(&dsid, %eval(&prevnum+1)));

			%if %substr(&varname,1,3) = VAR %then %do;
				data AVGML.&domain._vlm(rename=(&varname=CONTROLLED_TERMS_CODELIST_OR_F));
					set AVGML.&domain._vlm;
				run;
			%end;

			%let dsid_=%sysfunc(close(&dsid));

			proc copy in=AVGML out=&speclib;
				select &domain._vlm;
			run;
		%end;
		/* EW 2024-10-08 END */


		/*============================== Add ADSL Core Variables ==============================*/
		%if &domain ^= ADSL %then %do;
			%if ^%sysfunc(exist(&speclib..adsl)) %then %do;
				%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] ADSL specification does not exist. No ADSL Core variables will be added to &domain;
				%return;
			%end;
			%else %do;
				data AVGML.av_adsl_core;
					set &speclib..adsl;
					where ADSL__CORE = 'Y' and INCLUDE_Y_N_ = 'Y' and variable__name ^= '';

					/* Remove these variables if applicable since there source should be from the domain spec not ADSL */
					if variable__name in ('STUDYID', 'USUBJID') then delete;

					source = 'Predecessor';
					origin = cats('ADSL.', variable__name);
					count2 = _n_;
				run;

				data AVGML.av_domain;
					set AVGML.&domain;
					where variable__name ^= '';

					count2 = _n_;
				run;

				proc sql;
					create table AVGML.av_adsl_domain as
					select a.*, 
					/* Sort as first variables since they are taken from domain spec not ADSL spec */
					case when variable__name in ('STUDYID', 'USUBJID') then 1 
					else 2 end as count1
					from AVGML.av_domain as a
					outer union corr select b.*, 1 as count1 from AVGML.av_adsl_core as b
					order by variable__name, variable_label, count1;
				quit;

				data AVGML.av_adsl_domain_unique;
					set AVGML.av_adsl_domain;
					by variable__name variable_label count1;
					
		
					proc sort nodupkey;
						by variable__name variable_label;
				run;

				data AVGML.av_final_spec_sorted;
					set  AVGML.av_adsl_domain_unique;

					proc sort;
						by count1 count2;
				run;

				data AVGML.av_final_spec_dropped (drop=count1 count2);
					set AVGML.av_final_spec_sorted;
				run;

				%avTrimCharVarsToMaxLength(dataIn=AVGML.av_final_spec_dropped);

				data AVGML.&domain;
					set AVGML.av_final_spec_dropped;
				run;
			%end;
		%end;
		/*============================== Add ADSL Core Variables ==============================*/

		proc copy in=AVGML out=&speclib;
			select &domain;
		run;	
	%end;
%mend avUpdateSpecDataset;
