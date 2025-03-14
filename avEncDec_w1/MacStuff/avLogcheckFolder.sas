/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avLogcheckFolder.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Checks all logs in a specified folder and create summary PDF file in specified location
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avLogcheckFolder(logPath=, repPath=);
	%if %sysevalf(%superq(logPath)  =, boolean) or %sysevalf(%superq(repPath)=, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameters Log Path and Report Path are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(fileexist(&logPath.))=0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Log Path &logPath. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(fileexist(&repPath.))=0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Report Path &repPath. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	DM 'log;clear;';


	data AVGML._list;
		length list_ logfile $200;
		rc=filename("fileref", "&logPath");
		did=dopen("fileref");
		if did>0 then do;
			do i= 1 to dnum(did);
				list_=dread(did, i);
				logfile=catx("\","&logPath",list_);
				if scan(upcase(list_),-1, ".")= "LOG" then output;
			end;
		end;
		rc=dclose(did);
	run;

	proc sql noprint;
		select count(*) into : nl trimmed from AVGML._list;
		select logfile into : logfile1-:logfile&nl from AVGML._list;
	quit;

	data AVGML.logs_all;
	run;

	%do i= 1 %to &nl;
		filename logfile "&&logfile&i";

		data AVGML.logfile1;
			infile logfile missover pad;
			input _line $5000.;
		run;

		data AVGML.logfile2(keep=_line);
			set AVGML.logfile1;
			length type $100;
			where not missing(_line);
			line=upcase(_line);
			if anydigit(line)=1 then delete;
			if index(_line, "*")=1 then delete;
			
			if index(line, 'ERROR') and ^index(line, 'WITHOUT ERRORS') 	then type='Note: Error';
			if index(line, 'WARN') 										then type='Note: Warning';
			if index(line, 'UNINIT') 									then type='Note: Uninitialized';
			if index(line, 'MISSING VALUE') 							then type='Note: Missing value';
			if index(line, 'HAVE BEEN CONVERTED') 						then type='Note: Have been converted';
			if index(line, 'INVALID') 									then type='Note: Invalid';
			if index(line, 'REPEATS OF BY VALUES') 						then type='Note: MERGE statement with repeats of BY values';
			if index(line, 'STOPPED DUE TO LOOPING') 					then type='Note: Stopped due to looping';
			if index(line, 'OVERWRITTEN') 								then type='Note: overwritten by data set';
			if index(line, 'ONE W.D') 									then type='Note: At least one W.D format';
			if index(line, 'SAS WENT TO A NEW LINE') 					then type='Note: Input statement has issues';
			if index(line, 'NOT SUPPORTED BY THE V9 ENGINE') 			then type='Note: Not supported by the V9 engine';
			if index(line, 'DIVISION BY ZERO DETECTED ') 				then type='Note: Division by zero detected ';
			if index(line, 'OPERATIONS COULD NOT BE PERFORMED') 		then type='Note: Mathematical operations could not be performed';
			if index(line, 'TERMINATED') 								then type='Note: Terminated';

			if type^='';
		run;

		%let logch=0;

		proc sql noprint;
			select count(*) into: logch from AVGML.logfile2;
		quit;

		%if &logch > 0 %then %do;
			data AVGML.log_;
				length  _line  $5000. ;
				_line="&&logfile&i";
			run;

			data AVGML.logs_all(where=(_line^=''));
				set AVGML.logs_all AVGML.log_ AVGML.logfile2(in=a);
			run;

			proc delete data=AVGML.log_ AVGML.logfile1 AVGML.logfile2; 
			run;
		%end;

		%if &logch=0 %then %do;
			data AVGML.log_;
				length  _line  $5000. ;
				_line="&&logfile&i";
			run;

			data AVGML.logfile2;
				length  _line  $5000. ;
				_line="No Issue noted";
			run;

			data AVGML.logs_all(where=(_line^=''));
				set AVGML.logs_all AVGML.log_ AVGML.logfile2(in=a);
			run;

			proc delete data=AVGML.log_ AVGML.logfile1 AVGML.logfile2; 
			run;
		%end;

	%end;

	data AVGML.logs_all_excel;
		set AVGML.logs_all;

		Log = strip(_line);
		
		if index(_line, '.log') then flag = "0";
		else if index(upcase(_line), 'NOTE') then flag = "1";
		else if index(upcase(_line), 'WARNING') then flag = "2";
		else if index(upcase(_line), 'ERROR') then flag = "3";
		else flag = "4";
	run;

	data AVGML.coverpage;
		length flag legend $300.;
		label legend = "Colour Legend";
		flag = 'Note'; 		legend = "Note: A note in the SAS log is an informational message and does not stop your program from executing. A note can indicate that part of your code is programmatically incorrect."; output;
		flag = 'Warning'; 	legend = "Warning: A SAS warning message alerts you to potential problems with your code but does not stop program execution. For example, warning messages are issued when you enter a word incorrectly and SAS is able to interpret the word, and when a program produces no output."; output;
		flag = 'Error'; 	legend = "Error: A SAS error message alerts you to a significant problem with your code. SAS either stops program processing or flags errors and continues to process your program. An error message is written to the log."; output;
	run;

	
	title;
	footnote;

	%let systemOption = %sysfunc(getoption(validvarname, keyword));
	options validvarname=v7;

	ods escapechar='!';
	ods excel file="&repPath.\Logcheck_Folder_Report_%left(%sysfunc(today(),date9.)).xlsx" options(sheet_name="Cover Page" embedded_footnotes='on' embedded_titles='on' frozen_headers="on" sheet_interval="none") style=BarrettsBlue;
		title1 j=c "Avance Clinical Pty.Ltd.";
		title2 j=c "Log summary for: &logPath";
		title3 j=c "Report Generated by: %sysfunc(tranwrd(%bquote(&sysuserid), ., %str(, ))) On: %left(%sysfunc(today(), date9.))";
		proc report data=AVGML.coverpage style(report)=[width=100%] nowd headline headskip missing;
			column legend flag;
			define legend/ style(column)=[just=l cellwidth=100%];
			define flag/noprint;
			compute flag;
				if flag = "Note" 			then call define(_row_, "style", "style=[backgroundcolor=lightgreen]");
				else if flag = "Warning" 	then call define(_row_, "style", "style=[backgroundcolor=lightyellow]");
				else if flag = "Error"   	then call define(_row_, "style", "style=[backgroundcolor=lightred]");
			endcomp;
		run;
		title;

		ods excel options(sheet_name="Log Summary" sheet_interval="proc");
		proc report data=AVGML.logs_all_excel style(report)=[width=100%] nowd headline headskip missing;
			column Log flag;
			define Log/style(column)=[cellwidth=100%];
			define flag/noprint;
			compute flag;
				if flag = "1" 				then call define(_row_, "style", "style=[backgroundcolor=lightgreen]");
				else if flag = "2" 			then call define(_row_, "style", "style=[backgroundcolor=lightyellow]");
				else if flag = "3" 			then call define(_row_, "style", "style=[backgroundcolor=lightred]");
			endcomp;
		run;

	ods excel close;

	%*********************************************************************;
	%******************************Reset Options**************************;
	%*********************************************************************;


	options orientation= portrait  ls=127 ;

	title "Log location: &logPath";

	ods pdf file="&repPath\Logcheck_Folder_Report_%left(%sysfunc(today(),date9.)).pdf" ; 

	proc report data=AVGML.logs_all
		style(header)=[color=white backgroundcolor=LIOY ];	
		column _line ;
		define _line/ "list of Log issues" style(column)={textalign=left cellwidth=95% asis=on};; 

		compute _line;
			if index(_line, "&logPath") > 0  then call define(_col_, "style", "style={background=PKWH}");
		endcomp;
	run;

	ods pdf close;

	options &systemOption;
%mend avLogcheckFolder;
