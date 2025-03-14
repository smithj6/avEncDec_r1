/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avAssignVisit.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Assigns Visit, Visitnum and Visitdy from SV domain
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avAssignVisit(dataIn=, dataOut=, dateVar=, visitVar=);
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML is study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(exist(&sdtmp..sv)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Site Visit domain does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	proc sql noprint;
		select count(*) into :N from &sdtmp..sv;
	quit;

	%if &n. = 0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No visits present in SV domain;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(exist(work.&dataIn.)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Input dataset is required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(prxmatch(%str(m/^[A-Za-z_]([A-Za-z_0-9]{1,31})?$/oi), %bquote(&dataOut))) %then %do;
	 	%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] &dataOut is not a valid SAS dataset name;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysevalf(%superq(dateVar)  =, boolean) or %sysevalf(%superq(visitVar)  =, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameters dateVar and visitVar are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%let dsid = %sysfunc(open(&dataIn));
	%if ^%sysfunc(varnum(&dsid, &dateVar)) or ^%sysfunc(varnum(&dsid, &visitVar)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variables &dateVar. and &visitVar not present in dataset &dataIn.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let dsid_=%sysfunc(close(&dsid));
		%return;
	%end;
	%let dsid_=%sysfunc(close(&dsid));

	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	%if %sysfunc(exist(&speclib..tv_metadata)) %then %do;

		%let dsid = %sysfunc(open(&speclib..tv_metadata));
		%if %sysfunc(varnum(&dsid, visit)) and %sysfunc(varnum(&dsid, visit_crf)) %then %do;
			data AVGML.av_tv(keep=visit_crf visit);
				set &speclib..tv_metadata;

				proc sort nodupkey;
					by visit_crf visit;
			run;

			proc sql;
				create table AVGML.av_&dataIn._tv as
				select
					a.*,
					b.visit as av_visit_merge
				from &dataIn. as a
				left join AVGML.av_tv as b on a.&visitVar = b.visit_crf;
			quit;

			%let dsid_=%sysfunc(close(&dsid));
		%end;
		%else %do;
			%put NOTE:[AVANCE %sysfunc(datetime(), e8601dt.)] TV metadata sheet does not exist. Merge will be performed using only SV. CRF visits renamed in SV will not be resolved.;

			data AVGML.av_&dataIn._tv;
				set &dataIn.;

				av_visit_merge = strip(&visitVar.);
			run;
		%end
		%let dsid_=%sysfunc(close(&dsid));

	%end;
	%else %do;
		%put NOTE:[AVANCE %sysfunc(datetime(), e8601dt.)] TV metadata sheet does not exist. Merge will be performed using only SV. CRF visits renamed in SV will not be resolved.;

		data AVGML.av_&dataIn._tv;
			set &dataIn.;

			av_visit_merge = strip(&visitVar.);
		run;
	%end;

	data AVGML.av_&dataIn._tv_;
		set AVGML.av_&dataIn._tv;
		format av_temp_start e8601da.;

		if &dateVar ^= . then av_temp_start = datepart(&dateVar);

		/* Assign date for NOT DONE unscheduled observations from visit. If visit is incorrect merge will not work */
		if av_visit_merge = '' and av_temp_start = . then av_temp_start = input(strip(tranwrd(scan(&visitVar., 2, '('), ')', '')), date11.);
	run;

	data AVGML.av_sv(keep=usubjid visitnum visit visitdy svstdtc av_temp_start);
		set &sdtmp..sv;
		format av_temp_start e8601da.;

		if length(svstdtc) > 10 then av_temp_start = datepart(input(svstdtc, e8601dt.));
		else if length(svstdtc) = 10 then av_temp_start = input(svstdtc, e8601da.);
	run;
	 
	proc sql;
		create table AVGML.av_&dataIn._tv_sv as
		select
			a.*,
			b.visit as visit_sched,
			b.visitnum as visitnum_sched,
			b.visitdy as visitdy_sched,
			c.visit as visit_unsch,
			c.visitnum as visitnum_unsch,
			c.visitdy as visitdy_unsch,
			index(a.&visitVar, 'Unscheduled') as unsch_flag
		from AVGML.av_&dataIn._tv_ as a
		left join AVGML.av_sv as b on a.usubjid = b.usubjid and a.av_visit_merge = b.visit
		left join AVGML.av_sv as c on a.usubjid = c.usubjid and a.av_temp_start = c.av_temp_start and index(a.&visitVar, 'Unscheduled') and index(c.visit, 'Unscheduled');
	quit;

	data &dataOut. (drop=av_visit_merge unsch_flag visit_sched visitnum_sched visitdy_sched visit_unsch visitnum_unsch visitdy_unsch datetime av_temp_start);
		set AVGML.av_&dataIn._tv_sv;

		/* Used for warning messages */
		datetime=datetime();

		if unsch_flag = 1 then do;
			visit = visit_unsch;
			visitnum = visitnum_unsch;
			visitdy = visitdy_unsch;
		end;
		else do;
			visit = visit_sched;
			visitnum = visitnum_sched;
			visitdy = visitdy_sched;
		end;

		if visit = '' then do;
			put "NOTE:1/[AVANCE " datetime e8601dt. "] Visit not assigned for: " %sysfunc(strip(usubjid)) ", " %sysfunc(strip(&visitVar));
		end;
	run;
%mend avAssignVisit;
