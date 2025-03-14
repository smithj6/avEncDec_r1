/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avStatsPageBreakBasic.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Macro used to derive a basic page break variable.
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avStatsPageBreakBasic(dataIn=, dataOut=, byVarsIn=, sortVarOut=, obsCount=)/minoperator des='Macro used to derive a basic page break variable.';
	%let avMacroName = &sysmacroname;

	%if %avVerifyLibraryExists(library=avgml) %then %return;

	%if %avVerifyRequiredParameterNotNull(parameter=dataIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=dataOut) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=byVarsIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=obsCount) %then %return;

	%if %avVerifyDatasetExists(dataset=&dataIn) %then %return;
	%if %avVerifyValidDatasetName(datasetName=&dataOut) %then %return;

	%let byVarCount = %sysfunc(countw(&byVarsIn, #));
	%do i=1 %to &byVarCount;
		%local tempByVar;
		%let tempByVar = %scan(&byVarsIn, &i, #);

		%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&tempByVar) %then %return;
	%end;


	/* Check for variables used in macro */
	%if %avVerifyVariableDoesNotExist(dataIn=&dataIn,varIn=av_ident) %then %return;
	%if %avVerifyVariableDoesNotExist(dataIn=&dataIn,varIn=av_ident_lag) %then %return;
	%if %avVerifyVariableDoesNotExist(dataIn=&dataIn,varIn=av_inc) %then %return;
	%if %avVerifyVariableDoesNotExist(dataIn=&dataIn,varIn=&sortVarOut) %then %return;


	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	%local byVarReplaced byVarReplacedComma lastByVar;

	%let byVarReplaced = %sysfunc(tranwrd(&byVarsIn, #, ));
	%let byVarReplacedComma = %sysfunc(tranwrd(&byVarsIn, #, %str(, )));

	/*=========================== Get last by variable specified ==========================*/
	data _null_;
		by_variables = "&byVarReplaced";

		do i=1 by 1 while(scan(by_variables, i, ' ') ^= ' ');
			by_variable = scan(by_variables, i, ' ');
		end;

		call symputx("lastByVar", by_variable);
	run;


	data avgml.&dataIn._sorted;
		set &dataIn.;

		proc sort;
			by &byVarReplaced.;
	run;


	/*==================== Retain combination variable from all byvars ====================*/
	data avgml.retain_1;
		set avgml.&dataIn._sorted;
		by &byVarReplaced.;
		retain av_ident;
		length av_ident $2000.;

		if first.&lastByVar. then av_ident = catx('_', &byVarReplacedComma.);
	run;


	/*====================== Lag combination variable for comparison ======================*/
	data avgml.lag_1;
		set avgml.retain_1;
		by &byVarReplaced.;
		
		av_ident_lag = lag(av_ident);
	run;

	data avgml.final;
		set avgml.lag_1;
		by &byVarReplaced.;
		retain av_inc &sortVarOut.;

		if av_ident ^= '' and av_ident_lag = '' then do;
			av_inc = 1;
			&sortVarOut. = 1;
		end;
		else do;
			av_inc = av_inc + 1;

			if av_ident ^= av_ident_lag  then do;
				av_inc = 1;
				&sortVarOut. = &sortVarOut. + 1;
			end;
			else if av_inc > &obsCount. then do;
				av_inc = 1;
				&sortVarOut. = &sortVarOut. + 1;
			end;
		end;

		proc sort;
			by &sortVarOut. &byVarReplaced.;
	run;

	data &dataOut. (drop=av_ident av_ident_lag av_inc);
		set avgml.final;
	run;
%mend avStatsPageBreakBasic;



