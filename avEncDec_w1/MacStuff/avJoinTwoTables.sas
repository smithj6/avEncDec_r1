/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avJoinTwoTables.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Utility Macro to join two tables together
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/


%macro avJoinTwoTables(dataIn=
					  ,dataOut=
					  ,refDataIn=
					  ,joinType=left
					  ,dataJoinVariables=
					  ,refDataJoinVariables=
					  ,extendVariables=) / minoperator;
	%local libref i j dsid1 dsid2 rc ds1 ds2 size1 size2 operator duplicatedExtendVariables;
	%if %sysevalf(%superq(dataIn)                =, boolean) or 
		%sysevalf(%superq(dataOut)               =, boolean) or
		%sysevalf(%superq(refDataIn)             =, boolean) or
		%sysevalf(%superq(joinType)     		 =, boolean) or 
		%sysevalf(%superq(dataJoinVariables)     =, boolean) or
		%sysevalf(%superq(refDataJoinVariables)  =, boolean) or
		%sysevalf(%superq(extendVariables)=, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameters dataIn, dataOut, refDataIn, joinType, dataJoinVariables, refDataJoinVariables and extendVariables are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(exist(%bquote(&dataIn))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] data %bquote(&dataIn) does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(exist(%bquote(&refDataIn))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] data %bquote(&refDataIn) does not exist;
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
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Assign Library AVGML is study setup file.;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%eval(%qlowcase(%bquote(&joinType)) in full left right inner) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Join Type %bquote(&joinType) is not invalid.; 
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Vaild types are: full, left, right and inner;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysfunc(countw(%bquote(&refDataJoinVariables),#)) ne 
		%sysfunc(countw(%bquote(&dataJoinVariables),#)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Unequal number of join variables between refDataJoinVariables and dataJoinVariables;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Number of join variables must match;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%let ds1=&dataIn;
	%let ds2=&refDataIn;
	%let size1=%sysfunc(countw(&dataJoinVariables, #));
	%let size2=%sysfunc(countw(&extendVariables, #));

	%do i=1 %to &size1;
		%local ds1JoinVar&i ds2JoinVar&i;
		%let ds1JoinVar&i=%scan(&dataJoinVariables, &i, #);
		%let ds2JoinVar&i=%scan(&refDataJoinVariables, &i, #);
		%do j=1 %to 2;
			%if ^%sysfunc(prxmatch(%str(m/^[_A-Za-z]([_A-Za-z0-9]{1,31})?$/oi), %bquote(&&ds&j.JoinVar&i))) %then %do;
				%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable %bquote(&&ds&j.JoinVar&i) is not a valid variable name;
				%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
				%return;
			%end;
		%end;
	%end;
	%do i=1 %to 2;
		%local dsid&i;
		%let dsid&i=%sysfunc(open(&&ds&i));
		%do j=1 %to &size1;
			%if ^%sysfunc(varnum(&&dsid&i, &&ds&i.joinVar&j)) %then %do;
				%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &&ds&i.joinVar&j not found in &&ds&i data;
				%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
				%let rc=%sysfunc(close(&&dsid&i));
				%return;
			%end;	
		%end;
	%end;
	%do i=1 %to &size1;
		%if %sysfunc(vartype(&dsid1, %sysfunc(varnum(&dsid1, &&ds1joinVar&i)))) ne 
			%sysfunc(vartype(&dsid2, %sysfunc(varnum(&dsid2, &&ds2joinVar&i)))) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable type mismatch between &dataIn..&&ds1joinVar&i and &refDataIn..&&ds2joinVar&i;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let rc=%sysfunc(close(&dsid1));
			%let rc=%sysfunc(close(&dsid2));
			%return;
		%end;	
	%end;
	%do i=1 %to &size2;
		%local extendVar&i;
		%let extendVar&i=%scan(&extendVariables, &i, #);
		%if ^%sysfunc(prxmatch(%str(m/^[_A-Za-z]([_A-Za-z0-9]{1,31})?$/oi), %bquote(&&extendVar&i))) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable %bquote(&&extendVar&i) is not a valid variable name;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let rc=%sysfunc(close(&dsid1));
			%let rc=%sysfunc(close(&dsid2));
			%return;
		%end;
		%if ^%sysfunc(varnum(&dsid2, &&extendVar&i)) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &&extendVar&i not found in &refDataIn data;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let rc=%sysfunc(close(&dsid1));
			%let rc=%sysfunc(close(&dsid2));
			%return;
		%end;
		%if %sysfunc(varnum(&dsid1, &&extendVar&i)) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &&extendVar&i already exists in &dataIn data;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let rc=%sysfunc(close(&dsid1));
			%let rc=%sysfunc(close(&dsid2));
			%return;
		%end;	
	%end;

	%let rc=%sysfunc(close(&dsid1));
	%let rc=%sysfunc(close(&dsid2));

	%let duplicatedExtendVariables=0;
	data _null_;
		length vname $100;
		array list [&size2] $200 _temporary_ ( %do i=1 %to &size2;
												"%upcase(%trim(&&extendVar&i))"
											   %end;
											  );
		dcl hash _h_(hashexp:7);
				 _h_.definekey("vname");
				 _h_.definedone();

		do i=1 to dim(list);
			vname=strip(list[i]);
			if ^_h_.check() then do;
				call symputx('duplicatedVariable', vname, 'l');
				call symputx('duplicatedExtendVariables', 1, 'l');
				leave;
			end;
			rc=_h_.add();
		end;
	run;

	%if &duplicatedExtendVariables %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Duplicated variable &duplicatedVariable found in extendVariables list.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] All variables supplied to the extendVariables parameter must be unique.;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Remove all duplicated variables.;
		%put ERROR:4/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%do i=1 %to 2;
		%local dup&i;
		proc sql;
			create table AVGML.ds&i as 
				select 
					&&ds&i.joinVar1
					%do j=2 %to &size1;
						,&&ds&i.joinVar&j
					%end;
					,count(*) as _COUNT_
				from &&ds&i
				group by 
				&&ds&i.joinVar1
					%do j=2 %to &size1;
						,&&ds&i.joinVar&j
					%end;
				having count(*)> 1;
		quit;
		%let dup&i=&sqlObs;
	%end;
	%if &dup1 and &dup2 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Combination of join variables do not yield a unique row on either &dataIn or &refDataIn;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Many-to-Many Merge operation not supported;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] See AVGML.DS1 and AVGML.DS2 for details;
		%put ERROR:4/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%let operator=;
	%if %lowcase(&joinType) = full %then %do;
		%local size3;
		%let dsid1=%sysfunc(open(&dataIn));
		%let size3=0;
		%do i=1 %to %sysfunc(attrn(&dsid1, nvar));
			%if ^%eval(%lowcase(%sysfunc(varname(&dsid1, &i))) in %sysfunc(tranwrd(%trim(%left(%lowcase(&dataJoinVariables))), #, %str( )))) %then %do;
				%local selectVar&size3;
				%let size3=%eval(&size3 + 1);
				%let selectVar&size3 = %sysfunc(varname(&dsid1, &i));	
			%end;
		%end;
		%let rc=%sysfunc(close(&dsid1));
	%end;

	proc sql;
		create table &dataOut as 
			select 
			%if %lowcase(&joinType) = full %then %do;
				coalesce(l.&ds1joinVar1, r.&ds2joinVar1) as &ds1joinVar1
				%do i=2 %to &size1;
					,coalesce(l.&&ds1joinVar&i, r.&&ds2joinVar&i) as &&ds1joinVar&i
				%end;
				%do i=1 %to &size3;
					,l.&&selectVar&i
				%end;
			%end;
			%else %do;
				l.*
			%end;
			%do i=1 %to &size2;
				,r.&&extendVar&i
			%end;
			from &dataIn    as l &joinType join
				 &refDataIn as r on
			%do i=1 %to &size1;
				&operator
				l.&&ds1joinVar&i = r.&&ds2joinVar&i
				%let operator=and;
			%end;
			;
	quit;
%mend avJoinTwoTables;
