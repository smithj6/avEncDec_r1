/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avTrimCharVarsToMaxLength.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Utility macro to trim character variables to their maximum length
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avTrimCharVarsToMaxLength(dataIn=);
	%local dsid rc size i memname libname;
	%if %sysevalf(%superq(dataIn)=, boolean) %then %do;
	 	%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameter dataIn is required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(exist(%bquote(&dataIn))) %then %do;
	 	%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] data %bquote(&dataIn) does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %index(&dataIn, .) %then %do;
		%let libname=%scan(&dataIn, 1, .);
		%let memname=%scan(&dataIn, 2, .);
	%end;
	%else %do;
		%let libname=WORK;
		%let memname=&dataIn;
	%end;
	%let dsid=%sysfunc(open(&dataIn));
	%let size=0;
	%do i=1 %to %sysfunc(attrn(&dsid, nvar));
		%if %sysfunc(vartype(&dsid, &i)) = C %then %do;
			%let size=%eval(&size + 1);
			%local var&size;
			%let var&size=%sysfunc(varname(&dsid, &i));
		%end;
	%end;
	%let rc=%sysfunc(close(&dsid));
	%if ^&size %then %do;
		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Data &dataIn contains no character variables.;
		%put NOTE:2/[AVANCE %sysfunc(datetime(), e8601dt.)] No Trimming Done;
		%put NOTE:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	data _null_;
		set sashelp.vcolumn(where=(libname="%upcase(&libname)" and memname="%upcase(&memname)" and name 
							in ( 
								%do i=1 %to &size;
									"&&var&i"
								%end;
								)));
		call symputx(name, length, 'l');
	run;

	%do i=1 %to &size;
         %local maxlen&i;
	%end;
	proc sql noprint;
		select coalesce(max(length(&var1)), 1)
		%do i=2 %to &size;
              ,coalesce(max(length(&&var&i)), 1)
		%end;
		into :maxlen1 trimmed
		%do i=2 %to &size;
             ,:maxlen&i trimmed
		%end;
		from &dataIn;
	quit;
	%do i=1 %to &size;
		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Updating variable(&&var&i) from length=(%unquote(%nrstr(&)&&var&i)) to length=(&&maxlen&i);
	%end;
	proc sql;
		alter table &datain
		modify &var1 char(&maxlen1)
		%do i=2 %to &size;
              ,&&var&i char(&&maxlen&i)
		%end;
		;
	quit;
%mend avTrimCharVarsToMaxLength;
