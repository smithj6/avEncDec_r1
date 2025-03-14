/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avAppendCommentsToCO.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Utility Macro to append comments to the CO domain
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avAppendCommentsToCO(dataIn=
						   ,libOut=
						   ,varIn=
						   ,rDomain=
						   ,idVar=);
	dm 'flsvlast'; 
	%local dsid1 
           dsid2
		   ds1
		   ds2
           rc 
           size 
           var1 
           var2 
           var3 
           var4
           i 
           j 
           random
		   outerSize
		   innerSize
		   commonCharVarsSize
           varsInCommonSize;
	%if %sysevalf(%superq(dataIn)=, boolean) or  
		%sysevalf(%superq(varIn)=,  boolean) or	
		%sysevalf(%superq(libOut)=, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameters dataIn, varIn and libOut are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Assign Library AVGML is study setup file;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if %sysfunc(libref(%bquote(&libOut))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library %bquote(&libOut) is not assigned;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Assign Library &libOut is study setup file;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(exist(%bquote(&dataIn))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Data %bquote(&dataIn) does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysfunc(prxmatch(%str(m/^\w{2}$/oi), %bquote(&rDomain))) and ^%sysevalf(%superq(rDomain)=, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] rDomain %bquote(&rDomain) is not invalid;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Vaild values are 2 character domain names;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%sysevalf(%superq(rDomain)=, boolean) and %sysevalf(%superq(idvar)=, boolean) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid pairing between parameters idVar and rDomain;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expecting idVar when rDomain is not null;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%let dsid1=%sysfunc(open(&dataIn));
	%let var1=studyid;
	%let var2=usubjid;
	%if ^%sysevalf(%superq(idvar)=, boolean) %then %do;
		%let var3=&idvar;
		%let var4=domain;
		%let size=4;
	%end;
	%else %let size=2;
	%do i=1 %to &size;
		%if ^%sysfunc(varnum(&dsid1, &&var&i)) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &&var&i not found in &dataIn data;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let rc=%sysfunc(close(&dsid1));
			%return;
		%end;
		%if %bquote(&&var&i) ne %bquote(&idvar) and %sysfunc(vartype(&dsid1, %sysfunc(varnum(&dsid1, &&var&i)))) ne C %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &&var&i is not in expected type;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expeced type is character;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let rc=%sysfunc(close(&dsid1));
			%return;
		%end;
	%end;
	%if ^%sysevalf(%superq(idvar)=, boolean) %then %do;
		%if %sysevalf(%superq(rdomain)=, boolean) and ^%sysfunc(attrn(&dsid1, nlobsf)) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] data &dataIn is empty therefore RDOMAIN parameter cannot be determined;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Assign RDOMAIN paramter to 2 character DOMAIN name;
			%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let rc=%sysfunc(close(&dsid1));
			%return;
		%end;
		%if %sysevalf(%superq(rdomain)=, boolean) %then %do;
			%let rc=%sysfunc(fetch(&dsid1, 1));
			%let rDomain=%sysfunc(getvarc(&dsid1, %sysfunc(varnum(&dsid1, domain))));
			%if %sysevalf(%superq(rdomain)=, boolean) %then %do;
				%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Could not extract RDOMAIN from &dataIn..DOMAIN variable;
				%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] &dataIn..DOMAIN variable is NULL on the first row;
				%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Assign RDOMAIN paramter to 2 character DOMAIN name;
				%put ERROR:4/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
				%let rc=%sysfunc(close(&dsid1));
				%return;
			%end;
		%end;
	%end;
	%if %sysfunc(exist(&libOut..CO)) %then %do;
		%let dsid2=%sysfunc(open(&libOut..CO));
		%let outerSize=2;
	%end;
	%else %let outerSize=1;
	%let ds1=&dataIn;
	%let ds2=&libOut..CO;
	%let var1=domain;
	%if ^%sysevalf(%superq(idvar)=, boolean) %then %do;
		%let var2=idvar;
		%let var3=idvarval;
		%let var4=rdomain;
		%let innerSize=4;
	%end;
	%else %let innerSize=1;
	%do i=1 %to &outerSize;
		%do j=1 %to &innerSize;
			%if ^%sysfunc(varnum(&&dsid&i, &&var&j)) %then %goto skip;
			%if %sysfunc(vartype(&&dsid&i, %sysfunc(varnum(&&dsid&i, &&var&j)))) ne C %then %do;
				%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &&var&j in data &&ds&i is not in expected type;
				%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Expeced type is character;
				%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
				%let rc=%sysfunc(close(&dsid1));
				%if &outerSize = 2 %then %let rc=%sysfunc(close(&dsid2));
				%return;
			%end;
			%skip:
		%end;
		%let rc=%sysfunc(close(&&dsid&i));
	%end;
	
	%avUpdateSpecDataset(lib=01_SDTM, domain=CO);

	%avSplitCharVarExceedingMaxLength(dataIn=&dataIn
				   			         ,dataOut=avgml.splitcomments
				   			         ,maxLength=200
				   			         ,varIn=&varIn
				   			         ,varOutPrefix=COVAL);
	
	%if ^%sysfunc(exist(avgml.splitcomments)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Data avgml.splitcomments not created;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] See log for details;
		%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%let varsInCommonSize=0;
	%let commonCharVarsSize=0;
	%if %sysfunc(exist(&libOut..CO)) %then %do;
		proc sql;
			create table avgml.common01 as
				select name
				from dictionary.columns
				where libname="%upcase(&libOut)" and memname = "CO"

				intersect

				select name 	
				from dictionary.columns
				where libname="AVGML" and memname = "SPLITCOMMENTS"
				order by name;
		quit;
		%let varsInCommonSize=&sqlObs;
		%if &varsInCommonSize %then %do;
			data _null_;
				set avgml.common01;
				call symputx(cats('commonVar', _n_), name, 'l');
			run;
			%let dsid1=%sysfunc(open(avgml.splitcomments));
			%let dsid2=%sysfunc(open(&libOut..CO));
			%do i=1 %to &varsInCommonSize;
				%local ds1VarType&i
					   ds2VarType&i;
				%let ds1VarType&i = %sysfunc(vartype(&dsid1, %sysfunc(varnum(&dsid1, &&commonVar&i))));
				%let ds2VarType&i = %sysfunc(vartype(&dsid2, %sysfunc(varnum(&dsid2, &&commonVar&i))));
				%if &&ds1VarType&i ne &&ds2VarType&i %then %do;
					%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variable &&commonVar&i has been defined as both character and numeric in data &libOut..CO and &dataIn;
					%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Types must match;
					%put ERROR:3/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
					%let rc=%sysfunc(close(&dsid1));
					%let rc=%sysfunc(close(&dsid2));
					%return;
				%end;
				%if &&ds1VarType&i = C %then %do;
					%let commonCharVarsSize=%eval(&commonCharVarsSize + 1);
					%local commonCharVar&commonCharVarsSize;
					%let commonCharVar&commonCharVarsSize=&&commonVar&i;
				%end;
			%end;
			%let rc=%sysfunc(close(&dsid1));
			%let rc=%sysfunc(close(&dsid2));
			%if &commonCharVarsSize %then %do;
				%local libName1
				       libName2
					   memName1
					   memName2;
				%let libName1=%upcase(&libOut);
				%let libName2=AVGML;
				%let memName1=CO;
				%let memName2=SPLITCOMMENTS;
				%do i=1 %to 2;
					data _null_;
						set sashelp.vcolumn;
						where libname="&&libName&i" and memname="&&memName&i" and name in (%do j=1 %to &commonCharVarsSize;
																							"&&commonCharVar&j"
																					  	   %end;);
						call symputx(cats(name, symget('i')), length, 'l');
					run;
				%end;
			%end;
		%end;
		data avgml.co01;
			length rdomain $2;
			call missing(rdomain);
			set &libOut..CO;
			drop coseq;
		run;
	%end;
	%let random=V%sysfunc(rand(integer, 1, 5E6), hex8.);
	data &random.rows;
		%if &commonCharVarsSize %then %do;
			length 
			%do i=1 %to &commonCharVarsSize;
				&&commonCharVar&i $%sysfunc(max(%unquote(%nrstr(&)&&commonCharVar&i..1), %unquote(%nrstr(&)&&commonCharVar&i..2)))
			%end;
			;
		%end;
		set avgml.splitcomments(in=&random where=(^missing(coval)))
		%if %sysfunc(exist(&libOut..CO)) %then %do;
			avgml.co01(where=(upcase(rdomain) ne "%upcase(&rdomain)"))
		%end;
		;
		if &random then do;
			domain  = "CO";
			%if ^%sysevalf(%superq(idvar)=, boolean) %then %do;
				idvar    = "%upcase(&idvar)";
				idvarval = cats(&idvar);
				rdomain  = "%upcase(&rdomain)";
			%end;
		end;
	run;
	%avInterimDataToFinalStandard(dataIn=&random.rows
								 ,dataOut=&libOut..CO
								 ,standard=SDTM)
%mend avAppendCommentsToCO;
