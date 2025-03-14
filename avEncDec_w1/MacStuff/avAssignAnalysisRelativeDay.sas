/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avAssignAnalysisRelativeDay.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Derives ADY/ASTDY/AENDY with respect to the reference date(s) provided.
				   If phase/period/subperiod-dependent reference dates provided, APHASE/APERIOD/ASPER will be a pre-requisite.
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avAssignAnalysisRelativeDay(dataIn=			/* Dataset in */
								 , dataOut=			/* Dataset out, default to be &dataIn */
								 , varIn=			/* DT variable, e.g. ASTDT */
								 , varOut=			/* DY variable, default to use the prefix of &varIn */
								 , varRef=TRTSDT	/* Reference DT variable(s), e.g. TRTSDT, TRxxSDT, CSTM__DT */
)/minoperator;

	/* Exception handling: Mandatory Parameters */
	%if %sysevalf(%superq(dataIn)=,	boolean) or 
		%sysevalf(%superq(varIn)=,	boolean) or  
		%sysevalf(%superq(varRef)=,	boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] parameters dataIn, varIn and varRef are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	
	/* Exception handling: Existence of input dataset */
	%if ^%sysfunc(exist(%bquote(&dataIn))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] data %bquote(&dataIn) does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/* Exception handling: Optional Parameters */
	%if %sysevalf(%superq(dataOut)=, boolean) %then %do;
		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameter dataOut is missing, default as dataIn.;
		%let dataOut = &dataIn;
	%end;
	%if %sysevalf(%superq(varOut)=,  boolean) %then %do;
		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Optional parameter varOut is missing, default to use the prefix of &varIn;
		%let varOut = %substr(&varIn, 1, %length(&varIn)-2)DY;
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

	/* Exception handling: &varIn existence and type */
	%if "%avExecuteIfVarExists(dataIn=&dataIn,varIn=&varIn)" = "*" %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &varIn does not exist in Source Dataset &dataIn;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
		%return;
	%end;
	%if "%avExecuteIfVarTypeMatches(dataIn=&dataIn,varIn=&varIn,type=N)" = "*" %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &varIn in Source Dataset &dataIn is not in expected type;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expected type is Numeric;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/* Exception handling: Existed &varOut */
	%if "%avExecuteIfVarExists(dataIn=&dataIn,varIn=&varOut)" = "" %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &varOut already existed in Source Dataset &dataIn;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
		%return;
	%end;

	/* Split lib and ds from &dataIn */
	%if %index(&dataIn,.) %then %do;
		%let tmplib = %upcase(%scan(&dataIn,1,.));
		%let tmpds = %upcase(%scan(&dataIn,2,.));
	%end;
	%else %do;
		%let tmplib = WORK;
		%let tmpds = %upcase(&dataIn);
	%end;


	/*** Relative to Standard Phase DT var ***/
	%if %upcase(&varRef) in (PHWSDT PHWEDT) %then %do;
		/* Exception handling: APHASE existence and type */
		%if "%avExecuteIfVarExists(dataIn=&dataIn,varIn=APHASE)" = "*" %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable APHASE does not exist in Source Dataset &dataIn;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Check parameter varRef in &sysmacroname., &varRef is dependent on APHASE.;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
			%return;
		%end;
		%if "%avExecuteIfVarTypeMatches(dataIn=&dataIn,varIn=APHASE,type=N)" = "*" %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable APHASE in Source Dataset &dataIn is not in expected type;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expected type is Numeric;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;

		/* Get variable names specified in &varRef */
		proc sql noprint;
			select name into :refs separated by '|'
			from sashelp.vcolumn 
			where libname = "&tmplib"
			and memname = "&tmpds."
			and name like "%sysfunc(tranwrd(%upcase(&varRef),W,_))"
			and type = "num"
			;
		quit;
		/* Exception handling: Missing variables specified in &varRef */
		%if &sqlobs = 0 %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No numeric variable exist in the format of &varRef.;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
			%return;
		%end;
		
		data &dataOut;
			set &dataIn;

			%do i = 1 %to %sysfunc(countw(&refs,|));
				%if &i ne 1 %then %do; 
				else 
				%end;

				%let ref = %scan(&refs,&i,|);
				if APHASE = %substr(&ref,3,1) and ^missing(&ref) and ^missing(&varIn) then &varOut = &varIn - &ref + (&varIn >= &ref);
			%end;
		run;
	%end;


	/*** Relative to Standard Period DT var ***/
	%else %if %upcase(&varRef) in (TRXXSDT TRXXEDT APXXSDT APXXEDT) %then %do;
		/* Exception handling: APERIOD existence and type */
		%if "%avExecuteIfVarExists(dataIn=&dataIn,varIn=APERIOD)" = "*" %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable APERIOD does not exist in Source Dataset &dataIn;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Check parameter varRef in &sysmacroname., &varRef is dependent on APERIOD.;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
			%return;
		%end;
		%if "%avExecuteIfVarTypeMatches(dataIn=&dataIn,varIn=APERIOD,type=N)" = "*" %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable APERIOD in Source Dataset &dataIn is not in expected type;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expected type is Numeric;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;

		/* Get variable names specified in &varRef */
		proc sql noprint;
			select name into :refs separated by '|'
			from sashelp.vcolumn 
			where libname = "&tmplib"
			and memname = "&tmpds."
			and name like "%sysfunc(tranwrd(%upcase(&varRef),XX,__))"
			and type = "num"
			;
		quit;
		/* Exception handling: Missing variables specified in &varRef */
		%if &sqlobs = 0 %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No numeric variable exist in the format of &varRef.;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
			%return;
		%end;
		
		data &dataOut;
			set &dataIn;

			%do i = 1 %to %sysfunc(countw(&refs,|));
				%if &i ne 1 %then %do; 
				else 
				%end;

				%let ref = %scan(&refs,&i,|);
				if APERIOD = %sysfunc(inputn(%substr(&ref,3,2),best.)) and ^missing(&ref) and ^missing(&varIn) then &varOut = &varIn - &ref + (&varIn >= &ref);
			%end;
		run;
	%end;


	/*** Relative to Standard Subperiod DT var ***/
	%else %if %upcase(&varRef) in (PXXSWSDT PXXSWEDT) %then %do;
		/* Exception handling: APERIOD/ASPER existence and type */
		%if "%avExecuteIfVarExists(dataIn=&dataIn,varIn=APERIOD)" = "*" %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable APERIOD does not exist in Source Dataset &dataIn;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Check parameter varRef in &sysmacroname., &varRef is dependent on APERIOD.;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
			%return;
		%end;
		%if "%avExecuteIfVarTypeMatches(dataIn=&dataIn,varIn=APERIOD,type=N)" = "*" %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable APERIOD in Source Dataset &dataIn is not in expected type;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expected type is Numeric;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;
		%if "%avExecuteIfVarExists(dataIn=&dataIn,varIn=ASPER)" = "*" %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable ASPER does not exist in Source Dataset &dataIn;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Check parameter varRef in &sysmacroname., &varRef is dependent on ASPER.;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
			%return;
		%end;
		%if "%avExecuteIfVarTypeMatches(dataIn=&dataIn,varIn=ASPER,type=N)" = "*" %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable ASPER in Source Dataset &dataIn is not in expected type;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expected type is Numeric;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;

		/* Get variable names specified in &varRef */
		proc sql noprint;
			select name into :refs separated by '|'
			from sashelp.vcolumn 
			where libname = "&tmplib"
			and memname = "&tmpds."
			and name like "%sysfunc(tranwrd( %sysfunc(tranwrd(%upcase(&varRef),XX,__)), W, _ ))"
			and type = "num"
			;
		quit;
		/* Exception handling: Missing variables specified in &varRef */
		%if &sqlobs = 0 %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No numeric variable exist in the format of &varRef.;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
			%return;
		%end;
		
		data &dataOut;
			set &dataIn;

			%do i = 1 %to %sysfunc(countw(&refs,|));
				%if &i ne 1 %then %do; 
				else 
				%end;

				%let ref = %scan(&refs,&i,|);
				if APERIOD = %sysfunc(inputn(%substr(&ref,2,2),best.)) and ASPER = %substr(&ref,5,1) and ^missing(&ref) and ^missing(&varIn) then &varOut = &varIn - &ref + (&varIn >= &ref);
			%end;
		run;
	%end;


	/*** Relative to Custom Period DT var ***/
	%else %if %index(&varRef,__) %then %do;
		/* Exception handling: APERIOD existence and type */
		%if "%avExecuteIfVarExists(dataIn=&dataIn,varIn=APERIOD)" = "*" %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable APERIOD does not exist in Source Dataset &dataIn;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Check parameter varRef in &sysmacroname., &varRef is dependent on APERIOD.;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
			%return;
		%end;
		%if "%avExecuteIfVarTypeMatches(dataIn=&dataIn,varIn=APERIOD,type=N)" = "*" %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable APERIOD in Source Dataset &dataIn is not in expected type;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expected type is Numeric;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;

		/* Get variable names specified in &varRef */
		proc sql noprint;
			select name into :refs separated by '|'
			from sashelp.vcolumn 
			where libname = "&tmplib"
			and memname = "&tmpds."
			and name like "%upcase(&varRef)"
			and type = "num"
			;
		quit;
		/* Exception handling: Missing variables specified in &varRef */
		%if &sqlobs = 0 %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No numeric variable exist in the format of &varRef.;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
			%return;
		%end;

		%let periodPos = %index(&varRef,__);
		
		data &dataOut;
			set &dataIn;

			%do i = 1 %to %sysfunc(countw(&refs,|));
				%if &i ne 1 %then %do; 
				else 
				%end;

				%let ref = %scan(&refs,&i,|);
				if APERIOD = %sysfunc(inputn(%substr(&ref,&periodPos,2),best.)) and ^missing(&ref) and ^missing(&varIn) then &varOut = &varIn - &ref + (&varIn >= &ref);
			%end;
		run;
	%end;


	/*** Relative to static DT var, including TRTSDT, TRTEDT, any custom ------DT ***/
	%else %do;
		/* Exception handling: Missing variables specified in &varRef / type mismatch */
		%if "%avExecuteIfVarExists(dataIn=&dataIn,varIn=&varRef)" = "*" %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &varRef does not exist in Source Dataset &dataIn;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Check parameter varRef in &sysmacroname.;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
			%return;
		%end;
		%if "%avExecuteIfVarTypeMatches(dataIn=&dataIn,varIn=&varRef,type=N)" = "*" %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &varRef in Source Dataset &dataIn is not in expected type;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expected type is Numeric;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;

		data &dataOut;
			set &dataIn;  
			if ^missing(&varRef) and ^missing(&varIn) then &varOut = &varIn - &varRef + (&varIn >= &varRef); 
		run;
	%end;
%mend avAssignAnalysisRelativeDay;
