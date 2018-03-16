function CROSS_VALIDATION(DataBase_File, num_folder)

% number of folders
k_fold=num_folder;
%%%%%%%%%%% Load dataset
addpath('..\input')
temp_data=load(['..\input\' DataBase_File]);
data_num=size(temp_data,1);
attri_num=size(temp_data,2);
min_data=min(temp_data);
max_data=max(temp_data);
% for i=2:attri_num
    % temp_data(:,i)=(temp_data(:,i)-min_data(i))/(max_data(i)-min_data(i));
% end
% mix data
indices=zeros(data_num,1);
for i=1:data_num
    indices(i)=i;
end
indices=make_permutation(indices);
% generate new database from original database with another order of rows 
data=zeros(data_num,attri_num);
for i=1:data_num
    data(i,:)=temp_data(indices(i),:);
end

% store 4 folders of training data and testing data
m_train_input=cell(k_fold, 1);
m_train_output=cell(k_fold, 1);
m_test_input=cell(k_fold, 1);
m_test_output=cell(k_fold, 1);
min_index=1;
max_index=fix(data_num/k_fold);
for i=1:k_fold
    if i>1
        min_index=max_index+1;
        max_index=max_index+fix(data_num/k_fold);
        if i==k_fold
            m_train_input{i}=data(1:(min_index-1),2:attri_num);
            m_train_output{i}=data(1:(min_index-1),1);
        else
            m_train_input{i}=data([1:(min_index-1),(max_index+1):data_num],2:attri_num);
            m_train_output{i}=data([1:(min_index-1),(max_index+1):data_num],1);
        end
    else % i=1
        m_train_input{i}=data((max_index+1):data_num,2:attri_num);
        m_train_output{i}=data((max_index+1):data_num,1);
    end
    m_test_input{i}=data(min_index:max_index,2:attri_num);
    m_test_output{i}=data(min_index:max_index,1);   
end

% save all 
for i=1:k_fold
    filename=strrep(DataBase_File,'.txt','_data_fold_');
    filename=strcat(filename, num2str(i));
    train_input=m_train_input{i};
    train_output=m_train_output{i};
    test_input=m_test_input{i};
    test_output=m_test_output{i};
    addpath('..\output')
    save(['..\output\' filename], 'data');
    save(['..\output\' filename], 'train_input', '-append');
    save(['..\output\' filename], 'train_output', '-append');
    save(['..\output\' filename], 'test_input', '-append');
    save(['..\output\' filename], 'test_output', '-append');
end 
