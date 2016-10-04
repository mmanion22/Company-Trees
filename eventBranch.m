function [treeMatrix,sigMergers] = eventBranch(parent_permco,all_events,important_events,treeMatrix,sigMergers,num3,num4,count)



    %Fills in the rows of the treeMatrix for the parent company (may have
    %more than 1 row b/c each PERMCO may have more than 1 PERMNO)
    temprows = count*ones(size(all_events(all_events(:,2)==parent_permco,:),1),1);
    treeMatrix = [treeMatrix; [temprows,all_events(all_events(:,2)==parent_permco,:)]];
    
    %Creates a table of all instances where a company's NewPERMCO == parent_permco
    child_list = important_events(important_events(:,6)==parent_permco,:);
    child_list = child_list(child_list(:,2)~=parent_permco,:);
    child_list = [child_list(:,3),child_list];
    if (size(child_list,1) > 1);
        child_list = flip(unique(child_list,'rows'));
    end
    child_list = child_list(:,(2:end));
    
    %Determines if any mergers in childlist are significant and adds them to sigMergers if they are
    sigIncrease = 0.10; %Defines a significant increase in assets
    tempKey = num3(num3(:,6)==parent_permco,1);
    tempKey = unique(tempKey);
    if(isempty(child_list) == 0);    
        if (isempty(tempKey) == 0);
            for r=1:size(tempKey);
                tempAssets = num4(num4(:,1)==tempKey(r),:);
                for m=1:size(child_list,1);
                    for q=2:size(tempAssets,1);
                        if (child_list(m,3)<tempAssets(q,3) && child_list(m,3)>=tempAssets(q-1,3));
                            if (tempAssets(q,14) >= sigIncrease);
                                sigMergers = [sigMergers;child_list(m,:)];
                            end
                        end
                    end
                end
            end
        end
    end
    
                    
            
    %Runs recursively on all children
    if(isempty(child_list) == 0);
        for x=1:size(child_list,1);
            if (sum(treeMatrix(:,3)==child_list(x,2))<2);
                [treeMatrix,sigMergers] = eventBranch(child_list(x,2),all_events,important_events,treeMatrix,sigMergers,num3,num4,count+1);
            end
        end
    end
    
   
end





