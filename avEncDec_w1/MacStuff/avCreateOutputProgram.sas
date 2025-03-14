/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avCreateOutputProgram.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Create tfl programs in study timeline
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avCreateOutputProgram(output=, sourceExcel=N, sourceExcelSide=P)/minoperator;
	%if &sourceExcel = N %then %do;
		%if %sysevalf(%superq(output)  =, boolean) %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameter output is required when sourceExcel is N;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;
	%end;

	%if ^%eval(%qupcase(%bquote(&sourceExcel)) in Y N) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid selection for macro parameter sourceExcel (%bquote(&sourceExcel)). Valid selections are Y or N and are case insensitive;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%eval(%qupcase(%bquote(&sourceExcelSide)) in P V) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Invalid selection for macro parameter sourceExcelSide (%bquote(&sourceExcelSide)). Valid selections are P or V and are case insensitive;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

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

	%if %sysfunc(fileexist(&mspath.\08_Final Programs\03_TFL))=0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] TFL program path &mspath.\08_Final Programs\03_TFL does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	/* Upcase input parameters */
	%let sourceExcel = %qupcase(&sourceExcel);
	%let sourceExcelSide = %qupcase(&sourceExcelSide);

	proc datasets library=avgml memtype=data kill nolist nowarn;
	quit;

	%if &sourceExcel = Y %then %do;
		/*========================== Get program names from Excel =========================*/
		%if %sysfunc(fileexist(&mspath\01_Specifications\03_TFL\titles.sas7bdat))=0 %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Titles.sas7bdat does not exist in &mspath\01_Specifications\03_TFL when sourceExcel = Y;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;

		data AVGML.av_all_programs (keep=program source_program_name);
			set &spectf..titles;
			where program_name ^= '';
			length program $200.;
			side = "&sourceExcelSide";

			/* Program name from excel is expected to be correct. Doing same checks as done for parameter for consistency */
			program = strip(scan(program_name, 1, '.'));
			program = strip(tranwrd(compress(program), ' ', '_'));

			if index(upcase(program), '_V') = 0 and side = 'V' then program = cats(program, '_v');

			program = strip(lowcase(program));
		run;

		data AVGML.av_all_programs_unique;
			set AVGML.av_all_programs;
			where program ^= '';

			i = _n_;

			proc sort nodupkey;
				by program;
		run;
	%end;
	%else %if &sourceExcel = N %then %do;
		/*======================== Get program names from Parameter =======================*/
		data AVGML.av_all_programs_;
			col = "&output.";
			output;
		run;

		data AVGML.av_all_programs;
			set AVGML.av_all_programs_;
			length program source_program_name $200.;

			/* Use the default blank template for manual tfls */
			source_program_name = '_blank_';

			do i=1 by 1 while(scan(col, i, '#') ^= ' ');
				program = strip(scan(col, i, '#'));
				program = strip(scan(program, 1, '.'));
				program = strip(tranwrd(compress(program), ' ', '_'));
				program = strip(lowcase(program));
				output;
			end;
		run;

		data AVGML.av_all_programs_unique;
			set AVGML.av_all_programs;
			where program ^= '';

			proc sort nodupkey;
				by program;
		run;
	%end;

	%local N i nFiles singleOutput singleOutputSource _progloc _logloc _dirloc _outfile _type _file _source_file _side folderId;

	proc sql noprint;
		select count(*) into :N from AVGML.av_all_programs_unique;
	quit;

	%if &n. = 0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No unique outputs identified from input source;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%let i=1;
	%let nFiles = &n.;

	%let i = 1;
	%begin:
		proc sql noprint;
			select program into :singleOutput from AVGML.av_all_programs_unique where I = &i;
			select source_program_name into :singleOutputSource from AVGML.av_all_programs_unique where I = &i;
		quit;

		data AVGML.av_location;
			length progloc logloc dirloc outfile folderId $500. file type $20.;
			file = "&singleOutput.";
			source_file = "&singleOutputSource.";

			outfile = strip(file) || " {RFT file name} " || "-(" || "&StudyNo" || ")";

			if index(upcase(file), '_V') then folderId = 'Validation';
			else folderId = 'Production';

			/*======================= Assign path based on program name =======================*/
			if lowcase(substr(file, 1, 1)) = "f" then do;
				progloc	= cats("&mspath\08_Final Programs", "\", "03_TFL\", folderId, "\Figures", 		"\", file, ".sas");
				logloc	= cats("&mspath\08_Final Programs", "\", "03_TFL\", folderId, "\Figures\logs", 	"\", file, ".log");
				dirloc	= cats("TFLpath\", folderId, "\", "Figures");
				type = 'Figures';
			end;
			
			if lowcase(substr(file, 1, 1)) = "l" then do;
				progloc	= cats("&mspath\08_Final Programs", "\", "03_TFL\", folderId, "\Listings", 	 	"\", file, ".sas");
				logloc	= cats("&mspath\08_Final Programs", "\", "03_TFL\", folderId, "\Listings\logs", "\", file, ".log");
				dirloc	= cats("TFLpath\", folderId, "\", "Listings");
				type = 'Listings';
			end;
			
			if lowcase(substr(file, 1, 1)) = "t" then do;
				progloc	= cats("&mspath\08_Final Programs", "\",  "03_TFL\", folderId, "\Tables", 	   	"\", file, ".sas");
				logloc	= cats("&mspath\08_Final Programs",  "\", "03_TFL\", folderId, "\Tables\logs", 	"\", file, ".log");
				dirloc	= cats("TFLpath\", folderId, "\", "Tables");
				type = 'Tables';
			end;

			/*========================= Delete if path is not assigned ========================*/
			/* New types will need to be added manuually when required */
			if type = '' then delete;
		run;

		proc sql noprint;
			select count(*) into :N from AVGML.av_location;
		quit;

		%if &n. = 0 %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Could not derive output path from output &singleOutput;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Output name should start with L, T or F and match standard naming convention L_01_01_A for example;
			%goto skip;
		%end;

		proc sql noprint;
			select progloc 		into: _progloc 		trimmed from AVGML.av_location;
			select logloc  		into: _logloc  		trimmed from AVGML.av_location;
			select dirloc  		into: _dirloc  		trimmed from AVGML.av_location;
			select outfile 		into: _outfile 		trimmed from AVGML.av_location;
			select type 		into: _type 		trimmed from AVGML.av_location;
			select file 		into: _file 		trimmed from AVGML.av_location;
			select source_file 	into: _source_file 	trimmed from AVGML.av_location;
			select folderId		into: _side 		trimmed from AVGML.av_location;
		quit;

		%if ^%sysfunc(fileexist(&_progloc.))=0 %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Output program &_progloc. already exists;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Output program not created;
			%goto skip;
		%end;

		%if %sysevalf(%superq(_source_file)  =, boolean) %then %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] No source program specified for TFL program: (%bquote(&_file..sas));
			%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Blank output program will be created;

			%let _source_file = _blank_;
		%end;
		%else %if %sysfunc(fileexist(T:\Standard Programs\Prod\v&version\&CRFbuild\08_Final Programs\03_TFL\&_side\&_source_file..sas))=0 %then %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Standard TFL program: (%bquote(&_file..sas)) does not exist;
			%put WARNING:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Blank output program will be created;

			%let _source_file = _blank_;
		%end;

		%sysexec powershell -Command "$fileContents = gc %str(%')T:\Standard Programs\Prod\v&version\&CRFbuild\08_Final Programs\03_TFL\&_side\&_source_file..sas%str(%');
									  $fileContents = $fileContents -creplace '<Milestone>',%str(%')&mspath%str(%');
									  $fileContents = $fileContents -creplace '<Study Number>',%str(%')&studyno%str(%');
									  $fileContents = $fileContents -creplace '<Sponsor>',%str(%')%scan(&Client, 2, \)%str(%');
									  $fileContents = $fileContents -creplace '<Type>',%str(%')&_type%str(%');
									  $fileContents = $fileContents -creplace '<Program>',%str(%')&_file%str(%');
									  $fileContents = $fileContents -creplace '<Current Date>',%str(%')%left(%sysfunc(today(),date9.))%str(%');
									  $fileContents = $fileContents -creplace '<User>',%str(%')&sysuserid%str(%');
									  $fileContents = $fileContents -creplace '<Log Path>',%str(%')&_logloc%str(%');
									  
									  echo $fileContents | Out-File -encoding ASCII %str(%')&_progloc%str(%');";		
	%skip:
	%let i = %eval(&i + 1);
	%if &i <= &nFiles %then %goto begin;
%mend avCreateOutputProgram;
