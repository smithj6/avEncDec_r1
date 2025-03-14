/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avSupersedeLog.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Moves the log file for a specified domain to the superseded folder before the new log is created
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avSupersedeLog(lib=, domain=)/minoperator;
	%if ^%symglobl(mspath) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable mspath is not defined in global scope;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%eval(%bquote(&lib) in 01_SDTM 02_ADaM Tables Listings Figures) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid selection for macro parameter library (%bquote(&lib)). Valid selections are 01_SDTM, 02_ADaM, Tables, Listings or Figures and are case insensitive;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysevalf(%superq(lib)  =, boolean) or %sysevalf(%superq(domain)  =, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameters library and domain are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%local domain_low side type supersede_name bkdtc;

	%let domain_low = %sysfunc(lowcase(&domain));

	%if %sysfunc(index(&domain_low, _v)) %then %do;
		%let side = Validation;
	%end;
	%else %do;
		%let side = Production;
	%end;

	%if %eval(%bquote(&lib) in 01_SDTM 02_ADaM) %then %do;
		%let type = 02_CDISC;
	%end;
	%else %if %eval(%bquote(&lib) in Tables Listings Figures) %then %do;
		%let type = 03_TFL;
	%end;
	
	%if ^%sysfunc(fileexist(&mspath\08_Final Programs\&type\&side\&lib\Logs)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Log path &mspath\08_Final Programs\&type\&side\&lib\Logs does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(fileexist(&mspath\08_Final Programs\&type\&side\&lib\Logs\Superseded)) %then %do;
		data _null_;
			cdisc=dcreate("Superseded", "&mspath\08_Final Programs\&type\&side\&lib\Logs");
		run;
	%end;

	data _null_;
		length date1 $200.;
		date=today();
		time=strip(put(time(), tod8.));
		date1= catt(strip(put(date, YYMMDDN.))," h", scan(time, 1, ":"),"m", scan(time, 2, ":"),"s", scan(time, 3, ":"));
		call symputx("bkdtc", date1);
	run;

	%let supersede_name = &domain_low &bkdtc;

	%if %sysfunc(fileexist(&mspath\08_Final Programs\&type\&side\&lib\Logs\&domain_low..log)) %then %do;
		%sysexec copy "&mspath\08_Final Programs\&type\&side\&lib\Logs\&domain_low..log" "&mspath\08_Final Programs\&type\&side\&lib\Logs\Superseded\&supersede_name..log";

		%if ^%sysfunc(fileexist(&mspath\08_Final Programs\&type\&side\&lib\Logs\Superseded\&supersede_name..log)) %then %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Log &supersede_name..log not superseded successfully;
		%end;
	%end;
%mend avSupersedeLog;
