/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avStatsBigN.sas
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

%macro avStatsBigN(	dataIn=
			 		,subset=
			 		,treatmentVarIn=
			 		,treatmentPreloadfmt=
			 		,defineTotalGroups=
			 		,usubjid=
			 		,dataOut=
			 		,varOut=denom
			 		,subgroupVarsIn=
			 		,subgroupPreloadfmt=
			 		,displayfmt=
			 		,includeBigN=
			 		,bigNParenthesis=
			 		,splitBy=|
			 		,textBelowBigN=
			 	 );
	%local i
		   random
		   type
		   subgroupVarsSize
		   totalGroupsSize
		   subgroupFormatsSize
		   subgroupCharVarSize
		   avMacroName;	
 
	%let avMacroName = &sysmacroname;

	/****************************************/
	/**************Validation****************/
	/****************************************/
	%if %avVerifyRequiredParameterNotNull(parameter=dataIn) %then %return;							
	%if %avVerifyRequiredParameterNotNull(parameter=dataOut) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=usubjid) %then %return; 
	%if %avVerifyRequiredParameterNotNull(parameter=treatmentVarIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=treatmentPreloadfmt) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=displayfmt) %then %return;  
	%if %avVerifyRequiredParameterNotNull(parameter=includeBigN) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=bigNParenthesis) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=varOut) %then %return;
	%if %avVerifyValidVarName(varName=&varOut) %then %return;
	%if %avVerifyLibraryExists(library=avgml) %then %return;
	%if %avVerifyDatasetExists(dataset=&dataIn) %then %return;
	%if %avVerifyValidDatasetName(datasetName=&dataOut) %then %return;
	%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&usubjid) %then %return;						
	%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&treatmentVarIn) %then %return;
	%if %avVerifyVariableIsNumeric(dataIn=&dataIn,varIn=&treatmentVarIn) %then %return;
	%if %avVerifyYesNoValue(parameter=includeBigN) %then %return;
	%if %avVerifyYesNoValue(parameter=bigNParenthesis) %then %return;

	%if %upcase(&includeBigN) = N and (%upcase(bigNParenthesis)=Y or %sysevalf(%superq(textBelowBigN)^=, boolean)) %then %do;
		%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Since includeBigN is N;
		%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Values Assigned to bigNParenthesis and textBelowBigN are ignored;
	%end;

	%if %substr(&treatmentPreloadfmt, 1, 1) = $ %then %let treatmentPreloadfmt=%substr(&treatmentPreloadfmt, 2); 
	%if %substr(&treatmentPreloadfmt, %length(&treatmentPreloadfmt)) ne . %then %let treatmentPreloadfmt=&treatmentPreloadfmt..;
	%if %avVerifyCatalogEntryExists(entry=work.formats.&treatmentPreloadfmt.format) %then %return;								  


	%let subgroupVarsSize=%avArgumentListSize(argumentList=&subgroupVarsIn);
	%let subgroupFormatsSize=%avArgumentListSize(argumentList=&subgroupPreloadfmt);
	%let totalGroupsSize=%avArgumentListSize(argumentList=&defineTotalGroups);

	%do i=1 %to &subgroupVarsSize;
		%local subgroupVar&i
			   subgroupFormat&i;
	%end;
	%do i=1 %to &totalGroupsSize;
		%local totalGroup&i
			   totalGroup&i.condition
			   totalGroup&i.value;            
	%end;

	%if %avVerifyTotalGroups %then %return;
	%if %avVerifySubgroups %then %return;

	%let subgroupCharVarsSize=%avCharSubgroupsSize;
	%do i=1 %to &subgroupCharVarsSize;
		%local subgroupCharVar&i;            
	%end;

	%avCharSubgroupsArray
	
	proc sql;
		create table avgml.repeats as 
			select &usubjid
				  ,count(&usubjid) as count
			from &dataIn 
			%if %sysevalf(%superq(subset)^=, boolean) %then %do;
				where &subset
			%end;
			group by &usubjid
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
	%let random=V%sysfunc(rand(integer, 1, 5E6), hex8.);

	data avgml.prep;
		length &random %avCharSubgroups $200;
		set &dataIn;
		%if %sysevalf(%superq(subset)^=, boolean) %then %do;
			where &subset;
		%end;
		call missing(&random);
		output;
		%avTotalGroups
		keep &treatmentVarIn %avSubgroups;
	run;

	/****************************************/
	/***************Get Big N****************/
	/****************************************/
	
	proc summary data=avgml.prep completetypes nway;
		class &treatmentVarIn/preloadfmt exclusive;
		%avClassSubgroups
		format &treatmentVarIn &treatmentPreloadfmt
			   %avFormatSubgroups;
		output out=avgml.bign1;
	run;

	%if %qsubstr(&displayfmt, %length(&displayfmt)) ne . %then %let displayfmt=&displayfmt..;
	
	data &dataOut;
		set avgml.bign1;
		length label countc displayfmt gmacrovar $200;
		
		%if &bigNParenthesis=Y %then %do;
			countc = cats('(N=', _freq_, ')');
		%end;
		%else %do;
			countc = cats('N=', _freq_);
		%end;

		displayfmt = put(&treatmentVarIn, &displayfmt -l);

		%if &includeBigN=Y %then %do;
			label=catx("&splitBy", displayfmt, countc, "&textBelowBigN");
		%end;
		%else %do;
			label=catx("&splitBy", displayfmt);
		%end;

		gmacrovar = cats('_', catx('_', of %avSubgroups &treatmentVarIn));
		call symputx(gmacrovar, label, 'g');
		rename _freq_ = &varOut;
		keep _freq_ &treatmentVarIn %avSubgroups label gmacrovar;
	run;
%mend avStatsBigN;

