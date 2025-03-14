/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avSubjectLevelData.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : 100% Macro Code. Macro function returns a string containing a horizontal list 
				   of Common Variables.
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avSubjectLevelDataCommonVars(splitCommonVarsBy=
								   ,ignoreVars=STUDYID#USUBJID) /minoperator mindelimiter='#';
	%local i
		   dsid
		   rc
		   commonVar
		   commonVars;
	%if ^%symglobl(speclib) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro variable speclib is not defined in global scope;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Consider defining speclib in your in your study setup file;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysevalf(%superq(speclib)=, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global macro variable speclib is required and may not be null;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %length(%bquote(&splitCommonVarsBy))> 1 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] %bquote(&splitCommonVarsBy) is too long.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Only specify a single character;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysevalf(%superq(ignoreVars)=, boolean) and ^%sysfunc(prxmatch(%str(m/^\w+(#\w+)*$/oi), %bquote(&ignoreVars))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid pattern specified for ignoreVars parameter;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Each variable to exclude should be separated by a hash tag #. Otherwise ignoreVars should be left null;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysfunc(libref(&speclib)) %then %do;
	 	%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Libref &speclib is not assigned;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(exist(&speclib..adsl)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] &speclib..adsl does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%let dsid=%sysfunc(open(&speclib..adsl));
	%if ^%sysfunc(varnum(&dsid, variable__name)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable variable__name not found in &speclib..adsl data;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let rc=%sysfunc(close(&dsid));
		%return;
	%end;
	%if ^%sysfunc(varnum(&dsid, adsl__core)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable adsl__core not found in &speclib..adsl data;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let rc=%sysfunc(close(&dsid));
		%return;
	%end;
	%if ^%sysfunc(varnum(&dsid, include_y_n_)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable include_y_n_ not found in &speclib..adsl data;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let rc=%sysfunc(close(&dsid));
		%return;
	%end;
	%if ^%eval(%sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, adsl__core)))) 	 = C and
		       %sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, variable__name)))) = C and 
			   %sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, include_y_n_))))   = C) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variables ADSL__CORE/VARIABLE__NAME/INCLUDE_Y_N_ in &speclib..adsl data are not in expected type;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expected type is Character;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let rc=%sysfunc(close(&dsid));
		%return;	
	%end;
	%let commonVars=;
	%if %bquote(&splitCommonVarsBy)= %then %let splitCommonVarsBy=%str( );
	%do %while(^%sysfunc(fetch(&dsid)));
		%if %sysfunc(getvarc(&dsid, %sysfunc(varnum(&dsid, adsl__core))))   = Y and
			%sysfunc(getvarc(&dsid, %sysfunc(varnum(&dsid, include_y_n_)))) = Y %then %do;
			%let commonVar=%qupcase(%sysfunc(getvarc(&dsid, %sysfunc(varnum(&dsid, variable__name)))));
			%if ^%eval(%bquote(&commonVar) in %qupcase(&ignoreVars)) %then %do;
				%if %length(&commonVars) > 0 %then %let commonVars=&commonVars%bquote(&splitCommonVarsBy)&commonVar;
				%else %let commonVars=&commonVar;
			%end;
		%end;
	%end;
	%let rc=%sysfunc(close(&dsid));
	&commonVars
%mend avSubjectLevelDataCommonVars;
