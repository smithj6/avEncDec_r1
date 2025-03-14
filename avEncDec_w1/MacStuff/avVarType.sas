/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avVarType.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Determines the type of variable. Character or numeric
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avVarType(dataIn=
				,varIn=);			
	%local dsid
		   rc
		   varType;
	%let dsid=%sysfunc(open(&dataIn));
	%let varType = %sysfunc(vartype(&dsid, %sysfunc(varnum(&dsid, &varIn))));
	%let rc=%sysfunc(close(&dsid));
	&varType			
%mend avVarType;
