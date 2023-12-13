function dataset = extraction_bcic3_4a(channel_selected)
% Output
%       - dataset: it will be array of structs with number of subjects as
%       size of the parent struct.
%           Each struct of the dataset(i) will contain two field - eeg, and
%           label. 
%           - eeg: will be of size (n_channels*n_trials,n_samples) and
%           - labels: will be of (n_channels*n_trials,1)
% 
%    

n_samples = 3.5*1000;
n_channels = numel(channel_selected);
n_trials = 280;
path = pwd;

sub = ["a","l","v","w","y"];
folder = strcat(path,"\","datasets\","bcic3_4a\");

dataset = struct;


for s = 1:numel(sub)
    
    subjectname = strcat(folder,"data_set_IVa_a",sub(s),".mat");
    lablename = strcat(folder,"true_labels_a",sub(s),".mat");
    
    load(subjectname);
    load(lablename);
    
    
    dataset(s).eeg = zeros(n_channels*n_trials,n_samples);
    dataset(s).label = zeros(n_channels*n_trials,1);
    for i = 1:n_trials
        
        str_idx = (i - 1)*n_channels + 1;
        end_idx = i*n_channels;
        
        eeg_strt_idx = mrk.pos(i);
        eeg_end_idx = eeg_strt_idx + n_samples - 1;
        eeg = cnt(eeg_strt_idx:eeg_end_idx,:)';
        dataset(s).eeg(str_idx:end_idx,:) = eeg(channel_selected,:);
        dataset(s).label(str_idx:end_idx,:) = true_y(i);
    end
    % disp(strcat("data is loaded for ",sub(s)))
end
end































