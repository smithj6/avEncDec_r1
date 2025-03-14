/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avAnnCreateXLSfromXFDF.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Create XLSX file from XFDF file. Part 2 of CRF annotation through XLSX annotation file
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avAnnCreateXLSfromXFDF(xfdfIn=);
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML is study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%symglobl(mspath) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable mspath is not defined in global scope;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysevalf(%superq(xfdfIn)  =, boolean)  %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameter xfdfIn is required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(fileexist(%bquote(&mspath\01_Specifications\04_SDTM_aCRF\&xfdfIn.))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] File &xfdfIn. does not exist in &mspath\01_Specifications\04_SDTM_aCRF;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(fileexist(%bquote(&mspath\01_Specifications\04_SDTM_aCRF\xfdf2sas.map))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Standard map file xfdf2sas.map does not exist in &mspath\01_Specifications\04_SDTM_aCRF;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	%local xlsPath;

	/*=================================== Define XLS Path ==================================*/
    %if %sysfunc(index(%str(&xfdfIn.), .xfdf)) %then %let xlsPath = &mspath\01_Specifications\04_SDTM_aCRF\%sysfunc(tranwrd(%str(&xfdfIn.), .xfdf, .xls));


	/*================================== Read XFDF2SAS.MAP =================================*/
    filename blcrf "&mspath\01_Specifications\04_SDTM_aCRF\&xfdfIn.";
    libname blcrf xml xmlmap = "&mspath\01_Specifications\04_SDTM_aCRF\xfdf2sas.map" access = readonly;


	/*================================ Create Shell Dataset ================================*/
    proc sql noprint;
        create table AVGML._shell
        (DOMAIN      char(20)  		'Domain',
         NAME        char(20)  		'Name',
         ANNOTATION  char(20000) 	'Annotation',
         PAGENO      char(20)  		'CRF Page number',
         POSITION    char(200) 		'Annotation Position for Variable',
         ORIENTATION char(20)  		'Page Orientation',
		 BORDER      char(20)  		'Border'
		)
        ;
    quit;


	/*=============================== Populate Shell Dataset ===============================*/
    data AVGML._annotation;
        set AVGML._shell blcrf.freetext;
        domain = scan(domain, 1, '_');
        if missing(domain) and index(annotation, "(") then domain = strip(scan(annotation, 1, "("));
        orientation = ifc(orientation = '90', 'Portrait', 'Landscape');
      	pageno = put(input(strip(pageno), best.) + 1, best.);
		border = ifc(border = '', 'Solid', 'Striped');
    run;


    libname blcrf clear;
    filename blcrf clear;


	/*================================== Output XLS file ==================================*/
    title;
    footnote;
    ods listing close;
    ods tagsets.excelxp file = "%bquote(&xlsPath.)" style = meadow;
    ods tagsets.excelxp
        options(formulas             = 'no'
                sheet_interval       = 'none'
                embedded_titles      = 'yes'
                wraptext             = 'yes'
                suppress_bylines     = 'no'
                autofilter           = 'yes'
                autofit_height       = 'yes'
                gridlines            = 'yes'
                frozen_headers       = '1'
                absolute_column_width= '8,20,30,10,30,10');

    proc print data = AVGML._annotation noobs;
        var domain name annotation pageno position orientation border;
    quit;

    ods tagsets.excelxp close;
    ods listing;
    footnote;
    title;
%mend avAnnCreateXLSfromXFDF;
