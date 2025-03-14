/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avAssignAnalysisDuration.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Calculates duration between two specified dates
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avAssignAnalysisDuration(dataIn=, dataOut=, startDate=, endDate=, unit=, decimal=)/minoperator;
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
	%if ^%sysfunc(varnum(&dsid, &startDate)) or ^%sysfunc(varnum(&dsid, &endDate)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Both &startDate and &endDate needs to be present in &dataIn;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let dsid_=%sysfunc(close(&dsid));

		%return;
	%end;

	%if %sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, &startDate)))) ne C or %sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, &endDate)))) ne C %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &startDate or &endDate is not in expected type;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let dsid_=%sysfunc(close(&dsid));

		%return;
	%end;

	%local final_decimal decimalformat;

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

	%if &unit = DAY %then %do;
		data &dataOut;
			set &dataIn;

			if prxmatch('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[0-1])T([0-1][0-9]|2[0-3]|[1-9]):[0-5][0-9]$/oi', strip(&startDate)) and 
				prxmatch('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[0-1])T([0-1][0-9]|2[0-3]|[1-9]):[0-5][0-9]$/oi', strip(&endDate)) then do

				adurn = round((intck('min', input(&startDate, e8601dt.), input(&endDate, e8601dt.)) / 60) / 24 &final_decimal);
				aduru = 'DAYS';
			end;
			else if prxmatch('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[0-1])$/oi', strip(&startDate)) and 
				prxmatch('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[0-1])$/oi', strip(&endDate)) then do

				adurn = round(intck('day', input(&startDate, e8601da.), input(&endDate, e8601da.)) &final_decimal);
				aduru = 'DAYS';
			end;
		run;
	%end;
	%else %if &unit = MIN %then %do;
		data &dataOut;
			set &dataIn;

			if prxmatch('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[0-1])T([0-1][0-9]|2[0-3]|[1-9]):[0-5][0-9]$/oi', strip(&startDate)) and 
				prxmatch('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[0-1])T([0-1][0-9]|2[0-3]|[1-9]):[0-5][0-9]$/oi', strip(&endDate)) then do

				adurn = round((intck('sec', input(&startDate, e8601dt.), input(&endDate, e8601dt.)) / 60) &final_decimal);
				aduru = 'min';
			end;
			else if prxmatch('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[0-1])$/oi', strip(&startDate)) and 
				prxmatch('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[0-1])$/oi', strip(&endDate)) then do

				adurn = round((intck('day', input(&startDate, e8601da.), input(&endDate, e8601da.)) * 24) * 60 &final_decimal);
				aduru = 'min';
			end;
		run;
	%end;

	%let dsid_=%sysfunc(close(&dsid));

%mend avAssignAnalysisDuration;
