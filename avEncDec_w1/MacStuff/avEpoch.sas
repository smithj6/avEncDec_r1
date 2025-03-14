/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avEpoch.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Assigns Epoch Timing variable from SDTM.SE permanent dataset
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avEpoch(dataIn= 
			  ,varIn=
			  ,seDataIn=
			  ,dataOut=);
	%local libref i j dsid rc ds1 ds2 ds1var1 ds2var1 ds2var2 ds2var3 ds1size1 ds2size1 random;
	%if %sysevalf(%superq(dataIn)=,   boolean) or 
		%sysevalf(%superq(varIn)=,    boolean) or  
		%sysevalf(%superq(seDataIn)=, boolean) or
		%sysevalf(%superq(dataOut)=,  boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] parameters dataIn, varIn, seDataIn and dataOut are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML is study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(exist(%bquote(&dataIn))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] data %bquote(&dataIn) does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(exist(%bquote(&seDataIn))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] SE data %bquote(&seDataIn) does not exist;
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
	%if ^%sysfunc(prxmatch(%str(m/^[_A-Za-z]([_A-Za-z0-9]{1,31})?$/oi), %bquote(&varIn))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] variable %bquote(&varIn) is not a valid name;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%let dsid=%sysfunc(open(&dataIn));
	%if %sysfunc(varnum(&dsid, epoch)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable epoch is already in &dataIn data;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let rc=%sysfunc(close(&dsid));
		%return;
	%end;
	%let rc=%sysfunc(close(&dsid));
	%let random = V%sysfunc(rand(integer, 1, 5E6), hex8.);

	%let ds1=&dataIn;
	%let ds1var1=&varIn;
	%let ds1size1=1;

	%let ds2=&seDataIn;
	%let ds2var1=sestdtc;
	%let ds2var2=seendtc;
	%let ds2var3=epoch;
	%let ds2size1=3;

	%do i=1 %to 2;
		%let dsid=%sysfunc(open(&&ds&i));
		%do j=1 %to &&ds&i.size1;
			%if ^%sysfunc(varnum(&dsid, &&ds&i.var&j)) %then %do;
				%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &&ds&i.var&j not in &&ds&i data;
				%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
				%let rc=%sysfunc(close(&dsid));
				%return;
			%end;
			%if %sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, &&ds&i.var&j)))) ne C %then %do;
				%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &&ds&i.var&j in &&ds&i data is not in expected type;
				%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expected type is Character;
				%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
				%let rc=%sysfunc(close(&dsid));
				%return;
			%end;		
		%end;
		%if ^%sysfunc(varnum(&dsid, usubjid)) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable USUBJID not in &&ds&i data;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let rc=%sysfunc(close(&dsid));
			%return;
		%end;
		%if %sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, usubjid)))) ne C %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable USUBJID is not in expected type;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expected type is Character;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let rc=%sysfunc(close(&dsid));
			%return;
		%end;
		%let rc=%sysfunc(close(&dsid));
	%end;

	proc sort data=&seDataIn out=avgml.se;
		by usubjid sestdtc seendtc;
	run;

	data avgml.last;
		set avgml.se;
		by usubjid;
		if last.usubjid then &random.flag=1;
	run;

	data &dataOut;
		set &dataIn;
		retain &random.patternid1 &random.patternid2 &random.patternid3;
		if _n_ = 1 then do;
			if 0 then set avgml.last(keep=usubjid epoch sestdtc seendtc &random.flag);
			dcl hash &random._h_(dataset: "avgml.last(keep=usubjid epoch sestdtc seendtc &random.flag)", multidata: "Y", ordered: "Y");
			&random._h_.definekey("usubjid");
			&random._h_.definedata(all:"Y");
			&random._h_.definedone();
			&random.patternid1=prxparse('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[01])T([0-1][0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?$/oi');
			&random.patternid2=prxparse('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[01])$/oi');
			&random.patternid3=prxparse('m/^\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|1[0-9]|2[0-9]|3[01])(T([0-1][0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?)?$/oi');
		end;
		if prxmatch(&random.patternid1, strip(&varIn)) then do;
			&random&varIn=input(&varIn, e8601dt.);
			&random.lvl=1;
		end;
		else if prxmatch(&random.patternid2, strip(&varIn)) then do;
			&random&varIn=input(&varIn, e8601da.);
			&random.lvl=2;
		end;
		if ^missing(&random&varIn) and ^&random._h_.check() then do;
			&random.rc=&random._h_.find();
		 	do while(^&random.rc);
				if &random.lvl = 1 and prxmatch(&random.patternid1, strip(sestdtc)) and prxmatch(&random.patternid1, strip(seendtc)) then do;
					&random.start =input(sestdtc, e8601dt.);
					&random.end   =input(seendtc, e8601dt.);
				end;
				else if prxmatch(&random.patternid3, strip(sestdtc)) and prxmatch(&random.patternid3, strip(seendtc)) then do;
					&random.start =input(sestdtc, e8601da.);
					&random.end   =input(seendtc, e8601da.);
					&random.temp  =&random&varIn;
					if &random.lvl=1 then &random&varIn=datepart(&random&varIn);
				end;
				if (&random.flag  and .<&random.start<=&random&varIn<=&random.end) or
			   	   (^&random.flag and .<&random.start<=&random&varIn<&random.end) then leave;
				else call missing(epoch);
				&random&varIn=coalesce(&random.temp, &random&varIn);
				&random.rc=&random._h_.find_next();
				call missing(&random.temp);
			end;
		end;
		output;
		call missing(epoch);
		drop &random: sestdtc seendtc;
	run;
%mend avEpoch;
