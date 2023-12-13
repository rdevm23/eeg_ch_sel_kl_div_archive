# -*- coding: utf-8 -*-
"""
Created on Sun Aug 13 20:08:21 2023

@author: Admin
"""



import numpy as np
import mne
import pickle







numbers_00x = ["%03d" % i for i in range(110)]
trial_0x = ['04','08','12']
freq = 160
num_samples_per_trial = int(4*freq)
subjects_excluded = []
trials_raw = []
trials_lable = []
trial_precue = []

for xx in range(109):
    sub_num = numbers_00x[xx+1]
    for xxx in trial_0x:

        filename = 'C:/Raghav/matlab_drive/CH_SELECTION_ALGOs/\
eeg-motor-movementimagery-dataset-1.0.0/files/S'\
        + sub_num + '/' + 'S' + sub_num + 'R' + xxx + '.edf'
        
        # print(filename)
        annotations = {}
        data = mne.io.read_raw_edf(filename)
        eeg_data = data.get_data()*10**6
        annotations['events'] = data.annotations.description
        annotations['onset'] = data.annotations.onset
        annotations['duration'] = data.annotations.duration
        times_of_samples = list(data.times)
        if len(annotations['events']) < 30:
            print("###############################################################")
            print('Annotation of the subject ' + sub_num + 'are not complete')
            subjects_excluded.append(sub_num) 
            continue
        
        if min(annotations['duration']) < 4.1:
            print("###############################################################")
            print('Annotation of the subject ' + sub_num + 'are not complete')
            subjects_excluded.append(sub_num) 
            continue
        
        # To Remove zeros in the end
        row_eeg, col_eeg = eeg_data.shape
        eeg_data = eeg_data.T
        zero_rows = (eeg_data == 0).all(1)
        
        if all(i == 0 for i in zero_rows):
            first_invalid = col_eeg
        else:
            first_invalid = np.where(zero_rows)[0][0]
        eeg_data = eeg_data.T
        eeg_data = eeg_data[:,0:first_invalid]
        
        row_eeg, col_eeg = eeg_data.shape
        
        if col_eeg < 19200:
            print('Subject ' + sub_num + 'Data is incomplete')
            print("###############################################################")
            subjects_excluded.append(sub_num) 
            continue
        count = 0
        for event in annotations['events']:
            if event == 'T0':
                count = count + 1
                continue
            if event == 'T1':
                onset_t = annotations['onset'][count]
                strt_idx = times_of_samples.index(onset_t)
                end_idx = strt_idx + num_samples_per_trial
                trial_data = eeg_data[:,strt_idx:end_idx]
                trials_raw.append(trial_data)
                trials_lable.append('T1')
                
                baseline_data = eeg_data[:,strt_idx - num_samples_per_trial :strt_idx]
                trial_precue.append(baseline_data)
                
                count = count + 1
                continue
            if event == 'T2':
                onset_t = annotations['onset'][count]
                strt_idx = times_of_samples.index(onset_t)
                end_idx = strt_idx + num_samples_per_trial
                trial_data = eeg_data[:,strt_idx:end_idx]
                trials_raw.append(trial_data)
                trials_lable.append('T2')
                
                baseline_data = eeg_data[:,strt_idx - num_samples_per_trial :strt_idx]
                trial_precue.append(baseline_data)
                count = count + 1
                
                continue


#%% Saving to Matlab
all_trials = np.zeros((4260*64,640))
all_labels = np.zeros((4260*64,1))
all_precues = np.zeros((4260*64,640))

idx = 0

for k in range(4260):
    
    strt_idx = idx*64
    end_idx = (idx+1)*64
    
    all_trials[strt_idx:end_idx,:] = trials_raw[idx]
    all_precues[strt_idx:end_idx,:] = trial_precue[idx]
    if trials_lable[idx] == 'T1':
        all_labels[strt_idx:end_idx,:] = 1
    if trials_lable[idx] == 'T2':
        all_labels[strt_idx:end_idx,:] = 2
    
    idx = idx + 1
    

from scipy import io

mdic = {"all_trials":all_trials,"label":"Physionetdata"}
mlab = {"all_labels":all_labels,"label":"Physionetlabels"}
mprec = {"all_precue":all_precues,"label":"Physionetprecues"}
io.savemat('physionet_all_trials.mat',mdic)
io.savemat('physionet_all_labels.mat',mlab)
io.savemat('physionet_all_precue.mat',mprec)







