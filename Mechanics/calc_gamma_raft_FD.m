function gamma_raft = calc_gamma_raft_FD(H,meshH,H_raft)

a = size(meshH);

for i = 1:length(H)
    %%% CHANGE THIS TO HYPERBOLIC TANGENT
    % 1/2 tanh(..) + 1/2
    gamma_ind(i) = .5 - .5*(tanh((H(i) - H_raft)/.05));
%    gamma_ind(i) = ((1/pi)*atan(10*((2/pi)*atan(10*((H(i) - H_raft)))))) +.5;
    gamma_ind(i) = min(gamma_ind(i),1);
    gamma_ind(i) = max(gamma_ind(i),0);
    
    
end

for i = 1:length(H)
    for j = 1:length(H)
        gamma_raft(i,j) = gamma_ind(i)*gamma_ind(j);
    end
end




end