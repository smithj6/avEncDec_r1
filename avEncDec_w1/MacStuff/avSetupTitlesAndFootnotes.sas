/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avSetupTitlesAndFootnotes.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Assign default and output specific headers and footers for specified output
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avSetupTitlesAndFootnotes(output=);
	%if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML is study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%symglobl(client) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable client is not defined in global scope;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%symglobl(studyno) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable studyno is not defined in global scope;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%symglobl(mspath) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable mspath is not defined in global scope;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%symglobl(tflpath) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable tflpath is not defined in global scope;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%symglobl(tflpdfpath) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable tflpdfpath is not defined in global scope;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;


	%local av_spons av_prot av_vers av_pageline av_outputName_ av_outputType_ av_maintitle1 av_maintitle2 av_finalFootnote1 av_finalFootnote2 av_createdDate av_createdTime av_prevOutputName nTitles nFootnotes nObsCount bkdtc;
	%global outputName footnoteCount;


	/*======================= Set initial output Type and Name ========================*/
	%let outputName 	= %sysfunc(upcase(&output)) (&studyno); 	/* This is overwritten from excel spec */


	/*======================= Set Default Titles and Footnotes ========================*/
	%let av_sponsor 	= %scan(&client, 2, \);	/* Sponsor derived from avSetup.sas Client variable. Update if required */
	%let av_protocol 	= &studyno;				/* Protocol derived from avSetup.sas studyno variable. Update if required */
	%let av_version 	= Draft;
	%let av_pageline 	= '_________________________________________________________________________________________________________________________________________________';


	/* Set as per standard Shells. Updated if layout was changed */
	%let av_maintitle1 = 	justify = l "&av_sponsor" 				justify =r "Version: &av_version";
	%let av_maintitle2 = 	justify = l "Protocol: &av_protocol" 	justify =r "CONFIDENTIAL";


	title;
	title1 &av_maintitle1;
	title2 &av_maintitle2;

	/* Set as per standard Shells. Updated if layout was changed */
	%let footnoteCount = 1;
	footnote1 &av_pageline;


	%if %sysfunc(fileexist(&mspath\01_Specifications\03_TFL\titles.sas7bdat))=0 or %sysfunc(fileexist(&mspath\01_Specifications\03_TFL\footnotes.sas7bdat))=0 %then %do;
		%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Both Titles.sas7bdat and Footnotes.sas7bdat are required for output specific Titles and Footnotes;
		%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] No output specific Titles or Footnotes will be added;
	%end;
	%else %do;
		proc datasets library=avgml memtype=data kill nolist nowarn;
		quit;


		/*============================ Set all Titles from XLSX ===========================*/
		data AVGML.titles_output;
			set &spectf..titles;
			where upcase(program_name) = upcase("&output.");
		run;

		proc sql noprint;
			select coalesce(count(*), 0) into :nTitles from AVGML.titles_output;
		quit;

		%if &nTitles. = 0 %then %do;
			%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No title observations found for &output in Titles.sas7bdat;
			%put NOTE:2/[AVANCE %sysfunc(datetime(), e8601dt.)] No output specific titles added;

			/* Skip all output specific title creation */
			%goto skipTitles;
		%end;
		%else %if &nTitles. > 1 %then %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Multiple title observations found for &output in Titles.sas7bdat;
			%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Only one title observation allowed per output. Nodupkey performed;

			data AVGML.titles_output;
				set AVGML.titles_output;

				proc sort nodupkey;
					by program_name;
			run;
		%end;


		/*================================ Set output Name ================================*/
		proc sql noprint;
			select a.output_name into :av_outputName_ from AVGML.titles_output as a;
		quit;
		
		%let outputName 	= %sysfunc(upcase(&output)) %sysfunc(strip(&av_outputName_)) (&studyno);		/* Any additional formatting can be done here */


		/*=========================== Supersede previous output ===========================*/
		/* Can only be superseded once outputName is identified from sheet */
		data _null_;
			length date1 $200.;
			date=today();
			time=strip(put(time(), tod8.));
			date1= catt(strip(put(date, is8601da.))," h", scan(time, 1, ":"),"m", scan(time, 2, ":"),"s", scan(time, 3, ":"));
			call symputx("bkdtc", date1);
		run;

		%let av_prevOutputName = %sysfunc(scan(&outputName., 1, ' '));

		%if ^%sysfunc(fileexist(&tflpath\Superseded)) %then %do;
			data _null_;
				length superseded $200.;
				superseded=dcreate("Superseded", "&tflpath");
			run;
		%end;

		/* First part of previous name is used split by blank space, to avoid length issues. Assuming output name follows T_1_1_1 Summary... */
		%sysexec copy "&tflpath\&outputName..rtf" "&tflpath\Superseded\&av_prevOutputName &bkdtc..rtf";


		%if ^%sysfunc(fileexist(&tflpdfpath\Superseded)) %then %do;
			data _null_;
				length superseded $200.;
				superseded=dcreate("Superseded", "&tflpdfpath");
			run;
		%end;

		/* First part of previous name is used split by blank space, to avoid length issues. Assuming output name follows T_1_1_1 Summary... */
		%sysexec copy "&tflpdfpath\&outputName..pdf" "&tflpdfpath\Superseded\&av_prevOutputName &bkdtc..pdf";


		/*================================== Set Titles ===================================*/
		data AVGML.titles_sorted;
			set AVGML.titles_output;
			length output_number $200.;

			/* Derive program number from program name */
			program_name_ = scan(program_name, 1, ' ');	/* select first text if spaces are present in name */

			/* loop through each occurances between _ */
			do i=1 by 1 while(scan(program_name_, i, '_') ^= ' ');
				temp_numb = input(strip(scan(program_name_, i, '_')), ??best.); /* Attempt to create numeric value of text */
				output_number = catx('.', output_number, put(temp_numb, best.)); /* Create combined variable of each numeric value if created */
			end;

			proc sort;
				by program_name output_number;
		run;

		proc transpose data=AVGML.titles_sorted out=AVGML.titles_output_t;
			by program_name output_number;
			var title:;
		run;

		data AVGML.titles_final (keep=output_number title value count);
			set AVGML.titles_output_t;
			where _name_ ^= '' and col1 ^= '';
			length title $6. value $5000.;


			/* Increment the addition if more standard titles are added. Currently only 2 as per standard shells */
			title = cats('Title', input(scan(_label_, 2, '_'), best.) + 2);	

			/* Any occurance of the tag <output> is replaced with the output number */
			value = strip(tranwrd(col1, '<output_number>', compress(output_number)));
			count = input(scan(_label_, 2, '_'), best.);
		run;

		proc sql noprint;
			select coalesce(count(*), 0) into :nTitlesTot from AVGML.titles_final;
		quit;

		%let titleCount = 1;
		%beginTitles:
			proc sql noprint;
				select title into :tempTitle 		from AVGML.titles_final as a where a.count = &titleCount;
				select value into :tempTitleValue 	from AVGML.titles_final as a where a.count = &titleCount;				
			quit;

			&tempTitle "&tempTitleValue.";
		%endTitles:
		%let titleCount = %eval(&titleCount + 1);
		%if &titleCount <= &nTitlesTot %then %goto beginTitles;


		%skipTitles:

		/*========================== Set all Footnotes from XLSX ==========================*/
		data AVGML.footnotes_output;
			set &spectf..footnotes;
			where upcase(program_name) = upcase("&output.");
		run;

		proc sql noprint;
			select coalesce(count(*), 0) into :nFootnotes from AVGML.footnotes_output;
		quit;

		%if &nFootnotes. = 0 %then %do;
			%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No footnote observations found for &output in Footnotes.sas7bdat;
			%put NOTE:2/[AVANCE %sysfunc(datetime(), e8601dt.)] No output specific footnotes added;

			/* Skip all output specific footnote creation */
			%goto skipFootnotes;
		%end;
		%else %if &nFootnotes. > 1 %then %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Multiple footnote observations found for &output in Footnotes.sas7bdat;
			%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Only one footnote observation allowed per output. Nodupkey performed;

			data AVGML.footnotes_output;
				set AVGML.footnotes_output;

				proc sort nodupkey;
					by program_name;
			run;
		%end;

		proc sql noprint;
			select coalesce(count(*), 0) into :nObsCount from &tlfp..&programName;
		quit;

		%if &nObsCount. = 0 %then %do;
			%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No observations found in &tlfp..&programName;
			%put NOTE:2/[AVANCE %sysfunc(datetime(), e8601dt.)] No output specific footnotes added;

			/* Skip all output specific footnote creation */
			%goto skipFootnotes;
		%end;

		proc transpose data=AVGML.footnotes_output out=AVGML.footnotes_output_t;
			by program_name;
			var footnote:;
		run;

		data AVGML.footnotes_final (keep=footnote value count);
			set AVGML.footnotes_output_t;
			where _name_ ^= '' and col1 ^= '';
			length footnote $9. value $5000.;


			/* Increment by one to compensate for footline. Remove if footline is removed */
			footnote = cats('Footnote', input(scan(_label_, 2, '_'), best.) + 1);	

			/* Any occurance of the tag <output> is replaced with the output number */
			value = strip(col1);
			count = input(scan(_label_, 2, '_'), best.);
		run;

		proc sql noprint;
			select coalesce(count(*), 0) into :nFootnotesTot from AVGML.footnotes_final;
		quit;
		
		%beginFootnotes:
			proc sql noprint;
				select footnote into :tempFootnote 			from AVGML.footnotes_final as a where a.count = &footnoteCount;
				select value 	into :tempFootnoteValue 	from AVGML.footnotes_final as a where a.count = &footnoteCount;				
			quit;

			&tempFootnote justify=l "&tempFootnoteValue";
		%endFootnotes:
		%let footnoteCount = %eval(&footnoteCount + 1);
		%if &footnoteCount <= &nFootnotesTot %then %goto beginFootnotes;

		%skipFootnotes:
	%end;

	/*========================== Set Default ending Footnote ==========================*/
	%let av_createdDate 	= 	%sysfunc(date(), date11.);
	%let av_createdTime 	= 	%sysfunc(time(), time5.);

	%let av_finalFootnote1 = Footnote%eval(&footnoteCount + 1);
	%let av_finalFootnote2 = Footnote%eval(&footnoteCount + 2) justify=l "Program:&output..sas" 
															justify=c "Creation Date/Time: &av_createdDate. &av_createdTime."  
															justify=r "Page (*ESC*){thispage} of (*ESC*){lastpage}";
	
	&av_finalFootnote1;
	&av_finalFootnote2;

	/* Increment global footnoteCount variable. Can be used for paging */
	%let footnoteCount 	= 	%eval(&footnoteCount + 2);
%mend avSetupTitlesAndFootnotes;


/*================================== Report Templates =================================*/
proc template;
	define style COUR8_0;
	notes "Normal Report Style, Cellpadding = 0";
	class systemtitle /
		fontsize 		= 8pt
		fontweight		= bold
		fontfamily 		= "Courier New"

		/* margintop	= 25pt */
		backgroundcolor = White;

	class header /
	    backgroundcolor = White
		fontfamily 		= "Courier New"
		fontsize 		= 8pt
		fontweight		= bold;

	style byline from header;

	class footer /
	    backgroundcolor = White
		fontfamily 		= "Courier New"
		fontsize 		= 8pt
	  	frame			= above
		rules			= groups;

	class SystemFooter /
		font_face 		= "Courier New"
		font_size 		= 8pt
		background 		= white;

	class body /
		backgroundcolor = White
		color 			= Black
		fontfamily 		= "Courier New"
		fontsize 		= 8pt;

	class table /
		bordercolor 	= black
		borderstyle 	= solid
		borderwidth 	= 1pt
		cellpadding 	= 0pt
		cellspacing 	= 1pt
		fontfamily 		= "Courier New"
		fontsize 		= 8pt
	  	frame			= void
		rules			= groups;

	class data / 
		fontfamily 		= "Courier New" 
		fontsize 		= 8pt;
	end;
run;


proc template;
	define style COUR8_0_5;
	notes "Normal Report Style, Cellpadding = 1";
	class systemtitle /
		fontsize 		= 8pt
		fontweight 		= bold
		fontfamily 		= "Courier New"

		/* margintop	= 25pt */
		backgroundcolor = White;

	class header /
	    backgroundcolor = White
		fontfamily 		= "Courier New"
		fontsize 		= 8pt
		fontweight		= bold;

	style byline from header;

	class footer /
	    backgroundcolor = White
		fontfamily 		= "Courier New"
		fontsize 		= 8pt
	  	frame			= above
		rules			= groups;

	class SystemFooter /
		font_face 		= "Courier New"
		font_size 		= 8pt
		background 		= white;

	class body /
		backgroundcolor = White
		color 			= Black
		fontfamily 		= "Courier New"
		fontsize 		= 8pt;	

	class table /
		bordercolor 	= black
		borderstyle 	= solid
		borderwidth 	= 1pt
		cellpadding 	= 0.5pt
		cellspacing 	= 1pt
		fontfamily 		= "Courier New"
		fontsize 		= 8pt
	  	frame			= void
		rules			= groups;

	class data / 
		fontfamily 		= "Courier New" 
		fontsize 		= 8pt;
	end;
run;


proc template;
	define style COUR8_1;
	notes "Normal Report Style, Cellpadding = 1";
	class systemtitle /
		fontsize 		= 8pt
		fontweight		= bold
		fontfamily 		= "Courier New"

		/* margintop	= 25pt */
		backgroundcolor = White;

	class header /
	    backgroundcolor = White
		fontfamily 		= "Courier New"
		fontsize 		= 8pt
		fontweight		= bold;

	style byline from header;

	class footer /
	    backgroundcolor = White
		fontfamily 		= "Courier New"
		fontsize 		= 8pt
		frame			= above
		rules			= groups;

	class SystemFooter /
		font_face 		= "Courier New"
		font_size 		= 8pt
		background 		= white;

	class body /
		backgroundcolor = White
		color 			= Black
		fontfamily 		= "Courier New"
		fontsize 		= 8pt;	

	class table /
		bordercolor 	= black
		borderstyle 	= solid
		borderwidth 	= 1pt
		cellpadding 	= 1pt
		cellspacing 	= 1pt
		fontfamily 		= "Courier New"
		fontsize 		= 8pt
	  	frame			= void
		rules			= groups;

	class data / 
		fontfamily 		= "Courier New" 
		fontsize 		= 8pt;
	end;
run;


proc template;
	define style COUR8_0_2;
	notes "Normal Report Style, Cellpadding = 1";

	class systemtitle /
		fontsize 		= 8pt
		fontweight		= bold
		fontfamily 		= "Courier New"

		/* margintop	= 25pt */
		backgroundcolor = White;

	class header /
	    backgroundcolor = White
		fontfamily 		= "Courier New"
		fontsize 		= 8pt
		fontweight		= bold;

	style byline from header;

	class footer /
	    backgroundcolor = White
		fontfamily 		= "Courier New"
		fontsize 		= 8pt
		frame			= above
		rules			= groups;

	class SystemFooter /
		font_face 		= "Courier New"
		font_size 		= 8pt
		background 		= white;

	class body /
		backgroundcolor = White
		color 			= Black
		fontfamily 		= "Courier New"
		fontsize 		= 8pt;	

	class table /
		bordercolor 	= black
		borderstyle 	= solid
		borderwidth 	= 1pt
		cellpadding 	= 0.2pt
		cellspacing 	= 1pt
		fontfamily	 	= "Courier New"
		fontsize 		= 8pt
	  	frame			= void
		rules			= groups;

	class data / 
		fontfamily 		= "Courier New" 
		fontsize 		= 8pt;
	end;
run;

proc template;
	define style COUR8_2;
	notes "Normal Report Style, Cellpadding = 2";
	class systemtitle /
		fontsize 		= 8pt
		fontweight		= bold
		fontfamily 		= "Courier New"

		/* margintop	= 25pt */
		backgroundcolor = White;

	class header /
	    backgroundcolor = White
		fontfamily 		= "Courier New"
		fontsize 		= 8pt
		fontweight		= bold;

	style byline from header;

	class footer /
	    backgroundcolor = White
		fontfamily 		= "Courier New"
		fontsize 		= 8pt
		frame			= above
		rules			= groups;

	class SystemFooter /
		font_face 		= "Courier New"
		font_size 		= 8pt
		background 		= white;

	class body /
		backgroundcolor = White
		color 			= Black
		fontfamily 		= "Courier New"
		fontsize 		= 8pt;

	class table /
		bordercolor 		= black
		borderstyle 		= solid
		borderwidth 		= 1pt
		cellpadding 		= 2pt
		cellspacing 		= 1pt
		fontfamily 			= "Courier New"
		fontsize 			= 8pt
	  	frame				= void
		rules				= groups;

		class data / 
			fontfamily 		= "Courier New" 
			fontsize 		= 8pt;
		end;
run;

proc template;
	define style COUR8_3;
	notes "Normal Report Style, Cellpadding = 3";
	class systemtitle /
		fontsize 		= 8pt
		fontweight		= bold
		fontfamily 		= "Courier New"

		/* margintop	= 25pt */
		backgroundcolor = White;

	class header /
	    backgroundcolor = White
		fontfamily 		= "Courier New"
		fontsize 		= 8pt
		fontweight		= bold;

	style byline from header;

	class footer /
	    backgroundcolor = White
		fontfamily 		= "Courier New"
		fontsize 		= 8pt
		frame			= above
		rules			= groups;

	class SystemFooter /
		font_face 		= "Courier New"
		font_size 		= 8pt
		background 		= white;

	class body /
		backgroundcolor = White
		color 			= Black
		fontfamily 		= "Courier New"
		fontsize 		= 8pt;	

	class table /
		bordercolor 	= black
		borderstyle 	= solid
		borderwidth 	= 1pt
		cellpadding 	= 3pt
		cellspacing 	= 1pt
		fontfamily 		= "Courier New"
		fontsize 		= 8pt
	  	frame			= void
		rules			= groups;

	class data / 
		fontfamily 		= "Courier New" 
		fontsize 		= 8pt;
	end;
run;
