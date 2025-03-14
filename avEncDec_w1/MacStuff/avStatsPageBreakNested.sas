/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avStatsPageBreakNested.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Performs page breaks for nested variables. A child is never orphaned.
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avStatsPageBreakNested(dataIn=
				  	         ,dataOut=
				             ,subgroupVarsIn=
							 ,byVarsIn=
							 ,continuedLabel=(cont.)
							 ,nestedVarsIn=
						     ,linesPerPage=20
						     ,clearVarsIn=
							 ,catVarIn=
							);
	%local
	  	random
	    i
		j
		avMacroName
		subgroupVarsSize
		byVarsSize
		clearVarsSize
		nestedVarsSize;	
		
	/****************************************/
	/**************Validation****************/
	/****************************************/

	%let avMacroName = &sysmacroname;
	%if %avVerifyRequiredParameterNotNull(parameter=dataIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=linesPerPage) %then %return;
	%if %avVerifyIntegerValue(parameter=linesPerPage) %then %return;	
	%if %avVerifyRequiredParameterNotNull(parameter=continuedLabel) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=dataOut) %then %return; 
	%if %avVerifyRequiredParameterNotNull(parameter=nestedVarsIn) %then %return;
	%if %avVerifyLibraryExists(library=avgml) %then %return;
	%if %avVerifyDatasetExists(dataset=&dataIn) %then %return;
	%if %avVerifyValidDatasetName(datasetName=&dataOut) %then %return;	
	%if %avVerifyVariableExists(dataIn=&dataIn,varIn=col1) %then %return;	
	%if %avVerifyVariableIsCharacter(dataIn=&dataIn,varIn=col1) %then %return;	
	%if %avVerifyVariableDoesNotExist(dataIn=&dataIn,varIn=page) %then %return;	

	%if &linesPerPage <= 0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid value for linesPerPage;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Valid value must be a positive integer greater than 0;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted;
		%return;
	%end;
	
	%let subgroupVarsSize=%avArgumentListSize(argumentList=&subgroupVarsIn);
	%let byVarsSize=%avArgumentListSize(argumentList=&byVarsIn);
	%let nestedVarsSize=%avArgumentListSize(argumentList=&nestedVarsIn);
	%let clearVarsSize=%avArgumentListSize(argumentList=&clearVarsIn);

	%do i=1 %to &nestedVarsSize;
		%local nestedVar&i;
		%let nestedVar&i=%scan(&nestedVarsIn, &i, #);
		%if %avVerifyVariableExists(dataIn=&dataIn, varIn=&&nestedVar&i) %then %return;
		%if %avVerifyVariableExists(dataIn=&dataIn, varIn=_order&i._) %then %return;
		%if %avVerifyVariableIsNumeric(dataIn=&dataIn,varIn=_order&i._) %then %return;	
	%end;
	%do i=1 %to &subgroupVarsSize;
		%local subgroupVar&i;
		%let subgroupVar&i=%scan(&subgroupVarsIn, &i, #);
		%if %avVerifyVariableExists(dataIn=&dataIn, varIn=&&subgroupVar&i) %then %return;
	%end;
	%do i=1 %to &clearVarsSize;
		%local clearVar&i;
		%let clearVar&i=%scan(&clearVarsIn, &i, #);
		%if %avVerifyVariableExists(dataIn=&dataIn, varIn=&&clearVar&i) %then %return;
	%end;
	%do i=1 %to &byVarsSize;
		%local byVar&i;
	%end;

	%if %avVerifyByVars %then %return;

	%if ^%sysevalf(%superq(catVarIn)=, boolean) %then %do;
		%if %avVerifyVariableExists(dataIn=&dataIn, varIn=&catVarIn) %then %return;
		%if %avVerifyVariableIsNumeric(dataIn=&dataIn,varIn=&catVarIn) %then %return;	
		%local distinctCatVarInLevels;
		proc sql noprint;
			select count(distinct &catVarIn) 
				   into: distinctCatVarInLevels trimmed
			from &dataIn;
		quit;
	%end;

	proc sort data=&dataIn;
		by %avSubgroups %avByVars
			%do i=1 %to &nestedVarsSize;
				_order&i._ &&nestedVar&i
			%end;
			&catVarIn;
	run;

	%let random=V%sysfunc(rand(integer, 1, 5E6), hex8.);

	data avgml.prep;
		set &dataIn;
		by %avSubgroups %avByVars 
			%do i=1 %to &nestedVarsSize;
				_order&i._ &&nestedVar&i
			%end;;
		&random.row+1; **count the row number;
		%if &byVarsSize or &subgroupVarsSize %then %do;
			if first.
			%if &byVarsSize %then &&byVar&byVarsSize;
			%else %if &subgroupVarsSize %then &&subgroupVar&subgroupVarsSize;
			 then do; **handle subgroups; 
				page+1;
				&random.row=1;
			end;
		%end;
		&random.remaining = (&linesPerPage - &random.row) + 1;
		if
		%if %sysevalf(%superq(catVarIn)=, boolean) %then &random.row = &linesPerPage;
		%else last.&&nestedVar&nestedVarsSize and &random.remaining < &distinctCatVarInLevels;
			then do; 
			output; **initial Output;
			page+1;
			%do i=1 %to %eval(&nestedVarsSize - %sysevalf(%superq(catVarIn)=, boolean));
				if ^last.&&nestedVar&i then do; 
					col1=trim(&&nestedVar&i)!!" &continuedlabel";
					&random.row=&i;
					call missing (of &random.dummy %do j=1 %to &clearVarsSize;
														&&clearVar&j
												   %end;);
					output;
				end;
			%end;
			else &random.row=0; **should remove;
		end;
		else output; **original row;
		drop &random:;
	run;

	data &dataOut;
		set avgml.prep;
		page+1;
	run;

%mend avStatsPageBreakNested;
