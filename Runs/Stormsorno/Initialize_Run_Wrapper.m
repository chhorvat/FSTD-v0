%% Initialize_Run_Wrapper

FSTD = struct(); 
OPTS = struct(); 
THERMO = struct(); 
MECH = struct(); 
SWELL = struct(); 
OCEAN = struct(); 
DIAG = struct(); 
EXFORC = struct(); 


OPTS.numruns = 2; 
OPTS.NAMES = {'SavedOutput/Storms_Tmelt',...
    'SavedOutput/NoStorms_Tmelt'};