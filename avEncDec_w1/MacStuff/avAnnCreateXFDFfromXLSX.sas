/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avAnnCreateXFDFfromXLSX.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Create XFDF file from XLSX file. Part 1 of CRF annotation through XLSX annotation file
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avAnnCreateXFDFfromXLSX(xlsxIn =, lockComments = N, fontSize = 10)/minoperator;
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

	%if ^%eval(%qupcase(%bquote(&lockComments)) in Y N) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid selection for macro parameter lock comments (%bquote(&lockComments)). Valid selections are Y or N and are case insensitive;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %datatyp(&fontSize) ne NUMERIC %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid value for macro parameter font size (%bquote(&fontSize)). Numeric value expected;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	/*======================== Create _LEN with length information ========================*/
	data AVGML._len;
		length len 8 char $1.;
		len = 3.43; char = '!'; output; 	len = 4.82; char = '"'; output; 	len = 5.65; char = '#'; output; 	len = 5.65; char = '$'; output;		len = 8.99; char = '%'; output; 	len = 2.47; char = "'"; output; 	len = 3.41; char = '('; output; 
		len = 3.4;  char = ')'; output; 	len = 4;    char = '*'; output; 	len = 5.93; char = '+'; output; 	len = 2.84; char = ','; output; 	len = 3.42; char = '-'; output; 	len = 2.88; char = ''; output; 		len = 2.91; char = '/'; output; 
		len = 5.65; char = '0'; output; 	len = 5.66; char = '1'; output; 	len = 5.64; char = '2'; output; 	len = 5.64; char = '3'; output; 	len = 5.65; char = '4'; output; 	len = 5.65; char = '5'; output; 	len = 5.65; char = '6'; output; 
		len = 5.66; char = '7'; output; 	len = 5.64; char = '8'; output; 	len = 5.65; char = '9'; output; 	len = 3.42; char = ':'; output; 	len = 3.41; char = ';'; output; 	len = 5.95; char = '='; output; 	len = 5.91; char = '>'; output; 

		len = 6.2;  char = '?'; output; 	len = 9.84; char = '@'; output; 	len = 7.31; char = 'A'; output; 	len = 7.31; char = 'B'; output; 	len = 7.32; char = 'C'; output; 	len = 7.34; char = 'D'; output; 	len = 6.75; char = 'E'; output; 	
		len = 6.22; char = 'F'; output; 	len = 7.89; char = 'G'; output; 	len = 7.31; char = 'H'; output; 	len = 2.89; char = 'I'; output; 	len = 5.67; char = 'J'; output; 	len = 7.3;  char = 'K'; output; 	len = 6.21; char = 'L'; output; 
		len = 8.43; char = 'M'; output;  	len = 7.31; char = 'N'; output; 	len = 7.86; char = 'O'; output;  	len = 6.78; char = 'P'; output;  	len = 7.89; char = 'Q'; output;  	len = 7.29; char = 'R'; output;  	len = 6.75; char = 'S'; output;  
		len = 6.22; char = 'T'; output;  	len = 7.3;  char = 'U'; output;  	len = 6.76; char = 'V'; output;  	len = 9.58; char = 'W'; output;  	len = 6.76; char = 'X'; output;  	len = 6.8;  char = 'Y'; output;  	len = 6.23; char = 'Z'; output; 

		len = 3.43; char = '['; output; 	len = 2.87; char = '\'; output; 	len = 3.41; char = ']'; output; 	len = 5.95; char = '^'; output; 	len = 5.68; char = '_'; output; 	len = 3.42; char = '`'; output; 	len = 5.67; char = 'a'; output; 
		len = 6.21; char = 'b'; output; 	len = 5.64; char = 'c'; output; 	len = 6.21; char = 'd'; output; 	len = 5.64; char = 'e'; output; 	len = 3.43; char = 'f'; output; 	len = 6.18; char = 'g'; output; 	len = 6.18; char = 'h'; output;
		len = 2.86; char = 'i'; output; 	len = 2.86; char = 'j'; output; 	len = 5.64; char = 'k'; output; 	len = 2.87; char = 'l'; output; 	len = 8.97; char = 'm'; output; 	len = 6.22; char = 'n'; output; 	len = 6.21; char = 'o'; output; 
		len = 6.2;  char = 'p'; output; 	len = 6.18; char = 'q'; output; 	len = 3.98; char = 'r'; output; 	len = 5.68; char = 's'; output; 	len = 3.43; char = 't'; output; 	len = 6.21; char = 'u'; output; 	len = 5.64; char = 'v'; output; 

		len = 7.89; char = 'w'; output;  	len = 5.65; char = 'x'; output;  	len = 5.66; char = 'y'; output;  	len = 5.1;  char = 'z'; output;  	len = 4.01; char = '{'; output;  	len = 2.87; char = '|'; output;  	len = 3.98; char = '}'; output;  
		len = 5.94; char = '~'; output;  	len = 5.65; char = '#'; output;  	len = 5.91; char = '<'; output;  	len = 2.9;  char = '.'; output; 
	run;

	%if %sysevalf(%superq(xlsxIn)  =, boolean)  %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameter xlsxIn is required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%else %do;
		/* Assign mp_lock comments to Y if any other value than N is specified */
		%if %str(&lockComments.) ^= N %then %let lockComments = Y;


	    **1. Define the necessary local macro variables;
	    %local _fontsize_d _c_blue _c_green _c_red _c_yellow _c_purple _c_brown _c_beige _c_black _c_salmon _c_olive _xfdfname _dbms;

	    ****<Font Size>;
	    %let _fontsize_d = %eval(14 * &fontSize. / 10);

	    ****<Color>;
	    %let _c_black   = '#000000';
	    %let _c_blue   	= '#BFFFFF';
	    %let _c_red   	= '#ffbe9b';
	    %let _c_green  	= '#96ff96';
	    %let _c_salmon  = '#FFEFD5';
	    %let _c_yellow 	= '#ffff96';
	    %let _c_purple 	= '#BFAAFF';
	    %let _c_brown  	= '#FFFFFF';
	    %let _c_beige  	= '#F5F5DC';
	    %let _c_olive  	= '#006400';

	    ****<xfdf file name>;
	    %if       %sysfunc(index(%str(&xlsxIn.), xlsx)) %then %let _dbms = xlsx;
	    %else %if %sysfunc(index(%str(&xlsxIn.), xls))  %then %let _dbms = xls;

		%if ^%sysfunc(fileexist(%bquote(&mspath\01_Specifications\04_SDTM_aCRF\&xlsxIn.))) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] File &xlsxIn. does not exist in &mspath\01_Specifications\04_SDTM_aCRF;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;

	    %let _xfdfname = %sysfunc(tranwrd(&mspath\01_Specifications\04_SDTM_aCRF\&xlsxIn., &_dbms., xfdf));


	    proc import file = "&mspath\01_Specifications\04_SDTM_aCRF\&xlsxIn."
	        out = AVGML._anno dbms = xlsx replace;
	        getnames = yes;
	        datarow  = 2;
	    run;

		%let dsid = %sysfunc(open(AVGML._anno));
		%if ^%sysfunc(varnum(&dsid, DOMAIN)) or ^%sysfunc(varnum(&dsid, NAME)) or ^%sysfunc(varnum(&dsid, PAGENO)) or ^%sysfunc(varnum(&dsid, ANNOTATION)) or ^%sysfunc(varnum(&dsid, POSITION)) or ^%sysfunc(varnum(&dsid, ORIENTATION)) or ^%sysfunc(varnum(&dsid, BORDER)) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Variables DOMAIN, NAME, PAGENO, ANNOTATION, POSITION, ORIENTATION and BORDER has to be present in &xlsxIn.;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%let dsid_=%sysfunc(close(&dsid));
			%return;
		%end;
		%let dsid_=%sysfunc(close(&dsid));

	    
	    *Create _SHELL dataset with POSITION ORIENTATION variables;
	    proc sql noprint;
	        create table AVGML._shell
	            (POSITION    char length = 200,
	             ORIENTATION char length = 20)
	        ;
	    quit;

		/* Drop unwanted imported columns */
		data AVGML._anno_dropped(keep=domain name annotation pageno position orientation border);
			set AVGML._anno;
		run;

	    *Set _SHELL and _ANNO togehter;
	    data AVGML._anno2(drop = pageno_1);
	        set AVGML._shell AVGML._anno_dropped(rename = (pageno = pageno_1));
	        length domain1 $10;
	        **<Remove the control characters>;
	        array ary1(*) _character_;
	        do _i = 1 to dim(ary1);
	            ary1(_i) = compress(ary1(_i), , "c");
	        end;
	        **<Add the order variable>;
	        ORD = _n_;
	        **<Add a new domain variable DOMAIN1>;
	        domain1 = domain;
	        if index(upcase(annotation), 'NOT SUBMITTED') then domain1 = 'ZZ';
	        if index(upcase(annotation), 'NOTE:') then domain1 = 'ZN';
	        **<Assign ORIENTATION = P if missing>;
	        if missing(orientation) then orientation = "P";
	     **<PAGENO = PAGENO - 1>;
	     if compress(cats(pageno_1), , "kd") ne " " then pageno = put(input(cats(pageno_1), best.) - 1, best.);
	        **<Only keep the records with ANNOTATION not blank.>;
	        if not missing(annotation);
	    run;

	    proc sort data = AVGML._anno2;
	        by pageno domain1 ord;
	    run;

	    **5. Define color and count the width to assign the position if position is missing;
	    data AVGML._anno3;
	        length char $1.;
	        retain ord_domain;
	        set AVGML._anno2;
	        by pageno domain1 ord;

	        **<Define background color>;
	        domain_lag = lag(domain1);

	        if first.pageno then ord_domain = 1;
	        else if domain1 ne domain_lag then ord_domain = ord_domain + 1;

	        if      ord_domain = 1 then backcolor = &_c_blue.;
	        else if ord_domain = 3 then backcolor = &_c_green.;
	        else if ord_domain = 2 then backcolor = &_c_yellow.;
	        else if ord_domain = 5 then backcolor = &_c_salmon.;
	        else if ord_domain = 4 then backcolor = &_c_purple.;
	        if index(upcase(annotation),'NOT SUBMITTED') then backcolor = &_c_blue.;
	        if index(upcase(annotation),'NOTE:') then backcolor = &_c_beige.;

	        **<Define text color>;
	/*        if index(upcase(annotation),'NOT SUBMITTED') then textcolor = &_c_brown.;*/
	        if index(upcase(annotation),'NOTE:') then textcolor = &_c_olive.;
	        else if missing(name) then textcolor = &_c_black.;
	        else textcolor = &_c_black.;

	        **<Count the width>;
	        call missing(char, len);

	        declare hash h (dataset: 'avgml._len', ordered: 'ascending');
	        h.definekey ('char');
	        h.definedata('len');
	        h.definedone();

	        tot = 0;
	        do i = 1 to length(annotation);
	            rc  = h.find(key: substr(annotation, i, 1));
	            tot = tot + len;
	        end;

	        n1 = _n_;
	        n2 = _n_ + 10000;

	        if first.domain1 then ord_var = 1;
	        else if missing(position) then ord_var + 1;

	        if orientation = 'Landscape' then do;
	            x1 = 0 + (ord_var - 1) * &fontSize. + 20 * (ord_domain - 1);
	            x2 = x1 + tot + 5;
	            y1 = 500 - (ord_var - 1) * (&fontSize.);
	            y2 = y1 + 15;
	            **Position for NOT SUBMITTED;
	            x1_d = 0 + 20 * (ord_domain - 1);
	            x2_d = x1_d + tot * (&_fontsize_d. / &fontSize.) + 5 * (&_fontsize_d. / &fontSize.);
	            y1_d = 510;
	            y2_d = y1_d + 15 * (&_fontsize_d. / &fontSize.);
	        end;
	        else if orientation = 'Portrait' then do;
	            y1 = 0 + (ord_var - 1) * &fontSize. + 20 *(ord_domain - 1);
	            y2 = y1 + tot + 5;
	            x1 = 30 + (ord_var - 1) * (&fontSize.);
	            x2 = x1 - 15;
	            **Position for NOT SUBMITTED;
	            y1_d = 0 + 20 * (ord_domain - 1);
	            y2_d = y1_d + tot * (&_fontsize_d. / &fontSize.) + 5 * (&_fontsize_d. / &fontSize.);
	            x1_d = 20;
	            x2_d = x1_d - 15 * (&_fontsize_d. / &fontSize.);
	        end;
	    run;

	    **6. To output the xfdf file;
	    data _null_;
	        file "&_xfdfname.";
	        set AVGML._anno3 end = end;
	        by pageno ord_domain;

	        if _n_ = 1 then do;
	            put '<?xml version="1.0" encoding="UTF-8"?>';
	            put '<xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve"><annots>';
	        end;

	        if missing(name) and not index(upcase(annotation), 'NOT SUBMITTED') and not index(upcase(annotation), 'NOTE:') then do;
	            put '<freetext';
	            put ' color="' backcolor '"';
	            %if &lockComments. = Y %then %do;
	                put ' flags="locked"';
	            %end;
	            put ' name="' n2 '"';
	            put ' page="' pageno '"';
	            if orientation = 'Portrait' then do;
	                put ' rotation = "90"';
	            end;
	            if border = 'Striped' then do;
	                put ' width="1.000000" dashes="3.000000,3.000000" style="dash"';
	            end;
	            if missing(position) then do;
	                put ' rect="' x1_d ',' y1_d ',' x2_d ',' y2_d '">';
	            end;
	            if not missing(position) then do;
	                put ' rect="' position '">';
	            end;
	            put '<contents-richtext>';
	            put '<body xmlns="http://www.w3.org/1999/xhtml" xmlns:xfa="http://www.xfa.org/schema/xfa-data/1.0/"';
	            put ' xfa:APIVersion="Acrobat:11.0.0" xfa:spec="2.0.2" ';
	            put " style='font-size:&_fontsize_d. pt;text-align:left;color:#000000;font-weight:bold;";
	            put " font-family:Arial;font-stretch:normal'";
	            put '><p dir="ltr">' annotation '</p';
	            put '></body></contents-richtext></freetext>';
	        end;
	        else do;
	            put '<freetext';
	            put ' color="' backcolor '"';
	            %if &lockComments. = Y %then %do;
	                put ' flags="locked"';
	            %end;
	            put ' name="' n1 '"';
	            put ' page="' pageno '"';
	            if orientation = 'Portrait' then do;
	                put ' rotation = "90"';
	            end;
				if border = 'Striped' then do;
	                put ' width="1.000000" dashes="3.000000,3.000000" style="dash"';
	            end;
	            if missing(position) then do;
	                put ' rect="' x1 ',' y1 ',' x2 ',' y2 '"';
	            end;
	            if not missing(position) then do;
	                put ' rect="' position '"';
	            end;
	            put ' subject="' name '"';
	            put ' title="' domain '">';
	            put '<contents-richtext>';
	            put '<body xmlns="http://www.w3.org/1999/xhtml" xmlns:xfa="http://www.xfa.org/schema/xfa-data/1.0/"';
	            put ' xfa:APIVersion="Acrobat:11.0.0" xfa:spec="2.0.2" ';
	            put " style='font-size:&fontSize. pt;text-align:left;color:" textcolor ";font-weight:normal;";
	            put " font-family:Arial;font-stretch:normal'";
	            put '><p dir="ltr">' annotation '</p';
	            put '></body></contents-richtext></freetext>';
	        end;

	        if end then do;
	            put '</annots>';
	            put '</xfdf>';
	        end;
	    run;
	%end;

%mend avAnnCreateXFDFfromXLSX;
