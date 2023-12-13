 %% This Code is to implement the class for filtering and classification of MI Data
%==========================================================================
% Part of the code at https://github.com/anthonyesp/channel_selection has
% been reused and some has been modified and used. The work related to this
% code will be cited and authors of the code does not claim the IP of the
% reused or modified code. 

% Author - Raghav Dev, rdevm23@gmail.com
% Copyright(C) 2023, All Rights Reserved


% Date - 7th Aug 2023
% Version - 1.0
% Last Modified on - 7th Aug 2023


%% Class

classdef cls_classify_motorI
    
    properties (Access = public)
        signal
        classes
        f_sampl
        filter
        n_channels
        n_CSP_comp
        csp_W1 % assigned in csp_mats()
        csp_W2 % assigned in csp_mats()
        csp_C1 % assigned in csp_mats()
        csp_C2 % assigned in csp_mats()
        csp_lables % assigned in csp_apply()
        csp_signal % assigned in csp_apply()
    end
    
    properties (Access = protected)
        newFieldAdded
    end
    
    %% ===================== PUBLIC METHOD =========================
    methods (Access = public)
        % Functions 
        % 1) self = cls_classify_motorI(signal,classes,n_channels)
        % 2) self = create_filter(self)
        % 3) self = filter_bank(self)
        % 4) self = filter_bank(self)
        % 5) self = csp_mats(self,n_CSP_comp)
        
        function self = cls_classify_motorI(signal,classes,n_channels,fs)
            self.signal = signal;
            self.classes = classes;
            
            self.f_sampl = fs;
            self.n_channels = n_channels;
            
        end
        
        function self = create_filter(self)
            %filter
            f_low = 4;                  % low  cut off frequency
            f_high = 40;                % high cut off frequency
            order = 10;                 % chosen arbitrarily
            attenuation = 50;           % chosen arbitrarily
            [z,p,k] = cheby2(order,attenuation,2*[f_low f_high]/self.f_sampl);
            [sos,g] = zp2sos(z,p,k);
            self.filter = dfilt.df2sos(sos,g);
        end
        
        function self = filter_bank(self)
            eeg = self.signal;
            filtered_eeg = zeros(size(eeg));
            
            % check for not-a-numbers in the data and replace it with zeros
            signal_nan = find(isnan(eeg));
            if (~isempty(signal_nan))
                eeg(signal_nan) = 0;
            end
            
            % Filtering
            sosMatrix = self.filter.sosMatrix;
            ScaleValues = self.filter.ScaleValues;
            for j = 1:size(eeg,1)
                filtered_eeg(j,:) = filtfilt(sosMatrix,ScaleValues,eeg(j,:));
            end
            self.signal = filtered_eeg;
            
        end
        
        
        
        function self = csp_mats(self,n_CSP_comp)
            self.n_CSP_comp = n_CSP_comp;
            [W1,W2,C1,C2] = csp_train(self);
            self.csp_W1 = W1;
            self.csp_W2 = W2;
            self.csp_C1 = C1;
            self.csp_C2 = C2;
        end
        
        function self = csp_apply(self)
            
            eeg = self.signal;
            n_ch = self.n_channels;
            m = self.n_CSP_comp;
            n_trial = size(eeg,1)/n_ch;
            w1 = self.csp_W1;
            w2 = self.csp_W2;
            
            eeg = permute(reshape(eeg,...
                [n_ch, n_trial, size(eeg,2)]),[1,3,2]);
            v1 = zeros(n_trial,2*m);
            v2 = v1;
            for i = 1: n_trial
                sig = eeg(:,:,i);                
                c1 = (w1')*(sig)*(sig')*w1;
                c2 = (w2')*(sig)*(sig')*w2;
                v1(i,:) = transpose(log(diag(c1)/trace(c1)));
                v2(i,:) = transpose(log(diag(c2)/trace(c2)));
            end
            lables_csp_filt = reshape(self.classes,[n_ch,n_trial]);
            self.csp_lables = lables_csp_filt(1,:)';
            self.csp_signal = [v1,v2];
            
        end
    end
    
    %% ===================== PROTECTED METHOD =========================
    
    methods (Access = protected)
        
        % Functions
        % 1) [W1,W2,C1,C2] = csp_train(self)
        % 2) C = covariance(X) used in csp_train(self)
        
        function [W1,W2,C1,C2] = csp_train(self)
            eeg = self.signal;
            classes_ = self.classes;
            n_ch = self.n_channels;
            m = self.n_CSP_comp;
            
            % eeg is of size = [n_ch*trials n_sample]
            X1 = reshape(eeg(classes_==1,:), ...
                [n_ch, size(eeg(classes_==1,:),1)/n_ch size(eeg,2)]);
            X2 = reshape(eeg(classes_==2,:), ...
                [n_ch, size(eeg(classes_==2,:),1)/n_ch size(eeg,2)]);
            
            C1 = covariance(self,X1);
            C2 = covariance(self,X2);
            
            % Composit Cov
            C = C1 + C2;
            
            % Projection matrices
            % Complete projection matrices
            [W11, A1] = eig(C1,C);
            [W22, A2] = eig(C2,C);
            
            % Sorting
            [~, ind1] = sort(diag(A1));
            [~, ind2] = sort(diag(A2));
            
            W111 = W11(:,ind1);
            W222 = W22(:,ind2);
            
            % Reduced projection matrices
            % half eigenvectors corresponds to big eigenvalues and half of
            % small one
            W1 = [W111(:,1:m), W111(:,end-m+1:end)];
            W2 = [W222(:,1:m), W222(:,end-m+1:end)];
            
        end
        
        function C = covariance(~,X)
            % X is 3d: [n_ch trials n_sample]
            % C will of size [n_ch n_ch]
            X = permute(X,[1,3,2]);
            C = zeros(size(X,1));
            for i = 1:size(X,3) %(sum along the trials)
                M = X(:,:,i)*X(:,:,i)';
                C = C + M/(trace(M));
            end
            C = C/i;
        end
        
        
        
    end
    %% ===================== PROTECTED FUNCTION ENDS =====================

    
end





































































































