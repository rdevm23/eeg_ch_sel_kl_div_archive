classdef classifires_pool
    properties
        signal
        labels
        data_train
        data_test
        label_train
        label_test
        
        svm_model
        label_pred_svm
        accuracy_svm
        
        one_nn
        five_nn
        label_pred_1_nn
        label_pred_5_nn
        accuracy_1_nn
        accuracy_5_nn
    end
    
    
    methods (Access = public)
        
        function self = classifires_pool(signal,labels)
            self.signal = signal;
            self.labels = labels;
        end
        
        % ====================== SVM ==========================
        
        function self = test_train_split(self)
            % Cross varidation (train: 70%, test: 30%)
            rng(1)
            cv = cvpartition(size(self.signal,1),'HoldOut',0.2);
            idx = cv.test;
            % Separate to training and test data
            self.data_train = self.signal(~idx,:);
            self.data_test  = self.signal(idx,:);
            
            self.label_train = self.labels(~idx,:);
            self.label_test = self.labels(idx,:);
        end
        
        function self = svm_train(self)
            % Training the SVM
            
            self.svm_model = fitcsvm(self.data_train,self.label_train,'KernelFunction','rbf',...
                'Standardize',true,'ClassNames',[1,2]);
            
            % disp('SVM is trained')
        end
        
        function self = svm_pred(self)
            [self.label_pred_svm,~] = predict(self.svm_model,self.data_test);
            correct_pred = find(self.label_pred_svm == self.label_test);
            self.accuracy_svm = numel(correct_pred)*100/numel(self.label_test);
            %disp(strcat("Accuracy of SVM Prediction is ", string(self.accuracy_svm)));
        end
        % ============================================================
        % ========================= 1-nn =============================
        
        function self = one_nn_fun(self)
            self.one_nn = fitcknn(self.data_train,...
                self.label_train,'NumNeighbors',1,'Standardize',1);
            [self.label_pred_1_nn,~] = predict(self.one_nn,self.data_test);
            correct_pred = find(self.label_pred_1_nn == self.label_test);
            self.accuracy_1_nn = numel(correct_pred)*100/numel(self.label_test);
            %disp(strcat("Accuracy of 1-nn Prediction is ", string(self.accuracy_1_nn)));
        end
        
        % ============================================================
        % ========================= 5-nn =============================
        
        function self = five_nn_fun(self)
            self.five_nn = fitcknn(self.data_train,...
                self.label_train,'NumNeighbors',5,'Standardize',1);
            [self.label_pred_5_nn,~] = predict(self.five_nn,self.data_test);
            correct_pred = find(self.label_pred_5_nn == self.label_test);
            self.accuracy_5_nn = numel(correct_pred)*100/numel(self.label_test);
            %disp(strcat("Accuracy of 5-nn Prediction is ", string(self.accuracy_5_nn)));
        end
        % ============================================================
    end
end


