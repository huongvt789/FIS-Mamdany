function [TestingTime, AccuracyTesting, MAETesting, MSETesting] = Run_Test_FIS(database, filename, centers)

FIS_para_filename = strrep(database,'.txt','.mat');
FIS_para_filename = strrep(FIS_para_filename, 'Database', 'FIS');
addpath('..\output');
load(['..\output\' filename]);
load(['..\output\' FIS_para_filename]);
load(['..\output\RuleList.mat']);
load(['..\output\FIS_defuzz.mat']);
rule_num=size(ruleList,1);
data_num=size(test_input,1);
attri_num=size(test_input,2);
term_num=5;
defuzz_num=2;
output_order=1;

degree_M=ones(data_num,attri_num,term_num);

start_time_test = cputime;
j_M=0;
for i=1:data_num
    for j=1:attri_num
        for k=1:length(centers{j})
            degree_M(i,j,k)=gaussmf(test_input(i,j),[sigma_M(j,k) centers{j}(k)]);
        end   
    end
end
min_M=1;
M_DataPerRule = zeros(data_num,rule_num);
for i=1:data_num
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
temp_M=zeros(data_num,rule_num);
result=zeros(data_num,1);
wtsum=zeros(data_num,1);

for i=1:data_num
    result(i)=0;
    wtsum(i)=0;
    for j=1:rule_num
        wtsum(i)=wtsum(i)+M_DataPerRule(i,j); 
        result(i)=result(i)+M_DataPerRule(i,j)*defuzz_M(ruleList(j,output_order)); 
    end
    result(i)=result(i)/wtsum(i);
end

temp=round(result);
for i=1:data_num
    if temp(i)<1
        temp(i)=1;
    else if temp(i)>2
            temp(i)=2;
        end
    end
end

end_time_test = cputime;
TestingTime = end_time_test - start_time_test;
%Accuracy
AccuracyTesting = sum(temp==test_output)/size(test_output,1)

%MAE
MAETesting = mae(result-test_output)

%MSE
MSETesting = mse(result-test_output)
