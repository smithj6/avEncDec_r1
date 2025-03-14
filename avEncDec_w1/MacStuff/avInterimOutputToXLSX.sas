/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avInterimOutputToXLSX.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Used to create XLSX file during output reporting
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avInterimOutputToXLSX(outputName=, reportOutput=AVGML.av_XLSX);
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML is study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysevalf(%superq(outputName) =, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameter outputName is required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(exist(&reportOutput)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Dataset &reportOutput does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;


	%if ^%symglobl(tflxlsxpath) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable tflxlsxpath is not defined in global scope;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysfunc(fileexist(&tflxlsxpath.))=0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] XLSX path &tflxlsxpath. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%local sheetname;

	data _null_;
		shet="&tflxlsxpath\&outputName..xlsx";
		shet1=scan(shet,-1, "\");
		shet2=scan(shet1,1, " ");
		call symputx("sheetname" , shet2);
	run;

	data AVGML.excelout1(drop=grpx: _break_);
		set &reportOutput.;
		where _break_ ='';
	run;
	
	ods excel file="&tflxlsxpath\&outputName..xlsx" style=tfl_xlsx
		options(sheet_name="&sheetname."
			embedded_titles='yes'
			embedded_footnotes="yes"
			sheet_interval = 'none');
		
			proc report data=AVGML.excelout1 split='~' style(report)=[width=100%] nowd headline headskip missing;
			run;
	ods excel close;
%mend avInterimOutputToXLSX;

proc template;
	define style tfl_xlsx;
	parent=styles.excel;

	class systemtitle /
		fontsize 			= 8pt
		fontweight			= bold
		fontfamily 			= "Courier new"
		backgroundcolor 	= White;

	class header /
	    backgroundcolor 	= White 
		fontfamily 			= "Courier new"
		fontsize 			= 8pt
		fontweight			= bold;

	style byline from header;

	class footer /
	    backgroundcolor 	= White
		fontfamily 			= "Courier new"
		fontsize 			= 8pt
		frame				= above
		rules				= groups
		protectspecialchars = off;

	class SystemFooter /
		FONT_FACE 			= "Courier new"
		FONT_SIZE 			= 8pt
		BACKGROUND 			= white;

	class body /
		backgroundcolor 	= White
		color 				= Black
		fontfamily 			= "Courier new"
		fontsize 			= 8pt;	

	class table /
		bordercolor 		= black
		borderstyle 		= solid
		borderwidth 		= 1pt
		cellpadding 		= 2pt
		cellspacing 		= 1pt
		fontfamily 			= "Courier new"
		fontsize 			= 8pt
	  	frame				= void
		rules				= groups;

	class data / 
		fontfamily 			= "Courier new"
		fontsize 			= 8pt
		protectspecialchars	= off;

	class cell / 
		protectspecialchars = off;
	end;
run;

