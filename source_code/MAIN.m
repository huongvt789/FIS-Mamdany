function MAIN(database)
% FIS Main Program
clc;

num_folder=10;
TrainingTime=zeros(num_folder,1);
TrainingAccuracy=zeros(num_folder,1);
TestingTime=zeros(num_folder,1);
TestingAccuracy=zeros(num_folder,1);
MAE_Training=zeros(num_folder,1);
MSE_Training=zeros(num_folder,1);
MAE=zeros(num_folder,1);
MSE=zeros(num_folder,1);

fprintf('===============================================\n');
fprintf('  Start to make rules... \n');
fprintf('===============================================\n');

% Execute Rule Generation process to generate RuleList.mat
centers = MakeRules(database, database);

% cross-validate the database and generate all validation folders which contain
% trainging data and testing data
CROSS_VALIDATION(database, num_folder);

fprintf('===============================================\n');
fprintf('  Start to run FIS algorithm. \n');
fprintf('===============================================\n');

for i=1:num_folder
    fprintf('===============================================\n');
    fprintf('  Loading and validating Database... \n');
    fprintf('===============================================\n');
    filename = strrep(database,'.txt','_data_fold_');
    filename = strcat(filename, num2str(i), '.mat');
    load(['..\output\' filename]);
    First_Run_FIS(database, filename, centers);
    [TrainingTime(i), TrainingAccuracy(i), MAE_Training(i), MSE_Training(i)] = Second_Run_FIS(database, filename, centers);
    fprintf('===============================================\n');
    fprintf('  Start to testing Database... \n');
    fprintf('===============================================\n');
    [TestingTime(i), TestingAccuracy(i), MAE(i), MSE(i)] = Run_Test_FIS(database, filename, centers);
    fprintf('===============================================\n');
    fprintf('  Done! \n');
    fprintf('===============================================\n');
end

Mean_TrainingTime=mean(TrainingTime)
Mean_TrainingAccuracy=mean(TrainingAccuracy)
Mean_TestingTime=mean(TestingTime)
Mean_TestingAccuracy=mean(TestingAccuracy)
Mean_MAE=mean(MAE)
Mean_MSE=mean(MSE)
Mean_MAE_Training=mean(MAE_Training)
Mean_MSE_Training=mean(MSE_Training)

Train_Time = num2str(Mean_TrainingTime,'%0.3f');
Train_Acc = num2str(Mean_TrainingAccuracy,'%0.5f');
Train_MAE = num2str(Mean_MAE_Training,'%0.5f');
Train_MSE = num2str(Mean_MSE_Training,'%0.5f');
Test_Time = num2str(Mean_TestingTime,'%0.5f');
Test_Acc = num2str(Mean_TestingAccuracy,'%0.5f');
Test_MAE = num2str(Mean_MAE,'%0.5f');
Test_MSE = num2str(Mean_MSE,'%0.5f');

fprintf('\t\t\t\t\t\t\t======== FUZZY INFERENCE SYSTEM ========\n'); 
fprintf('+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+\n');
fprintf('|\t\t\t\t\t\t\tTraining\t\t\t\t\t\t\t|\t\t\t\t\t\t\tTesting\t\t\t\t\t\t\t\t|\n');
fprintf('+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+\n');
fprintf('|\t Time\t\t|\tAccuracy\t|\t\tMAE\t\t|\t\tMSE\t\t|\t Time\t\t|\tAccuracy\t|\t\tMAE\t\t|\t\tMSE\t\t|\n');
fprintf('|\t%s\t\t|\t%s\t\t|\t%s\t\t|\t%s\t\t|\t%s\t\t|\t%s\t\t|\t%s\t\t|\t%s\t\t|\n',...
    Train_Time,Train_Acc,Train_MAE,Train_MSE,Test_Time,Test_Acc,Test_MAE,Test_MSE);
fprintf('+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+\n');

output_file = strrep(database,'.txt','_output');
addpath('..\output')
save(['..\output\' output_file], 'TrainingTime');
save(['..\output\' output_file], 'TrainingAccuracy', '-append');
save(['..\output\' output_file], 'TestingTime', '-append');
save(['..\output\' output_file], 'TestingAccuracy', '-append');
save(['..\output\' output_file], 'MAE_Training', '-append');
save(['..\output\' output_file], 'MSE_Training', '-append');
save(['..\output\' output_file], 'MAE', '-append');
save(['..\output\' output_file], 'MSE', '-append');

