classdef classifires_pool_with_cv
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
        
        trn_acc_svm_model
        trn_acc_all_folds_svm
        trn_acc_1nn_model
        trn_acc_all_folds_1nn
        trn_acc_5nn_model
        trn_acc_all_folds_5nn


    end
    
    
    methods (Access = public)
        
        function self = classifires_pool_with_cv(signal,labels)
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
            
            self.svm_model = fitcsvm(self.data_train,...
                self.label_train,'KernelFunction','rbf',...
                'Standardize',true,'ClassNames',[1,2],KFold=10);
            
            self.trn_acc_all_folds_svm = (1 - kfoldLoss(self.svm_model,'Mode','individual'))*100;
            self.trn_acc_svm_model.mean = mean(self.trn_acc_all_folds_svm);
            self.trn_acc_svm_model.std = std(self.trn_acc_all_folds_svm);
            
        end
        
        function self = svm_pred(self)
            
            [~,idx] = sort(self.trn_acc_all_folds_svm,'descend');
            best_model = self.svm_model.Trained{idx};
            self.accuracy_svm = (1 - loss(best_model,self.data_test,self.label_test))*100;
            
        end
        % ============================================================
        % ========================= 1-nn =============================
        
        function self = one_nn_fun(self)
            self.one_nn = fitcknn(self.data_train,...
                self.label_train,'NumNeighbors',1,'Standardize',1,KFold=10);
            
            self.trn_acc_all_folds_1nn = (1 - kfoldLoss(self.one_nn,'Mode','individual'))*100;
            self.trn_acc_1nn_model.mean = mean(self.trn_acc_all_folds_1nn);
            self.trn_acc_1nn_model.std = std(self.trn_acc_all_folds_1nn);
            
            
            [~,idx] = sort(self.trn_acc_all_folds_1nn,'descend');
            best_model = self.one_nn.Trained{idx};
            self.accuracy_1_nn = (1 - loss(best_model,self.data_test,self.label_test))*100;
        end
        
        % ============================================================
        % ========================= 5-nn =============================
        
        function self = five_nn_fun(self)
            self.five_nn = fitcknn(self.data_train,...
                self.label_train,'NumNeighbors',5,'Standardize',1,KFold=10);
            
            
            self.trn_acc_all_folds_5nn = (1 - kfoldLoss(self.five_nn,'Mode','individual'))*100;
            self.trn_acc_5nn_model.mean = mean(self.trn_acc_all_folds_5nn);
            self.trn_acc_5nn_model.std = std(self.trn_acc_all_folds_5nn);
            
            
            [~,idx] = sort(self.trn_acc_all_folds_5nn,'descend');
            best_model = self.one_nn.Trained{idx};
            self.accuracy_5_nn = (1 - loss(best_model,self.data_test,self.label_test))*100;
        end
        % ============================================================
    end
end


