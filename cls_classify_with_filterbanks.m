classdef cls_classify_with_filterbanks
    
    properties
        signal
        classes
        f_sampl
        filter
        n_channels
        channels_selected
        n_CSP_comp
        csp_labels % assigned in csp_apply()
        csp_signal % assigned in csp_apply()
        csp_filt
        mibif_signal
    end
    
    methods (Access = public)
        function self = cls_classify_with_filterbanks(...
                signal,classes,n_channels,fs)
            self.signal = signal;
            self.classes = classes;
            
            self.f_sampl = fs;
            self.n_channels = n_channels;
        end
        function self = filtering(self)
            eeg = self.signal;
            f_samp = self.f_sampl;
            self.signal = filter_eeg_this_class(self,eeg,f_samp);
        end
        
        function self = csp_filtering(self,channels_selected,n_CSP_comp)
            eeg = self.signal;
            class = self.classes;
            ch = channels_selected;
            m = n_CSP_comp;
            self.n_CSP_comp = n_CSP_comp;
            self.channels_selected = channels_selected;
            
            [Xa, Xb] = separation_this_class(self,eeg,class,ch);
            [W1, W2,C1, C2, n1, n2] = CSP_train_this_class(self,Xa,Xb, m);
            
            self.csp_filt.W1 = W1;
            self.csp_filt.W2 = W2;
            self.csp_filt.C1 = C1;
            self.csp_filt.C2 = C2;
            self.csp_filt.n1 = n1;
            self.csp_filt.n2 = n2;
            
            self = csp_apply_this_class(self);
        end
        
        function self = feature_selection(self,k)
            class1 = 1;
            class2 = 2;
            m = self.n_CSP_comp;
            Y = self.csp_labels;
            V1 = self.csp_signal(:,1:size(self.csp_signal,2)/2);
            V2 = self.csp_signal(:,33:size(self.csp_signal,2));
            I1 = MIBIF(V1,Y,class1,m,k);
            I2 = MIBIF(V2,Y,class2,m,k);
            self.mibif_signal = [V1(:,I1),V2(:,I2)];

            
        end
        
    end
    
    %%=====================================================================
    methods (Access = protected)
        
        function self = csp_apply_this_class(self)
            eeg = self.signal;
            n_ch = self.n_channels;
            m = self.n_CSP_comp;
            n_trial = size(eeg,1)/n_ch;
            w1 = self.csp_filt.W1;
            w2 = self.csp_filt.W2;
            n_bands = size(w1,3);
            
            eeg = permute(reshape(eeg,...
                [n_ch, n_trial, size(eeg,2), size(eeg,3)]),[1,3,2,4]);
            
            v1 = zeros(n_trial,2*m*n_bands);
            v2 = v1;
            
            for i = 1:n_trial
                for j = 1:n_bands 
                    sig = eeg(:,:,i,j);
                    c1 = (w1(:,:,j)')*(sig)*(sig')*w1(:,:,j);
                    c2 = (w2(:,:,j)')*(sig)*(sig')*w2(:,:,j);
                    v1(i,(j-1)*2*m+1:j*2*m) = transpose(log(diag(c1)/trace(c1)));
                    v2(i,(j-1)*2*m+1:j*2*m) = transpose(log(diag(c2)/trace(c2)));
                end
            end
            self.csp_signal = [v1,v2];
            lables_csp_filt = reshape(self.classes,[n_ch,n_trial]);
            self.csp_labels = lables_csp_filt(1,:)';
        end
        
        function [W1, W2,C1, C2, n1, n2] = CSP_train_this_class(~,Xa,Xb, m)
            % This function trains the CSP block according to input data.
            % The input classes can be 2 or 4 in the current implementation.
            %
            %   INPUT:
            %   'eeg' is an array with EEG filtered at different pass-bands;
            %   'class' is a column vector with the class of each EEG signal;
            %   'ch' are the channels to consider for the eeg signal extraction;
            %   'm' is the number of CSP components to consider.
            %
            %   OUTPUT:
            %   'Wi' is the CSP projection matrix related to class i, with i in range (1,4);
            %   'Ci' is the covariance matrix related to class i, with i in range (1,4);
            %   'ni' is the trials number to calculate the covariance matrix related to class i, with i in range (1,4);
            %
            %
            %  authors:         A. Esposito
            %  correspondence:  anthony.esp@live.it
            %  last update:     2020/11/30
            
            % classes detection
            
            nb = size(Xa,4);
            nch = size(Xb,1);
            
            % projection matrices
            W1 = zeros(nch,2*m,nb);
            W2 = zeros(nch,2*m,nb);
            C1 = zeros(nch,nch,nb);
            C2 = zeros(nch,nch,nb);
            % CSP matrices
            for i = 1:nb
                [W1(:,:,i), W2(:,:,i), C1(:,:,i), C2(:,:,i), n1, n2] = CSP_2task(Xa(:,:,:,i),Xb(:,:,:,i), m);
            end
        end
        
        function [XL, XR] = separation_this_class(~,eeg,class,ch)
            % SEPARATION separates the signals per class and reshapes them in a 4D
            % array with channels-time-trials-band
            %
            %   INPUT:
            %   'eeg' is a 3D array with EEG filtered at different pass-bands;
            %   'class' is a column vector with the class of each EEG signal;
            %   'ch' are the channels to consider for the eeg signal extraction;
            %
            %   OUTPUT:
            %   'XL' is the 4D array with filtered EEG related to class 'left';
            %   'XR' is the 4D array with filtered EEG related to class 'right';
            %   
            %
            %
            %  authors:         A. Esposito
            %  correspondence:  anthony.esp@live.it
            %  last update:     2020/05/12
            
            % Separation per class
            nch = length(ch);
            eeg = reshape(eeg,[nch size(eeg,1)/nch size(eeg,2) size(eeg,3)]);
            class = reshape(class,[nch size(class,1)/nch]);
            
            per = [1 3 2 4];
            XL =  permute(eeg(:,class(1,:) == 1,:,:),per);
            XR =  permute(eeg(:,class(1,:) == 2,:,:),per);
        end
        
        function [filtered_eeg, HD] = filter_eeg_this_class(~,eeg, fsamp)
            % filter parameters
            order = 10;                 % * chosen arbitrarily
            attenuation = 50;           % * chosen arbitrarily
            
            % filter bands
            fcutL = 4;                        % low  cut off frequency
            fcutH = 40;                       % high cut off frequency
            fshif = 4;                        % shift for bands overlap
            fband = 8;                        % band width
            
            % filtered signal init
            n_bands = floor(((fcutH-fcutL) - fband)/fshif + 1);
            filtered_eeg = zeros([size(eeg) n_bands]);
            
            % check for not-a-numbers in the data and replace it with zeros
            signal_nan = find(isnan(eeg));
            if (~isempty(signal_nan))
                nnan = length(signal_nan);
                warning(strcat(num2str(nnan),' NaN were found in the signal to filter! They were replaced with 0.'));
                eeg(signal_nan) = 0;
            end
            
            % filtering 
            i = 1;
            create_filter = 1;
            while (i <= n_bands)
                % i-th pass-band
                f_low = fcutL + fshif*(i-1);
                f_high = f_low + fband;
                
                if (nargin == 2 || create_filter)
                    % Chebyshev type II filter
                    [z,p,k] = cheby2(order,attenuation,2*[f_low f_high]/fsamp);
                    [sos,g] = zp2sos(z,p,k);
                    HD(i) = dfilt.df2sos(sos,g);
                end
                
                % filtering each eeg from different channels/trials/runs
                for j = 1:size(eeg,1)
                    filtered_eeg(j,:,i) = filtfilt(HD(i).sosMatrix,HD(i).ScaleValues,eeg(j,:));
                end
                disp("One Band filtering is done")
                i = i + 1;
            end
        end
        
        
    end
    
end