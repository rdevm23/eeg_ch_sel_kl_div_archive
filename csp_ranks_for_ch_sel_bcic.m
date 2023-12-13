



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

classdef csp_ranks_for_ch_sel_bcic
    
    properties (Access = public)
        signal
        classes
        f_sampl
        filter
        n_channels
        csp_W1 % assigned in csp_mats()
        csp_W2 % assigned in csp_mats()
        csp_A1 % assigned in csp_mats()
        csp_A2 % assigned in csp_mats()
        
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
        
        function self = csp_ranks_for_ch_sel_bcic(signal,classes,n_channels,fs)
            self.signal = signal;
            self.classes = classes;
            
            self.f_sampl = fs;
            self.n_channels = n_channels;
            
        end
                
        
        function self = csp_mats(self)
            
            [W1,W2,A1,A2] = csp_train(self);
            self.csp_W1 = W1;
            self.csp_W2 = W2;
            self.csp_A1 = A1;
            self.csp_A2 = A2;
        end
        
        function self = csp_ranks(self)
            
            
        end
    end
    
    %% ===================== PROTECTED METHOD =========================
    
    methods (Access = protected)
        
        % Functions
        % 1) [W1,W2,C1,C2] = csp_train(self)
        % 2) C = covariance(X) used in csp_train(self)
        
        function [W1,W2,A1,A2] = csp_train(self)
            eeg = self.signal;
            classes_ = self.classes;
            n_ch = self.n_channels;
            m = 1;
            
            % eeg is of size = [n_ch*trials n_sample]
            X1 = reshape(eeg(classes_==1,:), ...
                [n_ch, size(eeg(classes_==1,:),1)/n_ch size(eeg,2)]);
            X2 = reshape(eeg(classes_==2,:), ...
                [n_ch, size(eeg(classes_==2,:),1)/n_ch size(eeg,2)]);
            
            C1 = covariance(self,X1);
            C2 = covariance(self,X2);
            
            % Composit Cov
            C = C1 + C2;
            
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

















































































































