/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avImportExcel.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Import excel file to specified folder
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avImportExcel(sourceFile=, destPath=, sheetName=, dataOut=);
	%if %sysevalf(%superq(sourceFile)  =, boolean) or %sysevalf(%superq(destPath)=, boolean) or %sysevalf(%superq(sheetName)=, boolean) or %sysevalf(%superq(dataOut)=, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameters Source File, Destination Path, Sheet Name and Dataset Name are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML is study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(fileexist(&sourceFile.)) = 0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Source File &sourceFile. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(fileexist(&destPath.)) = 0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Destination Path &destPath. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(prxmatch(%str(m/^[A-Za-z_]([A-Za-z_0-9]{1,31})?$/oi), %bquote(&dataOut))) %then %do;
	 	%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] &dataOut is not a valid SAS dataset name;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%let extension = %sysfunc(scan(&sourceFile, -1, "."));

	%if %sysfunc(lowcase(&extension.)) ^= xlsx %then %do;
	 	%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Source File &sourceFile. has to be XLSX extension;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	proc import datafile="&sourceFile"
		out		= AVGML.&dataOut
		dbms	= &extension
		replace;
		sheet	= "&sheetName";
	run;

	libname xlsxout "&destPath";

	proc copy in=AVGML out=xlsxout;
		select &dataOut;
	run;

	libname xlsxout clear;
%mend avImportExcel;
