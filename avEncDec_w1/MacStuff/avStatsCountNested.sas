/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avStatsCountNested.sas
Output           : _NA_
Created on       : 
By               : SP.Standards 
Modified         : 
Note             : obtains counts based on a categorical variable
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avStatsCountNested(dataIn=
					     ,dataOut=nested_count
					     ,usubjid=usubjid
				         ,subgroupVarsIn=
					     ,subgroupPreloadfmt=
					     ,byVarsIn=
					     ,treatmentVarIn=
					     ,treatmentPreloadfmt=
					     ,defineTotalGroups=
					     ,nestedVarsIn=
					     ,nestedVarsIndent=
					     ,catVarIn=
					     ,catPreloadfmt=
					     ,subset=
					     ,section=2
					     ,eventCountVarOut=
					     ,subjectCountVarOut=
					);
	%local
	    i
		random
		avMacroName
	    totalGroupsSize
		subgroupVarsSize
		subgroupFormatsSize
		subgroupCharVarsSize
		byVarsSize
		nestedVarsSize
		nestedVarsIndentSize;	
		
	/****************************************/
	/**************Validation****************/
	/****************************************/

	%let avMacroName = &sysmacroname;
	%if %avVerifyRequiredParameterNotNull(parameter=section) %then %return;						
	%if %avVerifyRequiredParameterNotNull(parameter=dataIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=usubjid) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=treatmentVarIn) %then %return; 
	%if %avVerifyRequiredParameterNotNull(parameter=treatmentPreloadfmt) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=dataOut) %then %return; 
	%if %avVerifyRequiredParameterNotNull(parameter=nestedVarsIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=nestedVarsIndent) %then %return;
	%if %avVerifyLibraryExists(library=avgml) %then %return;
	%if %avVerifyDatasetExists(dataset=&dataIn) %then %return;
	%if %avVerifyValidDatasetName(datasetName=&dataOut) %then %return;	
	%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&usubjid) %then %return;							
	%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&treatmentVarIn) %then %return;
	%if %avVerifyVariableIsNumeric(dataIn=&dataIn,varIn=&treatmentVarIn) %then %return;

	%if %sysevalf(%superq(eventCountVarOut)=, boolean) and %sysevalf(%superq(subjectCountVarOut)=, boolean) %then %do;
		%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Both eventCountVarOut and SubjectCount Parameters are null;
		%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Resetting to defaults;
		%put WARNING:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Assign a variable name to eventCountVarOut or subjectCountVarOut if only one is desired;
		%let eventCountVarOut = NEVT;
		%let subjectCountVarOut = NSUB;
	%end;
	%if %qupcase(&eventCountVarOut) = %qupcase(&subjectCountVarOut) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] eventCountVarOut and SubjectCount cannot be the same as they become variable names;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted;
		%return;
	%end;
	%if %sysevalf(%superq(catVarIn)^=, boolean) %then %do;
		%if %avVerifyRequiredParameterNotNull(parameter=catPreloadfmt) %then %return; 
		%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&catVarIn) %then %return;					
		%if %avVerifyVariableIsNumeric(dataIn=&dataIn,varIn=&treatmentVarIn) %then %return;
		%if %substr(&catPreloadfmt, 1, 1) = $ %then %let catPreloadfmt=%substr(&catPreloadfmt, 2); 
		%if %substr(&catPreloadfmt, %length(&catPreloadfmt)) ne . %then %let catPreloadfmt=&treatmentPreloadfmt..;
		%if %avVerifyCatalogEntryExists(entry=work.formats.&catPreloadfmt.format) %then %return;					
	%end;

	%if %substr(&treatmentPreloadfmt, 1, 1) = $ %then %let treatmentPreloadfmt=%substr(&treatmentPreloadfmt, 2); 
	%if %substr(&treatmentPreloadfmt, %length(&treatmentPreloadfmt)) ne . %then %let treatmentPreloadfmt=&treatmentPreloadfmt..;
	%if %avVerifyCatalogEntryExists(entry=work.formats.&treatmentPreloadfmt.format) %then %return;								  

	%let subgroupVarsSize=%avArgumentListSize(argumentList=&subgroupVarsIn);
	%let subgroupFormatsSize=%avArgumentListSize(argumentList=&subgroupPreloadfmt);
	%let totalGroupsSize=%avArgumentListSize(argumentList=&defineTotalGroups);
	%let byVarsSize=%avArgumentListSize(argumentList=&byVarsIn);
	%let nestedVarsSize=%avArgumentListSize(argumentList=&nestedVarsIn);
	%let nestedVarsIndentSize=%avArgumentListSize(argumentList=&nestedVarsIndent);

	%if &nestedVarsSize ne &nestedVarsIndentSize %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Unbalanced number of nested vars and nested var indends;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Number of nested var indents must mach number of nested variables;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted;
		%return;
	%end;
	%do i=1 %to &nestedVarsIndentSize;
		%local nestedVarIndent&i;
		%let nestedVarIndent&i=%scan(&nestedVarsIndent, &i, #);
		%if %avVerifyIntegerValue(parameter=nestedVarIndent&i) %then %return;
	%end;		
	%do i=1 %to &nestedVarsSize;
		%local nestedVar&i;
		%let nestedVar&i=%scan(&nestedVarsIn, &i, #);
		%if %avVerifyVariableExists(dataIn=&dataIn, varIn=&&nestedVar&i) %then %return;
	%end;
	%do i=1 %to &subgroupVarsSize;
		%local subgroupVar&i
		       subgroupFormat&i;
	%end;
	%do i=1 %to &byVarsSize;
		%local byVar&i;
	%end;
	%do i=1 %to &totalGroupsSize;
		%local totalGroup&i
			   totalGroup&i.condition
			   totalGroup&i.value;            
	%end;

	%if %avVerifyTotalGroups %then %return;
	%if %avVerifySubgroups %then %return;
	%if %avVerifyByVars %then %return;

	%let subgroupCharVarsSize=%avCharSubgroupsSize;
	%do i=1 %to &subgroupCharVarsSize;
		%local subgroupCharVar&i;            
	%end;

	%avCharSubgroupsArray
	
	proc sort data=&dataIn;
		by &usubjid %avSubgroups %avByVars
			%do i=1 %to &nestedVarsSize;
				&&nestedVar&i
			%end;;
	run;

	%let random=V%sysfunc(rand(integer, 1, 5E6), hex8.);

	data avgml.prep(rename=(
							%do i=1 %to &nestedVarsSize;
								&random._level_&i = &&nestedVar&i
							%end;
							%if %sysevalf(%superq(catVarIn)^=, boolean) %then %do;
								&random.max = &catVarIn
							%end;
							));
		length %avCharSubgroups &random.id_var col1 &random._level_1 - &random._level_&nestedVarsSize $200;
		set &dataIn;
		%if %sysevalf(%superq(subset)^=, boolean) %then %do;
			where &subset;
		%end;
		by &usubjid %avSubgroups %avByVars 
		%do i=1 %to &nestedVarsSize;
			&&nestedVar&i
		%end;;
		%if %sysevalf(%superq(catVarIn)^=, boolean) %then %do;
			retain &random._max_level_1 - &random._max_level_&nestedVarsSize;
		%end;
		%do i=1 %to &nestedVarsSize;
			%if %sysevalf(%superq(catVarIn)^=, boolean) %then %do;
				if first.&&nestedVar&i then &random._max_level_&i=-&sysMaxLong.;
				&random._max_level_&i = max(&random._max_level_&i, &catVarIn);
			%end;
			_indent_ = &&nestedVarIndent&i;
			nested_var_level=&i;
			col1=cats(&&nestedVar&i);
			&random._level_&i=&&nestedVar&i;
			%if %sysevalf(%superq(eventCountVarOut)^=, boolean) %then %do;
				&random.id_var = symget('eventCountVarOut');
				%if %sysevalf(%superq(catVarIn)^=, boolean) %then %do;
					&random.max = &catVarIn;
				%end;
				output;
				%avTotalGroups
			%end;
			%if %sysevalf(%superq(subjectCountVarOut)^=, boolean) %then %do;
				if last.&&nestedVar&i then do;
			    	&random.id_var = symget('subjectCountVarOut');
					%if %sysevalf(%superq(catVarIn)^=, boolean) %then %do;
						&random.max = &random._max_level_&i;
					%end;
					output;
					%avTotalGroups
				end;
			%end;
		%end;
		keep col1 
			&treatmentVarIn 
			&random.id_var 
			nested_var_level 
			%avSubgroups 
			%avByVars 
			&random._level_: 
			_indent_
		%if %sysevalf(%superq(catVarIn)^=, boolean) %then %do;
			&random.max 
		%end;;
	run;

	proc sort data=avgml.prep;
		by %avSubgroups %avByVars
			%do i=1 %to &nestedVarsSize;
				&&nestedVar&i
		    %end;
		    &catVarIn;
	run;

	%*********************************************************;
	%**************Create default order variables*************;
	%*********************************************************;

	 data avgml.prep02;
	 	set avgml.prep;
		by %avSubgroups %avByVars
		   %do i=1 %to &nestedVarsSize;
				&&nestedVar&i
		   %end;;
		%if &byVarsSize or &subgroupVarsSize %then %do;
			if first.
			%if &byVarsSize %then &&byVar&byVarsSize;
			%else %if &subgroupVarsSize %then &&subgroup&subgroupVarsSize;
			then do;
				%do i=1 %to &nestedVarsSize;
					_order&i._ = 0;
				%end;
			end;
		%end;
		%do i=1 %to %eval(&nestedVarsSize - 1);
			if first.&&nestedVar&i then _order%eval(&i + 1)_ =0;
		%end;
		%do i=1 %to &nestedVarsSize;
			if first.&&nestedVar&i then _order&i._ + 1;
		%end;
	run;

	proc sort data=avgml.prep02;
		by nested_var_level _indent_ %avByVars 
			%do i=1 %to &nestedVarsSize;
				_order&i._
				&&nestedVar&i
			%end;
		col1 
		&random.id_var;
	run;
	
	proc summary data=avgml.prep02 missing completetypes nway;
		by nested_var_level _indent_ %avByVars 
		   %do i=1 %to &nestedVarsSize;
		   		_order&i._
				&&nestedVar&i
		   %end;
		col1 
		&random.id_var;
		class &treatmentVarIn/exclusive preloadfmt;
		%if %sysevalf(%superq(catVarIn)^=, boolean) %then %do;
			class &catVarIn/exclusive preloadfmt;
		%end;
		%avClassSubgroups
		format &treatmentVarIn &treatmentPreloadfmt 
		%if %sysevalf(%superq(catVarIn)^=, boolean) %then %do;
			&catVarIn &catPreloadfmt
		%end;
		%avFormatSubgroups;
		output out=avgml.nested_count1;
	run;

	proc sort data=avgml.nested_count1;
		by nested_var_level _indent_ %avSubgroups %avByVars  
			%do i=1 %to &nestedVarsSize;
				_order&i._
				&&nestedVar&i
			%end;
			col1
			%if %sysevalf(%superq(catVarIn)^=, boolean) %then %do;
				&catVarIn
			%end;
			&treatmentVarIn 
			&random.id_var;
	run;
	
	proc transpose data=avgml.nested_count1 out=avgml.nested_count2;
		by nested_var_level _indent_ %avSubgroups %avByVars  
			%do i=1 %to &nestedVarsSize;
				_order&i._
				&&nestedVar&i
			%end;
			col1 
			%if %sysevalf(%superq(catVarIn)^=, boolean) %then %do;
				&catVarIn
			%end;
			&treatmentVarIn;
		var _freq_;
		id &random.id_var;
	run;
	
	data &dataOut;
		set avgml.nested_count2;
		_section_=&section;
		if _indent_ then col1 = repeat(' ', _indent_ - 1)!!col1;
		keep %avSubgroups %avByVars col1 _section_ nested_var_level &treatmentVarIn &subjectCountVarOut &eventCountVarOut _indent_
			 %if %sysevalf(%superq(catVarIn)^=, boolean) %then %do;
				&catVarIn
			 %end;
			 %do i=1 %to &nestedVarsSize;
				_order&i._
			 	&&nestedVar&i
			 %end;;
	run;
%mend avStatsCountNested;
