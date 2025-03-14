/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avStatsTransposeNarrowToWide.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Facilitates the process of transposing variables from narrow to wide. Useful, especially when transposing multiple variables.
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avStatsTransposeNarrowToWide(dataIn=
				  			  	   ,dataOut=
				  			  	   ,subgroupVarsIn=
				  			 	   ,byVarsIn=
				  			 	   ,idVarsIn=
				 			  	   ,transposeVarsIn=);

	%local	j
			transposeVarsSize
			idVarsSize
			subgroupVarsSize
			byVarsSize
			avMacroName 
			i;	

	/****************************************/
	/**************Validation****************/
	/****************************************/

	%let avMacroName = &sysmacroname;	
	%if %avVerifyRequiredParameterNotNull(parameter=dataIn) %then %return;							
	%if %avVerifyRequiredParameterNotNull(parameter=dataOut) %then %return;		
	%if %avVerifyRequiredParameterNotNull(parameter=transposeVarsIn) %then %return;			
	%if %avVerifyRequiredParameterNotNull(parameter=idVarsIn) %then %return;			
	%if %avVerifyLibraryExists(library=avgml) %then %return;
	%if %avVerifyValidDatasetName(datasetName=&dataOut) %then %return;	
	%let transposeVarsSize=%avArgumentListSize(argumentList=&transposeVarsIn);
	%let idVarsSize=%avArgumentListSize(argumentList=&idVarsIn);
	%let subgroupVarsSize=%avArgumentListSize(argumentList=&subgroupVarsIn);
	%let byVarsSize=%avArgumentListSize(argumentList=&byVarsIn);
	%do i=1 %to &transposeVarsSize;
		%local transposeVar&i;
		%let transposeVar&i=%scan(&transposeVarsIn, &i, #);
		%if %avVerifyVariableExists(dataIn=&dataIn, varIn=&&transposeVar&i) %then %return;
	%end;
	%do i=1 %to &idVarsSize;
		%local idVar&i;
		%let idVar&i=%scan(&idVarsIn, &i, #);
		%if %avVerifyVariableExists(dataIn=&dataIn, varIn=&&idVar&i) %then %return;
	%end;
	%do i=1 %to &subgroupVarsSize;
		%local subgroupVar&i;
		%let subgroupVar&i=%scan(&subgroupVarsIn, &i, #);
		%if %avVerifyVariableExists(dataIn=&dataIn, varIn=&&subgroupVar&i) %then %return;
	%end;
	%do i=1 %to &byVarsSize;
		%local byVar&i;
	%end;
	%if %avVerifyByVars %then %return;

	%if &subgroupVarsSize or &byVarsSize %then %do;
		proc sort data=&dataIn;
			by %avSubgroups %avByVars;
		quit;
	%end;

	%do i=1 %to &transposeVarsSize;
		
		proc sql;
			create table avgml.repeats as
			select &idVar1
					%do j=2 %to &idVarsSize;
						,&&idVar&j
					%end;
					%do j=1 %to &subgroupVarsSize;
						,&&subgroupVar&j
					%end;
					%do j=1 %to &&byVarsSize;
						,&&byVar&j
					%end; 
				from &dataIn
				group by 
				&idVar1
				%do j=2 %to &idVarsSize;
					,&&idVar&j 
				%end;
				%do j=1 %to &subgroupVarsSize;
					,&&subgroupVar&j
				%end;
				%do j=1 %to &&byVarsSize;
					,&&byVar&j
				%end;
				having count(*) > 1;
			quit;

		%if %avNumberOfObservations(dataIn=avgml.repeats) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Key combination of variable/s %avSubgroups %avByVars %sysfunc(tranwrd(&idVarsIn, #, %str( ))) does not yield a unique row;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Please ensure that key combination yields a unique row;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] See avgml.repeats data for further details;
			%put ERROR:4/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted;
			%return;
		%end;
		
		proc transpose data=&dataIn 
					   out=
			%if &transposeVarsSize = 1 %then %do;
				&dataOut
			%end;
			%else %do;
				avgml.&&transposeVar&i 
			%end;
			prefix=&&transposeVar&i.._;
			%if &subgroupVarsSize or &byVarsSize %then %do;
				by %avSubgroups %avByVars;
			%end;
			var &&transposeVar&i;
			id
			%do j=1 %to &idVarsSize;
				&&idVar&j
			%end;;
		run;

	%end;
	%if &transposeVarsSize ne 1 %then %do;
		data &dataOut;
			merge 
			%do i=1 %to &transposeVarsSize;
				avgml.&&transposeVar&i (keep=%avSubgroups %avByVars &&transposeVar&i.._:)
			%end;;
			%if &subgroupVarsSize or &byVarsSize %then %do;
				by %avSubgroups %avByVars;
			%end; 
		run;
	%end;
%mend avStatsTransposeNarrowToWide;
