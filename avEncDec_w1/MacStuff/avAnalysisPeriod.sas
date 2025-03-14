/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avAnalysisPeriod.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Derives APERIOD/APERIODC/TRTA/TRTP/TRTAN/TRTPN using ADT/ADTM/ASDT/ASDTM.
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avAnalysisPeriod(dataIn=
					   ,dataOut=
					   ,structure=
					   ,subjectLevelDataIn=) / minoperator;
	%local i
		   j
		   dateVar
		   libname
		   memname
		   extendVariables
		   totalPeriods
		   rc
		   dsid
		   ;
	%do i=1 %to 4;
		%local type&i suffix&i;
	%end;
	%do i=1 %to 6;
		%local var&i;
	%end;
	%if %sysevalf(%superq(dataIn)=,	             boolean) or 
		%sysevalf(%superq(dataOut)=,             boolean) or  
		%sysevalf(%superq(subjectLevelDataIn)=,	 boolean) or 
		%sysevalf(%superq(structure)=,	         boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameters dataIn, dataOut, structure, subjectlevelDataIn required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Assign Library AVGML is study setup file.;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%eval(%qlowcase(%bquote(&structure)) in bds occds) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] structure %bquote(&structure) is not invalid.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Vaild structures are: BDS, OCCDS.;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%let structure=%lowcase(&structure);
	%if ^%sysfunc(exist(%bquote(&dataIn))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Data %bquote(&dataIn) does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(exist(%bquote(&subjectLevelDataIn))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Data %bquote(&subjectLevelDataIn) does not exist;
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
	%let dateVar=%sysfunc(choosec(%sysfunc(whichc(&structure, bds, occds)), adt, astdt));
	%if ^%sysfunc(varnum(&dsid, &dateVar)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Structure is %upcase(structure) however, variable &dateVar not found in &dataIn data;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let rc=%sysfunc(close(&dsid));
		%return;
	%end;
	%if %sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, &dateVar)))) ne N %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &dateVar in &dataIn data is not in expected type;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expected type is Numeric;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let rc=%sysfunc(close(&dsid));
		%return;
	%end;
	%let var1=trta;
	%let var2=trtp;
	%let var3=trtan;
	%let var4=trtpn;
	%let var5=aperiod;
	%let var6=aperiodc;
	%do i=1 %to 6;
		%if %sysfunc(varnum(&dsid, &&var&i)) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &&var&i already exists in &dataIn data;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let rc=%sysfunc(close(&dsid));
			%return;
		%end;
	%end;
	%let rc=%sysfunc(close(&dsid));
	%if %index(&subjectLevelDataIn, .) %then %do;
		%let libname=%upcase(%scan(&subjectLevelDataIn, 1, .));
		%let memname=%upcase(%scan(&subjectLevelDataIn, 2, .));
	%end;
	%else %do;
		%let libname=WORK;
		%let memname=%upcase(&subjectLevelDataIn);
	%end;

	proc sql noprint;
		select coalesce(max(input(compress(name,,'kd'), best.)), 0) into: totalPeriods
		from dictionary.columns
		where libname="&libname" and memname="&memname" and prxmatch("m/^TRT\d{2}P$/oi", strip(name));
	quit;

	%if ^&totalPeriods %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No variables matching TRTxxP/TRTxxPN were found in &subjectLevelDataIn data;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	data avgml.vars;
		length name $32;
		array prefix [5] $3 _temporary_ (4 * 'trt' 'tr');
		array suffix [5] $3 _temporary_ ('a' 'p' 'an' 'pn' 'sdt');
		do i=1 to symgetn('totalPeriods');
			do j=1 to 5;
				name=cats(prefix[j], put(i, z2.), suffix[j]);
				output;
			end;
		end;
		drop i j;
	run;

	data _null_;
		if 0 then set avgml.vars;
		dcl hash _h_(dataset: 'avgml.vars');
		_h_.definekey('name');
		_h_.definedone();
		datetime=datetime();
		name='';
		do until(missing(name));
			call vnext(name);
			if _h_.find(key: lowcase(name))=0 then do;
				put "NOTE:1/[AVANCE " datetime e8601dt. "]" name "already exists in &dataIn data.";
				put "NOTE:2/[AVANCE " datetime e8601dt. "] The available variable will be used.";
				_h_.remove();
			end;
		end;
		_h_.output(dataset: 'avgml.extendvars');
		set &dataIn;
		stop;
	run;

	%let extendVariables=;
	proc sql noprint;
		select name into: extendVariables separated by '#'
		from avgml.extendvars;
	quit;

	%if &sqlObs %then %do;
		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Attempting to join data &dataIn with &subjectLevelDataIn by USUBJID;
		%put NOTE:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Further validation deffered to %nrstr(%%)avJoinTwoTables;

		%avJoinTwoTables(dataIn=&dataIn
						,dataOut=avgml.aperiod
						,refDataIn=&subjectLevelDataIn
						,joinType=left
						,dataJoinVariables=usubjid
						,refDataJoinVariables=usubjid
						,extendVariables=&extendVariables)

		%if ^%sysfunc(exist(avgml.aperiod)) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Could not successfully merge &dataIn with &subjectLevelDataIn.;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] See SAS Log For further details;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;

		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Successfully joined data &dataIn with &subjectLevelDataIn by USUBJID;
		%put NOTE:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Data avgml.aperiod created;
		%put NOTE:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Data avgml.aperiod will now be used as the source data for further execution;
		%let dataIn=avgml.aperiod;
	%end;
	%let dsid=%sysfunc(open(&dataIn));
	%let suffix1=pn;
	%let type1=N;
	%let suffix2=p;
	%let type2=C;
	%let suffix3=an;
	%let type3=N;
	%let suffix4=a;
	%let type4=C;
	%do i=1 %to &totalPeriods;
		%do j=1 %to 4;
			%if %sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, trt%sysfunc(putn(&i, z2.))&&suffix&j)))) ne &&type&j %then %do;
				%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable tr%sysfunc(putn(&i, z2.))&&sufix&j in &dataIn data is not in expected type;
				%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expected type is %sysfunc(choosec(%sysfunc(whichc(&&type&j, C, N)), Character, Numeric));
				%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
				%let rc=%sysfunc(close(&dsid));
				%return;
			%end;
		%end;
		%if %sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, tr%sysfunc(putn(&i, z2.))sdt)))) ne N %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable trt%sysfunc(putn(&i, z2.))sdt in &dataIn data is not in expected type;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expected type is Numeric;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let rc=%sysfunc(close(&dsid));
			%return;
		%end;
	%end;
	%let rc=%sysfunc(close(&dsid));
	%let random=V%sysfunc(rand(integer, 1, 5E6), hex8.);
	
	data &dataOut;
		set &dataIn;
		length aperiodc $200;
		array &random.date [&totalPeriods] 
		%do i=&totalPeriods %to 1 %by -1;
			tr%sysfunc(putn(&i, z2.))sdt
		%end;
		;
		array &random.trtn [&totalPeriods, 2]
		%do i=&totalPeriods %to 1 %by -1;
			trt%sysfunc(putn(&i, z2.))pn
			trt%sysfunc(putn(&i, z2.))an
		%end;
		;
		array &random.trtc [&totalPeriods, 2]
		%do i=&totalPeriods %to 1 %by -1;
			trt%sysfunc(putn(&i, z2.))p
			trt%sysfunc(putn(&i, z2.))a
		%end;
		;
		&random.anchor = &dateVar;
		%if &structure = bds %then %do;
			if .<&random.anchor<&random.date[&totalPeriods] then &random.anchor = &random.date[&totalPeriods];
		%end;
		do &random.i=1 to &totalPeriods;
			if &random.anchor >= &random.date[&random.i] > . then do;
				trta=&random.trtc[&random.i, 2];
				trtan=&random.trtn[&random.i, 2];
				trtp=&random.trtc[&random.i, 1];
				trtpn=&random.trtn[&random.i, 1];
				aperiod=&totalPeriods - &random.i + 1;
				aperiodc=catx(' ', 'Period', aperiod);
				leave;
			end;
		end;

		drop &random: 
		%if ^%sysevalf(%superq(extendVariables)=, boolean) %then %do;
			%sysfunc(tranwrd(&extendVariables, #, %str( )))
		%end;
		;
	run;
%mend avAnalysisPeriod;


