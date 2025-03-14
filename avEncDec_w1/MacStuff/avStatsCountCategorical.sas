/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avStatsCountCategorical.sas
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

%macro avStatsCountCategorical(	dataIn=
						 		,dataOut=
						 		,label=
						 		,usubjid=usubjid
				    	 		,subgroupVarsIn=
						 		,subgroupPreloadfmt=
						 		,byVarsIn=
						 		,treatmentVarIn=
						 		,treatmentPreloadfmt=
						 		,defineTotalGroups=
						 		,catVarIn=
						 		,catPreloadfmt=
						 		,section=1
								,indent=0
						 		,varOut=N
						 		,subset=);
	%local
	    i
		random
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
	%if %avVerifyRequiredParameterNotNull(parameter=dataIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=usubjid) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=label) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=treatmentVarIn) %then %return; 
	%if %avVerifyRequiredParameterNotNull(parameter=treatmentPreloadfmt) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=dataOut) %then %return; 
	%if %avVerifyRequiredParameterNotNull(parameter=catVarIn) %then %return; 
	%if %avVerifyRequiredParameterNotNull(parameter=catPreloadfmt) %then %return; 
	%if %avVerifyRequiredParameterNotNull(parameter=varOut) %then %return; 
	%if %avVerifyRequiredParameterNotNull(parameter=indent) %then %return; 
	%if %avVerifyValidVarName(varName=&varOut) %then %return;
	%if %avVerifyLibraryExists(library=avgml) %then %return;
	%if %avVerifyDatasetExists(dataset=&dataIn) %then %return;
	%if %avVerifyValidDatasetName(datasetName=&dataOut) %then %return;	
	%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&usubjid) %then %return;
	%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&catVarIn) %then %return;	
	%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&treatmentVarIn) %then %return;
	%if %avVerifyVariableIsNumeric(dataIn=&dataIn,varIn=&treatmentVarIn) %then %return;
	%if %avVerifyIntegerValue(parameter=indent) %then %return;

	%if %substr(&treatmentPreloadfmt, 1, 1) = $ %then %let treatmentPreloadfmt=%substr(&treatmentPreloadfmt, 2); 
	%if %substr(&treatmentPreloadfmt, %length(&treatmentPreloadfmt)) ne . %then %let treatmentPreloadfmt=&treatmentPreloadfmt..;
	%if %avVerifyCatalogEntryExists(entry=work.formats.&treatmentPreloadfmt.format) %then %return;	

	%if %substr(&catPreloadfmt, 1, 1) = $ %then %let catPreloadfmt=%substr(&catPreloadfmt, 2); 
	%if %substr(&catPreloadfmt, %length(&catPreloadfmt)) ne . %then %let catPreloadfmt=&catPreloadfmt..;
	%if %avVarType(dataIn=&dataIn,varIn=&catVarIn) = C %then %do;
		%if %avVerifyCatalogEntryExists(entry=work.formats.&catPreloadfmt.formatc) %then %return;
		%let catPreloadfmt=$&catPreloadfmt; 
	%end;
	%else %if %avVerifyCatalogEntryExists(entry=work.formats.&catPreloadfmt.format) %then %return;

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

	%let random=V%sysfunc(rand(integer, 1, 5E6), hex8.);

	proc sort data=&dataIn;
		by &usubjid %avSubgroups %avByVars &catVarIn;
	run;

	data avgml.prep;
		length &random %avCharSubgroups
		%if %avVarType(dataIn=&dataIn,varIn=&catVarIn) = C %then &catVarIn;
		$200;
		set &dataIn;
		%if %sysevalf(%superq(subset)^=, boolean) %then %do;
			where &subset;
		%end;
		by &usubjid %avSubgroups %avByVars &catVarIn;
		if first.&catVarIn then do;
			output;
			%avTotalGroups
		end;
		call missing(&random);
		keep &usubjid %avSubgroups %avByVars &catVarIn &treatmentVarIn;
	run;

	%if &byVarsSize %then %do;
		proc sort data=avgml.prep;
			by %avByVars;
		run;
	%end;

	proc summary data=avgml.prep nway missing completetypes noprint;
		%if &byVarsSize %then %do;
			by %avByVars;
		%end;
		%avClassSubgroups
		class &treatmentVarIn/preloadfmt exclusive;
		class &catVarIn/preloadfmt exclusive;
		format &treatmentVarIn &treatmentPreloadfmt
			   &catVarIn &catPreloadfmt %avFormatSubgroups;
		output out=avgml.cat1;
	run;

	 %let catPreloadfmt = %trim(%qupcase(%qsysfunc(compress(&catPreloadfmt, $.))));
	
	proc format cntlout=avgml.fmt(where=(fmtname="&catPreloadfmt" and type = "%avVarType(dataIn=&dataIn,varIn=&catVarIn)"));
	run;

	%do i=1 %to %avNumberOfObservations(dataIn=avgml.fmt);
		%local order&i;
	%end;

	proc sql;
		select 
			%if %avVarType(dataIn=&dataIn,varIn=&catVarIn) = C %then %do;
				quote(
			%end;
			strip(start)
			%if %avVarType(dataIn=&dataIn,varIn=&catVarIn) = C %then %do;
				)
			%end;
			into: order1-
		from avgml.fmt;
	quit;
			
	data &dataOut;
		set avgml.cat1;
		length label col1 $200;
		label = "&label";
		col1 = vvalue(&catVarIn);
		array &random [&sqlObs] 
		%if %avVarType(dataIn=&dataIn,varIn=&catVarIn) = C %then %do;
			$200
		%end;
		_temporary_ 
		(  %do i=1 %to &sqlObs;
				&&order&i	
			%end;
		);
		_section_ = &section;
		_indent_  = &indent;
		if _indent_ then col1 = repeat(' ', _indent_- 1)!!col1;
		_order1_=which%avVarType(dataIn=&dataIn,varIn=&catVarIn)(&catVarIn, of &random[*]);
		rename _freq_ = &varOut;
		keep &treatmentVarIn &catVarIn %avSubgroups %avByVars _freq_ col1 _section_ label _order1_ _indent_;
	run;
%mend avStatsCountCategorical;
