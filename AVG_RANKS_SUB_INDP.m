
function ranks_of_sub = AVG_RANKS_SUB_INDP(all_ranks,n_ch,n_sub)
ranks_of_sub = zeros(n_ch,1);
for s = 1:n_sub
    ranks = all_ranks(s).refs(2).ranks;
    ranks_of_sub = ranks_of_sub + ranks;
end
ranks_of_sub = ranks_of_sub/n_sub;
end