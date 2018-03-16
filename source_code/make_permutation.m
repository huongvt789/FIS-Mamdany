function permutation=make_permutation(old_arr)
    data_num=length(old_arr);
    for i=1:data_num
        index=1+floor(data_num*rand()-0.1);
        while index < 1
            index=1+floor(data_num*rand()-0.1);
        end
        temp=old_arr(i);
        old_arr(i)=old_arr(index);
        old_arr(index)=temp;
    end
    permutation=old_arr;
end