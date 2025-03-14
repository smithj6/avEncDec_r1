/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avGenerateNonStandardSpecADaM.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : To get generate ADaM specs (with no standard ones) from IG and SDTM specs provided.
				   Work for ADaM IG v1.3 as of now. SDTM version on another folder.
				   Current data structure supported: ADSL, BDS, TTE, ADNCA, OCCDS, AE
				   If specify source SDTM, can be single or multiple. (Multiple requires further testing)
				   TODO: Add sheet protection
				   TODO: Add Data validation
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avGenerateNonStandardSpecADaM(ig=, domain=, sourceDomain=, datasetStructure=, debug=0);

	/* Exception handling - mandatory parameters */
	%if %sysevalf(%superq(ig)  =, boolean) or %sysevalf(%superq(domain)  =, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameter IG and DOMAIN are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	
	/* Exception handling - mandatory global variables */
	%if ^%symglobl(mspath) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable mspath is not defined in global scope;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/* Exception handling - library integrity */
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML in study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysfunc(libref(&speclib.)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library &speclib. is not assigned. Assign Library &speclib. in study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	
	/* Exception handling - file path integrity */
	%if ^%sysfunc(fileexist(%bquote(T:\Standard Programs\Prod\Utility\ADaMIG))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] System-wide issue: ADaM IG folder does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Contact Stat Prog Standards Team;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(fileexist(%bquote(&mspath.\01_Specifications\02_ADaM))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Study ADaM spec xlsx folder &mspath.\01_Specifications\02_ADaM does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(fileexist(%bquote(T:\Standard Programs\Prod\Utility\avGenerateNonStandardSpecADaM_Library))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro-wide issue: Sub-Macro folder does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Contact Stat Prog Standards Team;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	
	/* Exception handling - existence of target file */
	%if %sysfunc(fileexist(%bquote(&mspath.\01_Specifications\02_ADaM\&domain..xlsx))) %then %do;
		%put WARNING:1[AVANCE %sysfunc(datetime(), e8601dt.)] Study specification for &domain. already exists;
		%put WARNING:2[AVANCE %sysfunc(datetime(), e8601dt.)] Specification will not be generated;
		%return;
	%end;

	/* ---------------- Parameters ---------------- */
	%let igSpecRoot = %str(T:\Standard Programs\Prod\Utility\ADaMIG);
	%let stdMacroRoot = %str(T:\Standard Programs\Prod\Utility\avGenerateNonStandardSpecADaM_Library);
	%let esc = `;


	/* ---------- Get source/export paths --------- */
	* Source: set IG folder;
	%if &ig = 1.3 %then %do;
		libname adamIG 	xlsx "&igSpecRoot.\ADaMIG_v1.3\ADaMIG_v1.3.xlsx";
		libname occdsIG xlsx "&igSpecRoot.\ADaMIG_v1.3\ADaM_OCCDS_v1.1.xlsx";
		libname ncaIG 	xlsx "&igSpecRoot.\ADaMIG_v1.3\ADaMIG_NCA_v1.0.xlsx";
	%end;

	* Source: SDTM spec library is inherited from %avSetup - stored in &speclib;

	* Output: set spec export folder ;
	%let exportFolder = &mspath\01_Specifications\02_ADaM;


	/* ---------------- Get macros ---------------- */
	* Get individual tab macros ;
	%include "&stdMacroRoot.\avGenerateSpecADaM_Lib.sas";
	* Get main calls that generate the whole spec ;
	%include "&stdMacroRoot.\avGenerateSpecADaM_Main.sas";


	/* --------------- Program Start -------------- */

	* Read xlsx sheets into work lib;
	data AVGML.adamig_var; set adamig.variables; run;
	data AVGML.occdsig_var; set occdsig.variables; run;
	data AVGML.ncaig_var; set ncaig.variables; run;

	* Upcase all input parameters;
	%if ^%sysevalf(%superq(domain)  =, boolean) %then %do;
		%let domain = %upcase(&domain);
	%end;
	%if ^%sysevalf(%superq(sourceDomain)  =, boolean) %then %do;
		%let sourceDomain = %upcase(&sourceDomain);
	%end;
	%if ^%sysevalf(%superq(datasetStructure)  =, boolean) %then %do;
		%let datasetStructure = %upcase(&datasetStructure);
	%end;

	* Generate single spec ;
	***
	Domain				- required.
	sourceDomain		- conditional. If ADxx points to an existing SDTM.xx, then this can be omitted, else specify.
										If multiple, separate by #.
	datasetStructure	- conditional. If ADxx points to an existing SDTM.xx, then ADSL/BDS/ADNCA/OCCDS/OCCDS-AE will be set by SDTM class (overruled if set), else specify.
										Note: TTE cannot be set from SDTM class.
										Note: if sourceDomain is AE, datasetStructure default to AE.
										Note: if sourceDomain is PC, datasetStructure default to ADNCA.
										Avaliable options: ADSL, BDS, TTE, ADNCA, OCCDS, AE
	;

	/* As ADAE -> AE, sourceDomain and dataStructure can be omitted */
	/*%avGenerateSpecADaM_Main(domain=ADAE)*/
	/*%avGenerateSpecADaM_Main(domain=ADSL)*/
	/*%avGenerateSpecADaM_Main(domain=ADLB)*/

	/* If specified as below, TTE will overrule and be used instead of BDS */
	/*%avGenerateSpecADaM_Main(domain=ADMB, datasetStructure=TTE)*/

	/* Case where ADxx does not point specifically to an SDTM domain */
	/*%avGenerateSpecADaM_Main(domain=ADNCA, sourceDomain=PP)*/
	/*%avGenerateSpecADaM_Main(domain=ADPD, sourceDomain=LB, datasetStructure=BDS)*/


	%avGenerateSpecADaM_Main(domain=&domain, sourceDomain=&sourceDomain, datasetStructure=&datasetStructure, exppath=&exportFolder)

	%if &debug = 0 %then %do;
		*clear ig libraries;
		libname adamig clear;
		libname occdsig clear;
		libname ncaig clear;
	%end;

%mend avGenerateNonStandardSpecADaM;
