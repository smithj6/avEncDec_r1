/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avAssignAnalysisBaseline.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Derives ABLFL/BASE/BASEC/CHG using aperiod and treatment start dates
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avAssignMaxPeriodDate(dataIn=, counter=);
	data AVGML.&dataIn;
		set AVGML.&dataIn;

		%avExecuteIfVarExists(dataIn=AVGML.&dataIn, varIn=tr&counter.sdtm) 
			avrefsdtm = tr&counter.sdtm;

		%avExecuteIfVarExists(dataIn=AVGML.&dataIn, varIn=tr&counter.sdt) 
			avrefsdt = tr&counter.sdt;
	run;
%mend avAssignMaxPeriodDate;

%macro avAssignAnalysisBaseline(dataIn=, dataOut=, byVar=, dtype=N)/minoperator;
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML is study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(exist(&dataIn)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Dataset &dataIn does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(prxmatch(%str(m/^[A-Za-z_]([A-Za-z_0-9]{1,31})?$/oi), %bquote(&dataOut))) %then %do;
	 	%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] &dataOut is not a valid SAS dataset name;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysevalf(%superq(byVar) =, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameter byVar is required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%eval(%qupcase(%bquote(&dtype)) in Y N) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid selection for macro parameter type (%bquote(&dtype)). Valid selections are Y or N and are case insensitive;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%let dsid = %sysfunc(open(&dataIn));

	%if ^%sysfunc(varnum(&dsid, AVAL)) or ^%sysfunc(varnum(&dsid, AVALC)) or ^%sysfunc(varnum(&dsid, ADT)) or ^%sysfunc(varnum(&dsid, ADTM)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variables AVAL, AVALC, ADT and ADTM are required in &dataIn;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let dsid_=%sysfunc(close(&dsid));
		%return;
	%end;

	%if ^%sysfunc(varnum(&dsid, tr01sdt)) or ^%sysfunc(varnum(&dsid, tr01sdtm)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] All ADSL treatment variables (TRXXSDT, TRXXSDTM etc.) as identified by APERIOD needs to be present in &dataIn;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] If APERIOD is not applicable TR01SDT, TR01SDTM needs to be present in &dataIn;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let dsid_=%sysfunc(close(&dsid));

		%return;
	%end;

	%if &dtype = Y %then %do;
		%if ^%sysfunc(varnum(&dsid, DTYPE)) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable DTYPE not present in &dataIn when parameter dtype equals Y;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let dsid_=%sysfunc(close(&dsid));
			%return;
		%end;
	%end;

	%if %sysfunc(varnum(&dsid, ABLFL)) or %sysfunc(varnum(&dsid, BASE)) or %sysfunc(varnum(&dsid, BASEC)) or %sysfunc(varnum(&dsid, CHG)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] The variables ABLFL, BASE, BASEC or CHG already present in &dataIn;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let dsid_=%sysfunc(close(&dsid));
		%return;
	%end;

	%let byVarCount = %sysfunc(countw(&byVar, #));
	%do i=1 %to &byVarCount;
		%local tempByVar;
		%let tempByVar = %scan(&byVar, &i, #);

		%if ^%sysfunc(varnum(&dsid, &tempByVar)) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &tempByVar not present in &dataIn;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let dsid_=%sysfunc(close(&dsid));

			%let dsid_=%sysfunc(close(&dsid));
			%return;
		%end;
	%end;

	%let dsid_=%sysfunc(close(&dsid));


	%local byVarReplaced avMaxPeriod lastByVar;

	%let byVarReplaced = %sysfunc(tranwrd(&byVar, #, ));
	
	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	/*============================ Get highest assigned APERIOD ===========================*/
	data AVGML.av_aperiod;
		set &dataIn.;

		aperiod_ = 1;
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=aperiod) 
			aperiod_ = aperiod;
	run;

	proc sql noprint;
		select coalesce(max(a.aperiod_), 1) into: avMaxPeriod trimmed from AVGML.av_aperiod as a;
	quit;
	/*============================ Get highest assigned APERIOD ===========================*/


	/*============================= Initialise reference dates ============================*/
	%if &dtype = Y %then %do;
		data AVGML.av_start;
			set AVGML.av_aperiod;
			format avrefsdtm adtm_ e8601dt. avrefsdt adt_ e8601da.;
			retain adtm_ adt_;

			avrefsdtm = .;
			avrefsdt = .;

			if adtm ^= . then adtm_ = adtm;
			if adt ^= . then adt_ = adt;
		run;
	%end;
	%else %do;
		data AVGML.av_start;
			set AVGML.av_aperiod;
			format avrefsdtm adtm_ e8601dt. avrefsdt adt_ e8601da.;

			avrefsdtm = .;
			avrefsdt = .;

			if adtm ^= . then adtm_ = adtm;
			if adt ^= . then adt_ = adt;
		run;
	%end;
	/*============================= Initialise reference dates ============================*/


	/*======================== Set reference date for each APERIOD ========================*/
	data _null_;
		do i=1 by 1 while(i =< &avMaxPeriod.);
			call execute('%avAssignMaxPeriodDate(dataIn=av_start, counter=' || strip(put(i, z2.)) || ')');
		end;
	run;
	/*======================== Set reference date for each APERIOD ========================*/


	/*=========================== Get last by variable specified ==========================*/
	data _null_;
		by_variables = "&byVarReplaced";

		do i=1 by 1 while(scan(by_variables, i, ' ') ^= ' ');
			by_variable = scan(by_variables, i, ' ');
		end;

		call symputx("lastByVar", by_variable);
	run;
	/*=========================== Get last by variable specified ==========================*/


	data AVGML.av_pre_post;
		set AVGML.av_start;

		if adtm_ ^= . then basefl = ifn(avrefsdtm > adtm_, 1, 2);
	    else if adt_ ^= . then basefl = ifn(avrefsdt > adt_, 1, 2);

		proc sort;
			by &byVarReplaced basefl adtm_ adt_;
	run;

	data AVGML.av_base;
		set AVGML.av_pre_post;
		by &byVarReplaced basefl adtm_ adt_;
	 
		if last.basefl and basefl = 1 then do;
			ablfl = 'Y';
		end;
	run;

	 
	data AVGML.av_base_retain;
		set AVGML.av_base;
		by &byVarReplaced basefl;
		length basec $200.;
		retain base basec;

		if first.&lastByVar then do;
			base = .;
			basec = '';
		end;
	  
		if ablfl = 'Y' then do;
			base = aval;
			basec = avalc;
		end;
	 
		proc sort;
			by &byVarReplaced basefl;
	run;

	data &dataOut (drop=adtm_ adt_ aperiod_);
		set AVGML.av_base_retain;
		length basetype $200.;

		if nmiss(aval, base) = 0 and ablfl ^= 'Y' then chg = aval - base;

		/* Assigned BASETYPE to temp APERIOD assigned for deriving baseline.*/
		/* BASETYPE is however assumed not to be assigned when APERIOD is not applicable */
		basetype = catx(' ', 'Period', put(aperiod_, best.));

		/* Assigns BASETYPE to APERIODC in APERIODC exists */
		%avExecuteIfVarExists(dataIn=AVGML.av_base_retain, varIn=aperiodc)
			basetype = strip(aperiodc);

		proc sort;
			by &byVarReplaced;
	run;
%mend avAssignAnalysisBaseline;
