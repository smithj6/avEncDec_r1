/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avStatsStack.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Obtains the bigN from a subject level dataset. Typically ADSL
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avStatsStack(dataIn=
			  		,dataOut=);
	%local tables
		   table
		   random
		   commonCharVars
		   setOperator
		   avMacroName
		   i;	
	%let avMacroName = &sysmacroname;	   
	%if %avVerifyRequiredParameterNotNull(parameter=dataIn) %then %return;							
	%if %avVerifyRequiredParameterNotNull(parameter=dataOut) %then %return;
	%if %avVerifyValidDatasetName(datasetName=&dataOut) %then %return;	
	%if %avVerifyLibraryExists(library=avgml) %then %return;
	%let tables = %avArgumentListSize(argumentList=&dataIn);
	%if &tables = 1 %then %do;
		%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Only one dataset passed to dataIn parameter;
		%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Ensure Multiple datasets are separated by a # hashtag;
	%end;
	%do i=1 %to &tables;
		%local libname&i
			   memname&i;
		%let table = %qupcase(%scan(&dataIn, &i, #));
		%if %avVerifyDatasetExists(dataset=&table) %then %return;
		%if %index(&table, .) %then %do;
			%let libname&i = %scan(&table, 1, .);
			%let memname&i = %scan(&table, 2, .);
		%end;
		%else %do;
			%let libname&i = WORK;
			%let memname&i = &table;
		%end;
	%end;
	%let commonCharVars=0;
	%let setOperator=;
	proc sql;
		create table avgml.commonvars as 
			select name
			from (
					%do i=1 %to &tables;
						&setOperator
						select upcase(name) as name
				    	from dictionary.columns
				   		where libname="&&libname&i" and memname="&&memname&i" 
				   		%let setOperator = union all;
				    %end; 
			   )
			group by name
			having count(name) > 1;
			%if ^&sqlObs %then %do;
				%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No common variables found between datasets;
				quit;
				%goto skip;
			%end;
			%let setOperator=;
			create table avgml.dupchk as
				select name 
				from (
						%do i=1 %to &tables;
							&setOperator
							select upcase(name) as name
					  	  		  ,type
							from dictionary.columns
							where libname="&&libname&i" and memname="&&memname&i" and calculated name in (select name from avgml.commonvars)
							%let setOperator = union;
						%end;
					 )
				group by name
				having count(name) > 1;
				%if &sqlObs %then %do;
					%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Conflicting types for variables with the same name;
					%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Variables with the same name must have the same type across all datasets;
					%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] See work.dupchk data for more information;
					%put ERROR:4/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
					quit;
					%return;
				%end;
				%let setOperator=;
				create table avgml.lengths as
				%do i=1 %to &tables;
					&setOperator
					select upcase(name) as name
					      ,length
					      ,&i as id
					from dictionary.columns
					where libname="&&libname&i" and memname="&&memname&i" and type = 'char' and calculated name in (select name from avgml.commonvars)
					%let setOperator = union all;
				%end;
				order by name;
	quit;
	
	%if ^&sqlObs %then %do;
		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No common character variables were found; 
		%goto skip;
	%end;
	
	proc transpose data=avgml.lengths out=avgml.t_len prefix=length;
		by name;
		var length;
		id id;
	run;
	
	data _null_;
		set avgml.t_len end=eof nobs=nobs;
		var+1;
		call symputx(cats('var', var), name, 'l');
		call symputx(cats('length', var), max(of length:), 'l');
		if eof then call symputx('commonCharVars', nobs, 'l');
	run;
	
	%skip:
	%let random=V%sysfunc(rand(integer, 1, 5E6), hex8.);
	data &dataOut;
		length &random $200
		%do i=1 %to &commonCharVars;
			&&var&i $&&length&i
		%end;;	
		set 
		%do i=1 %to &tables;
			&&libname&i...&&memname&i
		%end;;
		call missing(&random);
		drop &random;
	run;
%mend avStatsStack;
