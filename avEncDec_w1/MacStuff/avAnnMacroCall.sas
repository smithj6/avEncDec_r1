/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avAnnMacroCall.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Program used to call avAnnCreateXFDFfromXLSX, avAnnCreateXLSfromXFDF and avAnnCreateTableOfContents as part of the annotation process
				   avSetup.sas needs to be updated and run before using this program
 				   IMPORTANT: Border styles assigned through adobe does not export correctly to XFDF. 
							  Only Solid and Striped borders assigned through avAnnCreateXFDFfromXLSX using the XLSX file will be retained througout the process
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/


/*============================== avAnnCreateXFDFfromXLSX ==============================
Description     : 	Macro used for creating XFDF file from XLSX file. Can be used with avAnnCreateXLSXfromXFDF for annotation of CRF
					XLSX file needs to be located in the 01_Specifications\04_SDTM_aCRF folder in the study timeline
					XLSX file has to conform to standard aCRF.xlsx copied template
					DOMAIN, NAME, ANNOTATION and PAGENO columns needs to be populated before converting to XFDF
					XFDF file will be created in the 01_Specifications\04_SDTM_aCRF folder in the study timeline
					avSetup.sas needs to be updated and run before running this macro					
=======================================================================================
%avAnnCreateXFDFfromXLSX(xlsxIn=aCRF.xlsx,
            			 lockComments=N, 
						 fontSize=10);
*/


/*============================== avAnnCreateXLSXfromXFDF ==============================
Description     : 	Macro used for creating XLSX file from XFDF file. Can be used with avAnnCreateXFDFfromXLSX for annotation of CRF
					XFDF file needs to be located in the 01_Specifications\04_SDTM_aCRF folder in the study timeline
					Standard map file XFDF2SAS.MAP file needs to be located in the 01_Specifications\04_SDTM_aCRF folder in the study timeline
					XLS file will be created in 01_Specifications\04_SDTM_aCRF folder
					XLS contents will need to be moved to XLSX file manually. The XLSX file will not be overwritten
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avAnnCreateXLSfromXFDF(xfdfIn=aCRF.xfdf);
*/



/*================================================================================================================================================================*/
/*======================================================================== Auto TOC Calls ========================================================================*/
/*================================================================================================================================================================*/


/*============================= avAnnCreateTableOfContents ============================
Description     : 	Macro used for creating bookmarks and table of contents for the aCRF
					Study specific Data Dictionary is required for identification of Forms and Visits
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avAnnCreateTableOfContents(pathInCRFDataDictionary=&mspath.\01_Specifications\04_SDTM_aCRF\<Data Dictionary>.xlsx,
							pathInPdfDocument=&mspath.\01_Specifications\04_SDTM_aCRF\aCRF.pdf,
							fileOut=&mspath.\01_Specifications\04_SDTM_aCRF\aCRF_Bookmarked.pdf);



/*================================================================================================================================================================*/
/*======================================================================= Manual TOC Calls =======================================================================*/
/*================================================================================================================================================================*/

/*============================== avAnnExtractPDFBookmarks =============================
Description     : 	Macro used for extracting bookmarks from CRF which contains bookmarks for each form
					CSV file created containing all unique forms and corresponding page number
					This is the first step for manually generating bookmarks and table of contents
					avSetup.sas needs to be updated and run before running this macro
					IMPORTANT: Macro assumes no differentiation between visits in CRF. All visits mapped to the same page
=======================================================================================
%avAnnExtractPDFBookmarks(pdfIn=&mspath.\01_Specifications\04_SDTM_aCRF\blank_crf.pdf,
					   	  repPath=&mspath.\01_Specifications\04_SDTM_aCRF);
*/


/*================================ avAnnExtractDDVisits ===============================
Description     : 	Macro used for extracting Forms, Visits and Dashboard sheet from Data Dictionary
					Merges results with Bookmarks.csv created using avAnnExtractPDFBookmarks
					XLSX file created containing all unique forms, corresponding page number and visits
					This is the second step for manually generating bookmarks and table of contents
					Optionally the visitCRF and visitnumCRF formats can be used to rename or sort visits if required.
					If formats are not found or a specific visit is not included the sorting from the Data Dictionary will be used
					IMPORTANT: The inclusion of other = [200.] in the format is required to avoid truncation of visits
					IMPORTANT: Macro assumes no differentiation between visits in CRF. All visits mapped to the same page
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
proc format;
	value $visitCRF
		"Common" 					= "Running Records"
		"Unscheduled Visit" 		= "Unscheduled"
		other						= [$200.]
		;
 
	invalue visitnumCRF
		"Unscheduled Visit" 		= 998
		"Common" 					= 999
		;
run;

%avAnnExtractDDVisits(pathInFormsCSV=&mspath.\01_Specifications\04_SDTM_aCRF\bookmarks.csv,
					  pathInCRFDataDictionary=&mspath.\01_Specifications\04_SDTM_aCRF\DataDictionary.xlsx,
					  formsSheet=Forms,
					  visitsSheet=Folders,
					  dashboardSheet=Matrix4#MASTERDASHBOARD,
					  repPath=&mspath.\01_Specifications\04_SDTM_aCRF);
*/


/*========================== avAnnCreateTableOfContentsManual =========================
Description     : 	Macro used for creating bookmarks and table of contents for the aCRF
					Forms and Visits are generated from input XLSX generated from avAnnExtractDDVisits
					This is the final step for manually generating bookmarks and table of contents
					IMPORTANT: Macro assumes no differentiation between visits in CRF. All visits mapped to the same page
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avAnnCreateTableOfContentsManual(pathInXLSX=&mspath.\01_Specifications\04_SDTM_aCRF\FormsVisitsCombined.xlsx,
								  pathInPdfDocument=&mspath.\01_Specifications\04_SDTM_aCRF\aCRF.pdf,
								  fileOut=&mspath.\01_Specifications\04_SDTM_aCRF\aCRF_bookmarked.pdf);
*/
