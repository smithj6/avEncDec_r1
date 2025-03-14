/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avCreateFolderStructure.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Create standard folder structure for new study
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avCreateFolderStructure(client=, root=, milestone=, sourceMilestone=);
	%if ^%symglobl(version) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable version is not defined in global scope;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;
	%if ^%symglobl(CRFbuild) %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Global Macro variable CRF Build is not defined in global scope;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if %sysevalf(%superq(client)  =, boolean) or %sysevalf(%superq(root)  =, boolean)%sysevalf(%superq(Milestone)  =, boolean)  %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Parameters Client, Root and Milestone are required;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	options noxwait;

	data _null_;
		length path $300.;
		client="&client";
		root="&root";
		path=catx("\", client,root);
		call symputx("foldpath", path);
	run;

	/********************** Milestone folder structure ***********************/
	/*01_Specifications*/

	%if %sysfunc(fileexist(&foldpath.))=0 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified path &foldpath. does not exist;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	%if ^%sysevalf(%superq(sourceMilestone)  =, boolean) %then %do;
		%if %sysfunc(fileexist(&foldpath.\&sourceMilestone))=0 %then %do;
			%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified source milestone &sourceMilestone does not exist;
			%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
			%return;
		%end;
	%end;

	%if %sysfunc(fileexist(&foldpath.\&Milestone))=1 %then %do;
		%put ERROR:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Specified milestone &Milestone already exists in &foldpath.;
		%put ERROR:2/[AVANCE %sysfunc(datetime(), e8601dt.)] Macro &sysmacroname aborted;
		%return;
	%end;

	data _null_;
		%if %sysfunc(fileexist(&foldpath.\&Milestone))=0 %then %do;
			Docs=dcreate("&Milestone", "&foldpath.");
		%end;
	run;
	  
	data _null_;		
		Docs=dcreate("01_Specifications", "&foldpath.\&Milestone");
			Sdtm_spec=dcreate("01_SDTM", "&foldpath.\&Milestone\01_Specifications");
				Sdtm_spec_s=dcreate("Superseded", "&foldpath.\&Milestone\01_Specifications\01_SDTM");

			Adam_spec=dcreate("02_ADaM", "&foldpath.\&Milestone\01_Specifications");
				Adam_spec_s=dcreate("Superseded", "&foldpath.\&Milestone\01_Specifications\02_ADaM");

			tfl_spec=dcreate("03_TFL", "&foldpath.\&Milestone\01_Specifications");
				tfl_spec_s=dcreate("Superseded", "&foldpath.\&Milestone\01_Specifications\03_TFL");

			crf_acrf=dcreate("04_SDTM_aCRF", "&foldpath.\&Milestone\01_Specifications");
				crf_acrf_s=dcreate("Superseded", "&foldpath.\&Milestone\01_Specifications\04_SDTM_aCRF");
	run;

	/*02_SourceData*/
	data _null_;
		Raw=dcreate("02_SourceData", "&foldpath.\&Milestone");
			Raw_Superseded=dcreate("Superseded", "&foldpath.\&Milestone\02_SourceData");
	run;
	 
	/*03_Production*/
	data _null_;
		Production=dcreate("03_Production", "&foldpath.\&Milestone");
	/*---->SDTM*/
			sdtm=dcreate("01_SDTM", "&foldpath.\&Milestone\03_Production");
				xpt=dcreate("01_XPT", "&foldpath.\&Milestone\03_Production\01_SDTM");
					xpt_Superseded=dcreate("Superseded", "&foldpath.\&Milestone\03_Production\01_SDTM\01_XPT");

				cpt=dcreate("02_CPT", "&foldpath.\&Milestone\03_Production\01_SDTM");
					cpt_Superseded=dcreate("Superseded", "&foldpath.\&Milestone\03_Production\01_SDTM\02_CPT");

				excel=dcreate("03_Excel", "&foldpath.\&Milestone\03_Production\01_SDTM");
					excel_Superseded=dcreate("Superseded", "&foldpath.\&Milestone\03_Production\01_SDTM\03_Excel");

				excel_c=dcreate("04_Excel combined", "&foldpath.\&Milestone\03_Production\01_SDTM");
					excel_cs=dcreate("Superseded", "&foldpath.\&Milestone\03_Production\01_SDTM\04_Excel combined");
					
				csv=dcreate("05_CSV", "&foldpath.\&Milestone\03_Production\01_SDTM");
					csv_Superseded=dcreate("Superseded", "&foldpath.\&Milestone\03_Production\01_SDTM\05_CSV");

				p21=dcreate("06_P21", "&foldpath.\&Milestone\03_Production\01_SDTM");
					p21_Superseded=dcreate("Superseded", "&foldpath.\&Milestone\03_Production\01_SDTM\06_P21");

				sdtm_Superseded=dcreate("Superseded", "&foldpath.\&Milestone\03_Production\01_SDTM");
	/*---->ADAM*/
			adam=dcreate("02_ADaM", "&foldpath.\&Milestone\03_Production");
				xpta=dcreate("01_XPT", "&foldpath.\&Milestone\03_Production\02_ADaM");
					xpt_Supersededa=dcreate("Superseded", "&foldpath.\&Milestone\03_Production\02_ADaM\01_XPT");

				cpta=dcreate("02_CPT", "&foldpath.\&Milestone\03_Production\02_ADaM");
					cpt_Supersededa=dcreate("Superseded", "&foldpath.\&Milestone\03_Production\02_ADaM\02_CPT");

				excela=dcreate("03_Excel", "&foldpath.\&Milestone\03_Production\02_ADaM");
					excel_Supersededa=dcreate("Superseded", "&foldpath.\&Milestone\03_Production\02_ADaM\03_Excel");

				excel_ca=dcreate("04_Excel combined", "&foldpath.\&Milestone\03_Production\02_ADaM");
					excel_csa=dcreate("Superseded", "&foldpath.\&Milestone\03_Production\02_ADaM\04_Excel combined");
					
				csva=dcreate("05_CSV", "&foldpath.\&Milestone\03_Production\02_ADaM");
					csv_Supersededa=dcreate("Superseded", "&foldpath.\&Milestone\03_Production\02_ADaM\05_CSV");

				p21a=dcreate("06_P21", "&foldpath.\&Milestone\03_Production\02_ADaM");
					p21_Supersededa=dcreate("Superseded", "&foldpath.\&Milestone\03_Production\02_ADaM\06_P21");

				adam_Superseded=dcreate("Superseded", "&foldpath.\&Milestone\03_Production\02_ADaM");
	/*---->TFL*/
		tfl=dcreate("03_TFL", "&foldpath.\&Milestone\03_Production");
			xptat=dcreate("01_XPT", "&foldpath.\&Milestone\03_Production\03_TFL");
				xpt_Supersededat=dcreate("Superseded", "&foldpath.\&Milestone\03_Production\03_TFL\01_XPT");

			cptat=dcreate("02_CPT", "&foldpath.\&Milestone\03_Production\03_TFL");
				cpt_Supersededat=dcreate("Superseded", "&foldpath.\&Milestone\03_Production\03_TFL\02_CPT");

			excelat=dcreate("03_Excel", "&foldpath.\&Milestone\03_Production\03_TFL");
				excel_Supersededat=dcreate("Superseded", "&foldpath.\&Milestone\03_Production\03_TFL\03_Excel");

			excel_cat=dcreate("04_Excel combined", "&foldpath.\&Milestone\03_Production\03_TFL");
				excel_csat=dcreate("Superseded", "&foldpath.\&Milestone\03_Production\03_TFL\04_Excel combined");
				
			csvat=dcreate("05_CSV", "&foldpath.\&Milestone\03_Production\03_TFL");
				csv_Supersededat=dcreate("Superseded", "&foldpath.\&Milestone\03_Production\03_TFL\05_CSV");

			p21at=dcreate("06_P21", "&foldpath.\&Milestone\03_Production\03_TFL");
				p21_Supersededat=dcreate("Superseded", "&foldpath.\&Milestone\03_Production\03_TFL\06_P21");

			tfl_Supersededt=dcreate("Superseded", "&foldpath.\&Milestone\03_Production\03_TFL");
	run;

	/*	04_Validation*/
	data _null_;
		Validation=dcreate("04_Validation", "&foldpath.\&Milestone");
	/*---->SDTM*/
			sdtm=dcreate("01_SDTM", "&foldpath.\&Milestone\04_Validation");
				xpt=dcreate("01_XPT", "&foldpath.\&Milestone\04_Validation\01_SDTM");
					xpt_Superseded=dcreate("Superseded", "&foldpath.\&Milestone\04_Validation\01_SDTM\01_XPT");

				cpt=dcreate("02_CPT", "&foldpath.\&Milestone\04_Validation\01_SDTM");
					cpt_Superseded=dcreate("Superseded", "&foldpath.\&Milestone\04_Validation\01_SDTM\02_CPT");

				excel=dcreate("03_Excel", "&foldpath.\&Milestone\04_Validation\01_SDTM");
					excel_Superseded=dcreate("Superseded", "&foldpath.\&Milestone\04_Validation\01_SDTM\03_Excel");

				excel_c=dcreate("04_Excel combined", "&foldpath.\&Milestone\04_Validation\01_SDTM");
					excel_cs=dcreate("Superseded", "&foldpath.\&Milestone\04_Validation\01_SDTM\04_Excel combined");
					
				csv=dcreate("05_CSV", "&foldpath.\&Milestone\04_Validation\01_SDTM");
					csv_Superseded=dcreate("Superseded", "&foldpath.\&Milestone\04_Validation\01_SDTM\05_CSV");

				p21=dcreate("06_P21", "&foldpath.\&Milestone\04_Validation\01_SDTM");
					p21_Superseded=dcreate("Superseded", "&foldpath.\&Milestone\04_Validation\01_SDTM\06_P21");

				sdtm_Superseded=dcreate("Superseded", "&foldpath.\&Milestone\04_Validation\01_SDTM");
	/*---->ADAM*/
			adam=dcreate("02_ADaM", "&foldpath.\&Milestone\04_Validation");
				xpta=dcreate("01_XPT", "&foldpath.\&Milestone\04_Validation\02_ADaM");
					xpt_Supersededa=dcreate("Superseded", "&foldpath.\&Milestone\04_Validation\02_ADaM\01_XPT");

				cpta=dcreate("02_CPT", "&foldpath.\&Milestone\04_Validation\02_ADaM");
					cpt_Supersededa=dcreate("Superseded", "&foldpath.\&Milestone\04_Validation\02_ADaM\02_CPT");

				excela=dcreate("03_Excel", "&foldpath.\&Milestone\04_Validation\02_ADaM");
					excel_Supersededa=dcreate("Superseded", "&foldpath.\&Milestone\04_Validation\02_ADaM\03_Excel");

				excel_ca=dcreate("04_Excel combined", "&foldpath.\&Milestone\04_Validation\02_ADaM");
					excel_csa=dcreate("Superseded", "&foldpath.\&Milestone\04_Validation\02_ADaM\04_Excel combined");
					
				csva=dcreate("05_CSV", "&foldpath.\&Milestone\04_Validation\02_ADaM");
					csv_Supersededa=dcreate("Superseded", "&foldpath.\&Milestone\04_Validation\02_ADaM\05_CSV");

				p21a=dcreate("06_P21", "&foldpath.\&Milestone\04_Validation\02_ADaM");
					p21_Supersededa=dcreate("Superseded", "&foldpath.\&Milestone\04_Validation\02_ADaM\06_P21");

				adam_Superseded=dcreate("Superseded", "&foldpath.\&Milestone\04_Validation\02_ADaM");
	/*---->TFL*/
		tfl=dcreate("03_TFL", "&foldpath.\&Milestone\04_Validation");
			xptat=dcreate("01_XPT", "&foldpath.\&Milestone\04_Validation\03_TFL");
				xpt_Supersededat=dcreate("Superseded", "&foldpath.\&Milestone\04_Validation\03_TFL\01_XPT");

			cptat=dcreate("02_CPT", "&foldpath.\&Milestone\04_Validation\03_TFL");
				cpt_Supersededat=dcreate("Superseded", "&foldpath.\&Milestone\04_Validation\03_TFL\02_CPT");

			excelat=dcreate("03_Excel", "&foldpath.\&Milestone\04_Validation\03_TFL");
				excel_Supersededat=dcreate("Superseded", "&foldpath.\&Milestone\04_Validation\03_TFL\03_Excel");

			excel_cat=dcreate("04_Excel combined", "&foldpath.\&Milestone\04_Validation\03_TFL");
				excel_csat=dcreate("Superseded", "&foldpath.\&Milestone\04_Validation\03_TFL\04_Excel combined");
				
			csvat=dcreate("05_CSV", "&foldpath.\&Milestone\04_Validation\03_TFL");
				csv_Supersededat=dcreate("Superseded", "&foldpath.\&Milestone\04_Validation\03_TFL\05_CSV");

			p21at=dcreate("06_P21", "&foldpath.\&Milestone\04_Validation\03_TFL");
				p21_Supersededat=dcreate("Superseded", "&foldpath.\&Milestone\04_Validation\03_TFL\06_P21");

			tfl_Supersededt=dcreate("Superseded", "&foldpath.\&Milestone\04_Validation\03_TFL");
	run;

	/*05_OutputDocs*/
	data _null_;
		outputdocs=dcreate("05_OutputDocs", "&foldpath.\&Milestone");
	/*01_RTF*/
			rtf=dcreate("01_RTF", "&foldpath.\&Milestone\05_OutputDocs");
				rtf_Superseded=dcreate("Superseded", "&foldpath.\&Milestone\05_OutputDocs\01_RTF");
	/*02_Compares*/
			comp=dcreate("02_Compares", "&foldpath.\&Milestone\05_OutputDocs");
				comp_Superseded=dcreate("Superseded", "&foldpath.\&Milestone\05_OutputDocs\02_Compares");
	/*03_CDISC*/
			cdisc=dcreate("03_CDISC", "&foldpath.\&Milestone\05_OutputDocs");
				cdisc_Superseded=dcreate("Superseded", "&foldpath.\&Milestone\05_OutputDocs\03_CDISC");

				SDTM_Define=dcreate("01_SDTM_Define", "&foldpath.\&Milestone\05_OutputDocs\03_CDISC");
					SDTM_Define_s=dcreate("Superseded", "&foldpath.\&Milestone\05_OutputDocs\03_CDISC\01_SDTM_Define");

				SDTM_RG=dcreate("02_SDTM_RG", "&foldpath.\&Milestone\05_OutputDocs\03_CDISC");
					SDTM_RG_s=dcreate("Superseded", "&foldpath.\&Milestone\05_OutputDocs\03_CDISC\02_SDTM_RG");

				ADaM_Define=dcreate("03_ADaM_Define", "&foldpath.\&Milestone\05_OutputDocs\03_CDISC");
					ADaM_Define_s=dcreate("Superseded", "&foldpath.\&Milestone\05_OutputDocs\03_CDISC\03_ADaM_Define");

				ADaM_RG=dcreate("04_ADaM_RG", "&foldpath.\&Milestone\05_OutputDocs\03_CDISC");
					ADaM_RG_s=dcreate("Superseded", "&foldpath.\&Milestone\05_OutputDocs\03_CDISC\04_ADaM_RG");

	/*	04_Reports*/
			Reports=dcreate("04_Reports", "&foldpath.\&Milestone\05_OutputDocs");
				Reports_Superseded=dcreate("Superseded", "&foldpath.\&Milestone\05_OutputDocs\04_Reports");

	/*	05_Specifications*/
			Specifications=dcreate("05_Specifications", "&foldpath.\&Milestone\05_OutputDocs");
				Specifications_S=dcreate("Superseded", "&foldpath.\&Milestone\05_OutputDocs\05_Specifications");

	/* IE 2024-10-22 Added for XLSX reporting of tfl outputs */
	/*	06_XLSX*/
			xlsx=dcreate("06_XLSX", "&foldpath.\&Milestone\05_OutputDocs");
				xlsx_S=dcreate("Superseded", "&foldpath.\&Milestone\05_OutputDocs\06_XLSX");

	/* IE 2025-01-13 Added for PDF reporting of tfl outputs */
	/*	07_PDF*/
			xlsx=dcreate("07_PDF", "&foldpath.\&Milestone\05_OutputDocs");
				xlsx_S=dcreate("Superseded", "&foldpath.\&Milestone\05_OutputDocs\07_PDF");
	run;

	/*06_Define */
	data _null_;
		Framework=dcreate("06_Define", "&foldpath.\&Milestone");
			Framework_s=dcreate("Superseded", "&foldpath.\&Milestone\06_Define");

			Framework_sdtm=dcreate("SDTM", "&foldpath.\&Milestone\06_Define");
				Framework_sdtm_e=dcreate("EXPORT", "&foldpath.\&Milestone\06_Define\SDTM");
				Framework_sdtm_m=dcreate("META", "&foldpath.\&Milestone\06_Define\SDTM");
				Framework_sdtm_o=dcreate("OUTPUT", "&foldpath.\&Milestone\06_Define\SDTM");
				Framework_sdtm_q=dcreate("QC", "&foldpath.\&Milestone\06_Define\SDTM");

			Framework_adam=dcreate("ADAM", "&foldpath.\&Milestone\06_Define");
				Framework_adam_e=dcreate("EXPORT", "&foldpath.\&Milestone\06_Define\ADAM");
				Framework_adam_m=dcreate("META", "&foldpath.\&Milestone\06_Define\ADAM");
				Framework_adam_o=dcreate("OUTPUT", "&foldpath.\&Milestone\06_Define\ADAM");
				Framework_adam_q=dcreate("QC", "&foldpath.\&Milestone\06_Define\ADAM");
	run;

	/*07_Feedback*/
	data _null_;
		Feedback=dcreate("07_Feedback", "&foldpath.\&Milestone");
			Feedback_s=dcreate("01_Sponsor", "&foldpath.\&Milestone\07_Feedback");
				Feedback_ss=dcreate("Superseded", "&foldpath.\&Milestone\07_Feedback\01_Sponsor");
				
			Feedback_1=dcreate("02_Internal", "&foldpath.\&Milestone\07_Feedback");
				Feedback_1s=dcreate("Superseded", "&foldpath.\&Milestone\07_Feedback\02_Internal");
	run;

	/********************************** Program folder stucture *********************************/

	/*08_Final Programs*/
	data _null_;
		Feedback=dcreate("08_Final Programs", "&foldpath.\&Milestone");
	run;

	data _null_;	
	/*Macros*/
		Macro=dcreate("01_Macros", "&foldpath.\&Milestone\08_Final Programs");
			Macro_s=dcreate("Superseded", "&foldpath.\&Milestone\08_Final Programs\01_Macros");
	/*CDISC*/
	/*1. Production*/
			cdisc=dcreate("02_CDISC", "&foldpath.\&Milestone\08_Final Programs");
			Production=dcreate("Production", "&foldpath.\&Milestone\08_Final Programs\02_CDISC");
				Production_sdtm=dcreate("01_SDTM", "&foldpath.\&Milestone\08_Final Programs\02_CDISC\Production");
					Production_sdtm_s=dcreate("Superseded", "&foldpath.\&Milestone\08_Final Programs\02_CDISC\Production\01_SDTM");
					plogs=dcreate("Logs", "&foldpath.\&Milestone\08_Final Programs\02_CDISC\Production\01_SDTM");
						plogss=dcreate("Superseded", "&foldpath.\&Milestone\08_Final Programs\02_CDISC\Production\01_SDTM\Logs");

				Production_Adam=dcreate("02_ADaM", "&foldpath.\&Milestone\08_Final Programs\02_CDISC\Production");
					Production_adan_s=dcreate("Superseded", "&foldpath.\&Milestone\08_Final Programs\02_CDISC\Production\02_ADaM");
					aplogs=dcreate("Logs", "&foldpath.\&Milestone\08_Final Programs\02_CDISC\Production\02_ADaM");
						aplogss=dcreate("Superseded", "&foldpath.\&Milestone\08_Final Programs\02_CDISC\Production\02_ADaM\Logs");

	/*2. Validation*/
			Validation=dcreate("Validation", "&foldpath.\&Milestone\08_Final Programs\02_CDISC");
				Validation_sdtm=dcreate("01_SDTM", "&foldpath.\&Milestone\08_Final Programs\02_CDISC\Validation");
					Validation_sdtm_s=dcreate("Superseded", "&foldpath.\&Milestone\08_Final Programs\02_CDISC\Validation\01_SDTM");
					logs=dcreate("Logs", "&foldpath.\&Milestone\08_Final Programs\02_CDISC\Validation\01_SDTM");
						logss=dcreate("Superseded", "&foldpath.\&Milestone\08_Final Programs\02_CDISC\Validation\01_SDTM\Logs");

				Validation_Adam=dcreate("02_ADaM", "&foldpath.\&Milestone\08_Final Programs\02_CDISC\Validation");
					Validation_adan_s=dcreate("Superseded", "&foldpath.\&Milestone\08_Final Programs\02_CDISC\Validation\02_ADaM");
					alogs=dcreate("Logs", "&foldpath.\&Milestone\08_Final Programs\02_CDISC\Validation\02_ADaM");
						alogss=dcreate("Superseded", "&foldpath.\&Milestone\08_Final Programs\02_CDISC\Validation\02_ADaM\Logs");

	run;

	/*03_TFL*/
	data _null_;
			cdisc=dcreate("03_TFL", "&foldpath.\&Milestone\08_Final Programs");
				production = dcreate("Production", "&foldpath.\&Milestone\08_Final Programs\03_TFL");
					/*1. Figures*/
					P_Fig 		=	dcreate("Figures", 		"&foldpath.\&Milestone\08_Final Programs\03_TFL\Production");
					P_Fig_s 	=	dcreate("Superseded",  	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Production\Figures");
					P_Fig_l 	=	dcreate("Logs", 		"&foldpath.\&Milestone\08_Final Programs\03_TFL\Production\Figures");
					P_Fig_ls 	=	dcreate("Superseded", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Production\Figures\Logs");

					/*2. Listings*/
					P_List 		=	dcreate("Listings", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Production");
					P_List_s 	=	dcreate("Superseded", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Production\Listings");
					P_List_l 	=	dcreate("Logs", 		"&foldpath.\&Milestone\08_Final Programs\03_TFL\Production\Listings");
					P_List_ls 	=	dcreate("Superseded", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Production\Listings\Logs");


					/*3. PK Programs*/
					P_PK 		=	dcreate("PK Programs", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Production");
					P_PK_s 		=	dcreate("Superseded", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Production\PK Programs");
					P_PK_l 		=	dcreate("Logs", 		"&foldpath.\&Milestone\08_Final Programs\03_TFL\Production\PK Programs");
					P_PK_ls 	= 	dcreate("Superseded", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Production\PK Programs\Logs");


					/*4. Tables*/
					P_Tab 		=	dcreate("Tables", 		"&foldpath.\&Milestone\08_Final Programs\03_TFL\Production");
					P_Tab_s 	=	dcreate("Superseded", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Production\Tables");
					P_Tab_l 	=	dcreate("Logs", 		"&foldpath.\&Milestone\08_Final Programs\03_TFL\Production\Tables");
					P_Tab_ls 	=	dcreate("Superseded", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Production\Tables\Logs");

				validation = dcreate("Validation", "&foldpath.\&Milestone\08_Final Programs\03_TFL");
					/*1. Figures*/
					P_Fig 		=	dcreate("Figures", 		"&foldpath.\&Milestone\08_Final Programs\03_TFL\Validation");
					P_Fig_s 	=	dcreate("Superseded",  	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Validation\Figures");
					P_Fig_l 	=	dcreate("Logs", 		"&foldpath.\&Milestone\08_Final Programs\03_TFL\Validation\Figures");
					P_Fig_ls 	=	dcreate("Superseded", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Validation\Figures\Logs");

					/*2. Listings*/
					P_List 		=	dcreate("Listings", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Validation");
					P_List_s 	=	dcreate("Superseded", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Validation\Listings");
					P_List_l 	=	dcreate("Logs", 		"&foldpath.\&Milestone\08_Final Programs\03_TFL\Validation\Listings");
					P_List_ls 	=	dcreate("Superseded", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Validation\Listings\Logs");


					/*3. PK Programs*/
					P_PK 		=	dcreate("PK Programs", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Validation");
					P_PK_s 		=	dcreate("Superseded", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Validation\PK Programs");
					P_PK_l 		=	dcreate("Logs", 		"&foldpath.\&Milestone\08_Final Programs\03_TFL\Validation\PK Programs");
					P_PK_ls 	= 	dcreate("Superseded", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Validation\PK Programs\Logs");


					/*4. Tables*/
					P_Tab 		=	dcreate("Tables", 		"&foldpath.\&Milestone\08_Final Programs\03_TFL\Validation");
					P_Tab_s 	=	dcreate("Superseded", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Validation\Tables");
					P_Tab_l 	=	dcreate("Logs", 		"&foldpath.\&Milestone\08_Final Programs\03_TFL\Validation\Tables");
					P_Tab_ls 	=	dcreate("Superseded", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Validation\Tables\Logs");

				st_validation = dcreate("Stats Validation", "&foldpath.\&Milestone\08_Final Programs\03_TFL");
					/*1. Figures*/
					st_Fig 		=	dcreate("Figures", 		"&foldpath.\&Milestone\08_Final Programs\03_TFL\Stats Validation");
					st_Fig_s 	=	dcreate("Superseded",  	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Stats Validation\Figures");
					st_Fig_l 	=	dcreate("Logs", 		"&foldpath.\&Milestone\08_Final Programs\03_TFL\Stats Validation\Figures");
					st_Fig_ls 	=	dcreate("Superseded", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Stats Validation\Figures\Logs");

					/*2. Listings*/
					st_List 	=	dcreate("Listings", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Stats Validation");
					st_List_s 	=	dcreate("Superseded", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Stats Validation\Listings");
					st_List_l 	=	dcreate("Logs", 		"&foldpath.\&Milestone\08_Final Programs\03_TFL\Stats Validation\Listings");
					st_List_ls 	=	dcreate("Superseded", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Stats Validation\Listings\Logs");

					/*4. Tables*/
					st_Tab 		=	dcreate("Tables", 		"&foldpath.\&Milestone\08_Final Programs\03_TFL\Stats Validation");
					st_Tab_s 	=	dcreate("Superseded", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Stats Validation\Tables");
					st_Tab_l 	=	dcreate("Logs", 		"&foldpath.\&Milestone\08_Final Programs\03_TFL\Stats Validation\Tables");
					st_Tab_ls 	=	dcreate("Superseded", 	"&foldpath.\&Milestone\08_Final Programs\03_TFL\Stats Validation\Tables\Logs");
	run;

	/********************************* Output folder stucture ********************************/
	data _null_;
	/*1. Figures*/
			Figures=dcreate("Figures", "&foldpath.\10 Final Output");
			Figures_s=dcreate("Superseded", "&foldpath.\10 Final Output\Figures");

	/*2. Listings*/
			Listings=dcreate("Listings", "&foldpath.\10 Final Output");
			Listings_s=dcreate("Superseded", "&foldpath.\10 Final Output\Listings");

	/*3. PK Programs*/
			PKPrograms=dcreate("PK Output", "&foldpath.\10 Final Output");
			PKPrograms_s=dcreate("Superseded", "&foldpath.\10 Final Output\PK Output");

	/*4. Tables*/
			Tables=dcreate("Tables", "&foldpath.\10 Final Output");
			Tables_s=dcreate("Superseded", "&foldpath.\10 Final Output\Tables");

	/*5. TFL*/
			TFL=dcreate("TFL", "&foldpath.\10 Final Output");
			TFL_s=dcreate("Superseded", "&foldpath.\10 Final Output\TFL");
	run;

	%if %sysevalf(%superq(sourceMilestone)  =, boolean) %then %do;
		%if %sysfunc(fileexist(&foldpath.\&Milestone\08_Final Programs\01_Macros\setup.sas))=0 %then %do;
			%sysexec copy "T:\Standard Programs\Prod\v&version\&CRFbuild\08_Final Programs\01_Macros\avSetup.sas" "&foldpath.\&Milestone\08_Final Programs\01_Macros";

			%if %sysfunc(fileexist(&foldpath.\&Milestone\08_Final Programs\01_Macros\avSetup.sas))=1 %then %do;
				%let av_studyno 	= %scan(&Root, 1, \);

				%sysexec powershell -Command "$fileContents = gc %str(%')&foldpath.\&Milestone\08_Final Programs\01_Macros\avSetup.sas%str(%');
											  $fileContents = $fileContents -creplace '<Client>',%str(%')&client.%str(%');
											  $fileContents = $fileContents -creplace '<Root>',%str(%')&root.%str(%');
											  $fileContents = $fileContents -creplace '<Milestone>',%str(%')&milestone.%str(%');
											  $fileContents = $fileContents -creplace '<Studyno>',%str(%')&av_studyno.%str(%');
											  echo $fileContents | Out-File -encoding ASCII %str(%')&foldpath.\&Milestone\08_Final Programs\01_Macros\avSetup.sas%str(%');";
			%end;

			%sysexec copy "T:\Standard Programs\Prod\v&version\&CRFbuild\08_Final Programs\01_Macros\avMacroCall.sas" "&foldpath.\&Milestone\08_Final Programs\01_Macros";
			%sysexec copy "T:\Standard Programs\Prod\v&version\&CRFbuild\08_Final Programs\01_Macros\avSetupTitlesAndFootnotes.sas" "&foldpath.\&Milestone\08_Final Programs\01_Macros";

			%sysexec copy "T:\Standard Programs\Prod\v&version\&CRFbuild\01_Specifications\03_TFL\avTitleFooter.xlsx" "&foldpath.\&Milestone\01_Specifications\03_TFL";


			%sysexec copy "T:\Standard Programs\Prod\v&version\&CRFbuild\08_Final Programs\01_Macros\avAnnMacroCall.sas" "&foldpath.\&Milestone\08_Final Programs\01_Macros";
			%sysexec copy "T:\Standard Programs\Prod\v&version\&CRFbuild\01_Specifications\04_SDTM_aCRF\*.*" "&foldpath.\&Milestone\01_Specifications\04_SDTM_aCRF";

			%sysexec copy "T:\Standard Programs\Prod\v&version\&CRFbuild\07_Feedback\02_Internal\*.xlsx" "&foldpath.\&Milestone\07_Feedback\02_Internal";

			/* EW 2024-10-11: strip copy define programs out into %avCopyDefineFromStdLib */
			/*
			%sysexec copy "T:\Standard Programs\Prod\v&version\&CRFbuild\06_Define\SDTM" "&foldpath.\&Milestone\06_Define\SDTM";
			%sysexec powershell -Command "$fileContents = gc %str(%')T:\Standard Programs\Prod\v&version\&CRFbuild\06_Define\SDTM\avDefineSDTM.sas%str(%');
										  $fileContents = $fileContents -creplace '<Milestone>',%str(%')&foldpath.\&Milestone%str(%');
										  echo $fileContents | Out-File -encoding ASCII %str(%')&foldpath.\&Milestone\06_Define\SDTM\avDefineSDTM.sas%str(%');";
			%sysexec copy "T:\Standard Programs\Prod\v&version\&CRFbuild\06_Define\ADAM" "&foldpath.\&Milestone\06_Define\ADAM";
			%sysexec powershell -Command "$fileContents = gc %str(%')T:\Standard Programs\Prod\v&version\&CRFbuild\06_Define\ADAM\avDefineADaM.sas%str(%');
										  $fileContents = $fileContents -creplace '<Milestone>',%str(%')&foldpath.\&Milestone%str(%');
										  echo $fileContents | Out-File -encoding ASCII %str(%')&foldpath.\&Milestone\06_Define\ADAM\avDefineADaM.sas%str(%');";
			*/
		%end;

		%if %sysfunc(fileexist(&foldpath.\&Milestone\08_Final Programs\01_Macros\avSetup.sas)) = 0 %then %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] avSetup.sas not copied successfully;
		%end;

		%if %sysfunc(fileexist(&foldpath.\&Milestone\08_Final Programs\01_Macros\avMacroCall.sas)) = 0 %then %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] avMacroCall.sas not copied successfully;
		%end;

		%if %sysfunc(fileexist(&foldpath.\&Milestone\08_Final Programs\01_Macros\avAnnMacroCall.sas)) = 0 %then %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] avAnnMacroCall.sas not copied successfully;
		%end;

		%if %sysfunc(fileexist(&foldpath.\&Milestone\08_Final Programs\01_Macros\avSetupTitlesAndFootnotes.sas)) = 0 %then %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] avSetupTitlesAndFootnotes.sas not copied successfully;
		%end;

		%if %sysfunc(fileexist(&foldpath.\&Milestone\01_Specifications\03_TFL\avTitleFooter.xlsx)) = 0 %then %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] avTitleFooter.xlsx not copied successfully;
		%end;

		/* EW 2024-10-11: strip copy define programs out into %avCopyDefineFromStdLib */
		/*
		%if %sysfunc(fileexist(&foldpath.\&Milestone\06_Define\SDTM\avDefineSDTM.sas)) = 0 %then %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Define\SDTM folder not copied successfully;
		%end;

		%if %sysfunc(fileexist(&foldpath.\&Milestone\06_Define\ADAM\avDefineADaM.sas)) = 0 %then %do;
			%put WARNING:1/[AVANCE %sysfunc(datetime(), e8601dt.)] Define\ADAM folder not copied successfully;
		%end;
		*/
	%end;
	%else %do;
		/* Copy Source Specifications */
		%if %sysfunc(fileexist(&foldpath.\&Milestone\01_Specifications))=1 %then %do;
			%sysexec copy "&foldpath.\&sourceMilestone\01_Specifications\01_SDTM\*.*" "&foldpath.\&Milestone\01_Specifications\01_SDTM";
			%sysexec copy "&foldpath.\&sourceMilestone\01_Specifications\02_ADaM\*.*" "&foldpath.\&Milestone\01_Specifications\02_ADaM";
			%sysexec copy "&foldpath.\&sourceMilestone\01_Specifications\03_TFL\*.*" "&foldpath.\&Milestone\01_Specifications\03_TFL";
			%sysexec copy "&foldpath.\&sourceMilestone\01_Specifications\04_SDTM_aCRF\*.*" "&foldpath.\&Milestone\01_Specifications\04_SDTM_aCRF";
		%end;

		/* Copy Source Data */
		%if %sysfunc(fileexist(&foldpath.\&Milestone\02_SourceData))=1 %then %do;
			%sysexec copy "&foldpath.\&sourceMilestone\02_SourceData\*.*" "&foldpath.\&Milestone\02_SourceData";
		%end;

		/* Copy Source Programs */
		%if %sysfunc(fileexist(&foldpath.\&Milestone\08_Final Programs))=1 %then %do;
			%sysexec copy "&foldpath.\&sourceMilestone\08_Final Programs\01_Macros\*.*" "&foldpath.\&Milestone\08_Final Programs\01_Macros";

			%if %sysfunc(fileexist(&foldpath.\&Milestone\08_Final Programs\01_Macros\avSetup.sas))=1 %then %do;
				%let av_studyno 	= %scan(&Root, 1, \);

				%sysexec powershell -Command "$fileContents = gc %str(%')&foldpath.\&Milestone\08_Final Programs\01_Macros\avSetup.sas%str(%');
											  $fileContents = $fileContents -creplace %str(%')= &sourceMilestone.;%str(%'), %str(%')= &Milestone.;%str(%');
											  echo $fileContents | Out-File -encoding ASCII %str(%')&foldpath.\&Milestone\08_Final Programs\01_Macros\avSetup.sas%str(%');";
			%end;

			%sysexec copy "&foldpath.\&sourceMilestone\08_Final Programs\02_CDISC\Production\01_SDTM\*.*" "&foldpath.\&Milestone\08_Final Programs\02_CDISC\Production\01_SDTM";
			%sysexec copy "&foldpath.\&sourceMilestone\08_Final Programs\02_CDISC\Production\02_ADaM\*.*" "&foldpath.\&Milestone\08_Final Programs\02_CDISC\Production\02_ADaM";

			%sysexec copy "&foldpath.\&sourceMilestone\08_Final Programs\02_CDISC\Validation\01_SDTM\*.*" "&foldpath.\&Milestone\08_Final Programs\02_CDISC\Validation\01_SDTM";
			%sysexec copy "&foldpath.\&sourceMilestone\08_Final Programs\02_CDISC\Validation\02_ADaM\*.*" "&foldpath.\&Milestone\08_Final Programs\02_CDISC\Validation\02_ADaM";

			%sysexec copy "&foldpath.\&sourceMilestone\08_Final Programs\03_TFL\Production\Listings\*.*" "&foldpath.\&Milestone\08_Final Programs\03_TFL\Production\Listings";
			%sysexec copy "&foldpath.\&sourceMilestone\08_Final Programs\03_TFL\Production\Tables\*.*" "&foldpath.\&Milestone\08_Final Programs\03_TFL\Production\Tables";
			%sysexec copy "&foldpath.\&sourceMilestone\08_Final Programs\03_TFL\Production\Figures\*.*" "&foldpath.\&Milestone\08_Final Programs\03_TFL\Production\Figures";

			%sysexec copy "&foldpath.\&sourceMilestone\08_Final Programs\03_TFL\Validation\Listings\*.*" "&foldpath.\&Milestone\08_Final Programs\03_TFL\Validation\Listings";
			%sysexec copy "&foldpath.\&sourceMilestone\08_Final Programs\03_TFL\Validation\Tables\*.*" "&foldpath.\&Milestone\08_Final Programs\03_TFL\Validation\Tables";
			%sysexec copy "&foldpath.\&sourceMilestone\08_Final Programs\03_TFL\Validation\Figures\*.*" "&foldpath.\&Milestone\08_Final Programs\03_TFL\Validation\Figures";
		%end;

		/* Copy Source Define Programs */
		%if %sysfunc(fileexist(&foldpath.\&Milestone\06_Define))=1 %then %do;
			%sysexec xcopy "&foldpath.\&sourceMilestone\06_Define\*.*" "&foldpath.\&Milestone.\06_Define" /s;

			%if %sysfunc(fileexist(&foldpath.\&Milestone\06_Define\SDTM\avDefineSDTM.sas))=1 %then %do;
				%sysexec powershell -Command "$fileContents = gc %str(%')&foldpath.\&Milestone.\06_Define\SDTM\avDefineSDTM.sas%str(%');
											  $fileContents = $fileContents -creplace %str(%')&sourceMilestone.%str(%'), %str(%')&Milestone.%str(%');
											  echo $fileContents | Out-File -encoding ASCII %str(%')&foldpath.\&Milestone\06_Define\SDTM\avDefineSDTM.sas%str(%');";
			%end;

			%if %sysfunc(fileexist(&foldpath.\&Milestone\06_Define\ADAM\avDefineADaM.sas))=1 %then %do;
				%sysexec powershell -Command "$fileContents = gc %str(%')&foldpath.\&Milestone.\06_Define\ADAM\avDefineADaM.sas%str(%');
											  $fileContents = $fileContents -creplace %str(%')&sourceMilestone.%str(%'), %str(%')&Milestone.%str(%');
											  echo $fileContents | Out-File -encoding ASCII %str(%')&foldpath.\&Milestone\06_Define\ADAM\avDefineADaM.sas%str(%');";
			%end;
		%end;
	%end;

%mend avCreateFolderStructure;

/*
%avCreateFolderStructure(client=Z:\<sponsor>,
					   	 root=<studyid>\11 Stats\03 Analysis,
					   	 Milestone=<Milestone>);
*/
