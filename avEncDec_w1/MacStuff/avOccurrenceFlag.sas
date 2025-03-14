/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avOccurrenceFlag.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Set AOCCzzFL
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avOccurrenceFlag(dataIn=	/* Dataset in */
					  , dataOut=	/* Dataset out */
					  , flag=	/* AOCCzzFL name */
					  , bystr=	/* Variables to be sorted by separated by space */
					  , first=	/* First occurrence of this variable will flag as Y */
					  , whr=1	/* Conditions to filter the dataset in */
);

	/* Exception handling: Mandatory Parameters */
	%if %sysevalf(%superq(dataIn)=,  boolean) or 
		%sysevalf(%superq(flag)=,  boolean) or  
		%sysevalf(%superq(bystr)=, boolean) or 
		%sysevalf(%superq(first)=, boolean)  %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] parameters dataIn, flag, bystr and first are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/* Exception handling: Optional Parameters */
	%if %sysevalf(%superq(dataOut)=, boolean) %then %do;
		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameter dataOut is missing, default as dataIn.;
		%let dataOut = &dataIn;
	%end;
	%if %sysevalf(%superq(whr)=, boolean) %then %do;
		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameter whr is missing, default as 1, i.e. no condition.;
	%end;

	/* Exception handling: AVGML Lib */
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML is study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/* Exception handling: Existence of Input Dataset */
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

	/* Exception handling: Existence of 'first' variable at input dataset */
	%if "%avExecuteIfVarExists(dataIn=&dataIn,varIn=&first)" = "*" %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &first does not exist in Source Dataset &dataIn;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Check parameter first in &sysmacroname.;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
		%return;
	%end;

	/* Exception handling: &first in &byvar */
	%if %index(%upcase(&bystr),%upcase(&first)) = 0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &first is not in parameter bystr;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
		%return;
	%end;

	/* Exception handling: Existed &flag */
	%if "%avExecuteIfVarExists(dataIn=&dataIn,varIn=&flag)" = "" %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &flag already existed in Source Dataset &dataIn;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
		%return;
	%end;

	/* Exception handling: Name format of &flag */
	%if ^%sysfunc(prxmatch(%str(m/^AOCC(?!00)(S|P|I|SI|PI|[0-9][0-9])?FL$/oi), %bquote(&flag))) %then %do;
		%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &flag name format is not valid. Please refer to IG.;
		%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Continue proceeding.;
	%end;

	proc sort data=&dataIn; by &bystr; run;
	data &dataOut;
		set &dataIn;
		by &bystr;
		drop firstflag;
		retain firstflag;
	 
		if first.&first then firstflag = 'Y';
		if firstflag = 'Y' and &whr then do;
			&flag = 'Y';
			firstflag = '';
		end;
	run;
%mend avOccurrenceFlag;
