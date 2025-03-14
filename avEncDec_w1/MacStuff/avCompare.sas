/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avCompare.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Utility macro for comparing two datasets and output report as rtf.
				   Factored this out from avInterimDataToFinalStandard, and modified.
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  : 
Date changed     : 
By				 : 
=======================================================================================*/

%macro avCompare(dataOut=, domain=, standard=);
	options orientation= portrait;
	* ------------------------- ;
	* Template used for outputs ;
	* ------------------------- ;
	ODS PATH work.templat(update) sasuser.templat(read)
	               sashelp.tmplmst(read);
	PROC TEMPLATE;
	  DEFINE STYLE styles.CompareReport;
	  PARENT=styles.printer;
	  style parskip / fontsize = 0pt;
	  REPLACE FONTS /
	    'TitleFont'           = ('COURIER NEW', 8pt)
	    'TitleFont2'          = ('COURIER NEW', 8pt)
	    'StrongFont'          = ('COURIER NEW', 8pt)
	    'EmphasisFont'        = ('COURIER NEW', 8pt)
	    'HeadingEmphasisFont' = ('COURIER NEW', 8pt)
	    'HeadingFont'         = ('COURIER NEW', 8pt)
	    'DocFont'             = ('COURIER NEW', 8pt)
	    'FootFont'            = ('COURIER NEW', 8pt)
	    'FixedEmphasisFont'   = ('COURIER NEW', 8pt)
	    'FixedStrongFont'     = ('COURIER NEW', 8pt)
	    'FixedHeadingFont'    = ('COURIER NEW', 8pt)
	    'BatchFixedFont'      = ('COURIER NEW', 8pt)
	    'FixedFont'           = ('COURIER NEW', 8pt);
	  REPLACE TABLE FROM OUTPUT /
	    frame = box
	    rules = all
	    cellpadding = 1pt
	    cellspacing = 0pt;
	  CLASS SYSTEMTITLE /
	    protectspecialchars=OFF
	    asis=ON;
	  CLASS SYSTEMFOOTER /
	    font=Fonts('footFont')
	    protectspecialchars=OFF
	    asis=ON;
	  CLASS HEADER /
	    protectspecialchars=off;
	  CLASS DATA /
	    protectspecialchars=off;
	  CLASS ROWHEADER /
	    protectspecialchars=off;
	  CLASS USERTEXT /
	    protectspecialchars=off;
	  CLASS BYLINE /
	    protectspecialchars=off;
	  STYLE graphfonts from graphfonts /
	    'GraphDataFont'     = ('COURIER NEW', 8pt)
	    'GraphUnicodeFont'  = ('COURIER NEW', 8pt)
	    'GraphValueFont'    = ('COURIER NEW', 8pt)
	    'GraphLabel2Font'   = ('COURIER NEW', 8pt)
	    'GraphLabelFont'    = ('COURIER NEW', 8pt)
	    'GraphFootnoteFont' = ('COURIER NEW', 8pt)
	    'GraphTitleFont'    = ('COURIER NEW', 8pt)
	    'GraphTitle1Font'   = ('COURIER NEW', 8pt)
	    'GraphAnnoFont'     = ('COURIER NEW', 8pt);
	  STYLE usertext from usertext / outputwidth=100%;
	  END;
	RUN;

	%let rtf_ch= NOCMP;
	%let comp_p= ; 
	%let comp_v=;
	%let comp_sp=;
	%let comp_sv=;

	data _null_;
		length lib dsn $200;
		out="&dataOut";

		/* Splitting library and dataset from &dataOut */
		cnt=countw(out, ".");

		if cnt=2 then do;
			lib=upcase(scan(out, 1, "."));
			dsn=upcase(scan(out, 2, "."));
		end;
		else if cnt=1 then do;
			lib='WORK';
			dsn=scan(out, 1, ".");
		end;
		else do;
			/* Used for warning messages */
			datetime=datetime();
			put "WARNING:1/[AVANCE " datetime e8601dt. "] dataOut contains no or more than 1 fullstops('.'). [Code: CMP1].";
			put "WARNING:2/[AVANCE " datetime e8601dt. "] That should have been flagged in initial exception handling.";
		end;

		/* If validation (_v), set production datasets and rtf flag */
		if index(dsn, "_")>0 then do;
			%if %upcase(&standard)=SDTM %then %do;
				call symputx("comp_p", cats(tranwrd(lib, "SV", "SP"), ".", tranwrd(dsn, "_V", "")));
				call symputx("comp_v", cats(lib, ".", dsn));
				call symputx("comp_sp", cats(tranwrd(lib, "SV", "SP"), ".SUPP", tranwrd(dsn, "_V", "")));	
				call symputx("comp_sv", cats(lib, ".SUPP", dsn));
			%end;
			%else %if %upcase(&standard)=ADAM %then %do;
				call symputx("comp_p", cats(tranwrd(lib, "AV", "AP"), ".", tranwrd(dsn, "_V", "")));
				call symputx("comp_v", cats(lib, ".", dsn));
			%end;
			%else %if %upcase(&standard)=OUTPUT %then %do;
				call symputx("comp_p", cats(tranwrd(lib, "OV", "OP"), ".", tranwrd(dsn, "_V", "")));
				call symputx("comp_v", cats(lib, ".", dsn));
			%end;

			call symputx("rtf_ch", dsn);
		end;
	run;

	/**
	If NoCompare flag is not set,
	i.e. if it is not called from production (dataset name does not end with _v)
	*/
	%if %upcase(&rtf_ch)^=NOCMP %then %do;
		%if %sysfunc(exist(&comp_p)) and %sysfunc(exist(&comp_v))  %then %do;
			%avCompareRTF(domain=&domain, standard=&standard, base=&comp_p, compare=&comp_v)
		%end;
		%else %if ^%sysfunc(exist(&comp_p))  %then %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Compare Report - production dataset does not exist.;
		%end;
		%else %if ^%sysfunc(exist(&comp_v))  %then %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Compare Report - validation dataset does not exist.;
		%end;

		%if %upcase(&standard)=SDTM %then %do;
			%if %sysfunc(exist(&comp_sp)) and %sysfunc(exist(&comp_sv))  %then %do;
				%avCompareRTF(domain=SUPP&domain, standard=&standard, base=&comp_sp, compare=&comp_sv)
			%end;
			%else %if ^%sysfunc(exist(&comp_sp)) and ^%sysfunc(exist(&comp_sv))  %then %do;
				/* Both production and validation supp dataset do not exist */
				/* Do nothing. If supp is expected, that would have been flagged in the suppqual section of this macro. */
			%end;
			%else %if ^%sysfunc(exist(&comp_sp))  %then %do;
				%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Compare Report - production supp dataset does not exist.;
			%end;
			%else %if ^%sysfunc(exist(&comp_sv))  %then %do;
				%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Compare Report - validation supp dataset does not exist.;
			%end;
		%end;
	%end;
	options orientation= landscape;
%mend avCompare;
