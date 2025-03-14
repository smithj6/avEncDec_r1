/*======================================================================================
                           PROGRAM INFORMATION - AVANCE 							      
========================================================================================
Study number     : _NA_
Sponsor          : _NA_
Program name     : avCharSubgroupsSize.sas
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

%macro avCharSubgroupsSize;
	%local i  
		   subgroupCharVarsSize;
	%let subgroupCharVarsSize=0;
	%if &subgroupVarsSize %then %do i=1 %to &subgroupVarsSize;
		%if %avVarType(dataIn=&dataIn,varIn=&&subgroupVar&i)=C %then %let subgroupCharVarsSize=%eval(&subgroupCharVarsSize + 1);
	%end;
	&subgroupCharVarsSize
%mend avCharSubgroupsSize;
