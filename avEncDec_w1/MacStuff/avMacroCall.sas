/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avMacroCall.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Provides examples for standard macros available in study folder. 
				   IMPORTANT: Uncommenting macro calls might inadvertantly cause macros to be run when avSetup.sas is referenced.
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

/*================================================================================================================================================================*/
/*=================================================================== Operational Macro Calls ====================================================================*/
/*================================================================================================================================================================*/

/*============================== avCreateFolderStructure ==============================
Description     : 	Macro used for creating folder structure for a new timeline and copying standard setup and macro programs.
					Optionally a source milestone can be specified to copy exisiting specifications, source data and programs.
					Variable CRFBuild and Version needs to be specified if avSetup.sas has not been run
				    Include statement for macro code needs to be run after specifying CRFBuild and Version and avSetup.sas has not been run
					CRFBuild is used to specify database build. Valid options are Medrio, Rave or Zelta 
				    Version is used to Specify stanndards version. Valid options are 1.0
					IMPORTANT: Study/timeline specific avSetup.sas is created by this macro, which is why variables and the include statement are specified. 
					IMPORTANT: Update study\timeline specific avSetup.sas after running this macro and use study\timeline specific avMacroCall.sas.
=======================================================================================
%let CRFBuild	= Medrio;
%let version	= 1.0;
%include "T:\Standard Programs\Prod\v&version\&CRFBuild\08_Final Programs\01_Macros\avCreateFolderStructure.sas";

%avCreateFolderStructure(client=T:\<sponsor>,
					   	 root=<studyid>\11 Stats\03 Analysis,
						 milestone=<milestone>,
						 sourceMilestone=<source milestone>);
*/



/*================================== avCopySourceData =================================
Description     : 	Copy source data from specified source path to specified destination path
					Generates summary report to specified report path
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avCopySourceData(sourcePath=<path>,
				  destPath=&mspath\02_SourceData,
				  repPath=&mspath\05_OutputDocs\04_Reports); 
*/



/*=================================== avImportExcel ===================================
Description     : 	Import specified excel (XLSX) file to specified location in SAS7BDAT format
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avImportExcel(sourceFile=<file path>\<file name>.xlsx,
		   	   destPath=&mspath\02_SourceData,
			   sheetName=<sheet name>, 
			   dataOut=<dataset name>);
*/



/*=============================== avCopyMacroFromStdLib ===============================
Description     : 	Copy standard macros to study timeline
					Multiple macros can be specified using the macroList parameter, seperated by a #. avAssignAnalysisBaseline#avAssignAnalysisDatesFromSDTM for example
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avCopyMacroFromStdLib(macroList=avAssignAnalysisBaseline#avAssignAnalysisDatesFromSDTM);
*/



/*=========================== avMedrioDataDictionaryCompare ===========================
Description     : 	Compares data dictionaries and creates a summary report
					Standard data dictionary can be compared to study specific data dictionary to identify deviations from standard CRF
					Client and Protocol needs to be specified before running this macro
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%let client		= GDSR;
%let protocol	= 00000;

%avMedrioDataDictionaryCompare(pathInStandardDataDictionary=T:\Standard Programs\Prod\v1.0\Medrio\01_Specifications\04_SDTM_aCRF\Data Dictionaries\Medrio Data Dictionary v4.xlsx
							  ,pathInCRFDataDictionary=&mspath\01_Specifications\04_SDTM_aCRF\<study specific data dictionary>
							  ,pathOut=&mspath\05_OutputDocs\04_Reports)
*/



/*=============================== avCopySDTMSpecsFromStdLib ===============================
Description     : 	Copy CRFBuild and DB Version specific standard SDTM specifications to study timeline
					All domains identified from the annotated excel located here (01_Specifications\04_SDTM_aCRF) will be included					
					Domains that already exist in the timeline will not be replaced
					Additional domains can be specified using the include parameter, seperated by a #. SE#TA#TE#TI for example
					Copying only the specified domains can be specified by using the onlyInclude parameter as Y. Default is N
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avCopySDTMSpecsFromStdLib(ig=3.4, include=SE#TA#TE#TI#TS#TV, onlyInclude=N);
*/



/*=============================== avCopyADaMSpecsFromStdLib ===============================
Description     : 	Copy standard ADaM specifications to study timeline
					All domains identified from SDTM specifications will be included
					Domains that already exist in the timeline will not be replaced
					Additional domains can be specified using the include parameter, seperated by a #. ADZA#ADQS for example
					Copying only the specified domains can be specified by using the onlyInclude parameter as Y. Default is N
					avSetup.sas needs to be updated and run before running this macro
					IMPORTANT: Any specifications generated automatically when no standard exists needs to be opened in Excel and saved before running
=======================================================================================
%avCopyADaMSpecsFromStdLib(ig=1.3, include=ADSL, onlyInclude=N);
*/



/*========================== avCopyTemplateProgramFromStdLib ==========================
Description     : 	Create SDTM or ADaM program in study timeline
					If standard code for the specific domain exists for the specified CRFBuild and DB Version, the standard code will be copied to the program.
					Multiple domains can be specified in the domain parameter by using #. DM#AE#EX for example
					Blank template can be created if no standard code is required by specifying copyBlankTemplate=Y
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avCopyTemplateProgramFromStdLib(standard=SDTM, domain=ta#te#ti#ts#tv#dm#se#ds#sv, copyBlankTemplate=N);
%avCopyTemplateProgramFromStdLib(standard=ADAM, domain=adsl, copyBlankTemplate=N);
*/



/*=============================== avSpecCRFCompare ===============================
Description     : 	Compares annotations from aCRF.xlsx or aCRF.pdf with all annotations in specifications
					type can be used to specify which source to use for the compare. Either XLSX or PDF is acceptable
					addPages can be used to specify additional pages when compared with aCRF.xlsx, if pages from aCRF.xlsx is not updated
					addPages is ignored when compared with aCRF.pdf
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avSpecCRFCompare(type=PDF, repPath=&mspath\05_OutputDocs\04_Reports, addPages=0);
*/



/*================================ avUpdateTFLSpecDataset ===============================
Description     : 	Create Title and footnote datasets from avTitleFooter.xlsx
					Previous versions of both Titles and Footnotes datasets will be superseded
					Macro will fail if avTitleFooter.xlsx is in use
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avUpdateTFLSpecDataset;
*/



/*================================ avCreateOutputProgram ==============================
Description     : 	Create Listing, Table or Figure program in study timeline
					Timeline specific code will be included added as applicable
					Multiple outputs can be specified in the output parameter by using #. l_16_1_1_1#t_14_1_1_1#f_14_1_1_2 for example
					Production or Validation is determined by the presence of _v in the output name
					All output from the title and footnonte specification sheet can be created by specifying sourceExcel=Y
					Production or Validation output programs can be created from the title and footnonte specification sheet by specifying sourceExcelSide=P or sourceExcelSide=V
					Please note output parameter will be ignored when title and footnonte specification sheet is used. sourceExcel=Y
					Please note sourceExcelSide is only applicable to the title and footnote specification sheet
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avCreateOutputProgram(output=t_14_1_1_1#t_14_1_1_2);
%avCreateOutputProgram(sourceExcel=Y, sourceExcelSide=P);
*/



/*================================== avLogcheckFolder ==================================
Description     : 	Checks all logs in specified path and generates a report in specified destination
					Both PDF and XLSX versions of the report will be generated
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avLogcheckFolder(logPath=<path>,
				  repPath=&mspath\05_OutputDocs\04_Reports);
*/



/*================================ avCopyDefineFromStdLib ===============================
Description     : 	Copy files and macros required for define generation to study timeline
					Files copied and created will be located in &mspath.\06_Define
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avCopyDefineFromStdLib();
*/



/*================================== avCreateExportM5 ==================================
Description     : 	Creates a export folder in the m5 format
					aCRF, SDTM and ADaM xpts, SDTM and ADaM Defines, SDTM and ADaM Reviewer Guides in docx and pdf and all ADaM and TFL programs will be included
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avCreateExportM5(repPath=&mspath\05_OutputDocs\04_Reports);



/*================================== avCreateExportTLF ==================================
Description     : 	Creates a export folder containing TFL outputs
					Export folder will be created as YYYYMMDD_TFLs_<version>_<sponsor>_<studyno>
					<sponsor> and <studyno> will be derived from the global variables Client and Studyno
					Delivery parameter can be used to specify which output should be included, compared to delivery column in avTitleFooter.xlsx
					Multiple deliveries can be specified in the delivery parameter by using #. Safety#PK for example
					Output files will be copied from &mspath.\05_OutputDocs\01_RTF
					Output has to be specified in &mspath.\01_Specifications\03_TFL\avTitleFooter.xlsx for it to be included
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avCreateExportTLF(repPath=&mspath\05_OutputDocs\04_Reports, version=Final, delivery=safety#disposition);
*/



/*================================== avCreateExportSOP ==================================
Description     : 	Creates and copies all Source, SDTM, ADaM and TFL related files to the appropriate SOP folders
					All files are copied to the respective folders located in Z:\<Sponsor>\<studyid>\11 Stats\03 Analysis
					Sources files copied from: &mspath.\02_SourceData
					SDTM and ADaM programs copied from: &mspath.\08_Final Programs\02_CDISC\Production
					SDTM and ADaM datasets copied from: &mspath.\03_Production
					TFL programs copied from: &mspath.\08_Final Programs\03_TFL\Production
					TFL output copied from: &mspath.\05_OutputDocs\01_RTF					
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avCreateExportSOP(analysisPath=Z:\<Sponsor>\<studyid>\11 Stats\03 Analysis);
*/










/*================================================================================================================================================================*/
/*======================================================================= Misc Macro Calls =======================================================================*/
/*================================================================================================================================================================*/

/*=================================== avGetVisitDate ==================================
Description     : 	Get Visit and Date from dataset as visit_crf and date_crf
					Used to get visits and dates from multiple datasets
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avGetVisitDate(dataIn=&source..db1_gl_ds_comp, visVar=visit, dateVar=dsstdat, dataOut=contact_1);
*/



/*================================ avExecuteIfVarExists ===============================
Description     : 	Comment line of code if variable does not exist in dataset by adding *
					Used for error prevention by not executing code if variables are not present in dataset
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
data example;
	set sashelp.class;
	%avExecuteIfVarExists(dataIn=sashelp.class, varIn=age)
		ageInWeeks=age*52;
	%avExecuteIfVarExists(dataIn=sashelp.class, varIn=gender)
		gender=ifc(gender='M', 'Male', 'Female');
run;
*/



/*================================ avMergeAssignedText ===============================
Description     : 	Assigns text specified in the Assign Text column in the specifications to dataset
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avMergeAssignedText(domain=ml, in=dm_ml, out=dm_ml_spec);
*/



/*================================ avAssignVisit ===============================
Description     : 	Assigns Visit, Visitnum and Visitdy from SV
					If TV exists it will be checked if any visits were renamed from CRF to TV by utilising the visit_crf column in metadata tab
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avAssignVisit(dataIn=calc, dataOut=calc_sv, dateVar=temp_date, visitVar=visit_crf);
*/



/*================================ avAssignEpoch ===============================
Description     : 	Assigns EPOCH from SE
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avEpoch(dataIn=calc, varIn=egdtc, seDataIn=&sdtmp..se, dataOut=calc_se);
*/



/*================================ avAppendCommentsToCO ===============================
Description     : 	Allows comments to be added to CO domain from other domains
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avAppendCommentsToCO(dataIn=final, libOut=&sdtmp, varIn=coval, idvar=mlspid)
*/



/*================================ avAssignAnalysisDatesFromSDTM ===============================
Description     : 	Assigns analysis dates from SDTM date variables in correct date formats
					Will create analysis dates based on SDTM variables found based on domain specified. 
					From XXSTDTC the analysis variables astdtm, astdt and asttm will be created
					From XXENDTC the analysis variables aendtm, aendt and aentm will be created
					From XXDTC the analysis variables adtm, adt and atm will be created
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avAssignAnalysisDatesFromSDTM(dataIn=ae, dataOut=ae_dated, domain=ae);
*/



/*================================ avDuration ===============================
Description     : 	Calculates duration based on SDTM date variables specified
					Unit of duration can be specified. Valid options are DAY and MIN
					avSetup.sas needs to be updated and run before running this macro
=======================================================================================
%avAssignAnalysisDuration(dataIn=ae, dataOut=ae_dur, startDate=aestdtc, endDate=aeendtc, unit=DAY, decimal=0.1);
*/



/*=============================== avAnalysisRelativeDay ==============================
Description     : 	Set ADY/ASTDY/AENDY
					Mandatory parameters: dsin, dt
					Optional parameters: 
						dsout 	(default to dsin), 
						dy 		(default to use the prefix of ------DT), 
						refdt	(default to be TRTSDT)
					refdt can be one of the following (keep w, xx or __ as is, the macro will search the pattern):
					- Phase-dependent: PHwSDT, PHwEDT
					- Period-dependent: TRxxSDT TRxxEDT APxxSDT APxxEDT
					- Period/Subperiod-dependent: PxxSwSDT PxxSwEDT
					- Custom period-dependent: ****__DT
					- Static: TRTSDT, TRTEDT, any custom ******DT
=======================================================================================
%avAssignAnalysisRelativeDay(dataIn=a03, dataOut=a04, dt=ASTDT, dy=ASTDY, refdt=TRTSDT)
%avAssignAnalysisRelativeDay(dataIn=a03, dataOut=a04, dt=AENDT, dy=AENDY)
%avAssignAnalysisRelativeDay(dataIn=a03, dataOut=ASTDT, refdt=TRxxSDT)
%avAssignAnalysisRelativeDay(dataIn=a03, dataOut=CSTMSTDT, dy=CSTMSTDY, refdt=CSTM__DT)
*/



/*================================ avOccurrenceFlag ===============================
Description     : 	Set AOCCzzFL for ADaM.OCCDS
					Mandatory parameters: dsin, flag, bystr, first
					Optional parameters: dsout (default to dsin), whr (default to 1, i.e. no condition)
=======================================================================================
%avOccurrenceFlag(dataIn=a5, flag=AOCCFL, bystr=%STR(ACAT1 USUBJID ASTDT ASTTM AENDT AENTM AEDECOD), first=USUBJID)
%avOccurrenceFlag(dataIn=a5a, dataOut=a5b, flag=AOCCSFL, bystr=%STR(ACAT1 USUBJID AESOC ASTDT ASTTM AENDT AENTM), first=AESOC)
%avOccurrenceFlag(dataIn=a5b, dataOut=a5c, flag=AOCCPFL, bystr=%STR(ACAT1 USUBJID AESOC AEDECOD ASTDT ASTTM AENDT AENTM), first=AEDECOD)
%avOccurrenceFlag(dataIn=a5i, dataOut=a5j, flag=AOCC04FL, bystr=%STR(ACAT1 USUBJID ASTDT ASTTM AENDT AENTM AEDECOD), first=USUBJID, whr=%str(aeser='Y'))
*/
