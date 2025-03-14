/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avInterimOutputToFinalOutput.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Map interim output dataset to final output dataset
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avInterimOutputToFinalOutput(dataIn=, dataOut=)/minoperator;
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

	%if ^%sysfunc(exist(&dataIn)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Dataset &dataIn does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	dm 'flsvlast';

	%local avSpecLib avSpecProg avDatasetFolder bkdtc dsn_ck1 avProgLoc avProgLocArc;

	data _null_;
		length lib prog $200.;
		out = upcase("&dataOut.");
		cnt = countw(out, ".");

		if cnt = 2 then do;
			lib = scan(out, 1, ".");
			prog = scan(out, 2, ".");
		end;
		else if cnt = 1 then do;
			if index(upcase(out), '_v') then lib = '&tlfv';
			else lib = '&tlfp';
			prog = out;
		end;

		if lib ^= '' then call symputx("avSpecLib", lowcase(lib));
		if prog ^= '' then call symputx("avSpecProg", lowcase(prog));
	run;

	%if ^%sysfunc(prxmatch(%str(m/^[A-Za-z_]([A-Za-z_0-9]{1,31})?$/oi), %bquote(&avSpecProg))) %then %do;
	 	%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] &avSpecProg is not a valid SAS dataset name;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	
	options noxwait;

	/*============================= Set datetime variables ============================*/
	data _null_;
		length date1 $200.;
		date	= today();
		time	= strip(put(time(), tod8.));
		date1	= catt(strip(put(date, YYMMDDN.)),"_h", scan(time, 1, ":"),"m", scan(time, 2, ":"),"s", scan(time, 3, ":"));

		call symputx("bkdtc", date1);
	run;


	/*============================= Get last saved program ============================*/
	data AVGML._vextfl;
		set sashelp.vextfl;
		where scan(upcase(xpath),-1, ".")="SAS";
	run;

	proc sort data=AVGML._vextfl; by modate ; run;

	data _null_;
		set AVGML._vextfl end=last;
		dm = strip(scan(scan(xpath,-1, "\"), 1, '.'));
		if last then call symputx("avProgLoc", xpath);
		if last then call symputx("dsn_ck1", dm);
	run;

	proc delete data=AVGML._vextfl; run;


	/*========================== Supersede last saved program =========================*/
	%if &dsn_ck1 = &avSpecProg %then %do;
		/*Program-Archive*/
		data _null_;
			path = "&avProgLoc";
			pos = findc(path, "\", -200);
			archive = substr(path, 1, pos-1)||"\Superseded"||scan(substr(path, pos), 1, ".")||" "||"&bkdtc"||"."||scan(substr(path, pos), 2, ".");	
			call symputx("avProgLocArc", archive);
		run;

		%sysexec copy "&avProgLoc" "&avProgLocArc";
	%end;
	%else %do;
		%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Program could not be copied to Superseded folder;
		%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] No backup made;
	%end;


	/*========================== Supersede last saved dataset =========================*/
	%if %index(lowcase(&avSpecLib), ov) %then %do;
		%let avDatasetFolder = 04_Validation;
	%end;
	%else %do;
		%let avDatasetFolder = 03_Production;
	%end;

	%if %sysfunc(fileexist(&mspath\&avDatasetFolder.\03_TFL\&avSpecProg..sas7bdat))%then %do;
		%if ^%sysfunc(fileexist(&mspath\&avDatasetFolder.\03_TFL\Superseded)) %then %do;
			data _null_;
				cdisc=dcreate("Superseded", "&mspath\&avDatasetFolder.\03_TFL");
			run;
		%end;

		%sysexec copy "&mspath\&avDatasetFolder.\03_TFL\&avSpecProg..sas7bdat" "&mspath\&avDatasetFolder.\03_TFL\Superseded\&avSpecProg._&bkdtc..sas7bdat";
	%end;


	/*============================= Create output dataset =============================*/
	data AVGML.&avSpecProg.;
		set &dataIn.;
	run;


	/* Assigning maximum length */
	%avTrimCharVarsToMaxLength(dataIn=AVGML.&avSpecProg.);


	/* Copy dataset to final library */
	proc copy in = AVGML
	    out = &avSpecLib.;
		select &avSpecProg.;
	run;

	/*================================= Create compare ================================*/
	%if %index(lowcase(&avSpecLib), ov) %then %do;
		%avCompare(dataOut=&avSpecLib..&avSpecProg., domain=&avSpecProg., standard=OUTPUT)

		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] avCompare macro called for &avSpecProg.;
		%put NOTE:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Check compare location for details;
	%end;
%mend avInterimOutputToFinalOutput;
