function [TrainingTime, AccuracyTraining, MAETraining, MSETraining] = Second_Run_FIS(database, filename, centers)
%Complex weighted error
%learing rate
eta=0.000001;
output_order=1;
term_num=5;

FIS_para_filename = strrep(database,'.txt','.mat');
FIS_para_filename = strrep(FIS_para_filename, 'Database', 'FIS');
addpath('..\output');
load(['..\output\' filename]);
load(['..\output\' FIS_para_filename]);
load(['..\output\RuleList.mat']);
load(['..\output\FIS_defuzz.mat']);

input_num=size(train_input,1);
attri_num=size(train_input,2);
rule_num=size(ruleList,1);
degree_M=ones(input_num,attri_num,term_num);
wtsum = zeros(input_num,1);

M_DataPerRule = zeros(input_num,rule_num);

start_time_train = cputime;
for i=1:input_num
    for j=1:attri_num
        for k=1:length(centers{j})
            degree_M(i,j,k) = gaussmf(train_input(i,j),[sigma_M(j,k) centers{j}(k)]);
        end   
    end
end
min_M=1;

for i=1:input_num
    for j=1:rule_num
        min_M=1;
        for k=1:attri_num
            if min_M>degree_M(i,k,ruleList(j,k));
                min_M=degree_M(i,k,ruleList(j,k));
            end
        end
        M_DataPerRule(i,j)=min_M;
    end 
end
result=zeros(input_num,1);
sum_M =zeros(input_num,1);
for i=1:input_num
    result(i)=0;wtsum(i)=0;
    for j=1:rule_num
        wtsum(i)=wtsum(i)+M_DataPerRule(i,j);
        result(i)=result(i)+M_DataPerRule(i,j)*defuzz_M(ruleList(j,output_order));
    end
    result(i)=result(i)/wtsum(i);
end

temp=round(result);
data_num=size(result,1);
for i=1:data_num
    if temp(i)<1
        temp(i)=1;
    else if temp(i)>2
            temp(i)=2;
        end
    end
end
end_time_train = cputime;
TrainingTime = end_time_train - start_time_train;

AccuracyTraining=sum(temp==train_output)/size(train_output,1)
%MAE
MAETraining=mae(result-train_output)

%MSE
MSETraining=mse(result-train_output)

fprintf('==================================================\n');
fprintf('Second_Run_FIS.m done. Running Run_Test_FIS.m...  \n');
fprintf('==================================================\n');

addpath('..\output');
save(['..\output\FIS_para.mat'], 'sigma_M');
