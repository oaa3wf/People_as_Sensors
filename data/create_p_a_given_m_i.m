clear all;
load('/Users/oafolabi/Dropbox/SuperCoolCarStuff (1)/driver-model/p_actions.mat');

num_of_mi = size(map_dat,2);
num_of_Mi = size(map_dat,1);
num_of_actions = size(p_map1,2);

% for each i, find all the rows such that m_i = 1
% for each i, find all the rows such that m_i = 0
rows_st_m_i_1 = {};
rows_st_m_i_0 = {};

for j = 1:num_of_mi
    rows_st_m_i_1{j}  = find_m_st_m_i(map_dat,j,1);
    rows_st_m_i_0{j}  = find_m_st_m_i(map_dat,j,0);
end

p_map_1_a_given_m_i_0 = zeros(num_of_actions, num_of_mi);
p_map_1_a_given_m_i_1 = zeros(num_of_actions, num_of_mi);

p_map_2_a_given_m_i_0 = zeros(num_of_actions, num_of_mi);
p_map_2_a_given_m_i_1 = zeros(num_of_actions, num_of_mi);

% for each a, sum over all m st m_i to find p(a|m_i)
for i = 1:num_of_actions
    
    for j = 1:num_of_mi
        
        % find rows s.t m_i = 1
        rows = rows_st_m_i_1{j};
        p_M = 1/num_of_Mi;
        p_mi = size(rows,1)/num_of_Mi;
        % sum over those rows
        p_map_1_a_given_m_i_1(i,j) = (sum(p_map1(rows,i).*p_M))/p_mi;
        p_map_2_a_given_m_i_1(i,j) = (sum(p_map2(rows,i).*p_M))/p_mi;
        
        % find rows s.t m_i = 0
        rows = rows_st_m_i_0{j};
        p_M = 1/num_of_Mi;
        p_mi = size(rows,1)/num_of_Mi;
        % sum over those rows
        p_map_1_a_given_m_i_0(i,j) = (sum(p_map1(rows,i).*p_M))/p_mi;
        p_map_2_a_given_m_i_0(i,j) = (sum(p_map2(rows,i).*p_M))/p_mi;
        
        %i
        %j
        
    end
    
    
    
end




