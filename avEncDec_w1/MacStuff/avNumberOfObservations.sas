/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avNumberOfObservations.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Utility Macro returning number of observations in a dataset
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avNumberOfObservations(dataIn=);
	%local dsid rc nobs;
	%if %sysevalf(%superq(dataIn)=, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameter is required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(exist(%bquote(&dataIn))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] data %bquote(&dataIn) does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%let dsid=%sysfunc(open(&dataIn));
	%let nobs=%sysfunc(attrn(&dsid, nlobsf));
	%let rc=%sysfunc(close(&dsid));
	&nobs
%mend avNumberOfObservations;
