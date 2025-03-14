/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avStatsCountOneRow.sas
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

%macro avStatsCountOneRow(	dataIn=
							,dataOut=one_row
							,label=
							,usubjid=usubjid
				    		,subgroupVarsIn=
							,subgroupPreloadfmt=
							,byVarsIn=
							,treatmentVarIn=
							,treatmentPreloadfmt=
							,defineTotalGroups=
							,subset=
							,section=1
							,order1=1
							,eventCountVarOut=
							,subjectCountVarOut=
							,indent=0
						) /minoperator;
	%local
	    i
		avMacroName
	    totalGroupsSize
		subgroupVarsSize
		subgroupFormatsSize
		subgroupCharVarsSize
		byVarsSize;	
	
	/****************************************/
	/**************Validation****************/
	/****************************************/
	%let avMacroName = &sysmacroname;
	%if %avVerifyRequiredParameterNotNull(parameter=section) %then %return;	
	%if %avVerifyRequiredParameterNotNull(parameter=order1) %then %return;			
	%if %avVerifyRequiredParameterNotNull(parameter=dataIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=dataOut) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=usubjid) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=treatmentVarIn) %then %return; 
	%if %avVerifyRequiredParameterNotNull(parameter=treatmentPreloadfmt) %then %return; 
	%if %avVerifyRequiredParameterNotNull(parameter=label) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=indent) %then %return; 
	%if %avVerifyLibraryExists(library=avgml) %then %return;
	%if %avVerifyDatasetExists(dataset=&dataIn) %then %return;
	%if %avVerifyValidDatasetName(datasetName=&dataOut) %then %return;	
	%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&usubjid) %then %return;							
	%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&treatmentVarIn) %then %return;
	%if %avVerifyVariableIsNumeric(dataIn=&dataIn,varIn=&treatmentVarIn) %then %return;
	%if %avVerifyIntegerValue(parameter=indent) %then %return;

	%if %sysevalf(%superq(eventCountVarOut)=, boolean) and %sysevalf(%superq(subjectCountVarOut)=, boolean) %then %do;
		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Both eventCountVarOut and SubjectCount Parameters are null;
		%put NOTE:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Resetting to defaults;
		%put NOTE:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Assing variable name to eventCountVarOut or subjectCountVarOut if only one is desired;
		%let eventCountVarOut = NEVT;
		%let subjectCountVarOut = NSUB;
	%end;
	%if %qupcase(&eventCountVarOut) = %qupcase(&subjectCountVarOut) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] eventCountVarOut and SubjectCount cannot be the same as they become variable names;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted;
		%return;
	%end;

	%if %substr(&treatmentPreloadfmt, 1, 1) = $ %then %let treatmentPreloadfmt=%substr(&treatmentPreloadfmt, 2); 
	%if %substr(&treatmentPreloadfmt, %length(&treatmentPreloadfmt)) ne . %then %let treatmentPreloadfmt=&treatmentPreloadfmt..;
	%if %avVerifyCatalogEntryExists(entry=work.formats.&treatmentPreloadfmt.format) %then %return;

	%let label = %sysfunc(dequote(&label));  

	%let subgroupVarsSize=%avArgumentListSize(argumentList=&subgroupVarsIn);
	%let subgroupFormatsSize=%avArgumentListSize(argumentList=&subgroupPreloadfmt);
	%let totalGroupsSize=%avArgumentListSize(argumentList=&defineTotalGroups);
	%let byVarsSize=%avArgumentListSize(argumentList=&byVarsIn);
	
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
		by &usubjid %avSubgroups %avByVars;
	run;

	data avgml.prep;
		length id_var col1 %avCharSubgroups $200;
		set &dataIn;
		%if %sysevalf(%superq(subset)^=, boolean) %then %do;
			where &subset;
		%end;
		by &usubjid %avSubgroups %avByVars;
		col1="&label";
		%if %sysevalf(%superq(eventCountVarOut)^=, boolean) %then %do;
			id_var = "&eventCountVarOut";
			output;
			%avTotalGroups
		%end;
		%if %sysevalf(%superq(subjectCountVarOut)^=, boolean) %then %do;
			if first.%if &byVarsSize %then &&byVar&byVarsSize;
					 %else &usubjid; then do;
				id_var = "&subjectCountVarOut";
				output;
				%avTotalGroups
			end;
		%end;
		keep &treatmentVarIn id_var col1 %avSubgroups %avByVars;
	run;

	/* EW 2025-01-17: cater empty avgml.prep */
	proc sql noprint;
		select nobs into :nobs separated by ' ' from dictionary.tables
		where libname='AVGML' and memname='PREP';
	quit;
	%if &nobs = 0 %then %do;
		data avgml.prep;
			if 0 then set avgml.prep;
			col1="&label";
			%if %sysevalf(%superq(eventCountVarOut)^=, boolean) %then %do;
				id_var = "&eventCountVarOut";
				output;
			%end;
			%if %sysevalf(%superq(subjectCountVarOut)^=, boolean) %then %do;
				id_var = "&subjectCountVarOut";
				output;
			%end;
		run;
	%end;
	/* EW 2025-01-17: END cater empty avgml.prep */

	proc sort data=avgml.prep;
		by col1 id_var %avByVars;
	run;
	
	proc summary data=avgml.prep missing completetypes nway;
		by col1 id_var %avByVars;
		class &treatmentVarIn / exclusive preloadfmt;
		%avClassSubgroups
		format &treatmentVarIn &treatmentPreloadfmt %avFormatSubgroups;
		output out=avgml.countOnerow1;
	run;

	proc sort data=avgml.countOnerow1;
		by col1 %avSubgroups &treatmentVarIn %avByVars id_var;
	run;
	
	proc transpose data=avgml.countOnerow1 out=avgml.countOnerow2;
		by col1 %avSubgroups &treatmentVarIn %avByVars;
		var _freq_;
		id id_var;
	run;
	
	data &dataOut;
		set avgml.countOnerow2;
		_section_=&section;
		_order1_=&order1;
		_indent_  = &indent;
		if _indent_ then col1 = repeat(' ', _indent_- 1)!!col1;
		keep %avSubgroups &treatmentVarIn %avByVars &eventCountVarOut &subjectCountVarOut col1 _section_ _order1_ _indent_;
	run;
%mend avStatsCountOneRow;
