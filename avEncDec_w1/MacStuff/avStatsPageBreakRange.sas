/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avStatsPageBreakRange.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Macro used to derive a page break variable within a specified range.
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avStatsPageBreakRange(dataIn=, dataOut=, byVarsIn=, sortVarOut=, obsMinCount=, obsMaxCount=)/minoperator des='Macro used to derive a page break variable within a specified range.';
	%let avMacroName = &sysmacroname;

	%if %avVerifyLibraryExists(library=avgml) %then %return;

	%if %avVerifyRequiredParameterNotNull(parameter=dataIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=dataOut) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=byVarsIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=obsMinCount) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=obsMaxCount) %then %return;

	%if %avVerifyDatasetExists(dataset=&dataIn) %then %return;
	%if %avVerifyValidDatasetName(datasetName=&dataOut) %then %return;

	%let byVarCount = %sysfunc(countw(&byVarsIn, #));
	%do i=1 %to &byVarCount;
		%local tempByVar;
		%let tempByVar = %scan(&byVarsIn, &i, #);

		%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&tempByVar) %then %return;
	%end;


	/* Check for variables used in this macro */
	%if %avVerifyVariableDoesNotExist(dataIn=&dataIn,varIn=av_ident) %then %return;
	%if %avVerifyVariableDoesNotExist(dataIn=&dataIn,varIn=av_ident_lag) %then %return;
	%if %avVerifyVariableDoesNotExist(dataIn=&dataIn,varIn=av_inc) %then %return;
	%if %avVerifyVariableDoesNotExist(dataIn=&dataIn,varIn=av_n_) %then %return;
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

	/*================================== Set inital sort ==================================*/
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

	/*========================== Get Count for each combination ===========================*/
	proc means data=avgml.lag_1 noprint;
		by &byVarReplaced.;
		output out=avgml.lag_1_means(drop=_type_ _freq_) n=av_n_;
	run;

	data avgml.merged;
		merge avgml.lag_1 avgml.lag_1_means;
		by &byVarReplaced.;

		proc sort;
			by &byVarReplaced.;
	run;


	/*================================ Set sorting variable ===============================*/
	data avgml.final;
		set avgml.merged;
		by &byVarReplaced.;
		retain av_inc &sortVarOut.;

		/* Used for warning messages */
		datetime=datetime();

		if av_ident ^= '' and av_ident_lag = '' then do;
			av_inc = 1;
			&sortVarOut. = 1;
		end;
		else do;
			if first.&lastByVar. and av_inc > &obsMinCount. and (av_inc + av_n_) > &obsMaxCount. then do;
				av_inc = 1;
				&sortVarOut. = &sortVarOut. + 1;
			end;
			else do;
				av_inc = av_inc + 1;
			end;

			/* Add hard stop if above check fails */
			if (av_inc > &obsMaxCount. + 1) then do;
				put "WARNING:1/[AVANCE " datetime e8601dt. "] Hard stop for page sorting occurred for group variable: " av_ident;
				put "WARNING:1/[AVANCE " datetime e8601dt. "] Increment variable: (" av_inc ") passed max count (&obsMaxCount.) without the by group breaking";

				av_inc = 1;
				&sortVarOut. = &sortVarOut. + 1;
			end;
		end;

		proc sort;
			by &sortVarOut. &byVarReplaced.;
	run;

	/*=================================== Drop variables ==================================*/
	data &dataOut. (drop=av_ident av_ident_lag av_inc av_n_ datetime);
		set avgml.final;
	run;
%mend avStatsPageBreakRange;



