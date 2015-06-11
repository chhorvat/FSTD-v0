%% Drive_FD
% This routine initializes and then executes multiple runs as the main
% wrapper and driver of the FD code.

% It is written in general format for future runs

% There are five major structure files which govern the development of the
% FSTD. They are

% FSTD: which contains PSI as well as other related variables
% THERMO: containing the thermodynamic options
% MECH: similar, for mechanics
% SWELL: similar, for swell fracture
% OPTS: containing global options

% There are several structures that need to be passed. 
% struct FSTD % FSTD op tions
% struct THERMO % Thermodynamics options
% struct MECH % Mechanics options
% struct SWELL % Swell fracture options
% struct OPTS % General options
% struct OCEAN % hehe . Contains information about the ocean model
% struct DIAG % Contains diagnostics
% struct EXFORC % Contains External Forcing

%% Actually Run the Model

clear 
 
location_of_files = 'Runs/Stormsorno';

addpath(location_of_files)

Initialize_Run_Wrapper;

for runnum = 1:OPTS.numruns
    
    Initialize_Run_Wrapper; 

    OPTS.run_number = runnum; 

    [FSTD,OPTS,THERMO,MECH,SWELL,DIAG,EXFORC,OCEAN] = Set_General_Run_Variables(FSTD,OPTS,THERMO,MECH,SWELL,DIAG,EXFORC,OCEAN);
    [FSTD,OPTS,THERMO,MECH,SWELL,DIAG,EXFORC,OCEAN] = Set_Specific_Run_Variables(runnum,FSTD,OPTS,THERMO,MECH,SWELL,DIAG,EXFORC,OCEAN);
    [FSTD,OPTS,THERMO,MECH,SWELL,DIAG,EXFORC,OCEAN] = FD_Run(FSTD,OPTS,THERMO,MECH,SWELL,DIAG,EXFORC,OCEAN) ;
    
    save(['../FSTD-OUTPUT/' OPTS.NAMES{OPTS.run_number}],'-v7.3')

end



if FSTD.DO
    
    
end
