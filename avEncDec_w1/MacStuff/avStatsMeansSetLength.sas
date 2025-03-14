/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avStatsMeansSetLength.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Macro used to perform proc means from a dataset. Typically summary stats.
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avStatsMeansSetLength(dataIn=, dataOut=, usubjid=usubjid, varIn=, byVarsIn=, lengthVarsIn=, treatmentVarIn=, treatmentPreloadfmt=, defineTotalGroups=, section=1, subset=)/minoperator des='Macro used to perform proc means from a dataset. Typically summary stats.';
	%let avMacroName = &sysmacroname;

	%if %avVerifyLibraryExists(library=avgml) %then %return;

	%if %avVerifyRequiredParameterNotNull(parameter=dataIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=dataOut) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=varIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=byVarsIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=lengthVarsIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=treatmentVarIn) %then %return;
	%if %avVerifyRequiredParameterNotNull(parameter=treatmentPreloadfmt) %then %return; 
	%if %avVerifyRequiredParameterNotNull(parameter=section) %then %return;	

	%if %avVerifyDatasetExists(dataset=&dataIn) %then %return;
	%if %avVerifyValidDatasetName(datasetName=&dataOut) %then %return;
	%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&treatmentVarIn) %then %return;


	%let byVarCount = %sysfunc(countw(&byVarsIn, #));
	%do i=1 %to &byVarCount;
		%local tempByVar;
		%let tempByVar = %scan(&byVarsIn, &i, #);

		%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&tempByVar) %then %return;
	%end;

	%let byVarCount = %sysfunc(countw(&lengthVarsIn, #));
	%do i=1 %to &byVarCount;
		%local tempByVar;
		%let tempByVar = %scan(&lengthVarsIn, &i, #);

		%if %avVerifyVariableExists(dataIn=&dataIn,varIn=&tempByVar) %then %return;
	%end;

	%if %substr(&treatmentPreloadfmt, 1, 1) = $ %then %let treatmentPreloadfmt=%substr(&treatmentPreloadfmt, 2); 
	%if %substr(&treatmentPreloadfmt, %length(&treatmentPreloadfmt)) ne . %then %let treatmentPreloadfmt=&treatmentPreloadfmt..;
	%if %avVerifyCatalogEntryExists(entry=work.formats.&treatmentPreloadfmt.format) %then %return;

	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	%local byVarReplaced byVarReplacedComma byVarLenReplaced totalGroupsSize;

	%let byVarReplaced = %sysfunc(tranwrd(&byVarsIn, #, ));
	%let byVarReplacedComma = %sysfunc(tranwrd(&byVarsIn, #, %str(, )));
	%let byVarLenReplaced = %sysfunc(tranwrd(&lengthVarsIn, #, ));

	%let totalGroupsSize = %avArgumentListSize(argumentList=&defineTotalGroups);
	%do i=1 %to &totalGroupsSize;
		%local totalGroup&i
			   totalGroup&i.condition
			   totalGroup&i.value;            
	%end;

	%if %avVerifyTotalGroups %then %return;

	proc sql;
		create table avgml.repeats as 
			select &usubjid, &byVarReplacedComma, count(*) as count
			from &dataIn 
			%if %sysevalf(%superq(subset)^=, boolean) %then %do;
				where &subset
			%end;
			group by &usubjid, &byVarReplacedComma
			having count(*) > 1;
	quit;

	%if %avNumberOfObservations(dataIn=avgml.repeats) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Key combination of variable/s do not yield a unique row;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Please Ensure that key combination yields a unique row;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] See avgml.repeats data for further details;
		%put ERROR:4/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &avMacroName aborted;
		%return;
	%end;

	/*==================================== Initial Sort ===================================*/
	data AVGML.initial_sort;
		set &datain.;

		proc sort;
			by &byVarReplaced.;
	run;


	/*================================== Set Treatments ===================================*/
	data AVGML.start;
		set AVGML.initial_sort;
		format &treatmentVarIn &treatmentPreloadfmt;
		output;

		%avTotalGroups;
	run;


	/*=================================== Select Subset ===================================*/
	data AVGML.start_sorted;
		set AVGML.start;

		%if %sysevalf(%superq(subset)^=, boolean) %then %do;
			where &subset;
		%end;
		
		proc sort;
			by &byVarReplaced. &treatmentVarIn.;
	run;


	/*================================== Calculate Stats ==================================*/
	proc means data=AVGML.start_sorted noprint completetypes nway;
		by &byVarReplaced.;
		class &treatmentVarIn. / preloadfmt;
		format &treatmentVarIn. &treatmentPreloadfmt. ;
		var &varIn.;
		output out=AVGML.av_means_out n=n_ mean=mean_ std=std_ median=median_ min=min_ max=max_ q1=q1_ q3=q3_;
	run;

	/*================================ Get Initial Lengths ================================*/
	data AVGML.lengths(keep=&byVarLenReplaced. length);
		set AVGML.start_sorted;
	 
		if index(strip(put(&varIn., best.)), '.') > 0 then length = length(scan(strip(put(&varIn., best.)), 2, '.'));
		else length = 0;
	 
		proc sort;
			by &byVarLenReplaced. descending length;
	run;

	proc sort nodupkey data=AVGML.lengths; by &byVarLenReplaced.; run;


	/*================================ Set Stats and Length ===============================*/
	data AVGML.av_means_out_lengths;
		merge AVGML.av_means_out AVGML.lengths;
		by &byVarLenReplaced.;
	run;


	/*================================= Set Final Dataset =================================*/
	data &dataOut. (keep=&byVarReplaced. &treatmentVarIn. length _section_ calc_:);
		set AVGML.av_means_out_lengths;

	    if length = 0 then do;
			if n_ ^= 0 		then calc_n 	 	= strip(put(n_				, best.));
			if mean_ ^= . 	then calc_mean 		= strip(put(round(mean_		, 0.1), 8.1));
			if std_ ^= . 	then calc_sd 	 	= strip(put(round(std_		, 0.01), 8.2));
			if median_ ^= . then calc_median 	= strip(put(round(median_	, 0.1), 8.1));
			if q1_ ^= . 	then calc_q1 	 	= strip(put(round(q1_		, 0.1), 8.1));
			if q3_ ^= . 	then calc_q3 	 	= strip(put(round(q3_		, 0.1), 8.1));
			if min_ ^= . 	then calc_min 	 	= strip(put(min_			, best.));
			if max_ ^= . 	then calc_max 	 	= strip(put(max_			, best.));
	    end;
	  	if length = 1 then do;
			if n_ ^= 0 		then calc_n 	 	= strip(put(n_				, best.));
			if mean_ ^= . 	then calc_mean 		= strip(put(round(mean_		, 0.01), 8.2));
			if std_ ^= . 	then calc_sd 	 	= strip(put(round(std_		, 0.001), 8.3));
			if median_ ^= . then calc_median 	= strip(put(round(median_	, 0.01), 8.2));
			if q1_ ^= . 	then calc_q1 	 	= strip(put(round(q1_		, 0.01), 8.2));
			if q3_ ^= . 	then calc_q3 	 	= strip(put(round(q3_		, 0.01), 8.2));
			if min_ ^= . 	then calc_min 	 	= strip(put(round(min_		, 0.1),  8.1));
			if max_ ^= . 	then calc_max 	 	= strip(put(round(max_		, 0.1),  8.1));
	  	end;
	  	if length = 2 then do;
			if n_ ^= 0 		then calc_n 	 	= strip(put(n_				, best.));
			if mean_ ^= . 	then calc_mean 		= strip(put(round(mean_		, 0.001), 8.3));
			if std_ ^= . 	then calc_sd 	 	= strip(put(round(std_		, 0.0001), 8.4));
			if median_ ^= . then calc_median 	= strip(put(round(median_	, 0.001), 8.3));
			if q1_ ^= . 	then calc_q1 		= strip(put(round(q1_		, 0.001), 8.3));
			if q3_ ^= . 	then calc_q3 	 	= strip(put(round(q3_		, 0.001), 8.3));
			if min_ ^= . 	then calc_min 	 	= strip(put(round(min_		, 0.01),  8.2));
			if max_ ^= . 	then calc_max 	 	= strip(put(round(max_		, 0.01),  8.2));
	  	end;
	  	if length > 2 then do;
			if n_ ^= 0 		then calc_n 		= strip(put(n_				, best.));
			if mean_ ^= . 	then calc_mean 		= strip(put(round(mean_		, 0.0001), 8.4));
			if std_ ^= . 	then calc_sd 	 	= strip(put(round(std_		, 0.00001), 8.5));
			if median_ ^= . then calc_median 	= strip(put(round(median_	, 0.0001), 8.4));
			if q1_ ^= . 	then calc_q1 	 	= strip(put(round(q1_		, 0.0001), 8.4));
			if q3_ ^= . 	then calc_q3 	 	= strip(put(round(q3_		, 0.0001), 8.4));
			if min_ ^= . 	then calc_min 	 	= strip(put(round(min_		, 0.001), 8.3));
			if max_ ^= . 	then calc_max 	 	= strip(put(round(max_		, 0.001), 8.3));
	  	end;

		_section_ = &section.;

		proc sort;
			by &byVarReplaced. &treatmentVarIn.;
	run;

	/*============================== Transpose Final Dataset ==============================*/
	proc transpose data=&dataOut. out=&dataOut._t prefix=&dataOut._;
		by &byVarReplaced. _section_;
		id &treatmentVarIn.;
		var calc_n calc_mean calc_sd calc_median calc_q1 calc_q3 calc_min calc_max;
	run;
%mend avStatsMeansSetLength;
