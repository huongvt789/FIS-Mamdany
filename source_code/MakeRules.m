function centers = MakeRules(full_dataset, train_dataset)
% Input:
% 1. full_dataset: all data records for determining minimum and maximum
% value of each feature
% 2. train_dataset: training dataset for rules generation, train_dataset can be
% the same with full_dataset
%
% Output:
% 1. ruleList: a set of rule
% 2. sigma_M: array of N Sigmas for later use corresponding N featueres
% (Sigma of Label is not in this output)
% 3. centers: array of N centers corresponding N featueres for later use
% (Center of Label is not in this output)
%
% 3 outputs will be saved to FIS_para.mat

addpath('..\input');
full_data = load(['..\input\' full_dataset]);
train_data = load(['..\input\' train_dataset]);
[data_num attribute_num] = size(train_data);
cluster = zeros(1, attribute_num);                  % determine the number of clusters for all attributes
cluster(1) = 2;                                     % add the number of clusters for label
for i=2:attribute_num
    temp = length(unique(train_data(:,i)));
    if temp == 2
        cluster(i) = 2;
    elseif temp == 3
        cluster(i) = 3;
    else
        cluster(i) = 5;
    end
end

m = 2;
esp = 0.01;
maxTest = 200;
center_vector = cell (1, attribute_num);
centers = cell(attribute_num-1, 1);

for feature_index=1:attribute_num
    feature_data = train_data(:,feature_index);
    V = 0;
    min_value = min(full_data(:,feature_index));
    max_value = max(full_data(:,feature_index));
    delta = max_value - min_value;
    if cluster(feature_index) == 2
        V(1,1) = min_value - 0.5;
        V(2,1) = max_value;
    elseif cluster(feature_index) == 3
        V(1,1) = min_value;
        V(2,1) = min_value + delta/2;
        V(3,1) = max_value;
    else
        V(1,1) = min_value;
        V(2,1) = min_value + delta/4;
        V(3,1) = min_value + 2*delta/4;
        V(4,1) = min_value + 3*delta/4;
        V(5,1) = max_value;
    end
    [center,U] = FCM_Function(feature_data,cluster(feature_index),V,m,esp,maxTest);
    U = U';
    center_vector{feature_index}(:,1) = center(:,1);
    for i=1:data_num
        maximum = max(U(i,:));
        for j=1:cluster(feature_index)
            if (maximum == U(i,j))
                rules(i,feature_index) = j;
            end
        end
    end
    if feature_index ~= 1           % Not include center of Label
        center = center';
        centers{feature_index-1} = center(1,:);
    end
end

%Get weight of membership
[t,sigma_M] = RuleWeight(rules, train_data,cluster,center_vector);

%Create sigma_M for FIS
sigma_M(1,:) = [];                  % Remove Sigma of Label
for i=1:(attribute_num-1)
    sigma_M(i,2:5) = sigma_M(i,1);
end

%Get weight for each rule
for i=1:data_num
    rules(i,(attribute_num+1)) = min(t(i,2:attribute_num));
    rules(i,(attribute_num+2)) = train_data(i,1);
end

%Remove weaker or duplicate rules
for i=1:data_num-1
    for j=i+1:data_num
        if(rules(i,2:attribute_num) == rules(j,2:attribute_num))
            if(rules(i,(attribute_num+1)) > rules(j,(attribute_num+1)))
                rules(j,:)=0;
            else
                rules(i,:)=0;
            end
        end
    end
end

%Rules with weight < 0.5 will be removed
for i=1:data_num
    if(rules(i,(attribute_num+1)) < 0.5)
        rules(i,:) = 0;
    end
end

%Filter rules
RuleCheck = zeros(1,(attribute_num+2));
j = 1;
for i=1:data_num
    if (rules(i,:) ~= RuleCheck(1,:))
        FilteredRules(j,:) = rules(i,:);
        j = j + 1;
    end
end
ruleList = FilteredRules(:,1:attribute_num);

filename = strrep(train_dataset,'.txt','.mat');
filename = strrep(filename, 'Database', 'FIS');
addpath('..\output');
save(['..\output\RuleList.mat'], 'ruleList');
save(['..\output\' filename], 'sigma_M');

fprintf('==============================================================================\n');
fprintf('Rule Generation process is done. RuleList.mat created. \n');
fprintf('Running CROSS_VALIDATION.m... \n');
fprintf('==============================================================================\n');