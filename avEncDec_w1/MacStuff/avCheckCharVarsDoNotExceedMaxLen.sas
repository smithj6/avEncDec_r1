/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avCheckCharVarsDoNotExceedMaxLen.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Prints errors when a specified variable exceeds the max length specified
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/


%macro avCheckCharVarsDoNotExceedMaxLen(dataIn=
							           ,maxLength=200
						     		   ,varsIn=);
	%local random dsid rc size i validatedSize;
	%if %sysevalf(%superq(dataIn)=,	   boolean) or 
		%sysevalf(%superq(maxLength)=, boolean) or
		%sysevalf(%superq(varsIn)=,    boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameters dataIn, maxLength and varsIn required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(exist(%bquote(&dataIn))) %then %do;
	 	%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] data %bquote(&dataIn) does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %datatyp(%bquote(&maxLength)) ne NUMERIC %then %do;
	 	%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] maxLength is not a valid integer;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(prxmatch(%str(m/^\w+(#\w+)*$/oi), %bquote(&varsIn))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid selection for macro parameter varsIn;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Separate muliple entries with a hash tag e.g. var1#var2;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%let dsid=%sysfunc(open(&dataIn));
	%let size=%sysfunc(countw(%bquote(&varsIn), #));
	%let validatedSize=0;
	%do i=1 %to &size;
		%local var&i;
		%let var&i=%qscan(%bquote(&varsIn), &i, #);
		%if ^%sysfunc(varnum(&dsid, &&var&i)) %then %do;
	 		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] &&var&i variable was not found in dataset &dataIn;
			%put NOTE:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Skipping variable &&var&i;
			%goto skip;
		%end;
		%if %sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, &&var&i)))) ne C %then %do;
			%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &&var&i is not in expected type;
			%put NOTE:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expeced type is Character;
			%put NOTE:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Skipping variable &&var&i;
			%goto skip;
		%end;
		%let validatedSize=%eval(&validatedSize + 1);
		%local validatedCharVar&validatedSize;
		%let validatedCharVar&validatedSize=&&var&i;
		%skip:
	%end;
	%let rc=%sysfunc(close(&dsid));
	%if ^&validatedSize %then %do;
		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Neither of the variables supplied are suitable;
		%put NOTE:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Variables either do not exist or are numeric;
		%put NOTE:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%let random=V%sysfunc(rand(integer, 1, 5E6), hex8.);
	length &random.var $32;
	&random.datetime=datetime();
	array &random.vars [&validatedSize] %do i=1 %to &validatedSize;
											&&validatedCharVar&i
							   			%end;
							  ;
	do &random.i=1 to dim(&random.vars);
		&random.var=vname(&random.vars[&random.i]);
		if length(&random.vars[&random.i]) > &maxLength then do;
			put "WARNING:1/[AVANCE " &random.datetime e8601dt. "] Truncation issue at row=" _n_;
			put "WARNING:2/[AVANCE " &random.datetime e8601dt. "] Length for variable" &random.var +(-1) "> &maxLength charcters.";
		end;
	end;
	drop &random:;
%mend avCheckCharVarsDoNotExceedMaxLen;




