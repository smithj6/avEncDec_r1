/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avStatsNPercentage.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Used to calculate percentage from reference dataset
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avStatsNPercentage(	dataIn=
				   			,dataOut=
				   			,denomDataIn=
				   			,subgroupVarsIn=
				   			,byVarsIn= 
				   			,treatmentVarIn=
				   			,eventCountVarIn=N
				   			,subjectCountVarIn=N
				   			,denomVarIn=Denom
				   			,varOut=N_PCT
				   			,displayOption=1
				   			,nullIfDenomZero=Y 
				   			,zeroDecimal100Percent=Y 
							,nOnly0Count=Y 
				   			,percentSymbol=Y
				   			,percentFmt=8.1
					 	   ) /minoperator;

 %local i
 		random
 		nOnlyDisplay
		nPercentDisplay
		nPercentDenominatorDisplay
		nPercentEventDisplay
		nPercentDenominatorEventDisplay
 		joinVariables
		avMacroName;

	%*Option 0: n;
	%*Option 1: n (x.xx[%]);
	%*Option 2: n/N (x.xx[%]);
	%*Option 3: n (x.xx[%]) [xx];
	%*Option 4: n/N (x.xx[%]) [xx];

	%let nOnlyDisplay					 =0;	
	%let nPercentDisplay				 =1;	
	%let nPercentDenominatorDisplay		 =2;	
	%let nPercentEventDisplay			 =3;
	%let nPercentDenominatorEventDisplay =4;	
 
	%let avMacroName = &sysmacroname;

	/****************************************/
	/**************Validation****************/
	/****************************************/

	%if %avVerifyRequiredParameterNotNull(parameter=dataIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=dataOut) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=varOut) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=subjectCountVarIn) %then %return; 
	%if %avVerifyRequiredParameterNotNull(parameter=displayOption) %then %return;
	%if %avVerifyValidVarName(varName=&varOut) %then %return;
	%if %avVerifyLibraryExists(library=avgml) %then %return;
	%if %avVerifyDatasetExists(dataset=&dataIn) %then %return;
	%if %avVerifyValidDatasetName(datasetName=&dataOut) %then %return;					
	%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&subjectCountVarIn) %then %return;
	%if %avVerifyVariableIsNumeric(dataIn=&dataIn,varIn=&subjectCountVarIn) %then %return;
	%if %avVerifyVariableDoesNotExist(dataIn=&dataIn,varIn=&varOut) %then %return;
	%if %avVerifyVariableDoesNotExist(dataIn=&dataIn,varIn=pct) %then %return;

	%if ^(%bquote(&displayOption) in (&nOnlyDisplay &nPercentDisplay &nPercentDenominatorDisplay &nPercentEventDisplay &nPercentDenominatorEventDisplay)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid selection for displayOption;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Valid options are &nOnlyDisplay, &nPercentDisplay, &nPercentDenominatorDisplay, &nPercentEventDisplay, and &nPercentDenominatorEventDisplay;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted.;
		%return;
	%end;

	%if &displayOption %then %do;
		%if %avVerifyRequiredParameterNotNull(parameter=treatmentVarIn) %then %return;
		%if %avVerifyRequiredParameterNotNull(parameter=percentSymbol) %then %return;
		%if %avVerifyRequiredParameterNotNull(parameter=percentFmt) %then %return;
		%if %avVerifyRequiredParameterNotNull(parameter=denomDataIn) %then %return;
		%if %avVerifyRequiredParameterNotNull(parameter=denomVarIn) %then %return; 
		%if %avVerifyRequiredParameterNotNull(parameter=nullIfDenomZero) %then %return; 
		%if %avVerifyRequiredParameterNotNull(parameter=zeroDecimal100Percent) %then %return; 
		%if %avVerifyRequiredParameterNotNull(parameter=nOnly0Count) %then %return; 
		%if %avVerifyDatasetExists(dataset=&denomDataIn) %then %return;
		%if %avVerifyYesNoValue(parameter=nullIfDenomZero) %then %return;
		%if %avVerifyYesNoValue(parameter=percentSymbol) %then %return;
		%if %avVerifyYesNoValue(parameter=zeroDecimal100Percent) %then %return;
		%if %avVerifyYesNoValue(parameter=nOnly0Count) %then %return;

		%if ^%sysfunc(prxmatch(%str(m/^\d\.\d$/oi), &percentFmt)) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid selection for percentFmt;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Supply a valid format w.d format;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted.;
			%return;
		%end;
	
		%let joinVariables = %sysfunc(tranwrd(&treatmentVarIn &subgroupVarsIn &byVarsIn, %str( ), #));
	
		%avJoinTwoTables(dataIn=&dataIn
						,dataOut=avgml.percent
						,refDataIn=&denomDataIn
						,joinType=left
						,dataJoinVariables=&joinVariables
						,refDataJoinVariables=&joinVariables
						,extendVariables=&denomVarIn) 

		%if %avVerifyDatasetExists(dataset=avgml.percent) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Could not successfully merge &dataIn with &denomDataIn;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] See Log for futher details;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted.;
			%return;
		%end;

		%if %avVerifyVariableIsNumeric(dataIn=avgml.percent,varIn=&denomVarIn) %then %return;
	%end;

	%if &displayOption in (&nPercentEventDisplay &nPercentDenominatorEventDisplay) %then %do;
		%if %avVerifyRequiredParameterNotNull(parameter=eventCountVarIn) %then %return;
		%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&eventCountVarIn) %then %return;
		%if %avVerifyVariableIsNumeric(dataIn=&dataIn,varIn=&eventCountVarIn) %then %return;
	%end;

	%let random=V%sysfunc(rand(integer, 1, 5E6), hex8.);

	data &dataOut;
		set %if &displayOption %then avgml.percent;
			%else &dataIn;;
		length &varOut $200;
		retain &random "%sysfunc(ifc(&percentSymbol=Y, %str(%%), %str( )))";
		%if &displayOption = &nOnlyDisplay %then %do;
			&varOut=cats(&subjectCountVarIn);
		%end;
		%else %do;
			if &denomVarIn not in (. 0) then do;
				pct=divide(&subjectCountVarIn, &denomVarIn) * 100;
				pct_formatted = strip(put(pct, &percentFmt.));

				%if &zeroDecimal100Percent = Y %then %do;
					if pct_formatted = '100.0' then do;
						pct_formatted = strip(put(int(pct), best.));
					end;
				%end;

				%if &displayOption = &nPercentDisplay %then %do;
					&varOut=catx(' ', &subjectCountVarIn, cats('(', pct_formatted, &random, ')'));
				%end;
				%else %if &displayOption = &nPercentDenominatorDisplay %then %do;
					&varOut=catx(' ', catx('/', &subjectCountVarIn, &denomVarIn), cats('(', pct_formatted, &random ,')'));
				%end;
				%else %if &displayOption = &nPercentEventDisplay %then %do;
					&varOut=catx(' ', &subjectCountVarIn, cats('(', pct_formatted, &random, ')'), &eventCountVarIn);
				%end;
				%else %if &displayOption = &nPercentDenominatorEventDisplay %then %do;
					&varOut=catx(' ', catx('/', &subjectCountVarIn, &denomVarIn), cats('(', pct_formatted, &random ,')'), &eventCountVarIn);
				%end;
			end;
			else do;
				/* Set default value when denominator is 0 */
				&varOut = '-';

				%if &nullIfDenomZero = N %then %do;
					pct = 0;
					pct_formatted = strip(put(pct, &percentFmt.));

					%if &displayOption = &nPercentDisplay %then %do;
						&varOut=catx(' ', &subjectCountVarIn, cats('(', pct_formatted, &random, ')'));
					%end;
					%else %if &displayOption = &nPercentDenominatorDisplay %then %do;
						&varOut=catx(' ', catx('/', &subjectCountVarIn, &denomVarIn), cats('(', pct_formatted, &random ,')'));
					%end;
					%else %if &displayOption = &nPercentEventDisplay %then %do;
						&varOut=catx(' ', &subjectCountVarIn, cats('(', pct_formatted, &random, ')'), &eventCountVarIn);
					%end;
					%else %if &displayOption = &nPercentDenominatorEventDisplay %then %do;
						&varOut=catx(' ', catx('/', &subjectCountVarIn, &denomVarIn), cats('(', pct_formatted, &random ,')'), &eventCountVarIn);
					%end;
				%end;
			end;

			/* Set only n count if only flagged to remove % */
			%if &nOnly0Count = Y %then %do;
				if &subjectCountVarIn = 0 and pct = 0 then do;
					&varOut = strip(put(&subjectCountVarIn, best.));
				end;
			%end;

		%end;
		drop &random;
	run;
%mend avStatsNPercentage; 
