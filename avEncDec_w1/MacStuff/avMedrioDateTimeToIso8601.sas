/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avMedrioDateTimeToIso8601.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Utility Macro to Map Raw CRF dates to IS08601 Standard
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avMedrioDateTimeToIso8601(dataIn=
				  		        ,dataOut=
							    ,varsIn=
							    ,varsOut=) / minoperator;
	%local libref
		   i 
		   j 
		   dsid 
		   size
		   timeSize
		   partialSize
		   rc
		   random;
	%if %sysevalf(%superq(dataIn)   =, boolean) or 
		%sysevalf(%superq(dataOut)  =, boolean) or
		%sysevalf(%superq(varsIn)  	=, boolean) or
		%sysevalf(%superq(varsOut)  =, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameters dataIn, dataOut, varsIn, and varsOut are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(exist(%bquote(&dataIn))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] data %bquote(&dataIn) does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
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
	%let size=%sysfunc(countw(%bquote(&varsIn), #));
	%if &size ne %sysfunc(countw(&varsOut, #)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid number of out variables specified;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Number of dates and out variables must match;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%let dsid=%sysfunc(open(&dataIn));
	%let timeSize=0;
	%let partialSize=0;
	%do i=1 %to &size;
		%local map&i 
			   map&i.entries
			   varOut&i;
		%let map&i = %qscan(%bquote(&varsIn), &i, #);
		%let map&i.entries=%sysfunc(countc(&&map&i, :));
		%let varOut&i=%qscan(%bquote(&varsOut), &i, #);
		%if %sysfunc(varnum(&dsid, &&varOut&i)) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &&varOut&i already exists in &dataIn data;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let rc=%sysfunc(close(&dsid));
			%return;
		%end;
		%if &&map&i.entries ne 3 %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid number of keys detected;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expecting a total of 3 keys;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Expecting keys for date, time and partial;
			%put ERROR:4/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let rc=%sysfunc(close(&dsid));
			%return;
		%end;
		%do j=1 %to 3;
			%local date&i
				   time&i
				   partial&i
				   map&i.entry&j
				   map&i.key&j
				   map&i.value&j;
			%let map&i.entry&j=%qscan(&&map&i, &j, %str( ));
			%let map&i.key&j=%qlowcase(%qscan(&&map&i.entry&j, 1, :));
			%let map&i.value&j=%qlowcase(%qscan(&&map&i.entry&j, 2, :));
			%if ^%eval(&&map&i.key&j in date time partial) %then %do;
				%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid key &&map&i.key&j;
				%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Valid keys are date, time and partial;
				%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
				%let rc=%sysfunc(close(&dsid));
				%return;
			%end;
			%let &&map&i.key&j..&i=&&map&i.value&j;
			%if &&map&i.value&j = _na_ %then %goto skip;
			%if ^%sysfunc(varnum(&dsid, &&map&i.value&j)) %then %do;
				%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &&map&i.value&j not in &dataIn data;
				%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
				%let rc=%sysfunc(close(&dsid));
				%return;
			%end;
			%if &&map&i.key&j = date and %sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, &&map&i.value&j)))) ne N %then %do;
				%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &&map&i.value&j is not in expected type;
				%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expected type is Numeric;
				%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
				%let rc=%sysfunc(close(&dsid));
				%return;
			%end;
			%if &&map&i.key&j ne date and %sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, &&map&i.value&j)))) ne C %then %do;
				%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &&map&i.value&j is not in expected type;
				%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expected type is Character;
				%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
				%let rc=%sysfunc(close(&dsid));
				%return;
			%end;
			%if &&map&i.key&j = time %then %let timeSize=%eval(&timeSize + 1); 
			%else %if &&map&i.key&j = partial %then %let partialSize=%eval(&partialSize + 1); 
			%skip:	
		%end;
	%end;
	%let rc=%sysfunc(close(&dsid));
	%let random = V%sysfunc(rand(integer, 1, 5E6), hex8.);
	%if &partialSize and &partialSize ne &size %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid number of partial date variables specified.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] All entries for partial dates must be either _NA_ or a valid variable.;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Specifying some partial date entries as _NA_ and others as valid variables is not supported.;
		%put ERROR:4/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if &timeSize and &timeSize ne &size %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid number of time variables specified.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] All entries for time must be either _NA_ or a valid variable.;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Specifying some time entries as _NA_ and others as valid variables is not supported.;
		%put ERROR:4/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;	
	%end;
	
	data &dataOut;
		set &dataIn;
		array &random.dates [&size] %do i=1 %to &size;
										&&date&i
									 %end;;
		%if &partialSize %then %do;
			array &random.dates_p [&size] %do i=1 %to &size;
											&&partial&i
									 	  %end;;
		%end;
		%if &timeSize %then %do;
			array &random.times [&size] %do i=1 %to &size;
											&&time&i
									 	%end;;
		%end;
		array &random.tmp     [3] $10 _temporary_;
		array &random.datesc  [&size] $16 %do i=1 %to &size;
											&&varOut&i
									 	   %end;;
		do &random.i=1 to 2;
			if ^missing(&random.dates[&random.i]) then do;
				&random.tmp[1]=cats(year(&random.dates[&random.i]));
				&random.tmp[2]=put(month(&random.dates[&random.i]),z2. -l);
				&random.tmp[3]=put(day(&random.dates[&random.i]),z2. -l);
			end;
			%if &partialSize %then %do;
				else if ^missing(&random.dates_p[&random.i]) then do;
					do &random.j=1 to 3;
						&random.datepart=scan(&random.dates_p[&random.i], &random.j, '-', 'b');
						if ^(&random.datepart =: 'UN') then do;
							** if month is given, change month to numeric format where Jan=01, Feb=02 etc;
							if &random.j=2 then &random.tmp[&random.j] = put(month(input(cats('01', &random.datepart, year(today())), date9.)), z2. -l);
							else &random.tmp[&random.j] = &random.datepart;
						end;
					end;
					do &random.j=2 to 3;
						if ^missing(&random.tmp[&random.j]) and missing(&random.tmp[&random.j - 1]) then &random.tmp[&random.j - 1] ='-';
					end;
				end;
			%end;
			%if &timeSize %then %do;
				if ^missing(&random.times[&random.i]) then do;
					 do &random.j=1 to 3;
						&random.tmp[&random.j]=coalescec(&random.tmp[&random.j], '-');
					end;
				end;
				&random.datesc[&random.i]=catx('T', catx('-', of &random.tmp[*]), &random.times[&random.i]);
			%end;
			%else %do;
				&random.datesc[&random.i] = catx('-', of &random.tmp[*]);
			%end;
			call missing(of &random.tmp[*]);
		end;
		drop &random.i 
			%if &partialSize or &timeSize %then %do;
				&random.j
			%end; 
			%if &partialSize %then %do;
				&random.datepart
			%end;
			;
	run;
%mend avMedrioDateTimeToIso8601;
