/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avStatsSummaryDisplay.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Creates an output dataset with statistics displayed as requested by the user
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avStatsSummaryDisplay(dataIn=
							,dataOut=
							,varsIn=
							,displayTemplate=%str({N}#{Mean}#{SD}#{Min}#{Max}) 
							,emptyNIndicator=
							,emptyStatsIndicator=
							);
	%local arrayVars
		   statsSize
		   position
		   id
		   stop
		   length
		   start
		   text
		   i
		   j
		   avMacroName
		   random
		   varsSize;

	%let avMacroName = &sysmacroname;

	/****************************************/
	/**************Validation****************/
	/****************************************/

	%if %avVerifyRequiredParameterNotNull(parameter=dataIn) %then %return;							
	%if %avVerifyRequiredParameterNotNull(parameter=dataOut) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=varsIn) %then %return;  
	%if %avVerifyRequiredParameterNotNull(parameter=displayTemplate) %then %return;
	%if %avVerifyDatasetExists(dataset=&dataIn) %then %return;
	%if %avVerifyValidDatasetName(datasetName=&dataOut) %then %return;

	%let varsSize=%avArgumentListSize(argumentList=&varsIn);
	%do i=1 %to &varsSize;
		%local var&i;
		%let var&i=%scan(&varsIn, &i, #);
	%end;

	%let id = %sysfunc(prxparse(%str(m/\{\w+\}/oi)));
	%let statsSize=0;
	%do i=1 %to %avArgumentListSize(argumentList=&displayTemplate);
		%let text=%qscan(&displayTemplate, &i, #);
		%let position=0;
		%let start=1;
		%let stop=%length(&text);
		%let position=0;
		%let length=0;
		%syscall prxnext(id, start, stop, text, position, length);
		%do %while(&position);
			%let statsSize = %eval(&statsSize + 1);
			%local stats&statsSize;
			%let stats&statsSize = %substr(&text, %eval(&position + 1), %eval(&length - 2));
			%syscall prxnext(id, start, stop, text, position, length);
		%end;
	%end;

	%if ^&statsSize %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No statistics found in display template;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Please ensure that statistics are enclosed in curly braces {};
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted;
		%return;
	%end;
	
	%let arrayVars=;
	%do i=1 %to &varsSize;
		%do j=1 %to &statsSize;
			%let arrayVars=&arrayVars &&var&i.._&&stats&j;
			%if %avVerifyVariableExists(dataIn=&dataIn, varIn=&&var&i.._&&stats&j) %then %return;
		%end;
	%end;

	%let random = V%sysfunc(rand(integer, 1, 5E6), hex8.);

	data &dataOut;
		set &dataIn;
		length col1 stats &random.temp &random.frag &random.cln_single &random.cln_single_resolved &random.cln_comb &random.cln_comb_resolved variable $200;
		retain &random.template "&displayTemplate";
		array &random.labels [&statsSize] $200 _temporary_ (%do i=1 %to &statsSize;
																"&&stats&i"
															%end;);
		array &random.stats [&varsSize, &statsSize] &arrayVars;
		do &random.i=1 to dim1(&random.stats); 
			do &random.j=1 to dim2(&random.stats); 
				call symputx(&random.labels[&random.j], &random.stats[&random.i, &random.j], 'l');
			end;
			do &random.j=1 to countw(&random.template, '#');
				variable=scan(vname(&random.stats[&random.i, 1]), 1, '_');

				&random.frag=scan(&random.template, &random.j, '#');
				&random.temp=compress(tranwrd(&random.frag, '{', '&'), '}');

				/* Validate stats for missing data */
				&random.cln_single = '';
				&random.cln_single_resolved = '';
				&random.cln_comb = '';
				
				/* Loop through each stat identified in a single observation */
				do &random.k=1 to countc(&random.frag, '}');
					&random.cln_single = scan(&random.template, &random.j, '#');
					&random.cln_single = scan(&random.cln_single, &random.k, '}');
					&random.cln_single = substr(&random.cln_single, index(&random.cln_single, '{') +1);					
					&random.cln_single = cats('&', &random.cln_single);

					&random.cln_single_resolved = resolve(&random.cln_single);				
					&random.cln_comb = cats(&random.cln_comb, &random.cln_single);

					if &random.cln_single_resolved = '' and "&emptyNIndicator" ^= '' and &random.cln_single = '&N' then do;
						call symputx(tranwrd(&random.cln_single, '&', ''), '&emptyNIndicator.', 'l');
					end;
					else if &random.cln_single_resolved = '' and "&emptyStatsIndicator" ^= '' then do;
						call symputx(tranwrd(&random.cln_single, '&', ''), '&emptyStatsIndicator.', 'l');
					end;
				end;
				&random.cln_comb_resolved = resolve(&random.cln_comb);			

				col1=compress(&random.frag, '{}');
				/* Do not resolve column if combined vars are empty. Assumming all values are blank or populated */
				stats='';
				if &random.cln_comb_resolved ^= '' then stats=resolve(&random.temp);
				_order1_=&random.j;

				output;
			end;
		end;
		drop &random:;
	run;
%mend avStatsSummaryDisplay;

