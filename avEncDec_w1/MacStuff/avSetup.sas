/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avSetup.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Setup file for study wide libraries and variables
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

/*============================== Removing Macro varables ==============================*/
proc sql noprint;
	select name into : del_mvar separated by " " from sashelp.vmacro
	where upcase(scope)="GLOBAL" and not (index(upcase(name), "SQL") or name = "AVGML" or name = "SYSDBMSG" or name = "SYSDBRC");
quit;

%if %symglobl(del_mvar) %then %do; 
	%symdel &del_mvar del_mvar;
%end;

%if ^%symglobl(avgml) %then %do;
	%let avgml = %sysfunc(dcreate(avgml, %sysfunc(pathname(work))));
%end;


/*================================= Assigning Options =================================*/
options validvarname=upcase;
options compress=yes;
options msglevel= i missing=' ' papersize='A4' ls=93 pageno=1 orientation= landscape nodate nonumber yearcutoff=1930 
		topmargin=1in bottommargin=1in rightmargin=1in leftmargin=1in;
option nobyline nomprint nomlogic nosymbolgen noxwait xmin noquotelenmax;
ods escapechar='^';


/*======================= Assigning Global Macros and Libararies ======================*/
%global mspath tflpath client root milestone studyno CRFBuild version;

%let Client			= <Client>;
%let Root			= <Root>;
%let Milestone		= <Milestone>;
%let studyno		= <Studyno>;

%let mspath			= &Client\&root\&Milestone;
%let tflpath		= &Client\&root\&Milestone\05_OutputDocs\01_RTF;
%let tflxlsxpath 	= &Client\&root\&Milestone\05_OutputDocs\06_XLSX;
%let tflpdfpath	 	= &Client\&root\&Milestone\05_OutputDocs\07_PDF;
%let CRFBuild		= Medrio;
%let version		= 2.0;


/*============================ Autocall Libraries - Macros ============================*/
%if %sysfunc(fileref(Macros)) %then %do; 
	libname Macros "&mspath\08_Final Programs\01_Macros";
%end;

options mrecall mautosource mstored sasmstore=Macros sasautos=(sasautos, "&mspath\08_Final Programs\01_Macros", "T:\Standard Programs\Prod\v&version\&CRFbuild\08_Final Programs\01_Macros") mcompilenote=all mautolocdisplay mautolocindes mautocomploc;


/*================================ avInitial moved here ===============================*/
%global styn;

data _null_;
	study1="00000"||strip(compress("&studyno", '', 'kd'));
	study=strip(reverse(substr(strip(reverse(compress(study1))), 1, 5)));
	call symputx("styn", study);
run;

data lib_1;
	set sashelp.vslib;
	where upcase(libname) not in ("MAPS" "MAPSGFK" "MAPSSAS" "SASHELP" "SASUSER" "WORK" "MACROS");
run;

proc sort data=lib_1; by libname; 
run;

proc sql noprint;
	select count(*) into: n_lib from lib_1;
quit;

%if &n_lib >0 %then %do;
	proc sql noprint;
		select "libname "|| strip(libname)|| "  clear;" into: reassign_lib separated by " " from lib_1 ;
	quit;
		
	&reassign_lib;
%end;

proc delete data=lib_1; 
run;

/* 		Assign Libnames 	*/
libname A&styn.rs 	"&mspath\02_SourceData" access=readonly;
libname A&styn.sp 	"&mspath\03_Production\01_SDTM" ;
libname A&styn.ap 	"&mspath\03_Production\02_ADaM" ;
libname A&styn.sv 	"&mspath\04_Validation\01_SDTM" ;
libname A&styn.av 	"&mspath\04_Validation\02_ADaM" ;
libname A&styn.zs 	"&mspath\05_OutputDocs\05_Specifications";
libname A&styn.tf   "&mspath\01_Specifications\03_TFL";
libname A&styn.op   "&mspath\03_Production\03_TFL";
libname A&styn.ov   "&mspath\04_Validation\03_TFL";
libname AVGML 		"&avgml";
/*================================ avInitial moved here ===============================*/


/*======================= Assign variables for study libraries ========================*/
%global source SDTMp SDTMv ADaMp ADaMv speclib spectf tlfp tlfv;

%let source  = A&styn.rs;
%let SDTMp   = A&styn.sp;
%let ADaMP   = A&styn.ap;
%let SDTMv   = A&styn.sv;
%let ADaMv   = A&styn.av;
%let speclib = A&styn.zs;
%let spectf  = A&styn.tf;
%let tlfp    = A&styn.op;
%let tlfv    = A&styn.ov;



/*============================== Declare study variables ==============================*/
%let defaultUsubjid					= usubjid;			/* Specify the default subject identifier variable */
%let defaultTreatmentVar			= trt01an;			/* Specify the default treatment identifier variable */

%let defaultTreatmentDisplayfmt		= displayfmt.;		/* Variable used to reference the default treatment display format, defined below */
%let defaultTreatmentPreloadfmt		= trt.;				/* Variable used to reference the default treatment format, defined below */
%let defaultStatsDisplayfmt			= statDisp.;		/* Variable used to reference the default stats display format, defined below */

%let defaultDefineTotalGroups		= 1 2=3;			/* Default treatment assignment. = can be used to create combinations. # can be used to create multiple combinations */
%let defaultOverallTrtN				= 3;				/* Default treatment that will be used for sorting. Default should be the overall treatment */
%let defaultSubgroup				= ;					/* Default sub group within treatment */

%let defaultIncludeBigN				= Y;				/* Specify whether N count is included in treatment assignment through avStatsBigN */
%let defaultBigNParenthesis			= Y;				/* Specify the default inclusion of parenthesis for N calculation through avStatsBigN. Y for (N=XX) N for N=XX */
%let defaultTextBelowBigN			= n %str(%(%%%));	/* Specify the default text to include below N through avStatsBigN. Default is n (%) */
%let defaultTextBelowBigNM			= n %str(%(%%%)) M;	/* Specify the default text to include below N through avStatsBigN. Default is n (%) M */

%let defaultSplitBy					= ~;				/* Specify the default split character used for summary stats */
%let defaultAlignment				= decimal;			/* Specify the default alignment used summary stats. Either decimal or center */
%let defaultStatsdisplay			= {N}#{Mean}#{SD}#{Median}#{Min}#{Max}; /* Specify the default layout for summary stats. Rows seperated by # */
 


/*=============================== Declare study formats ===============================*/
proc format;
	value displayfmt
		1 ='Treatment 1'
		2 ='Treatment 2'
		3 ='Total';

	value trt
		1='1'
		2='2'
		3='3';

	value $statDisp
		"N" 		= "n"
		"Mean" 		= "Mean"
		"SD" 		= "Standard deviation"
		"Median" 	= "Median"
		"Min" 		= "Minimum"
		"Max" 		= "Maximum";

	value $tpt
		"pre-dose" 				= "Pre-dose"
		"15 min post-dose" 		= "15 min Post-dose"
		"0.25 hour post-dose" 	= "15 min Post-dose"
		"30 min post-dose" 		= "30 min Post-dose"
		"0.5 hour post-dose" 	= "30 min Post-dose"
		"45 min post-dose" 		= "45 min Post-dose"
		"0.45 hour post-dose" 	= "45 min Post-dose"
		"1 hour post-dose" 		= "1 hour Post-dose"
		"2 hour post-dose" 		= "2 hours Post-dose"
		"3 hour post-dose" 		= "3 hours Post-dose"
		"4 hour post-dose" 		= "4 hours Post-dose"
		"5 hour post-dose" 		= "5 hours Post-dose"
		"6 hour post-dose" 		= "6 hours Post-dose"
		"7 hour post-dose" 		= "7 hours Post-dose"
		"8 hour post-dose" 		= "8 hours Post-dose"
		"9 hour post-dose" 		= "9 hours Post-dose"
		"10 hour post-dose" 	= "10 hours Post-dose"
		"11 hour post-dose" 	= "11 hours Post-dose"
		"12 hour post-dose" 	= "12 hours Post-dose"
		other 					= 'Assign value'
		;
 
	invalue tptnum
		"pre-dose" 				= 0
		"15 min post-dose" 		= 0.15
		"0.25 hour post-dose" 	= 0.15
		"30 min post-dose" 		= 0.30
		"0.5 hour post-dose" 	= 0.30
		"45 min post-dose" 		= 0.45
		"0.45 hour post-dose" 	= 0.45
		"1 hour post-dose" 		= 1
		"2 hour post-dose" 		= 2
		"3 hour post-dose" 		= 3
		"4 hour post-dose" 		= 4
		"5 hour post-dose" 		= 5
		"6 hour post-dose" 		= 6
		"7 hour post-dose" 		= 7
		"8 hour post-dose" 		= 8
		"9 hour post-dose" 		= 9
		"10 hour post-dose" 	= 10
		"11 hour post-dose" 	= 11
		"12 hour post-dose" 	= 12
		other 					= 99;
		;
run;

