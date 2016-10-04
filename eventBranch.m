%It would be nice to have an overview here of what this function actually
%does and how it does it
function [treeMatrix,sigMergers] = eventBranch(parent_permco,all_events,important_events,treeMatrix,sigMergers,num3,num4,count)



    %Fills in the rows of the treeMatrix for the parent company (may have
    %more than 1 row b/c each PERMCO may have more than 1 PERMNO)
    temprows = count*ones(size(all_events(all_events(:,2)==parent_permco,:),1),1);
    treeMatrix = [treeMatrix; [temprows,all_events(all_events(:,2)==parent_permco,:)]];
    
    %Creates a table of all instances where a company's NewPERMCO == parent_permco
    child_list = important_events(important_events(:,6)==parent_permco,:);
    child_list = child_list(child_list(:,2)~=parent_permco,:);
    child_list = [child_list(:,3),child_list];
    % Explanation here would be useful
    if (size(child_list,1) > 1);
        child_list = flip(unique(child_list,'rows'));
    end
    child_list = child_list(:,(2:end));
    
    %Determines if any mergers in childlist are significant and adds them to sigMergers if they are
    % maybe this could be another variable that you pass into the function?
    sigIncrease = 0.10; %Defines a significant increase in assets
    tempKey = unique(num3(num3(:,6)==parent_permco,1));
    % some more explanation of this condition/for loop could be helpful
    if ~isempty(child_list) && ~isempty(tempKey);
        for r=1:size(tempKey,1);
            tempAssets = num4(num4(:,1)==tempKey(r),:);
            % it seems like there has to be a faster way to do this than
            % looping over all possiblities, nested for loops should be
            % avoided as much as possible (although this is pretty quick so
            % it's not a huge deal)
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
    
                    
            
    %Runs recursively on all children
    if(isempty(child_list) == 0);
        for x=1:size(child_list,1);
            if (sum(treeMatrix(:,3)==child_list(x,2))<2);
                [treeMatrix,sigMergers] = eventBranch(child_list(x,2),all_events,important_events,treeMatrix,sigMergers,num3,num4,count+1);
            end
        end
    end
    
   
end

