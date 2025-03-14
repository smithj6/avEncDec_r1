/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avAssignAnalysisRelativeTime.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Calculates relative time between two specified dates
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/
%macro avAssignMaxPeriodDate(dataIn=, counter=);
	data AVGML.&dataIn;
		set AVGML.&dataIn;

		avrefsdtm = tr&counter.sdtm;
		avrefsdt = tr&counter.sdt;
	run;
%mend avAssignMaxPeriodDate;

%macro avAssignAnalysisRelativeTime(dataIn=, dataOut=, date=, unit=, decimal=)/minoperator;
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

	%if %sysevalf(%superq(unit)  =, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameter Unit is required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%eval(%qupcase(%bquote(&unit)) in DAY MIN) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid selection for macro parameter unit (%bquote(&unit)). Valid selections are DAY or MIN and are case insensitive;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%let dsid = %sysfunc(open(&dataIn));
	%if ^%sysfunc(varnum(&dsid, &date)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] &date needs to be present in &dataIn;
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

	%if %sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, &date)))) ne C %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &date is not in expected type;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let dsid_=%sysfunc(close(&dsid));

		%return;
	%end;

	%local final_decimal decimalformat avMaxPeriod;

	%if %sysevalf(%superq(decimal)  =, boolean) %then %do;
		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameter Decimal not specified, defaulting to 2 decimals;
		
		%let final_decimal = ,0.01;
	%end;
	%else %if &decimal = 0 %then %do;
		%let final_decimal = ;
	%end;
	%else %do;
		%let decimalformat = %sysfunc(cats(z, &decimal)).;
		%put &decimalformat;

		data _null_;
			length decimal $50.;
			decimal = cats(',0.', put(1, &decimalformat)); output;
			call symputx("final_decimal", decimal);
		run;
	%end;

	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	/*============================ Get highest assigned APERIOD ===========================*/
	data AVGML.av_aperiod;
		set &dataIn.;
		format avrefsdtm e8601dt. avrefsdt e8601da.;

		avrefsdtm = .;
		avrefsdt = .;

		aperiod_ = 1;
		%avExecuteIfVarExists(dataIn=&dataIn., varIn=aperiod) 
			aperiod_ = aperiod;
	run;

	proc sql noprint;
		select coalesce(max(a.aperiod_), 1) into: avMaxPeriod trimmed from AVGML.av_aperiod as a;
	quit;
	/*============================ Get highest assigned APERIOD ===========================*/


	/*======================== Set reference date for each APERIOD ========================*/
	data _null_;
		do i=1 by 1 while(i =< &avMaxPeriod.);
			call execute('%avAssignMaxPeriodDate(dataIn=av_aperiod, counter=' || strip(put(i, z2.)) || ')');
		end;
	run;
	/*======================== Set reference date for each APERIOD ========================*/

	%if &unit = DAY %then %do;
		data &dataOut (drop=aperiod_ avrefsdtm avrefsdt av_dtm av_dt);
			set AVGML.av_aperiod;
			format av_dtm e8601dt. av_dt e8601da.;

			if prxmatch('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[0-1])T([0-1][0-9]|2[0-3]|[1-9]):[0-5][0-9]$/oi', strip(&date)) then do;
				av_dtm = input(&date, e8601dt.);
				av_dt = input(substr(&date, 1, 10), e8601da.);
			end;
			else if prxmatch('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[0-1])$/oi', strip(&date)) then do;
				av_dt = input(&date, e8601da.);
			end;

			if av_dtm ^= . and avrefsdtm ^= . then do;
				areltm = round((intck('min', avrefsdtm, av_dtm, 'continuous') /60) / 24 &final_decimal);
				areltmu = 'DAYS';

			end;
			else if av_dt ^= . and avrefsdt ^= . then do;
				areltm = round((intck('day', avrefsdt, av_dt, 'continuous') ) &final_decimal);
				areltmu = 'DAYS';
			end;
		run;
	%end;
	%else %if &unit = MIN %then %do;
		data &dataOut (drop=aperiod_ avrefsdtm avrefsdt av_dtm av_dt);
			set AVGML.av_aperiod;
			format av_dtm e8601dt. av_dt e8601da.;

			if prxmatch('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[0-1])T([0-1][0-9]|2[0-3]|[1-9]):[0-5][0-9]$/oi', strip(&date)) then do;
					av_dtm = input(&date, e8601dt.);
					av_dt = input(substr(&date, 1, 10), e8601da.);
			end;
			else if prxmatch('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[0-1])$/oi', strip(&date)) then do;
					av_dt = input(&date, e8601da.);
			end;

			if av_dtm ^= . and avrefsdtm ^= . then do;
				areltm = round((intck('sec', avrefsdtm, av_dtm, 'continuous') /60) / 24 &final_decimal);
				areltmu = 'min';
			end;
			else if av_dt ^= . and avrefsdt ^= . then do;
				areltm = round((intck('day', avrefsdt, av_dt, 'continuous') * 24) * 60 &final_decimal);
				areltmu = 'min';
			end;
		run;
	%end;

	%let dsid_=%sysfunc(close(&dsid));
%mend avAssignAnalysisRelativeTime;
