/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avGeneralDateTimeToIso8601.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Convert EDC full/partial date/time into ISO8601. At least worked on both Medrio and Rave.
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  : Rename macro and parameters to align with standard. Added exception handling. 
Date changed     :            
By				 :                   
=======================================================================================*/

%macro avGeneralDateTimeToIso8601(dataIn=		/* Mandatory: Dataset in */
								, dataOut= 		/* Mandatory: Dataset out */
								, varInDate=	/* Mandatory: Variable in (Date) */
								, varInTime= 	/* Optional:  Variable in (Time) */
								, varOut=		/* Mandatory: Variable out (--DTC) */
								, format=		/* Mandatory: Format of varInDate and varInTime separated by |, e.g. DD-MMM-YYYY|HHMM */
);

	/* Exception handling: Mandatory Parameters */
	%if %sysevalf(%superq(dataIn)=,  boolean) or 
		%sysevalf(%superq(dataOut)=, boolean) or  
		%sysevalf(%superq(varInDate)=,boolean) or  
		%sysevalf(%superq(varOut)=, boolean) or 
		%sysevalf(%superq(format)=,boolean)  %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] parameters dataIn, dataOut, varInDate, varOut and format are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/* Exception handling: AVGML Lib */
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML is study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/* Exception handling: Existence of Input Datasets */
	%if ^%sysfunc(exist(%bquote(&dataIn))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] data %bquote(&dataIn) does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	
	/* Exception handling: Name format of output dataset */
	%if %sysfunc(prxmatch(%str(m/^[A-Za-z_][A-Za-z_0-9]{1,7}[.][A-Za-z_]([A-Za-z_0-9]{1,31})?$/oi), %bquote(&dataOut))) %then %do;
		%let libref=%scan(&dataOut, 1, .);
		%if %sysfunc(libref(&libref)) %then %do;
	 		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] dataOut is a valid SAS 2 level name, however libref &libref is not assigned!;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;
	%end;
	%else %if ^%sysfunc(prxmatch(%str(m/^[A-Za-z_]([A-Za-z_0-9]{1,31})?$/oi), %bquote(&dataOut))) %then %do;
	 	%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] dataOut is not a valid SAS dataset name!;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/* Exception handling: Existence of variables - &varInDate */
	%if "%avExecuteIfVarExists(dataIn=&dataIn,varIn=&varInDate)" = "*" %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &varInDate does not exist in Source Dataset &dataIn;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Check parameter varInDate in &sysmacroname.;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
		%return;
	%end;

	/* Exception handling: Existence of variables - &varInTime (if provided) */
	%if ^%sysevalf(%superq(varInTime)=, boolean) %then %do;
		%if "%avExecuteIfVarExists(dataIn=&dataIn,varIn=&varInTime)" = "*" %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &varInTime does not exist in Source Dataset &dataIn;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Check parameter varInTime in &sysmacroname.;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
			%return;
		%end;
	%end;

	/* Exception handling: Existed &varOut */
	%if "%avExecuteIfVarExists(dataIn=&dataIn,varIn=&varOut)" = "" %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &varOut already existed in Source Dataset &dataIn;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
		%return;
	%end;

	/* Exception handling: Validity of &format */
	%let dateFormat = %scan(&format,1,|);
	%let timeFormat = %sysfunc(compress(%scan(&format,2,|),,ka));
	%if "%sysfunc(compress(&dateFormat,%str(YMD-/ ),i))" ne "" %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid parameter &format. Valid format: <date> or <date>|<time>;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Valid date can only consist of the following characters: Y, M, D, -, /, <space>;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
		%return;
	%end;
	%if "%sysfunc(compress(&timeFormat,%str(HMS),i))" ne "" %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid parameter &format. Valid format: <date> or <date>|<time>;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Valid time can be either: HH:MM, HH:MM:SS (both valid if without colon);
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
		%return;
	%end;
	%if ^%sysevalf(%superq(varInTime)=, boolean) and %sysevalf(%superq(timeFormat)=, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameter 'varInTime' provided but no time format detected in parameter 'format';
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Valid format if time present: <date>|<time>;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Check parameter varInTime and format in &sysmacroname.;
		%put ERROR:4/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
		%return;
	%end;



	/*** Start of main ***/


	/** 
	Get date and time type. 
	Get all variable names in dataIn for keep 
	*/
	%let tm_ty=; %let dtc_ty=;
	proc sql noprint;
		select name into: keepVarDataIn separated by "," from sashelp.vcolumn
			where upcase(libname)="WORK" and upcase(memname)=%upcase("&dataIn");
		select upcase(type) into: dtc_ty  from sashelp.vcolumn
			where upcase(libname)="WORK" and upcase(memname)=%upcase("&dataIn") and  upcase(name)=%upcase("&varInDate");
	%if &varInTime ^= %then %do;
		select upcase(type) into: tm_ty from sashelp.vcolumn
			where upcase(libname)="WORK" and upcase(memname)=%upcase("&dataIn") and  upcase(name)=%upcase("&varInTime");
	%end;
	quit;


	/* Format of month name */
	proc format;
		value $ mon
		"JAN" , "JANUARY" ,		"1" , "01"	="01"
		"FEB" , "FEBRUARY" ,	"2" , "02"	="02"
		"MAR" , "MARCH" , 		"3" , "03"	="03"
		"APR" , "APRIL" , 		"4" , "04"	="04"
		"MAY" , 				"5" , "05"	="05"
		"JUN" , "JUNE" , 		"6" , "06"	="06"
		"JUL" , "JULY" , 		"7" , "07"	="07"
		"AUG" , "AUGUST" , 		"8" , "08"	="08"
		"SEP" , "SEPTEMBER" ,	"9" , "09"	="09"
		"OCT" , "OCTOBER" ,  	"10"		="10"
		"NOV" , "NOVEMBER" , 	"11"		="11"
		"DEC" , "DECEMBER" ,	"12"		="12"
		other= " ";
	run;


	/** 
	Get positions and lengths of D, M, Y.
	Get time format if provided.
	*/
	%let dpos = %index(&dateFormat, D);
	%let mpos = %index(&dateFormat, M);
	%let ypos = %index(&dateFormat, Y);

	%let dlen = %length(%sysfunc(compress(&dateFormat,D,k)));
	%let mlen = %length(%sysfunc(compress(&dateFormat,M,k)));
	%let ylen = %length(%sysfunc(compress(&dateFormat,Y,k)));

	%let Time_fmt_w=; 

	%if ^%sysevalf(%superq(timeFormat)=, boolean) %then %do;
		%if 		%length(&timeFormat) = 4 %then %let Time_fmt_w = ??tod5.;
		%else %if 	%length(&timeFormat) = 6 %then %let Time_fmt_w = ??tod8.;
		%else %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid time format provided.;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Valid time can be either: HH:MM, HH:MM:SS (both valid if without colon);
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
			%return;
		%end;
	%end;
	%else %do;
		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Time format is not provided. Please ensure there is no time component to be considered.;
	%end;



	%if &dtc_ty=CHAR %then %do; /* CHAR TYPE  Start*/
	data AVGML.date_&dataIn;
		length &varOut &varOut._dtc $200;
		set &dataIn;
		/* DAY */
		day1=compress(substr(&varInDate, &dpos, &dlen), " ", "kd");
		if length(day1)=1 and day1 ^='' then day="0"||strip(day1);
		else if length(day1)=2 and day1 ^='' then day=day1;
		/* MONTH */
		month1=strip(substr(&varInDate, &mpos, &mlen));
		month=strip(put(upcase(month1), $mon.));
		/* YEAR */
		year=compress(substr(&varInDate, &ypos, &ylen), " ", "kd");

		if year^='' then do;
			if month ^='' and day^='' then &varOut._dtc=catx("-", year, month, day);
			if month ^='' and day='' then &varOut._dtc=catx("-", year, month);
			if month ='' and day='' then &varOut._dtc=strip(year);
		end;
		if month^='' then do;
			if year ='' and day='' then &varOut._dtc=catx("-", "-", month);
			if year ='' and day ^='' then &varOut._dtc=catx("-", "-", month, day);
		end;
		if day^='' then do;
			if year ='' and month='' then &varOut._dtc=catx("-", "-", "-", day);
			if year ^='' and month='' then &varOut._dtc=catx("-", year, "-", day);
			if year ='' and month^='' then &varOut._dtc=catx("-", "-",month, day);
		end;

		%if &tm_ty=NUM and &varInTime ^= %then %do;
		if not missing(&varInTime) then do;
			&dataIn._time=strip(put(&varInTime, &Time_fmt_w));
			length  &dataIn._date $200;

			if year^='' then do;
				if month ^='' and day^='' then &dataIn._date=catx("-", year, month, day);
				if month ^='' and day='' then &dataIn._date=catx("-", year, month, "-");
				if month ='' and day='' then &dataIn._date=catx("-", year, "-", "-");;
			end;
			if month^='' then do;
				if year ='' and day='' then &dataIn._date=catx("-", "-", month, "-");
				if year ='' and day ^='' then &dataIn._date=catx("-", "-", month, day);
			end;
			if day^='' then do;
				if year ='' and month='' then &dataIn._date=catx("-", "-", "-", day);
				if year ^='' and month='' then &dataIn._date=catx("-", year, "-", day);
				if year ='' and month^='' then &dataIn._date=catx("-", "-",month, day);
			end;
			if day='' and month='' and year='' then  &dataIn._date="-----";

			&varOut=catx("T",&dataIn._date, &dataIn._time);
		end;

		else if missing(&varInTime) then &varOut= &varOut._dtc;
		%end;

		%if &tm_ty=CHAR and &varInTime ^= %then %do;
		if not missing(&varInTime) then do;
			length  &dataIn._date $200;

			if not missing(&varInTime) then &dataIn._time= strip(put(input(&varInTime, ??anydttme.),&Time_fmt_w)) ;
			if &dataIn._time='' and &varInTime ^='' then do;
				drop datetime;

				/* Used for warning messages */
				datetime=datetime();
				put "WARNING:1/[AVANCE " datetime e8601dt. "] Partial time present in the dataset.";
				put "WARNING:2/[AVANCE " datetime e8601dt. "] Whole time component will be set as null.";
			end;

			if year^='' then do;
				if month ^='' and day^='' then &dataIn._date=catx("-", year, month, day);
				if month ^='' and day='' then &dataIn._date=catx("-", year, month, "-");
				if month ='' and day='' then &dataIn._date=catx("-", year, "-", "-");;
			end;
			if month^='' then do;
				if year ='' and day='' then &dataIn._date=catx("-", "-", month, "-");
				if year ='' and day ^='' then &dataIn._date=catx("-", "-", month, day);
			end;
			if day^='' then do;
				if year ='' and month='' then &dataIn._date=catx("-", "-", "-", day);
				if year ^='' and month='' then &dataIn._date=catx("-", year, "-", day);
				if year ='' and month^='' then &dataIn._date=catx("-", "-",month, day);
			end;
			if day='' and month='' and year='' then  &dataIn._date="-----";

			&varOut=catx("T",&dataIn._date, &dataIn._time);
		end;
		else if missing(&varInTime) then &varOut= &varOut._dtc;

		%end;

		%if &varInTime =  %then %do;
			&varOut=&varOut._dtc;
		%end;
	run;
	%end;/* CHAR TYPE  End*/

	%if &dtc_ty=NUM %then %do; /* NUM TYPE  Start*/
	data AVGML.date_&dataIn;
		length &varOut._dtc &varOut $200;
		set &dataIn;
		&varOut._dtc=strip(put(&varInDate, ??is8601da.));

		%if &tm_ty=NUM and &varInTime ^= %then %do;
		if not missing(&varInTime) then do;
			&dataIn._time=strip(put(&varInTime, &Time_fmt_w));
			if not missing(&varOut._dtc) then &varOut=catx("T",&varOut._dtc, &dataIn._time);
			else if missing(&varOut._dtc) then &varOut=catx("T","-----", &dataIn._time);
		end;
		else if missing(&varInTime) then do;
			&varOut=&varOut._dtc;
		end;
		%end;

		%if &tm_ty=CHAR and &varInTime ^= %then %do;
		if not missing(&varInTime) then do;
			if not missing(&varInTime) then &dataIn._time= strip(put(input(&varInTime, ??anydttme.),&Time_fmt_w)) ;
			if &dataIn._time='' and &varInTime ^='' then do;
				drop datetime;

				/* Used for warning messages */
				datetime=datetime();
				put "WARNING:1/[AVANCE " datetime e8601dt. "] Partial time present in the dataset.";
				put "WARNING:2/[AVANCE " datetime e8601dt. "] Whole time component will be set as null.";
			end;
			if not missing(&varOut._dtc) then &varOut=catx("T",&varOut._dtc, &dataIn._time);
			else if missing(&varOut._dtc) then &varOut=catx("T","-----", &varOut._dtc);
		end;

		else if missing(&varInTime) then do;
			&varOut=&varOut._dtc;
		end;
		%end;

		%if &varInTime =  %then %do;
			&varOut=&varOut._dtc;
		%end;

	run;
	%end;/* NUM TYPE  End*/


	proc sql;
		create table &dataOut as select
		&varOut, &keepVarDataIn from AVGML.date_&dataIn;
	quit;


	/* Clear AVGML library */
	proc datasets library = avgml memtype = data kill nolist nowarn;
	quit;
%mend;
