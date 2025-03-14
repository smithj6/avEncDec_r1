/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avTreatmentEmergentFlag.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Utility Macro used to derive Supplemental Qualifier AETRTEM
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avTreatmentEmergentFlag(dataIn=
							  ,dataOut=
							  ,dmDataIn=);
	%local dsid
		   rc
		   var1
		   var2
		   libref
		   random;
	%if %sysevalf(%superq(dataIn)                =, boolean) or 
		%sysevalf(%superq(dataOut)               =, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameters dataIn, and dataOut are required;
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
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML is study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%let dsid=%sysfunc(open(&dataIn));
	%if ^%sysfunc(varnum(&dsid, aestdtc)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable AESTDTC not in &dataIn data;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let rc=%sysfunc(close(&dsid));
		%return;
	%end;
	%if %sysfunc(varnum(&dsid, aetrtem)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable AETRTEM already exsits in &dataIn data;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let rc=%sysfunc(close(&dsid));
		%return;
	%end;
	%if ^%sysfunc(varnum(&dsid, rfxstdtc)) %then %do;
		%if %sysevalf(%superq(dmDataIn)=, boolean) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable RFXSTDTC not in &dataIn data;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Pass a valid dataset referring;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let rc=%sysfunc(close(&dsid));
			%return;
		%end;
		%if ^%sysfunc(exist(%bquote(&dmDataIn))) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] data %bquote(&dmDataIn) does not exist;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let rc=%sysfunc(close(&dsid));
			%return;
		%end;
		%let rc=%sysfunc(close(&dsid));
		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Attempting to join data &dataIn with &dmDataIn by USUBJID;
		%put NOTE:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Further validation deffered to %nrstr(%%)avJoinTwoTables;

		%avJoinTwoTables(dataIn=&dataIn
					    ,dataOut=avgml.rfxstdtc
					    ,refDataIn=&dmDataIn
					    ,joinType=left
					    ,dataJoinVariables=usubjid
					    ,refDataJoinVariables=usubjid
					    ,extendVariables=rfxstdtc)

		%if ^%sysfunc(exist(avgml.rfxstdtc)) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Could not successfully merge &dataIn with &dmDataIn;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] See SAS Log For further details;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;

		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Successfully joined data &dataIn with &dmDataIn by USUBJID;
		%put NOTE:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Data avgml.rfxstdtc created;
		%put NOTE:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Data avgml.rfxstdtc will now be used as the source data for further execution;

		%let dataIn=avgml.rfxstdtc;
		%let dsid=%sysfunc(open(&dataIn));
	%end;
	%let var1=aestdtc;
	%let var2=rfxstdtc;
	%do i=1 %to 2;
		%if %sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, &&var&i)))) ne C %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &&var&i in &dataIn data is not in expected type;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expected type is Character;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let rc=%sysfunc(close(&dsid));
		%end;
	%end;
	%let rc=%sysfunc(close(&dsid));
	%let random=V%sysfunc(rand(integer, 1, 5E6), hex8.);

	data &dataOut;
		set &dataIn;
		retain &random.patternID1 &random.patternID2;
		if _n_ = 1 then do;
			&random.patternID1=prxparse('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[01])(T([0-1][0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?)?$/oi');
			&random.patternID2=prxparse('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[01])T([0-1][0-9]|2[0-3]|[1-9]):[0-5][0-9]$/oi');
		end;
		if prxmatch(&random.patternID2, strip(aestdtc)) and prxmatch(&random.patternID2, strip(rfxstdtc)) then do;
			&random.aedat=input(aestdtc, e8601dt.);
			&random.rfxdat=input(rfxstdtc, e8601dt.);
		end;
		else if prxmatch(&random.patternID1, strip(aestdtc)) and prxmatch(&random.patternID1, strip(rfxstdtc)) then do;
			&random.aedat=input(aestdtc, e8601da.);
			&random.rfxdat=input(rfxstdtc, e8601da.);
		end;
		if &random.aedat>=&random.rfxdat>. then aetrtem='Y';
		else aetrtem='N';
		drop &random:;
	run;
%mend avTreatmentEmergentFlag;
