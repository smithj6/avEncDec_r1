/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avSplitCharVarExceedingMaxLength.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Utility macro to split char variables exceeding maximum length
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avSplitCharVarExceedingMaxLength(dataIn=
				   					   ,dataOut=
				   					   ,maxLength=200
				   					   ,varIn=
									   ,splitVarInBy=
				   					   ,varOutPrefix=);
	%local dsid 
		   rc 
		   libref
		   i
		   extendVariables 
		   random;
 	%if %sysevalf(%superq(dataIn)=,         boolean)  or 
 	 	%sysevalf(%superq(dataOut)=,        boolean)  or
	 	%sysevalf(%superq(maxLength)=,      boolean)  or  
	 	%sysevalf(%superq(varIn)=,          boolean)  or 
	 	%sysevalf(%superq(varOutPrefix)=,   boolean)  %then %do;
	 		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameters dataIn, dataOut, varIn, varOutPrefix and maxLength are required;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
	%end;
	%if ^%sysfunc(exist(%bquote(&dataIn))) %then %do;
	 	%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] data %bquote(&dataIn) does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysfunc(libref(avgml)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Assign Library AVGML is study setup file.;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %length(%bquote(&splitVarInBy)) > 1 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Split character %bquote(&splitVarInBy) is too long;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Specify only one character;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(prxmatch(%str(m/^[A-Za-z_][A-Za-z_]+$/oi), %bquote(&varOutPrefix))) %then %do;
	 	%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] varOutPrefix is not a valid prefix for a variable name;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] varOutPrefix must begin with an underscore or a letter and may not contain numbers;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %datatyp(%bquote(&maxLength)) ne NUMERIC %then %do;
	 	%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] maxLen is not a valid integer;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysfunc(prxmatch(%str(m/^[A-Za-z_][A-Za-z_0-9]{1,7}[.][A-Za-z_][A-Za-z_0-9]{1,31}$/oi), %bquote(&dataOut))) %then %do;
		%let libref=%scan(&dataOut, 1, .);
		%if %sysfunc(libref(&libref)) %then %do;
	 		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] dataOut is a valid SAS 2 level name, however libref &libref is not assigned;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;
	%end;
	%else %if ^%sysfunc(prxmatch(%str(m/^[A-Za-z_][A-Za-z_0-9]{1,31}$/oi), %bquote(&dataOut))) %then %do;
	 	%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] dataOut is not a valid SAS dataset name;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%let dsid=%sysfunc(open(&dataIn));
	%if ^%sysfunc(varnum(&dsid, %bquote(&varIn))) %then %do;
		%let rc=%sysfunc(close(&dsid));
	 	%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] &varIn variable was not found in dataset &dataIn;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, &varIn)))) ne C %then %do;
		%let rc=%sysfunc(close(&dsid));
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &varIn is not in expected type;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expeced type is Character;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%let rc=%sysfunc(close(&dsid));
	%if %sysevalf(%superq(splitVarInBy)=, boolean) %then %let splitVarInBy=%str( );
	%let random=V%sysfunc(rand(integer, 1, 5E6), hex8.);

	data avgml.split(drop=&random:) avgml.temp(keep=row&random &random.counter &random.text);
		retain &random.flag &random.maxCol 0;
		set &dataIn(rename=(&varIn = &random)) end=eof;
		length &random.text $&maxLength.;
		&random.tmp=strip(compbl(&random));
		&random.counter=0;
		row&random. = _n_;
		&random.datetime=datetime();
		do while(length(&random.tmp) > &maxLength);
			&random.counter+1;
			&random.pos = find(&random.tmp, "&splitVarInBy", 'i', -&maxLength);
			if ^&random.pos then do;
				put "ERROR:1/[AVANCE " &random.datetime e8601dt. "] record " _n_ "split character &splitVarInBy not found in '" &random.tmp +(-1) "' within &maxLength character limit";
				put "ERROR:2/[AVANCE " &random.datetime e8601dt. "] record " _n_ "review input variable and adjust lengths as needed";
				put "ERROR:3/[AVANCE " &random.datetime e8601dt. "] record " _n_ "split unsuccsessful";
				goto end;
			end;
			else do;
				&random.text = substr(&random.tmp, 1, &random.pos - 1);
				&random.tmp  = strip(substr(&random.tmp, &random.pos + 1));
			end;
			output avgml.temp;
			&random.flag = 1;
		end;
		if ^missing(&random.tmp) then do;
			&random.counter+1;
			&random.text=&random.tmp;
			output avgml.temp;
		end;
		&random.maxCol = max(&random.maxCol, &random.counter);
		end:
		if eof then do;
			call symputx('numberOfColumns', &random.maxCol, 'l');
			call symputx('anyDataSplit', &random.flag, 'l');
		end;
		output avgml.split;
	run;

	%if %avNumberOfObservations(dataIn=avgml.temp) %then %do;

		proc transpose data=avgml.temp out=avgml.t_text prefix=&varOutPrefix;
			by row&random;
			id &random.counter;
			var &random.text;
		run;

		proc datasets lib=avgml mt=data nodetails nolist;
			modify t_text;
			rename
				&varOutPrefix.1 = &varOutPrefix
				%do i=2 %to &numberOfColumns;
					&varOutPrefix&i = &varOutPrefix.%eval(&i - 1)
				%end;
				;
		quit;

		proc sql noprint;
			select name into: extendVariables separated by '#'
			from dictionary.columns
			where libname='AVGML' and memname='T_TEXT' and name eqt "%upcase(&varOutPrefix)";
		quit;

		%avJoinTwoTables(dataIn=avgml.split
						,dataOut=&dataOut
						,refDataIn=avgml.t_text
						,joinType=left
						,dataJoinVariables=row&random
						,refDataJoinVariables=row&random
						,extendVariables=&extendVariables)

		%if ^%sysfunc(exist(&dataOut)) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Data &dataOut not created;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] See Log For details;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;

		%if ^&anyDataSplit %then %do;
			%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No text is greater than &maxLength characters.;
			%put NOTE:2/[AVANCE %sysfunc(datetime(), e8601dt.)] No Splitting Done.;
		%end;

		proc sql;
			alter table	&dataOut
			drop column row&random;
		quit;	
	%end;
	%else %do;
		data &dataOut;
			set avgml.split;
			length &varOutPrefix $&maxLength;
			call missing(of &varOutPrefix);
			drop row&random;
		run;
	%end;
%mend avSplitCharVarExceedingMaxLength;
