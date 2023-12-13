







n_itr = 1000;

chs_comb_store = struct;

for i = 1:n_itr

loss = loass_function(chs,positions);

end




function loss = loass_function(chs,positions)

% chs : selection channels n*1, n is the number of channels
% positions: positions of all the chs n*dim_of_position

n_channels = size(chs,1);
if n_channels ~= size(positions,1)
    error("number of chs and position are not same")
end
comb = nchoosek(1:n_channels,2);
vect_i = positions(comb(:,1),:);
vect_j = positions(comb(:,2),:);
loss = 0.5*sum(sum((vect_i-vect_j),2)).^2;
end
























































































