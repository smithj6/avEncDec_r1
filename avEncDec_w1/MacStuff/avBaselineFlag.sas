/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avBaselineFlag.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Set--BLFL and --LOBXFL
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	Bug fix: flag only if --ORRES is present, and add exception handling if --ORRES is not present.
Date changed     :  2024-08-19
By				 :	Edgar Wong 

Purpose/Changes  :	Added exception handling.
Date changed     :  2024-07-12
By				 :	Edgar Wong 

Purpose/Changes  :	Copied from S:\SAS Macro Library. Changed macro name to 'av...'.
Date changed     :  2024-06-19
By				 :	Edgar Wong 
=======================================================================================*/

%macro avBaselineFlag(dataIn=	/* Dataset in */
					, dataOut=	/* Dataset out */
					, dtcvar=	/* --DTC for deriving --BLFL/--LOBXFL */
					, byvar=	/* By variables seperated by <space> for derivation */
					, varOut=	/* --BLFL or --LOBXFL */
);


	/* Exception handling: Mandatory Parameters */
	%if %sysevalf(%superq(dataIn)=,  boolean) or 
		%sysevalf(%superq(dataOut)=, boolean) or  
		%sysevalf(%superq(dtcvar)=,boolean) or  
		%sysevalf(%superq(byvar)=, boolean) or 
		%sysevalf(%superq(varOut)=,boolean)  %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] parameters dataIn, dataOut, dtcvar, byvar and varOut are required;
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

	/* Exception handling: Existence of variables - &dtcvar */
	%if "%avExecuteIfVarExists(dataIn=&dataIn,varIn=&dtcvar)" = "*" %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &dtcvar does not exist in Source Dataset &dataIn;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Check parameter dtcvar in &sysmacroname.;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
		%return;
	%end;

	/* Exception handling: Existence of variables - &byvar */
	%do i = 1 %to %sysfunc(countw(&byvar,%str( )));
		%if "%avExecuteIfVarExists(dataIn=&dataIn,varIn=%scan(&byvar,&i,%str( )))" = "*" %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable %scan(&byvar,&i,%str( )) does not exist in Source Dataset &dataIn;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Check parameter byvar in &sysmacroname.;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
			%return;
		%end;
	%end;

	/* Exception handling: --TESTCD in &byvar */
	%if %index(%upcase(&byvar),TESTCD) = 0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable --TESTCD is not in parameter byVar;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
		%return;
	%end;

	/* Exception handling: Existence of variables - --ORRES */
	%if "%avExecuteIfVarExists(dataIn=&dataIn,varIn=%substr(%upcase(&varOut), 1, 2)ORRES)" = "*" %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable --ORRES does not exist in Source Dataset &dataIn;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
		%return;
	%end;

	/* Exception handling: Existed &varOut */
	%if "%avExecuteIfVarExists(dataIn=&dataIn,varIn=&varOut)" = "" %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &varOut already existed in Source Dataset &dataIn;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
		%return;
	%end;

	options validvarname=upcase;

	/* Assigning local macro variables */
	%local flagvar dm refer_dtc check_refer_dtc all_blflvar;

	/* Split &varOut into dm(Domain) and flagvar (Flag affix) */
	%let dm = %substr(%upcase(&varOut), 1, 2);
	%let flagvar = %substr(%upcase(&varOut), 3);

	/* Set reference date to RFSTDTC or RFXSTDTC depending on --BLFL/--LOBXFL */
/*	%let refer_dtc= ;*/
	%if &flagvar = BLFL %then %let refer_dtc = RFSTDTC;
	%else %if &flagvar = LOBXFL %then %let refer_dtc = RFXSTDTC;
	%else %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Check parameter varOut in &sysmacroname, should either be --BLFL or --LOBXFL.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
		%return;
	%end;

	%let check_refer_dtc = NIL;

	proc sql noprint;
		/* Save &dataIn variable list */
		select name into :all_blflvar separated by " " from sashelp.vcolumn
			where upcase(libname) = "WORK" 
			and upcase(memname) = %upcase("&dataIn")
		;

		/* Check if reference DTC exists in &dataIn */
		select name into :check_refer_dtc from sashelp.vcolumn
			where upcase(libname)="WORK" 
			and upcase(memname) = %upcase("&dataIn") 
			and upcase(name) = %upcase("&refer_dtc");
	quit;

	/* If reference DTC does not exist, return error */
	%if &check_refer_dtc = NIL %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] &refer_dtc variable is not available in %upcase(&dataIn).;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname. aborted.;
		%return;
	%end;
	%else %do;

		data AVGML.flag1_&dataIn;
			set &dataIn;

			/* if both --DTC and reference DTC have time components, compare datetimes, else compare dates */
			if index(&dtcvar, "T") and index(&refer_dtc, "T") then do;

				/* Get numeric datetime for record and reference */
				blfl_dt = input(&dtcvar, ??is8601dt.);
				rfs_dt = input(&refer_dtc,??is8601dt.);
				
				/* Set 1 if both datetimes non-missing and record datetime prior to reference */
				flag = rfs_dt and blfl_dt and (blfl_dt < rfs_dt);
			end;
			else do;

				/* Get numeric date for record and reference */
				blfl_d = input(scan(&dtcvar, 1, "T"), ??is8601da.);
				rfs_d = input(scan(&refer_dtc, 1, "T"), ??is8601da.);

				/* Set 1 if both dates non-missing and record date prior to reference */
				flag = rfs_d and blfl_d and (blfl_d < rfs_d);
			end;
		run;

		/* Split records with --TESTCD and date/time prior reference to one dataset, and the rest to another */
		data AVGML.flag2_&dataIn AVGML.flag_np_&dataIn;
			set AVGML.flag1_&dataIn;
			if ^missing(&dm.testcd) and ^missing(&dm.orres) and flag
				then output AVGML.flag2_&dataIn;
				else output AVGML.flag_np_&dataIn;
		run;

		proc sort data = AVGML.flag2_&dataIn;
			by &byvar;
		run;

		/* Within the prior reference date/time record, set --BLFL/LOBXFL to 'Y' for the last --TESTCD */
		data AVGML.flag3_&dataIn;
			length &varOut $10;
			set AVGML.flag2_&dataIn;
			by &byvar;
			if last.&dm.testcd then &varOut = "Y";
		run;

		/* Combine the dataset with --BLFL/LOBXFL and the one with records after reference date/time */
		data &dataOut(keep = &all_blflvar &varOut) ;
			set AVGML.flag3_&dataIn AVGML.flag_np_&dataIn;	
		proc sort;
			by &byvar;
		run;

	%end;

	/* Clear AVGML library */
	proc datasets library = avgml memtype = data kill nolist nowarn;
	quit;
%mend;

/*%Baseline_flag(dataIn=class1, dataOut=class2, dtcvar=egdtc, byvar=usubjid egtestcd egdtc, varOut=eglobxfl)*/
