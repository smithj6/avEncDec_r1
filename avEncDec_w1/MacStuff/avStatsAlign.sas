/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avStatsAlign.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Macro used to align decimals.
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avStatsAlign( dataIn=
					,dataOut=
					,varIn=
					,varOut=
					,byVarsIn=
					,type=decimal
);
	%let avMacroName = &sysmacroname;

	%if %avVerifyLibraryExists(library=avgml) %then %return;

	%if %avVerifyRequiredParameterNotNull(parameter=dataIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=dataOut) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=varIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=varOut) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=byVarsIn) %then %return;

	%if %avVerifyDatasetExists(dataset=&dataIn) %then %return;
	%if %avVerifyValidDatasetName(datasetName=&dataOut) %then %return;
	%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&varIn) %then %return;
	
	%let byVarCount = %sysfunc(countw(&byVarsIn, #));
	%do i=1 %to &byVarCount;
		%local tempByVar;
		%let tempByVar = %scan(&byVarsIn, &i, #);

		%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&tempByVar) %then %return;
	%end;

	%if &type = decimal %then %do;
		%let byVarFrmted = %sysfunc(tranwrd(&byVarsIn,#,%nrbquote(,)));
		%put &byVarFrmted;
		data avgml.align1;
			set &dataIn;

			length avgml_pattern $200;
			avgml_pattern = prxchange('s/([-0-9.]+)( ?\D*)([-0-9.]*)( ?\D*)([-0-9.]*)/[AV1]$2[AV2]$4[AV3]/', -1, strip(&varIn.));

			%do counter = 1 %to 3;
			avgml_val&counter. = scan(&varIn., &counter., ' ');
			avgml_n&counter. = compress(avgml_val&counter.,'-.','kd');
			avgml_f&counter. = scan(avgml_n&counter.,1,'.');
			avgml_flen&counter. = ifn(avgml_f&counter. = '', 0, length(avgml_f&counter.));
			avgml_a&counter. = scan(avgml_n&counter.,2,'.');
			avgml_alen&counter. = ifn(avgml_a&counter. = '', 0, length(avgml_a&counter.));
			%end;
		run;

		proc sql noprint;
		create table avgml.align2 as
		select *
			%do counter = 1 %to 3;
			, max(avgml_flen&counter.) as avgml_flen&counter.m
			, max(avgml_alen&counter.) as avgml_alen&counter.m
			%end;
		from avgml.align1
		group by &byVarFrmted
		;
		quit;

		data avgml.align3;
			set avgml.align2;

			%do counter = 1 %to 3;
			avgml_flen&counter.diff = avgml_flen&counter.m - avgml_flen&counter.;
			avgml_alen&counter.diff = avgml_alen&counter.m - avgml_alen&counter.;

			length avgml_f&counter.f $100;
			if avgml_f&counter. = '' 			then avgml_f&counter.f = '';
			else if avgml_flen&counter.diff = 0 then avgml_f&counter.f = avgml_f&counter.;
			else 									 avgml_f&counter.f = cats( cat('(*ESC*){nbspace ',avgml_flen&counter.diff,'}'), avgml_f&counter. );
			
			length avgml_a&counter.f $100;
			if avgml_f&counter. = '' 			then avgml_a&counter.f = '';
			else if avgml_alen&counter.diff = 0 then avgml_a&counter.f = avgml_a&counter.;
			else if avgml_a&counter. = '' 		then avgml_a&counter.f = cats( avgml_a&counter. , cat('(*ESC*){nbspace ',avgml_alen&counter.diff+1,'}') );
			else 									 avgml_a&counter.f = cats( avgml_a&counter. , cat('(*ESC*){nbspace ',avgml_alen&counter.diff,'}') );

			length avgml_val&counter.f $100;
			if avgml_a&counter.f = '' 		then avgml_val&counter.f = avgml_f&counter.f;
			else if avgml_a&counter. = '' 	then avgml_val&counter.f = cats(avgml_f&counter.f,avgml_a&counter.f);
			else 								 avgml_val&counter.f = cats(avgml_f&counter.f,'.',avgml_a&counter.f);
			%end;

			length &varOut. $200;
			&varOut. = tranwrd(avgml_pattern, '[AV1]', strip(avgml_val1f));
			&varOut. = tranwrd(&varOut., '[AV2]', strip(avgml_val2f));
			&varOut. = tranwrd(&varOut., '[AV3]', strip(avgml_val3f));
		run;

		data &dataOut;
			set avgml.align3;
			drop avgml_:;
		run;
	%end;
	%else %do;
		data &dataOut;
			set &dataIn;
			&varOut. = &varIn.;
		run;
	%end;
%mend avStatsAlign;
