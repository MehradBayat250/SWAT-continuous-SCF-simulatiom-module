Although SCF is an effective variable for snow simulation, original SWAT only calculates this variable for days in which the snowmelt process is triggered by daily mean temperature when is raised above the temperature threshold, i.e. SMTMP parameter. Moreover, for days in which the snowmelt process is not activated, i.e. days with snow accumulation, the model does not calculate the SCF value. Moreover, the model simulates the snow processes at the HRU scale, while considers the snow parameters at the (sub)basin scale (e.g. SMTMP, SFTMP, SMFMN, SMFMX, and TIMP) or whole basin scale (e.g. SNOCOVMX and SNO50COV). Therefore, there is a mismatch between the spatial scale of the snow parameters and the model’s equations related to snow processes.
To address the above-mentioned limitations, we modified some subroutines of the model as below:
1) The modified snow module of the model (snom.f) that continuously simulates the SCF value for all days of the simulation period.
2) the modified modparm and allocate_parms subroutines in which the new parameters are defined.
3) the readfile.f subroutine in which some new txt files are defined to allocate the new parameter values to the model by any algorithm/user.
4) the readfile.f subroutine which prints the value of HRU-scale SCF and  more other variables in some new output files

the user can compile these modified subroutines with other original SWAT subroutine to access to modified version of the SWAT model. 
