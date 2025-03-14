/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avLogcheck.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Checks log for specific domain
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avLogcheck();
	proc printto log=log;
	run;

	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	data AVGML.templog1;
		infile templog missover pad;
		input line $10000.;
	run;

	data AVGML.templog2;
		set AVGML.templog1;
		length type $100;
		where not missing(line);
		line=upcase(line);
		if anydigit(line)=1 then delete;

		/* Used for warning messages */
		datetime=datetime();

		if length(line) > 10000 then do;
			put "WARNING:1/[AVANCE " datetime e8601dt. "] High possibility of truncation";
		end;
		
		if ^index(line, 'AVANCE') then do;
			if index(line, 'ERROR') and ^index(line, 'WITHOUT ERRORS') 	then type='Note: Error';
			if index(line, 'WARN') 										then type='Note: Warning';
			if index(line, 'UNINIT') then 								type='Note: Uninitialized';
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
		end;
		else if index(line, 'AVANCE') then do;
			if index(line, 'NOTE') 			then type='Avance standard Note';
			if index(line, 'WARNING') 		then type='Avance standard Warning';
			if index(line, 'ERROR') 		then type='Avance standard Error';
		end;
	run;

	proc sql;
		create table AVGML.templog3 as
			select count(type) as cnt , type from AVGML.templog2
				where type ne ''
					group by type;
	quit;

	proc sql noprint;
		select count(*) into: issue_cnt from AVGML.templog3;
	quit;

	data AVGML.templog4;
		length final_issue $100 ;
		set AVGML.templog3;
		len=55-length(type);
		final_issue=strip(type)||repeat("-", len+2)||"> "||strip(put(cnt, z2.))||"	*";
	run;

	options nosource nonotes;

	proc printto log=log; run;

	proc printto log=templog; run;

	%if &issue_cnt > 0 %then %do;

		%put ************************ list of issues noted **************************;
		%put;
		data _null_;
			set AVGML.templog4;
			put "*		" final_issue;
		run;
		%put;
		%put ************************************************************************;

	%end;

	%if &issue_cnt = 0 %then %do;

	%put ***********************************************************************;
	%put;
	%put *********************** No issues noted in the log ********************;
	%put;
	%put ***********************************************************************;

	%end;

	proc printto log=log;
	run;

	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	options source notes;

	data _null_;
		infile templog;
		input;
		putlog _infile_;
	run;
%mend avLogcheck;

