/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avAssignAnalysisDatesFromSDTM.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Assigns analysis dates from SDTM date variables in correct date formats
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avAssignAnalysisDatesFromSDTM(dataIn=, dataOut=, domain=);
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

	%if %sysevalf(%superq(domain)  =, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameter Domain is required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%let dsid = %sysfunc(open(&dataIn));
	%if ^%sysfunc(varnum(&dsid, &domain.stdtc)) and ^%sysfunc(varnum(&dsid, &domain.endtc)) and ^%sysfunc(varnum(&dsid, &domain.dtc)) %then %do;
		%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No date variables &domain.stdtc or &domain.endtc or &domain.dtc are present in dataset &dataIn;
		%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Output dataset &dataOut created with no changes;
		%let dsid_=%sysfunc(close(&dsid));

		data &dataOut;
			set &dataIn;
		run;

		%return;
	%end;

	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	data AVGML.avTempDate;
		set &dataIn;
	run;

	%if %sysfunc(varnum(&dsid, &domain.stdtc))%then %do;
		%if %sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, &domain.stdtc)))) ne C %then %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &domain.stdtc is not in expected type. Expected type is Character;
			%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Analysis date variables for &domain.stdtc will not be created;
		%end;
		%else %do;
			%if %sysfunc(varnum(&dsid, astdtm)) or %sysfunc(varnum(&dsid, astdt)) or %sysfunc(varnum(&dsid, asttm)) %then %do;
				%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Analysis date variables for &domain.stdtc already exists;
				%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Analysis date variables for &domain.stdtc will not be created;
			%end;
			%else %do;
				data AVGML.avTempDate;			
					set AVGML.avTempDate;
					format astdtm e8601dt. astdt e8601da. asttm time5.;

					if prxmatch('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[0-1])$/oi', strip(&domain.stdtc)) then do;
						astdt = input(substr(&domain.stdtc, 1, 10), e8601da.);
					end;
					else if prxmatch('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[0-1])T([0-1][0-9]|2[0-3]|[1-9]):[0-5][0-9]$/oi', strip(&domain.stdtc)) then do;
						astdt = input(substr(&domain.stdtc, 1, 10), e8601da.);
						astdtm = input(&domain.stdtc, e8601dt.);
						asttm = timepart(astdtm);
					end;
				run;
			%end;
		%end;
	%end;

	%if %sysfunc(varnum(&dsid, &domain.endtc))%then %do;
		%if %sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, &domain.endtc)))) ne C %then %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &domain.endtc is not in expected type. Expected type is Character;
			%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Analysis date variables for &domain.endtc will not be created;
		%end;
		%else %do;
			%if %sysfunc(varnum(&dsid, aendtm)) or %sysfunc(varnum(&dsid, aendt)) or %sysfunc(varnum(&dsid, aentm)) %then %do;
				%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Analysis date variables for &domain.endtc already exists;
				%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Analysis date variables for &domain.endtc will not be created;
			%end;
			%else %do;
				data AVGML.avTempDate;
					set AVGML.avTempDate;
					format aendtm e8601dt. aendt e8601da. aentm time5.;

					if prxmatch('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[0-1])$/oi', strip(&domain.endtc)) then do;
						aendt = input(substr(&domain.endtc, 1, 10), e8601da.);
					end;
					else if prxmatch('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[0-1])T([0-1][0-9]|2[0-3]|[1-9]):[0-5][0-9]$/oi', strip(&domain.endtc)) then do;
						aendt = input(substr(&domain.endtc, 1, 10), e8601da.);
						aendtm = input(&domain.endtc, e8601dt.);
						aentm = timepart(aendtm);
					end;
				run;
			%end;
		%end;
	%end;

	%if %sysfunc(varnum(&dsid, &domain.dtc)) %then %do;
		%if %sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, &domain.dtc)))) ne C %then %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &domain.dtc is not in expected type. Expected type is Character;
			%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Analysis date variables for &domain.dtc will not be created;
		%end;
		%else %do;
			%if %sysfunc(varnum(&dsid, adtm)) or %sysfunc(varnum(&dsid, adt)) or %sysfunc(varnum(&dsid, atm)) %then %do;
				%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Analysis date variables for &domain.dtc already exists;
				%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Analysis date variables for &domain.dtc will not be created;
			%end;
			%else %do;
				data AVGML.avTempDate;
					set AVGML.avTempDate;
					format adtm e8601dt. adt e8601da. atm time5.;

					if prxmatch('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[0-1])$/oi', strip(&domain.dtc)) then do;
						adt = input(substr(&domain.dtc, 1, 10), e8601da.);
					end;
					else if prxmatch('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[0-1])T([0-1][0-9]|2[0-3]|[1-9]):[0-5][0-9]$/oi', strip(&domain.dtc)) then do;
						adt = input(substr(&domain.dtc, 1, 10), e8601da.);
						adtm = input(&domain.dtc, e8601dt.);
						atm = timepart(adtm);
					end;
				run;
			%end;
		%end;
	%end;

	%let dsid_=%sysfunc(close(&dsid));

	data &dataOut;
		set AVGML.avTempDate;
	run;
%mend avAssignAnalysisDatesFromSDTM;
