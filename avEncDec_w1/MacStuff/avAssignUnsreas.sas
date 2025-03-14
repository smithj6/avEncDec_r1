/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avAssignUnsreas.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Assigns UNSREAS variable from source.uns dataset
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avAssignUnsreas(dataIn=	/* Dataset in */
					  ,dataUns=	/* Dataset with unsreas */
					  ,dataOut=	/* Dataset out */
					  ,unsfls=	/* UNS flags separated by #. Either all coded or non-coded. */
					  ,joinVars=/* Join variables between &dataIn and &dataUns separated by #. */
					  ,EDC=		/* EDC, available values: Medrio/Rave/Zelta */
);

	/**
		Required:
		- &joinVars present in &dataIn and &dataUns
		- Macros: avExecuteIfVarExists, avJoinMapTables
	*/


	/* Exception handling: Mandatory Parameters */
	%if %sysevalf(%superq(dataIn)=,  boolean) or 
		%sysevalf(%superq(dataUns)=, boolean) or  
		%sysevalf(%superq(dataOut)=, boolean) or  
		%sysevalf(%superq(unsfls)=,  boolean) or 
		%sysevalf(%superq(joinVars)=,boolean) or 
		%sysevalf(%superq(EDC)=, boolean)  %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] parameters dataIn, dataUns, dataOut, unsfls, joinVars and EDC are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/* Exception handling: AVGML Lib */
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML is study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/* Exception handling: Existence of Input Datasets */
	%if ^%sysfunc(exist(%bquote(&dataIn))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] data %bquote(&dataIn) does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(exist(%bquote(&dataUns))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] data %bquote(&dataUns) does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	
	/* Exception handling: Name format of output dataset */
	%if %sysfunc(prxmatch(%str(m/^[A-Za-z_][A-Za-z_0-9]{1,7}[.][A-Za-z_]([A-Za-z_0-9]{1,31})?$/oi), %bquote(&dataOut))) %then %do;
		%let libref=%scan(&dataOut, 1, .);
		%if %sysfunc(libref(&libref)) %then %do;
	 		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] dataOut is a valid SAS 2 level name, however libref &libref is not assigned!;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;
	%end;
	%else %if ^%sysfunc(prxmatch(%str(m/^[A-Za-z_]([A-Za-z_0-9]{1,31})?$/oi), %bquote(&dataOut))) %then %do;
	 	%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] dataOut is not a valid SAS dataset name!;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/* Exception handling: Existence of uns flags at uns dataset */
	%do i = 1 %to %sysfunc(countw(&unsfls,%str(#)));
		%if "%avExecuteIfVarExists(dataIn=&dataUns,varIn=%scan(&unsfls,&i,%str(#)))" = "*" %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable %scan(&unsfls,&i,%str(#)) does not exist in Source Dataset &dataUns;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Check parameter unsfls in &sysmacroname.;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
			%return;
		%end;
	%end;


	/* EDC-specific macro */
	%macro unsFlCond(EDC=);
		%if &EDC = Medrio %then %do;
			%if %index(%upcase(&unsfls),%str(_CODED)) %then %do;
				%sysfunc( tranwrd(&unsfls,%str(#),%str(+)) ) >= 1
			%end;
			%else %do;
				%sysfunc( tranwrd(&unsfls,%str(#),%str(="Yes" or )) ) = "Yes"
			%end;
		%end;
		%else %if &EDC = Rave %then %do;
			%if %index(%upcase(&unsfls),%str(_RAW)) %then %do;
				%sysfunc( tranwrd(&unsfls,%str(#),%str(="1" or )) ) = "1"
			%end;
			%else %do;
				%sysfunc( tranwrd(&unsfls,%str(#),%str(+)) ) >= 1
			%end;
		%end;
	%mend unsFlCond;



	/* Filter uns dataset with flags */
	data AVGML.unsch;
		set &dataUns;
		where %unsFlCond(EDC=&EDC) ;
	run;
	 
	/* Join dataIn and uns */
	%avJoinTwoTables(dataIn=&dataIn.
					,dataOut=AVGML.beforeSplit
					,refDataIn=AVGML.unsch
					,joinType=left
					,dataJoinVariables=&joinVars
					,refDataJoinVariables=&joinVars
					,extendVariables=unsreas)

	/* Split UNSREAS if > 200 char */
	%avSplitCharVarExceedingMaxLength(dataIn		= AVGML.beforeSplit
				   					 ,dataOut		= &dataOut
				   					 ,varIn			= unsreas
				   					 ,varOutPrefix	= unsreas)

	/* Clear AVGML library */
	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;
%mend;
