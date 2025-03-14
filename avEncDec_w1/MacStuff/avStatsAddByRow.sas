/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avStatsAddByRow.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Macro used to add descriptive by row for groupings. Typically summary stats.
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avStatsAddByRow(	dataIn=, 
						dataOut=, 
						labelVar=, 
						displayVar=, 
						sortVarOut=, 
						byVarsIn=, 
						clearVars=, 
						parentRowPrefix=,
						childRowPrefix=)/minoperator des='Macro used to add descriptive by row for groupings. Typically summary stats.';
	%let avMacroName = &sysmacroname;

	%if %avVerifyLibraryExists(library=avgml) %then %return;

	%if %avVerifyRequiredParameterNotNull(parameter=dataIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=dataOut) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=byVarsIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=labelVar) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=displayVar) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=sortVarOut) %then %return;

	%if %avVerifyDatasetExists(dataset=&dataIn) %then %return;
	%if %avVerifyValidDatasetName(datasetName=&dataOut) %then %return;


	%let byVarCount = %sysfunc(countw(&byVarsIn, #));
	%do i=1 %to &byVarCount;
		%local tempByVar;
		%let tempByVar = %scan(&byVarsIn, &i, #);

		%if %avVerifyVariableExists(dataIn=&dataIn, varIn=&tempByVar) %then %return;
	%end;


	%let byVarCount = %sysfunc(countw(&clearVars, #));
	%do i=1 %to &byVarCount;
		%local tempByVar;
		%let tempByVar = %scan(&clearVars, &i, #);

		%if %sysfunc(index(%superq(tempByVar), :)) = 0 %then %do;
			%if %avVerifyVariableExists(dataIn=&dataIn, varIn=&tempByVar) %then %return;
		%end;
	%end;


	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	%local byVarReplaced byVarReplacedComma lastByVar clearVarReplaced;

	%let byVarReplaced = %sysfunc(tranwrd(&byVarsIn, #, ));
	%let byVarReplacedComma = %sysfunc(tranwrd(&byVarsIn, #, %str(, )));

	%let clearVarReplaced = %sysfunc(tranwrd(&clearVars, #, ));

	/*=========================== Get last by variable specified ==========================*/
	data _null_;
		by_variables = "&byVarReplaced";

		do i=1 by 1 while(scan(by_variables, i, ' ') ^= ' ');
			by_variable = scan(by_variables, i, ' ');
		end;

		call symputx("lastByVar", by_variable);
	run;


	data AVGML.sorted;
		set &dataIn.;

		&sortVarOut = 2;
	 
		proc sort;
			by &byVarReplaced.;
	run;


	/*==================================== Get By Rows ====================================*/
	%if ^%sysevalf(%superq(parentRowPrefix)  =, boolean) %then %do;
		data AVGML.by_rows (drop=&clearVarReplaced.);
			set AVGML.sorted;
			by &byVarReplaced.;

			if first.&lastByVar. then do;
				&displayVar = cats( "&parentRowPrefix.", &labelVar);
				&sortVarOut = 1;
				output;
			end;
		run;
	%end;
	%else %do;
		data AVGML.by_rows (drop=&clearVarReplaced.);
			set AVGML.sorted;
			by &byVarReplaced.;

			if first.&lastByVar. then do;
				&displayVar = &labelVar;
				&sortVarOut = 1;
				output;
			end;
		run;
	%end;


	/*===================================== Add Prefix ====================================*/
	%if ^%sysevalf(%superq(childRowPrefix)  =, boolean) %then %do;
		data AVGML.combined;
		 	set AVGML.sorted(in=a) AVGML.by_rows(in=b);

			if a then do;
				&displayVar = cats( "&childRowPrefix.", &displayVar);
			end;
		run;
	%end;
	%else %do;
		data AVGML.combined;
		 	set AVGML.sorted(in=a) AVGML.by_rows(in=b);
		run;
	%end;

	data &dataOut.;
	 	set AVGML.combined;

		proc sort;
			by &byVarReplaced. &sortVarOut.;
	run;
%mend avStatsAddByRow;
