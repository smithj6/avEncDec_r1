/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avStatsSortNested.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Used to sort nested count data in any direction
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avStatsSortNested(dataIn=
				   		,dataOut=
						,byVarsIn=
				   		,subgroupVarsIn=
						,nestedVarsIn=
				   		,nestedVarsSortOrder=
						,nestedVarsSortDirection=
						,nestedFrequencySortVarsIn= 
					 	);

	%local
	    i
		j
		operator
		avMacroName
		subgroupVarsSize
		nestedVarsSortOrderSize
		numericSortOrderVarsSize
		nestedVarsSortDirectionSize
		nestedFrequencySortVarsSize
		byVarsSize
		nestedVarsSize;	
		
	/****************************************/
	/**************Validation****************/
	/****************************************/

	%let avMacroName = &sysmacroname;	
	%if %avVerifyRequiredParameterNotNull(parameter=dataIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=dataOut) %then %return; 
	%if %avVerifyRequiredParameterNotNull(parameter=nestedVarsIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=nestedVarsSortOrder) %then %return;	
	%if %avVerifyRequiredParameterNotNull(parameter=nestedVarsSortDirection) %then %return;		
	%if %avVerifyLibraryExists(library=avgml) %then %return;
	%if %avVerifyDatasetExists(dataset=&dataIn) %then %return;
	%if %avVerifyValidDatasetName(datasetName=&dataOut) %then %return;	
	%if %avVerifyVariableExists(dataIn=&dataIn, varIn=nested_var_level) %then %return;
	%if %avVerifyVariableIsNumeric(dataIn=&dataIn,varIn=nested_var_level) %then %return;
	%if %avVerifyVariableExists(dataIn=&dataIn, varIn=_section_) %then %return;
	%if %avVerifyVariableIsNumeric(dataIn=&dataIn,varIn=_section_) %then %return;

	%let subgroupVarsSize=%avArgumentListSize(argumentList=&subgroupVarsIn);
	%let nestedVarsSize=%avArgumentListSize(argumentList=&nestedVarsIn);
	%let nestedVarsSortOrderSize=%avArgumentListSize(argumentList=&nestedVarsSortOrder);
	%let nestedVarsSortDirectionSize=%avArgumentListSize(argumentList=&nestedVarsSortDirection);
	%let nestedFrequencySortVarsSize=%avArgumentListSize(argumentList=&nestedFrequencySortVarsIn);
	%let byVarsSize=%avArgumentListSize(argumentList=&byVarsIn);

	%if &nestedVarsSize ne &nestedVarsSortOrderSize %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Unbalanced number of entries between nestedVarsIn and nestedVarsSortOrder;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Number of entries must match;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted;
		%return;
	%end;
	%if &nestedVarsSize ne &nestedVarsSortDirectionSize %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Unbalanced number of entries between nestedVarsIn and nestedVarsSortDirection;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Number of entries must match;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted;
		%return;
	%end;
	%let numericSortOrderVarsSize = 0;
	%do i=1 %to &nestedVarsSize;
		%local nestedVar&i 
			   sortOrder&i
			   sortDirection&i
			   frequencySortVar&i;
		%let nestedVar&i=%scan(&nestedVarsIn, &i, #);
		%let sortOrder&i=%qlowcase(%qscan(&nestedVarsSortOrder, &i, #));
		%let sortDirection&i=%qlowcase(%qscan(&nestedVarsSortDirection, &i, #));
		%let frequencySortVar&i = %scan(&nestedFrequencySortVarsIn, &i, #);
		%if %avVerifyVariableExists(dataIn=&dataIn, varIn=&&nestedVar&i) %then %return;
		%if %avVerifyVariableExists(dataIn=&dataIn, varIn=_order&i._) %then %return;
		%if %avVerifyVariableIsNumeric(dataIn=&dataIn,varIn=_order&i._) %then %return;
		%if ^%sysevalf(%superq(frequencySortVar&i)=, boolean) %then %do;
			%if %avVerifyVariableExists(dataIn=&dataIn, varIn=&&frequencySortVar&i) %then %return;
			%if %avVerifyVariableIsNumeric(dataIn=&dataIn,varIn=&&frequencySortVar&i) %then %return;
		%end;
		%if &&sortDirection&i = ascending %then %let sortDirection&i=;
		%else %if &&sortDirection&i ne descending %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid selection for nestedVarsSortDirection parameter.;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Valid values are ASCENDING/DESCENDING case insensitive.;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted.;
			%return;
		%end;
		%if &&sortOrder&i = numeric %then %let numericSortOrderVarsSize=%eval(&numericSortOrderVarsSize + 1);
		%else %if &&sortOrder&i ne alphabetic %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid selection for nestedVarsSortOrder parameter.;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Valid values are NUMERIC/ALPHABETIC case insensitive.;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted.;
			%return;
		%end;
	%end;
	%if &numericSortOrderVarsSize ne &nestedFrequencySortVarsSize %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] &numericSortOrderVarsSize nested levels are to be sorted numerically, yet only &nestedFrequencySortVarsSize numeric sort variable is given ;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Number of numeric sorting levels must match with number of numeric sorting variables;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted.;
		%return;
	%end;
	%do i=1 %to &subgroupVarsSize;
		%local subgroupVar&i;
		%let subgroupVar&i=%scan(&subgroupVarsIn, &i, #);
		%if %avVerifyVariableExists(dataIn=&dataIn, varIn=&&subgroupVar&i) %then %return;
	%end;
	%do i=1 %to &byVarsSize;
		%local byVar&i;
	%end;
	%if %avVerifyByVars %then %return;

	%do i=1 %to &nestedVarsSize;

		proc sql;
			create table avgml.aggregated&i as 
				select count(*) as dummy
					   %if &&sortOrder&i = numeric %then %do;
						 ,sum(&&frequencySortVar&i) as &&frequencySortVar&i
					   %end;
					   %do j=1 %to &i;
							,&&nestedVar&j
					   %end;
					   %do j=1 %to &subgroupVarsSize;
							,&&subgroupVar&j
					   %end;
					   %do j=1 %to &byVarsSize;
							,&&byVar&j
					   %end;
				from &dataIn
				where nested_var_level=&i
				group by nested_var_level
						 %do j=1 %to &i;
							,&&nestedVar&j
						 %end;
						 %do j=1 %to &subgroupVarsSize;
							,&&subgroupVar&j
						 %end;
						 %do j=1 %to &byVarsSize;
							,&&byVar&j
						 %end;;	
		quit;

		proc sort data=avgml.aggregated&i
				  out=avgml.level&i.sorted
				  (keep=%avSubgroups %avByVars 
					%do j=1 %to &i;
						&&nestedVar&j
					%end;
					%if &&sortOrder&i = numeric %then &&frequencySortVar&i;
					);
			by %avSubgroups %avByVars 
				%do j=1 %to %eval(&i - 1);
					&&nestedVar&j
				%end;
				&&sortDirection&i
				%if &&sortOrder&i = numeric %then &&frequencySortVar&i;
				&&nestedVar&i;
		run;

		data avgml.level&i.;
			set avgml.level&i.sorted;
			by %avSubgroups %avByVars 
				%do j=1 %to %eval(&i - 1);
					&&nestedVar&j
				%end;
				&&sortDirection&i
				%if &&sortOrder&i = numeric %then &&frequencySortVar&i;
				&&nestedVar&i;
			%do j=1 %to %eval(&i - 1);
				if first.&&nestedVar&j then _order&i._= 0;
			%end;
			_order&i._ + 1;
		run;

		proc sql;
			update &dataIn a
				set _order&i._ = (select _order&i._  from avgml.level&i. b where 
										%do j=1 %to &subgroupVarsSize;
											&operator a.subgroupVar&j = b.subgroupVarj
											%let operator=and;
										%end;
										%let operator=;
										%do j=1 %to &byVarsSize;
											&operator a.byVar&j = b.byVar&j
											%let operator=and;
										%end;
										%let operator=;
										%do j=1 %to &i;
											&operator a.&&nestedVar&j=b.&&nestedVar&j
											%let operator=and;
										%end;
								 )
			;
		quit;
	%end;

	proc sort data=&dataIn out=&dataOut;
		by _section_
			%do i=1 %to &nestedVarsSize;
				_order&i._ &&nestedVar&i
			%end;;
	run;

%mend avStatsSortNested;
