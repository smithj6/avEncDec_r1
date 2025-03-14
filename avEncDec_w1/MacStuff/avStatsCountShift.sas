/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avStatsCountShift.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Obtains the shift from baseline count. Typically used in Labs, ECGs for safety analysis
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avStatsCountShift(dataIn=
				        ,dataOut=
				        ,treatmentVarIn=
				        ,treatmentPreloadfmt=
				        ,defineTotalGroups=
				        ,subgroupVarsIn=
				        ,subgroupPreloadfmt=
				        ,byVarsIn=
				        ,usubjid=usubjid
				        ,subset=
				        ,varOut=denom
				        ,section=1
				        ,baseVarIn=
				        ,basePreloadfmt=
				        ,postBaseVarIn=
				        ,postBasePreloadfmt=);

	%local i
		   type
		   subgroupVarsSize
		   totalGroupsSize
		   byVarsSize
		   subgroupFormatsSize
		   subgroupCharVarSize
		   baseVarType
		   postBaseVarType
		   random
		   avMacroName;	
 
	%let avMacroName = &sysmacroname;

	/****************************************/
	/**************Validation****************/
	/****************************************/

	%if %avVerifyRequiredParameterNotNull(parameter=dataIn) %then %return;							
	%if %avVerifyRequiredParameterNotNull(parameter=dataOut) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=usubjid) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=section) %then %return;	 
	%if %avVerifyRequiredParameterNotNull(parameter=treatmentVarIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=treatmentPreloadfmt) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=baseVarIn) %then %return;  
	%if %avVerifyRequiredParameterNotNull(parameter=postBaseVarIn) %then %return;  
	%if %avVerifyRequiredParameterNotNull(parameter=basePreloadfmt) %then %return;  
	%if %avVerifyRequiredParameterNotNull(parameter=postBasePreloadfmt) %then %return;  
	%if %avVerifyRequiredParameterNotNull(parameter=varOut) %then %return;
	%if %avVerifyLibraryExists(library=avgml) %then %return;
	%if %avVerifyDatasetExists(dataset=&dataIn) %then %return;
	%if %avVerifyValidDatasetName(datasetName=&dataOut) %then %return;
	%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&usubjid) %then %return;						
	%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&treatmentVarIn) %then %return;
	%if %avVerifyVariableIsNumeric(dataIn=&dataIn,varIn=&treatmentVarIn) %then %return;
	%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&baseVarIn) %then %return;
	%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&postBaseVarIn) %then %return;

	%if %substr(&treatmentPreloadfmt, 1, 1) = $ %then %let treatmentPreloadfmt=%substr(&treatmentPreloadfmt, 2); 
	%if %substr(&treatmentPreloadfmt, %length(&treatmentPreloadfmt)) ne . %then %let treatmentPreloadfmt=&treatmentPreloadfmt..;
	%if %avVerifyCatalogEntryExists(entry=work.formats.&treatmentPreloadfmt.format) %then %return;

	%let baseVarType = %avVarType(dataIn=&dataIn, varIn=&baseVarIn);
	%if %substr(&basePreloadfmt, 1, 1) = $ %then %let basePreloadfmt=%substr(&basePreloadfmt, 2); 
	%if %substr(&basePreloadfmt, %length(&basePreloadfmt)) ne . %then %let basePreloadfmt=&basePreloadfmt..;
	%if %avVerifyCatalogEntryExists(entry=work.formats.&basePreloadfmt.format%sysfunc(ifc(&baseVarType=C, C, %str( )))) %then %return;
	%if &baseVarType=C %then %let basePreloadfmt=$&basePreloadfmt;


	%let postBaseVarType = %avVarType(dataIn=&dataIn, varIn=&postBaseVarIn);
	%if %substr(&postBasePreloadfmt, 1, 1) = $ %then %let postBasePreloadfmt=%substr(&postBasePreloadfmt, 2); 
	%if %substr(&postBasePreloadfmt, %length(&postBasePreloadfmt)) ne . %then %let postBasePreloadfmt=&postBasePreloadfmt..;
	%if %avVerifyCatalogEntryExists(entry=work.formats.&postBasePreloadfmt.format%sysfunc(ifc(&postBaseVarType=C, C, %str( )))) %then %return;
	%if &postBaseVarType=C %then %let postBasePreloadfmt=$&postBasePreloadfmt;
	

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
	
	proc sql;
		create table avgml.repeats as 
			select &usubjid
				  ,count(&usubjid) as count
				   %do i=1 %to &byVarsSize;
			         	,&&byVar&i
			       %end;
			       %do i=1 %to &&subgroupVarsSize;
			         	,&&subgroupVar&i
			       %end;
			from &dataIn 
			%if %sysevalf(%superq(subset)^=, boolean) %then %do;
				where &subset
			%end;
			group by &usubjid
			         %do i=1 %to &byVarsSize;
			         	,&&byVar&i
			         %end;
			          %do i=1 %to &&subgroupVarsSize;
			         	,&&subgroupVar&i
			         %end;
			having count(&usubjid) > 1;
	quit;

	%if %avNumberOfObservations(dataIn=avgml.repeats) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Key combination of variable/s &usubjid does not yield a unique row;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Please Ensure that key combination yields a unique row;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] See avgml.repeats data for further details;
		%put ERROR:4/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted;
		%return;
	%end;

	/****************************************/
	/**************Prep Data*****************/
	/****************************************/

	%let random = V%sysfunc(rand(integer, 1, 5E6), hex8.);

	data avgml.shift01;
		length &random %avCharSubgroups 
		%if &baseVarType=C %then %do;
			&baseVarIn
		%end; 
		%if &postBaseVarType=C %then %do;
			&postBaseVarIn
		%end; 
		$200;
		set &dataIn;
		%if %sysevalf(%superq(subset)^=, boolean) %then %do;
			where &subset;
		%end;
		call missing(&random);
		output;
		%avTotalGroups
		keep &treatmentVarIn %avSubgroups %avByVars &postBaseVarIn &baseVarIn &usubjid;
	run;

	%if &byVarsSize %then %do;
		proc sort data=avgml.shift01;
			by %avByVars;
		run;
	%end;

	proc summary data=avgml.shift01 missing completetypes nway;
		%if &byVarsSize %then %do;
			by %avByVars;
		%end;
		class &treatmentVarIn/preloadfmt exclusive;
		class &postBaseVarIn &baseVarIn/ mlf preloadfmt exclusive;
		%avClassSubgroups
		format &treatmentVarIn &treatmentPreloadfmt &postBaseVarIn &postBasePreloadfmt &baseVarIn &basePreloadfmt
			   %avFormatSubgroups;
		output out=avgml.shift02;
	run;

	data &dataOut;
		set avgml.shift02;
		length col1 postbase $200;
		_section_=&section;
		col1 = vvalue(&baseVarIn);
		postbase=vvalue(&postBaseVarIn);
		rename _freq_ = &varOut;
	run;
%mend avStatsCountShift;
