/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avMedrioDataDictionaryCompare.sas
Output           : MedrioDataDictionaryCompareReport<dd-mm-yyyy>
Created on       : 
By               : SP.Standards
Modified         : 
Note             : 
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avMedrioDataDictionaryCompare(pathInStandardDataDictionary=
									,pathInCRFDataDictionary=
									,pathOut=);


	%local varExists validVarName quoteLenMax i j k dsid rc fileref;
	%do i=1 %to 2;
		%local file&i
			   file&i.Out1
			   file&i.Out2
			   id&i
			   id&i.Summary
			   id&i.columns1
			   id&i.columns2
			   compareOut&i	
			   out&i
			   out&i.Summary1
			   out&i.Summary2
			   arrayColumns&i
			   sheet&i
			   title&i
			   title&i.Summary;
	%end;

	%if %sysevalf(%superq(pathInStandardDataDictionary)=, boolean) or
	    %sysevalf(%superq(pathInCRFDataDictionary)=,      boolean) or 
		%sysevalf(%superq(pathOut)=,                      boolean) %then %do;
		%put ERROR: 1/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro Parameters pathInStandardDataDictionary, pathInCRFDataDictionary and pathOut are required and may not be null;
		%put ERROR: 2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(fileexist(%bquote(&pathInStandardDataDictionary))) %then %do;
		%put ERROR: 1/[AVANCE %sysfunc(datetime(), e8601dt.)] %bquote(&pathInStandardDataDictionary) is not a valid path on the system;
		%put ERROR: 2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(fileexist(%bquote(&pathInCRFDataDictionary))) %then %do;
		%put ERROR: 1/[AVANCE %sysfunc(datetime(), e8601dt.)] %bquote(&pathInCRFDataDictionary) is not a valid path on the system;
		%put ERROR: 2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Assign Library AVGML is study setup file;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(fileexist(%bquote(&pathOut))) %then %do;
		%put ERROR: 1/[AVANCE %sysfunc(datetime(), e8601dt.)] %bquote(&pathOut) is not a valid path on the system;
		%put ERROR: 2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%symglobl(client) %then %do;
		%put ERROR: 1/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro variable client is not set in global scope;
		%put ERROR: 2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%symglobl(protocol) %then %do;
		%put ERROR: 1/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro variable protocol is not set in global scope;
		%put ERROR: 2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysevalf(%superq(protocol)=, boolean) or %sysevalf(%superq(client)=, boolean) %then %do;
		%put ERROR: 1/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro variable client is not set in global scope;
		%put ERROR: 2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %qsubstr(%bquote(&pathOut), %length(%bquote(&pathOut))) ne %str(\) %then %let pathOut=&pathOut\;
	%let rc  = %sysfunc(filename(fileref, &pathOut));
	%let did = %sysfunc(dopen(&fileref));
	%if ^&did %then %do;
		%put ERROR: 1/[AVANCE %sysfunc(datetime(), e8601dt.)] %bquote(&pathOut) is not a valid directory, or cannot be opened;
		%put ERROR: 2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%let rc  = %sysfunc(filename(fileref));
		%return;
	%end;
	%let rc = %sysfunc(dopen(&did));
	%let rc = %sysfunc(filename(fileref));

	%let validVarName = %sysfunc(getoption(validvarname, keyword));
	%let quoteLenMax  = %sysfunc(getoption(quotelenmax));

	options validvarname=v7 noquotelenmax;

	%let file1=&pathInStandardDataDictionary;
	%let file1Out1=FormStd;
	%let file1Out2=CodeListStd;
	%let id1=Form_Name Form_Export_Name Variable_Export_Name Variable_Name;
	%let id1Summary=Form_Name Form_Export_Name;
	%let id1columns1=id1Summary;
	%let id1columns2=id1;
	%let compareOut1=FormProbs;
	%let out1=Form_verbose;
	%let out1Summary1=Form_brief_summary;
	%let out1Summary2=Form_extended_summary;
	%let arrayColumns1=form_external_id--footer;
	%let sheet1=Forms;
	%let title1=Forms Level Comparison;
	%let title1Summary=Brief;

	%let file2=&pathInCRFDataDictionary;
	%let file2Out1=FormCRF;
	%let file2Out2=CodeListCRF;
	%let id2=Form_Name Form_Export_Name Variable_Export_Name Variable_Name List;
	%let id2Summary=Form_Name Form_Export_Name Variable_Export_Name Variable_Name;
	%let id2columns1=id2Summary;
	%let id2columns2=id2;
	%let compareOut2=CodeListProbs;
	%let arrayColumns2=Research_or_Operational_Data--exclude;
	%let out2=CodeList_verbose;
	%let out2Summary1=CodeList_brief_summary;
	%let out2Summary2=CodeList_extended_summary;
	%let sheet2=Code Lists;
	%let title2=Code List Level Comparison;
	%let title2Summary=Extended;

	proc sql;
		create table avgml.status (
			sheet char(200) label="Sheet",
			code  num		label="Compare Result Code",
			clvl1 num       label="Data set labels differ",
			clvl2 num       label="Data set types differ",
			clvl3 num       label="Variable has different informat",
			clvl4 num       label="Variable has different format",
			clvl5 num       label="Variable has different length",
			clvl6 num       label="Variable has different label",
			clvl7 num       label="Standard Dataset has observations not in CRF Dataset",
			clvl8 num       label="CRF Dataset has observations not in Standard Dataset",
			clvl9 num       label="Standard Dataset has BY group not in CRF Dataset",
			clvl10 num      label="CRF Dataset has BY group not in Standard Dataset",
			clvl11 num      label="Standard Dataset has variable not in CRF Dataset",
			clvl12 num      label="CRF Dataset has variable not in Standard Dataset",
			clvl13 num      label="A value comparison was unequal",
			clvl14 num      label="Conflicting variable types",
			clvl15 num      label="BY variables do not match",
			clvl16 num      label="Fatal Error: Comparison not done"
		);
	quit;

	%do i=1 %to 2;
		%do j=1 %to 2;

			%if ^%sysfunc(prxmatch(%str(m/^.+\.xlsx$/oi), %bquote(&&file&j))) %then %do;
				%put ERROR: 1/[AVANCE %sysfunc(datetime(), e8601dt.)] File &&file&j does not end in .xlsx extenstion;
				%put ERROR: 2/[AVANCE %sysfunc(datetime(), e8601dt.)] Import Unsuccsessful.;
				%put ERROR: 3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
				%return;
			%end;

			%*********************************************************************;
			%***************************Import Source Files***********************;
			%*********************************************************************;

			proc import datafile="&&file&j"
				out=avgml.&&file&j.Out&i
				dbms=xlsx
				replace;
				getnames = yes;
				sheet="&&sheet&i";
			run;
			
			%if &syserr %then %do;
				%put ERROR: 1/[AVANCE %sysfunc(datetime(), e8601dt.)] Import Unsuccsessful. See SAS Log;
				%put ERROR: 2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
				%return;
			%end;

			%let dsid=%sysfunc(open(avgml.&&file&j.Out&i));
			%let varExists = %sysfunc(varnum(&dsid, object_type));
			
			%*********************************************************************;
			%************************Ensure ID columns Exist**********************;
			%*********************************************************************;

			%do k=1 %to %sysfunc(countw(&&id&i));
				%if ^%sysfunc(varnum(&dsid, %scan(&&id&i, &k, %str( )))) %then %do;
					%put ERROR: 1/[AVANCE %sysfunc(datetime(), e8601dt.)] Required Variable %scan(&&id&i, &k, %str( )) Not found;
					%put ERROR: 2/[AVANCE %sysfunc(datetime(), e8601dt.)] Some or All required variables are not found in &&file&i;
					%put ERROR: 3/[AVANCE %sysfunc(datetime(), e8601dt.)] Required variables are &&id&i;
					%put ERROR: 4/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
					%let rc=%sysfunc(close(&dsid));
					%return;
				%end;
			%end;
			%let rc=%sysfunc(close(&dsid));
			%if &varExists %then %do;
				proc sql;
					delete from avgml.&&file&j.Out&i where upcase(object_type) ne "VARIABLE";
				quit;
			%end;

			proc sort data=avgml.&&file&j.Out&i; 
				by &&id&i;
			run;
			
			%*********************************************************************;
			%*****************Ensure ID Variables Yield Unique Row****************;
			%*********************************************************************;

			proc sql;
				create table avgml.t&i.primary_keys&j as
					select %sysfunc(tranwrd(&&id&i, %str( ), %str(, )))
				from avgml.&&file&j.Out&i
				group by %sysfunc(tranwrd(&&id&i, %str( ), %str(, )))
				having count(*) > 1;
			quit;

			%if &sqlobs %then %do;
				%put ERROR: 1/[AVANCE %sysfunc(datetime(), e8601dt.)] Key combination of &&id&i does not yield a unique row;
				%put ERROR: 2/[AVANCE %sysfunc(datetime(), e8601dt.)] Please Ensure that Key combination yields a unique row;
				%put ERROR: 3/[AVANCE %sysfunc(datetime(), e8601dt.)] See avgml.t&i.primary_keys&j data for further details;
				%put ERROR: 4/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
				%return;
			%end;
	
			%*********************************************************************;
			%*****************************Compare Metadata************************;
			%*********************************************************************;

			proc sql;
				create table avgml.t&i.meta&j as
					select name
						  ,type
					from dictionary.columns
					where libname = "AVGML" and memname="%upcase(&&file&j.Out&i)"
					order by name, type;
			quit;

			proc sort nodupkey data=avgml.&&file&j.Out&i(keep=&&id&i.summary) out=avgml.&&file&j.Out&i..uniq;
				by &&id&i.summary;
			run;
		%end;

		proc compare base=avgml.t&i.meta1
					 compare=avgml.t&i.meta2 outbase outcomp outnoeq outdiff out=avgml.t&i.compare;
		run;

		%if &sysinfo %then %do;
			%put ERROR: 1/[AVANCE %sysfunc(datetime(), e8601dt.)] Metadata inconsistencies found between Standard and CRF.;
			%put ERROR: 2/[AVANCE %sysfunc(datetime(), e8601dt.)] See avgml.t&i.compare data for further details;
			%put ERROR: 3/[AVANCE %sysfunc(datetime(), e8601dt.)] Ensure variables and types between Standard Data Dictionary and CRF data dictionary match.;
			%put ERROR: 4/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;

		proc compare base=avgml.&&file1Out&i
			      compare=avgml.&&file2Out&i outbase outcomp outdiff out=avgml.&&compareOut&i;
			id &&id&i;
		run;
	
		%let rc=&sysinfo;

		data avgml.comparedcode&i;
			length sheet $200;
			array levels [16] clvl1-clvl16 (16 * 0);
			sheet="&&sheet&i";
			code=&rc;
			if code then do i=1 to 16;
				binval=2**(i-1);
				match=band(binval, code);
				key=sign(match)*i;
				levels[key+1]=1;
			end;
			keep clvl1-clvl16 sheet code;
		run;

		proc append base=avgml.status 
					data=avgml.comparedcode&i force;
		run;

		data avgml.metadata&i;
			length flag $500 rowid 8;
			stop;
			set avgml.&&CompareOut&i;
			call missing(of _all_);
		run;

		data _null_;
			length temp flag $500 vname $32 rowid 8;
			if _n_ = 1 then do;
				dcl hash comments(dataset: "avgml.metadata&i", ordered: 'Y');
			 	 	 comments.definekey("rowid");
			 	 	 comments.definedata(all: "Y");
			     	 comments.definedone();
				dcl hash vars(hashexp:8);
				 		 vars.definekey("vname");
			 	 	     vars.definedone();
				dcl hiter iter("vars");
				call symputx("size_&i", vars.num_items, 'l');
			end;
			set avgml.&&compareOut&i end=eof;
			array char [*] &&arrayColumns&i;
			rowid=_n_;
			check=0;
			if _type_ ne "DIF" then do;
				flag=ifc(_type_ = "BASE", "0", "1");
				comments.add();
			end;
			else do;
				do i=1 to dim(char);
					vname=vname(char[i]);
					if index(char[i], 'X') then do;
						check=1;
						temp=catx(' ', flag, vname);
						if vars.check() then vars.add();
					end;
				end;
				do rowid=_n_ -1 to _n_ -2 by -1;
					rc=comments.find();
					flag=coalescec(temp, "2");
					rc=comments.replace();
				end;
			end;
			if eof then do;
				i=0;
				comments.output(dataset: "avgml.&&out&i(drop=rowid)");
				do while(iter.next()=0);
					i+1;
					call symputx(cats("var_&i._", i), vname, 'l');
				end;
				call symputx("size_&i", vars.num_items, 'l');
			end;
		run;

		%avTrimCharVarsToMaxLength(dataIn=avgml.&&out&i)

		proc sort nodupkey data=avgml.&&out&i out=avgml.&&out&i.summary2;
			by &&id&i flag;
		run;

		data _null;
			set sashelp.vcolumn end=eof;
			where libname='AVGML' and memname="%upcase(&&file1Out&i..uniq)" and type='char';
			call symputx(cats('name', _n_), name, 'l');
			if eof then call symputx('charVarsSize', _n_, 'l');
		run;

		%*********************************************************************;
		%*********Explicitly Set length to 10K to avoid truncation************;
		%*********************************************************************;

		proc sql;
			%do j=1 %to 2;
				alter table avgml.&&file1Out&j..uniq
				modify &name1 char(5000)
				%do k=2 %to &charVarsSize;
					,&&name&k char(5000)
				%end;
				;
			%end;
		quit;

		data avgml.&&out&i.summary1;
			merge avgml.&&file1Out&i..uniq (in=x)
				  avgml.&&file2Out&i..uniq (in=y);
			by &&id&i.summary;
			if x and y then flag="X";
			else if x  then flag="0";
			else if y  then flag="1";
		run;
		
		%avTrimCharVarsToMaxLength(dataIn=avgml.&&out&i.summary1)
	
		proc sql;
			create table avgml.&&out&i.summary1._score as
				select %sysfunc(tranwrd(&&id&i.summary, %str( ), %str(, )))
						,case
								when count(case when flag="2" then flag else "" end) = count(flag) then "2"
								else "3"
						 end as flag length=1
				from avgml.&&out&i
				group by %sysfunc(tranwrd(&&id&i.summary, %str( ), %str(, )))
				order by %sysfunc(tranwrd(&&id&i.summary, %str( ), %str(, )));
		
			update avgml.&&out&i.summary1 a
				set flag = (select flag from avgml.&&out&i.summary1._score b 
							where a.%scan(&&id&i.summary, 1, %str( )) = b.%scan(&&id&i.summary, 1, %str( ))
							%do j=2 %to %sysfunc(countw(&&id&i.summary));
								and a.%scan(&&id&i.summary, &j, %str( )) = b.%scan(&&id&i.summary, &j, %str( ))										
							%end;)
				where flag="X";
		quit;
	%end;

	data avgml.coverpage;
		length legend $100;
		label legend = "Colour Legend";
		do legend="Record Present Only in Global Standard"
			 	 ,"Record Present Only in CRF"
			  	 ,"Common Record With No Difference/s"
			     ,"Common Record With Difference/s";
			output;
		end;
	run;

	%avTrimCharVarsToMaxLength(dataIn=avgml.coverpage)

	%*********************************************************************;
	%*****************************Reporting Effort************************;
	%*********************************************************************;

	ods escapechar='!';
	ods excel file="&pathOut.Medrio_Data_Dictionary_Compare_Report_%left(%sysfunc(today(),date9.)).xlsx" options(sheet_name="Cover Page" embedded_footnotes='on' embedded_titles='on' frozen_headers="on" sheet_interval="none") style=BarrettsBlue;
		title1 j=c "Avance Clinical Pvt.Ltd.";
		title2 j=c "PROTOCOL ID: &protocol";
		title3 j=c "CLIENT: &client";
		title4 j=c "Medrio Data Dictionary Compare between &pathInStandardDataDictionary and &pathInCRFDataDictionary";
		title5 j=c "Report Generated by: %sysfunc(tranwrd(%bquote(&sysuserid), ., %str(, ))) On: %left(%sysfunc(today(), date9.))";
		proc report data=avgml.coverpage style(report)=[width=100%] nowd headline headskip missing;
			column legend;
			define legend/ style(column)=[just=l cellwidth=80%];
			compute legend;
				if legend = "Record Present Only in Global Standard" 	then call define(_col_, "style", "style=[backgroundcolor=lightyellow]");
				else if legend = "Record Present Only in CRF" 			then call define(_col_, "style", "style=[backgroundcolor=lightred]");
				else if legend = "Common Record With No Difference/s"   then call define(_col_, "style", "style=[backgroundcolor=lightgreen]");
				else if legend = "Common Record With Difference/s"      then call define(_col_, "style", "style=[backgroundcolor=lightorange]");
			endcomp;
		run;
		title;
		proc report data=avgml.status style(report)=[width=100%] nowd headline headskip missing;
			columns sheet clvl1-clvl16;
			define sheet/style(column)=[cellwidth=30%];
			%do i=1 %to 16;
				define clvl&i/display;
				compute clvl&i;
					if clvl&i = 1 then call define(_col_, "style", "style=[backgroundcolor=lightorange]");
				endcomp;
			%end;
		run;
		%do i=1 %to 2;
			title j=l "&&title&i (Summary)";
			%do j=1 %to 2;
				%if &i.&j = 12 %then %do;
					title j=l "&&title&i/Variable (Summary)";
				%end;
				ods excel options(sheet_name="&&sheet&i - &&title&j.Summary Summary" sheet_interval="proc");
				proc report data=avgml.&&out&i.summary&j missing nowd headline headskip;
					column %unquote(%nrstr(&)&&id&i.columns&j) flag compareSummary;
					define flag/noprint;
					define compareSummary/computed "Compare Summary";
					compute compareSummary/character length=200;
						if flag = "0" then do;
							compareSummary = "Record Present Only in Global Standard";
							call define(_col_, "style", "style=[backgroundcolor=lightyellow]");
						end;
						else if flag = "1" then do;
							compareSummary = "Record Present Only in CRF"; 
							call define(_col_, "style", "style=[backgroundcolor=lightred]");
						end;
						else if flag = "2" then do;
							compareSummary = "Common Record With No Difference/s";
							call define(_col_, "style", "style=[backgroundcolor=lightgreen]"); 
						end;
						else do;
							compareSummary = "Common Record With Difference/s"; 
							call define(_col_, "style", "style=[backgroundcolor=lightorange]");
						end;
					endcomp;
				run;
			%end;
			title j=l "&&title&i (Verbose)";
			ods excel options(sheet_name="&&sheet&i - Verbose" sheet_interval="proc");
				proc report data=avgml.&&out&i missing nowd headline headskip;
					column _all_;
					define flag/noprint;
					compute flag;
						if flag = "0" 		then call define(_row_, "style", "style=[backgroundcolor=lightyellow]");
						else if flag = "1" 	then call define(_row_, "style", "style=[backgroundcolor=lightred]");
						else if flag = "2" 	then call define(_row_, "style", "style=[backgroundcolor=lightgreen]");
					endcomp;
					%if &&size_&i %then %do j=1 %to &&size_&i;
						compute &&var_&i._&j;
							if indexw(strip(flag), "&&var_&i._&j") then call define(_col_, "style", "style=[backgroundcolor=lightorange]");
						endcomp;
					%end;
				run;
			%end;
		ods excel close;

		%*********************************************************************;
		%******************************Reset Options**************************;
		%*********************************************************************;

		options &validVarName &quoteLenMax;
		title;
		footnote;

%mend avMedrioDataDictionaryCompare;
