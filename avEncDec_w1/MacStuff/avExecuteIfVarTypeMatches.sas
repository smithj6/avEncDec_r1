/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avExecuteIfVarTypeMatches.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : %avExecuteIfVarTypeMatches Executes a Line of Code If a Variable Matches the Type Specified, 
				   Otherwise An Asterisk * Is Returned 
				   Modified from %avExecuteIfVarExists
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :  
By			     :  
=======================================================================================*/

%macro avExecuteIfVarTypeMatches(dataIn=
						   		,varIn=
								,type=);
	%local dsid rc;
	%if %sysevalf(%superq(dataIn)=, boolean) or 
		%sysevalf(%superq(varIn)=, boolean) or 
		%sysevalf(%superq(type)=, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] parameters dataIn, varIn and type are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(exist(%bquote(&dataIn))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] data %bquote(&dataIn) does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(prxmatch(%str(m/^[_A-Za-z]([_A-Za-z0-9]{1,31})?$/oi), %bquote(&varIn))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] variable %bquote(&varIn) is not a valid name;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%let dsid=%sysfunc(open(&dataIn));
	%let rc=%sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, &varIn))));
	%let dsid=%sysfunc(close(&dsid));
	%if &rc ne &type %then %str(*);
%mend avExecuteIfVarTypeMatches;
