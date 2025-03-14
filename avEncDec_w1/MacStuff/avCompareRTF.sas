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
Note             : Utility function for rtf output used with avCompare.
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  : 
Date changed     : 
By				 : 
=======================================================================================*/

%macro avCompareRTF(domain=, standard=, base=, compare=);
	ods listing close;
	ods noresults;
	ods rtf style= CompareReport  file="&mspath\05_OutputDocs\02_Compares\%upcase(&domain).rtf";
	ods rtf StartPage=no ;

	%let CreatedDate = %sysfunc(date(),date9.) ;
	%let CreatedTime= %sysfunc(time(),tod5.) ;
	%let sponsor = %scan(&client,2,\);

	%let maintitle = justify =l "(*ESC*)R'\pvmrg\posyt' Sponsor: &sponsor" justify =r "Milestone: &Milestone" ;
	%let maintitle2 = justify =l "(*ESC*)R'\pvmrg\posyt' Protocol No.: &studyno" justify =r 'Page (*ESC*){thispage} of (*ESC*){lastpage}';

	%let footer= justify =l "(*ESC*)R'\pvmrg\posyb\fs16' ..\\&Milestone\\05_OutputDocs\\02_Compares\\%upcase(&domain).rtf" justify =r "&CreatedDate &Createdtime";

	title;
	title1 &maintitle ;
	title2 &maintitle2 ;
	title3 "(*ESC*)R'\pvmrg\posyt\fs8' (*ESC*){nbspace 1}";
	title4 justify=c "(*ESC*)S={FONTWEIGHT=bold BACKGROUNDCOLOR = cxEDF2F9}(*ESC*)R'\pvmrg\posyt\qc' Verification result for: %upcase(&standard) %upcase(&domain) domain";
	title5 "(*ESC*)R'\pvmrg\posyt\fs8' (*ESC*){nbspace 1}";
	title6 justify=l "(*ESC*)R'\pvmrg\posyt' Production programmer: Not Available";
	title7 justify=l "(*ESC*)R'\pvmrg\posyt' Validation programmer: &sysuserid";
	title8 "(*ESC*)R'\pvmrg\posyt\brdrb\brdrth\brdrw15\brsp1\fs2' (*ESC*){nbspace 1}";
/*		title9 "(*ESC*)R'\pvmrg\posyt\fs8' (*ESC*){nbspace 1}";*/
	footnote1 "(*ESC*)R'\pvmrg\posyb' ____________________________________________________________________________________________";
	footnote2 "(*ESC*)R'\pvmrg\posyb\brdrt\brdrth\brdrw15\brsp1\fs2' (*ESC*){nbspace 1}";
	footnote3 &footer;

	proc compare base=&base compare= &compare listall criterion=0.001; run;

	
	ods rtf close;
	ods listing;
%mend avCompareRTF;
