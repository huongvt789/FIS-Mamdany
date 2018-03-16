function First_Run_FIS(database, filename, centers)
% Complex weighted error
%learing rate
eta = 1;

FIS_para_filename = strrep(database,'.txt','.mat');
FIS_para_filename = strrep(FIS_para_filename, 'Database', 'FIS');
addpath('..\output');
load(['..\output\' filename]);
load(['..\output\' FIS_para_filename]);
load(['..\output\RuleList.mat']);

defuzz_M = [1;2];
d_defuzzM=zeros(2,1);
rule_num=size(ruleList,1);
data_num=size(train_input,1);
attri_num=size(train_input,2);
term_num=5;
defuzz_num=2;
output_order=1;

degree_M=ones(data_num,attri_num,term_num);
D_err_defuzzM=zeros(data_num,defuzz_num);

err_sum=0;
j_M=0;
    for i=1:data_num
        for j=1:attri_num
            for k=1:length(centers{j})
                degree_M(i,j,k)=gaussmf(train_input(i,j),[sigma_M(j,k) centers{j}(k)]);
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
    sum_M =zeros(data_num,1);
    for i=1:data_num
        sum_M(i) = sum(degree_M(i,:));
    end
iter_num=50;
FIS_fval1=zeros(iter_num,1);
for t=1:iter_num
    D_err_defuzzM=zeros(data_num,defuzz_num);
    for i=1:data_num
        result(i)=0;
        wtsum(i)=0;
        for j=1:rule_num
            wtsum(i)=wtsum(i)+M_DataPerRule(i,j);
            result(i)=result(i)+M_DataPerRule(i,j)*defuzz_M(ruleList(j,output_order)); 
            D_err_defuzzM(i,ruleList(j,output_order))=D_err_defuzzM(i,ruleList(j,output_order))+M_DataPerRule(i,j);
        end
        result(i)=result(i)/wtsum(i);
    end
    error=result-train_output;
    FIS_fval1(t)=sqrt(mse(error));
    ['objective value : ' num2str(FIS_fval1(t))]
    d_defuzzM=zeros(defuzz_num,1);
    for  i=1:data_num
        for d=1:defuzz_num
            d_defuzzM(d)=d_defuzzM(d)+error(i)*D_err_defuzzM(i,d)/wtsum(i);
        end
    end
    d_defuzzM=-eta*d_defuzzM/data_num;
    defuzz_M=defuzz_M+d_defuzzM;
end

fprintf('========================================================\n');
fprintf('First_Run_FIS.m done. Running Second_Run_FIS.m next...  \n');
fprintf('========================================================\n');

addpath('..\output');
save(['..\output\FIS_fval.mat'], 'FIS_fval1');
save(['..\output\FIS_defuzz.mat'], 'defuzz_M');
