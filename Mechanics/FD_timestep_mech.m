%% Function FD_timestep_mech
% This routing calculates the tendency at each floe size and thickness
% according to the FD parameterizations, and also updates the
% large-ice-thickness class appropriately.

% Reduces mechanical action by reducing the ability of certain size classes
% to participate in interactions

% Press = [H H_max]*exp(-20*openwater)/P_0;
% Press = [H H_max]/H_0;

%% Calculate outgoing term
K_raft =  Prob_Interact_raft;
K_ridge = Prob_Interact_ridge;


% First floe size
for r1 = 1:length(R)
    %    for r1 = 1:1
    % First floe thickness
    for r2 = 1:length(R)
        % Second floe size
        raft_loc_r = S_R_raft(r1,r2);
        ridge_loc_r = S_R_ridge(r1,r2);
        %        for h1 = 1:1
        for h1 = 1:length(H)
            % Second floe thickness
            for h2 = 1:length(H)
                
                raft_loc_h = S_H_raft(r1,r2,h1,h2);
                ridge_loc_h = S_H_ridge(r1,r2,h1,h2);
                
                if ridge_loc_h == length(H)+1
                    correct_Hmax_ridge = HMSAVE(1)/H_max;
                else
                    correct_Hmax_ridge = 1;
                end
                
                if raft_loc_h == length(H)+1
                    correct_Hmax_raft = HMSAVE(1)/H_max;
                else
                    correct_Hmax_raft = 1;
                end
                
                diagone = .5;
                diagtwo = 1;
                
                if r1 == r2 && h1 == h2
                    diagone = 1;
                    diagtwo = 2;
                end
                
                %% Rafting Step
                if rafting
                    
                    % In from combination of (r1,h1) and (r2,h2)
                    In_raft(raft_loc_r,raft_loc_h) = In_raft(raft_loc_r,raft_loc_h) + ...
                        + diagone*correct_Hmax_raft*Kfac_raft(r1,r2,h1,h2)*pi*R(raft_loc_r)^2*K_raft(r1,r2)*gamma_raft(h1,h2)* ...
                        numfloes(r1,h1)*numfloes(r2,h2);
                    
                    % Out from rafting combination with (r2,h2)
                    Out_raft(r1,h1) = Out_raft(r1,h1) + ...
                        diagtwo*K_raft(r1,r2)*gamma_raft(h1,h2)*numfloes(r1,h1)*numfloes(r2,h2)*pi*R(r1)^2;
                end
                
                %% Ridging Step
                if ridging
                    
                    % In from ridging combination of (r1,h1) and (r2,h2)
                    In_ridge(ridge_loc_r,ridge_loc_h) = In_ridge(ridge_loc_r,ridge_loc_h) + ...
                        + diagone*correct_Hmax_ridge*Kfac_ridge(r1,r2,h1,h2)*pi*R(ridge_loc_r)^2*K_ridge(r1,r2)*gamma_ridge(h1,h2)* ...
                        numfloes(r1,h1)*numfloes(r2,h2);
                    
                    % Out from ridging combination with (r2,h2)
                    Out_ridge(r1,h1) = Out_ridge(r1,h1) + ...
                        diagtwo*K_ridge(r1,r2)*gamma_ridge(h1,h2)*numfloes(r1,h1)*numfloes(r2,h2)*pi*R(r1)^2;
                end
                
                % Test to see if it is broken

                
            end
            
        end
    end
end

                if sum(Out_ridge(:)) - sum(In_ridge(:)) < 0
                    error('Ridge Broken')
                else
                    if sum(Out_raft(:)) - sum(In_raft(:)) < 0
                        error('Raft Broken')
                    end
                end

%% Here we handle what happens to the thickest floe class

% We now just treat the top row of floe thicknesses as its
% own FSD which adheres to the usual FSD equation. These
% thick floes will just stay in the thick category
for r1 = 1:length(R)
    for r2 = 1:length(R)
        
        ridge_loc_r = S_R_ridge(r1,r2);
        raft_loc_r = S_R_raft(r1,r2);
        
        diagone = .5;
        diagtwo = 1;
        
        
        
        if r1 == r2
            diagone = 1;
            diagtwo = 2;
        end
        
        %% Rafting Step
        if rafting
            
            % In from rafting combination of (r1,h_max) and (r2,h_max)
            In_raft(raft_loc_r,end) = In_raft(raft_loc_r,end) + ...
                + diagone*K_raft(r1,r2)*gamma_raft(end,end)*numfloes(r1,end)*numfloes(r2,end) * ...
                pi * R(raft_loc_r)^2 * Kfac_raft(r1,r2,end,end);
            
            % Out from rafting combination of (r1,h_max) and (r2,h_max)
            Out_raft(r1,end) = Out_raft(r1,end) + ...
                diagtwo * K_raft(r1,r2)*gamma_raft(end,end) * numfloes(r1,end) * numfloes(r2,end) * ...
                pi * R(r1)^2 ;
            
        end
        
        %% Ridging Step
        if ridging
            
            % In from ridging combination of (r1,h_max) and (r2,h_max)
            
            
            In_ridge(ridge_loc_r,end) = In_ridge(ridge_loc_r,end) + ...
                + diagone*K_ridge(r1,r2)*gamma_ridge(end,end)*numfloes(r1,end)*numfloes(r2,end) * ...
                pi * R(ridge_loc_r)^2 * Kfac_ridge(r1,r2,end,end);
            
            % Out from ridging combination of (r1,h_max) and (r2,h_max)
            Out_ridge(r1,end) = Out_ridge(r1,end) + ...
                diagtwo * K_ridge(r1,r2)*gamma_ridge(end,end) * numfloes(r1,end) * numfloes(r2,end) * ...
                pi * R(r1)^2 ;
        end
        
    end
end


%%
In = In_raft + In_ridge;
Out = Out_raft + Out_ridge;

if sum(In(:)) > sum(Out(:))
    error('Creating Volume, In > Out')
end

diff_mech = In - Out;
diff_raft = In_raft - Out_raft;
diff_ridge = In_ridge - Out_ridge;

% This is an ad-hoc way of doing the normalization, but fine here since
% the Kernel is normalized. If In = Out, use eps to make diff = 0.
sum(diff_mech(:));
sum(abs(diff_mech(:)));
diffeps = 0;

if sum(sum(abs(diff_mech))) == 0
    diffeps = eps;
end
%%

% diff is the ridging mode, must be normalized to -1
normalizer = sum(sum(diff_mech)) + diffeps;

diff_mech = - diff_mech / normalizer;

%%
In = - mag*alpha_c*In / normalizer;
Out = - mag*alpha_c*Out / normalizer;

% Here is the "convergent mode" part of the total change in ice
% partial concentrations, which tells how much redistribution is
% done in a "volume conserving" way.

diff_mech = mag*alpha_c*diff_mech;

% This is the divergent mode, the total amount of water opened by
% divergence of water, which replaces ice with open water and drops
% the volume
divopening = mag*alpha_0;

% At the moment, volume is not conserved: this is because some
% volume has left the "regular" floe sizes to reach the largest
% thickness category, and some of the area has left the largest
% thickness category, as well. We must update the ice thickness in
% this category to reflect these changes
% On the other hand, area has been correctly reported to all floe
% sizes.
V_max_in_mech = -integrate_FD(diff_mech(:,1:end-1),H,0);

% Open water is that from divergence + that freed up by convergence
opening_mech = divopening - sum(diff_mech(:));

if V_max_in_mech*dt/H_max < 1e-8
    V_max_in_mech = 0; 
end

if sum(psi(:)) <= 1e-8
    diff_mech = 0*psi;
    opening_mech = 0;
    diffeps = eps;
    psi = 0*psi;
    openwater = 1;
end


%% Loss due to divergence of ice
diffadv = (psi/(sum(sum(psi))+diffeps))*divopening;

% Here is the amount of ice volume which is lost from the largest
% thickness category due to divergenceH
V_max_out_mech = H_max*sum(diffadv(:,end));
if V_max_out < eps
    V_max_out = 0;
end

% Here, now, is the total change in partial concentrations across
% the board, accounting for mechanical combination and divergence
diff_mech_noadv = diff_mech; 
diff_mech = diff_mech - diffadv;