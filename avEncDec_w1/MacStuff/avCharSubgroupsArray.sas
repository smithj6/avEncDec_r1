/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avCharSubgroupsArray.sas
Output           : _NA_
Created on       : 
By               : SP.Standards
Modified         : 
Note             : Obtains the bigN from a subject level dataset. Typically ADSL
=======================================================================================
Modification History
=======================================================================================
Purpose/Changes  :	
Date changed     :                     
=======================================================================================*/

%macro avCharSubgroupsArray;
	%local i  
		   subgroupCharVarsSize;
	%let subgroupCharVarsSize=0;
	%do i=1 %to &subgroupVarsSize;
		%if %avVarType(dataIn=&dataIn,varIn=&&subgroupVar&i)=C %then %do;
			%let subgroupCharVarsSize=%eval(&subgroupCharVarsSize + 1);
			%let subgroupCharVar&subgroupCharVarsSize=&&subgroupVar&i;
		%end;
	%end;
%mend avCharSubgroupsArray;
