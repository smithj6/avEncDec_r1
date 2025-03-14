/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avMergeAssignedText.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Merges assigned text column from specifications to dataset
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avMergeAssignedText(domain=, dataIn=, dataOut=);
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML is study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysevalf(%superq(domain)  =, boolean) or %sysevalf(%superq(dataIn)=, boolean) or %sysevalf(%superq(dataOut)=, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameters Domain, dataIn and dataOut are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(prxmatch(%str(m/^[A-Za-z_]([A-Za-z_0-9]{1,31})?$/oi), %bquote(&dataOut))) %then %do;
	 	%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] &dataOut is not a valid SAS dataset name;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(exist(work.&dataIn.)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Input dataset does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	/*================================== Start Spec Assigned Text =========================*/
	data AVGML.av_spec (keep=variable__name assign_text);
		length assign_text $200. variable__name $20.;
		set &speclib..&domain.;
		format _all_;
		where assign_text ^= '';
	run;

	data AVGML.av_failsafe;
		length assign_text $200. variable__name $20.;
		variable__name = 'avFailSafe';
		assign_text = 'Temp';
		output;
	run;

	data AVGML.av_spec_failsafe;
		set AVGML.av_spec AVGML.av_failsafe;

		proc sort;
			by variable__name assign_text;
	run;

	proc transpose data=AVGML.av_spec_failsafe out=AVGML.av_spec_t(drop=_name_ _label_);
		id variable__name;
		var assign_text;
	run;
	/*=================================== End Spec Assigned Text ==========================*/


	/*============================== Get Duplicate Variables ==============================*/
	%local variablestodrop;

	data AVGML.av_original;
		set &dataIn.;
	run;

	proc sql;
		create table AVGML.av_drop as
		select a.name
		from sashelp.vcolumn as a 
		where memname in ('AV_ORIGINAL' 'AV_SPEC_T')
		group by a.name having  count(a.name) > 1;
	quit;

	proc sql noprint;
		select name into: variablestodrop separated by ' ' from AVGML.av_drop;
	quit;
	/*============================== Get Duplicate Variables ==============================*/

	%if %sysevalf(%superq(variablestodrop) =, boolean) %then %do;
		proc sql;
			create table AVGML.av_av_spec_t_in as 
			select a.*, b.*
			from &dataIn. as a
			left join AVGML.av_spec_t as b on 1=1;
		quit;
	%end;
	%else %do;
		%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Duplicate variables: &variablestodrop. droppped from input dataset: &dataIn.;
		proc sql;
			create table AVGML.av_av_spec_t_in as 
			select a.*, b.*
			from &dataIn.(drop=&variablestodrop) as a
			left join AVGML.av_spec_t as b on 1=1;
		quit;
	%end;

	data &dataOut.(drop=avFailSafe);
		set AVGML.av_av_spec_t_in;
	run;

%mend avMergeAssignedText;
