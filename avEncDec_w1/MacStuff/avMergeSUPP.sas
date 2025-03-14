/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avMergeSUPP.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Merge domain with supplemental domain
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avMergeSUPP(library=, domain=, idvar=);
	 %if %sysfunc(libref(AVGML)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library AVGML is not assigned. Assign Library AVGML is study setup file;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysfunc(libref(&library)) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Library &library is not assigned.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(exist(%bquote(&library..&domain))) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Domain &domain does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysfunc(exist(%bquote(&library..supp&domain))) %then %do;
		%put NOTE:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Supplemental domain supp&domain does not exist. No merge performed;

		data &domain._supp&domain;
			set &library..&domain.;
		run;

		%return;
	%end;
	%else %do;
		proc datasets library=avgml memtype=data kill nolist nowarn;
		quit;

		data AVGML.av_supp;
			set &library..supp&domain.;

			%if &idvar^= %then %do;	
				&idvar. =input(idvarval, best.);
			%end;

			keep usubjid &idvar. qnam qval qlabel;
		run;

		proc sort data=AVGML.av_supp; 
			by usubjid &idvar. ;
		run;

		proc transpose data=AVGML.av_supp out=AVGML.av_supp_t(drop=_name_ _label_);
			by usubjid &idvar.;
			var qval;
			id qnam;
			idlabel qlabel;
		run;

		proc sort data=&library..&domain out=AVGML.av_main;
			by usubjid &idvar.;
		run;

		proc sort data=AVGML.av_supp_t;
			by usubjid &idvar.;
		run;

		data &domain._supp&domain;
			merge AVGML.av_main(in=a) AVGML.av_supp_t(in=b);
			by usubjid &idvar.;

			if a;
		run;
	%end;
%mend avMergeSUPP;
