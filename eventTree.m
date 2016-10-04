%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% DELISTING CODES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%     100-199   Active                       %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%     200-299   Mergers                      %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%     300-399   Exchanges                    %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%     400-499   Liquidations                 %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%     500-599   Dropped                      %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%     600-699   Expirations                  %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%     900-999   Domestics Became Foreign     %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%     231       When merged, shareholders primarily receive common stock or ADRs.
%%%%%     233       When merged, shareholders receive cash payments.
%%%%%     241       When merged, shareholders primarily receive common stock and cash, issue on CRSP file.
%%%%%     261       When merged, shareholders primarily receive cash and preferred stock, or warrants, or rights, or debentures, or notes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% It would be good to have a header with things like the objective,
% dependencies, maybe the date and your name just in case

clear
% I like for Matlab to have a home directory, it makes pulling stuff easier
% and makes commands shorter
home = 'R:\Mark M\Matt';
cd(home)

% it might be good to give these more descriptive names, but it's not a huge deal
[all_events,~,raw] = xlsread('All Events 1995-2016.csv','All Events 1995-2016');
[num2,~,raw2] = xlsread('All Names.csv','All Names');
[num3,~,~] = xlsread('CRSP Compustat Link 1995-2016.csv','CRSP Compustat Link 1995-2016');
[num4,~,~] = xlsread('Quarterly Assets.csv','Quarterly Assets');

%Creates a directory of all PERMNO's and PERMCO's
all_ids = all_events(:,(1:2));

%Creates a matrix of all instances when a delisting occurs
all_events_temp = all_events(:,(3:6));
all_events_temp(isnan(all_events_temp)==1) = 0;
[~,unique_index,~] = unique(all_events_temp,'rows','stable');
important_events = all_events(unique_index,:);

%Creates an empty treeMatrix that will be added to in the function        
treeMatrixBlank = NaN(0,size(all_events,2)+1);
sigMergersBlank = NaN(0,size(all_events,2));

%Initialize list of permcos we care about
permco_list = [7 54287 20017 41871 137 29870 216 15473 20204 20684 90,...
    20315 3151 20277 11112 20265 36336 20331 540 20483 20408,...
    20473 43613 30513 21401 7882 10486 21185 20440 20606 20587,...
    20597 20557 20608 16285 8093 20643 21396 20750 54084 20763,...
    1685 21287 20791 20792 11300 53554 45483 35048 20868 5085,...
    22168 20990 2367 21018 20436 20468 21102 21110 2709 50700,...
    21177 41680 2850 37138 21205 21398 40148 21188 21224 8048,...
    3194 31769 8045 21322 21384 21394 21446 52978 11253 21492,...
    11592 21576 21640 30086 21645 20561 11412 21737 7267 21810,...
    36383 1645 21832 52983 20288 21881 21305 21880 20678];

%No need to assign these every loop
%File destination and suffix
folder = 'R:\Mark M\Matt\Company Trees\S&P 100\';
type = ' Tree.csv';
%variable a is a matrix that corresponds to raw cell data from Names file
a = [NaN(1,7);num2];
for n=1:size(permco_list,2);
    %this comment didn't really make sense here, maybe before the loop, and
    %also some extra about the loop could be helpful
    [treeMatrix,sigMergers] = eventBranch(permco_list(n),all_events,important_events,treeMatrixBlank,sigMergersBlank,num3,num4,0);

    %Converts tree to cell and adds extra columns for name and share class variables
    treeMatrix = num2cell(treeMatrix);
    treeMatrix = [treeMatrix,cell(size(treeMatrix,1),2)];

    %adds most recent name and share class for each PERMNO the tree
    for j=1:size(treeMatrix,1);
        name_list = raw2(a(:,5)==cell2mat(treeMatrix(j,2)),:);
        recent_name = name_list(cell2mat(name_list(:,1))==max(cell2mat(name_list(:,1))),2);
        recent_class = name_list(cell2mat(name_list(:,1))==max(cell2mat(name_list(:,1))),4);
        treeMatrix(j,(8:9)) = [recent_name, recent_class];
    end

    %re-orders columns and adds titles
    treeMatrix = [treeMatrix(:,1),treeMatrix(:,8),treeMatrix(:,(2:3)),treeMatrix(:,9),treeMatrix(:,(4:7))];
    treeMatrix = [{'Branch','Recent Name','PERMNO','PERMCO','Share Class','Delist Date','Delist Code','NewPERMNO','NewPERMCO',};treeMatrix];
    
    %adds the column for significant mergers
    treeMatrix = [treeMatrix,num2cell(zeros(size(treeMatrix,1),1))];
    for z=2:size(treeMatrix,1);
        treeMatrix(z,10) = {sum(sigMergers(:,1)==cell2mat(treeMatrix(z,3)))>0};
    end
    treeMatrix(1,10) = {'Significant Merger'};
    
    %adds the column for whether a GVKEY link exists
    treeMatrix = [treeMatrix,num2cell(ones(size(treeMatrix,1),1))];
    for b=2:size(treeMatrix,1);
        tempKey = unique(num3(num3(:,6)==cell2mat(treeMatrix(b,4)),1));
        if (isempty(tempKey) == 1);
            treeMatrix(b,11) = {0};
        end
    end
    treeMatrix(1,11) = {'GVKEY Link Exists'};
    
    %Gets most recent name of parent-PERMCO company for naming the file
    parent_list = treeMatrix((2:end),:);
    parent_list = parent_list(cell2mat(parent_list(:,4))==permco_list(n),:);
    max_date = max(cell2mat(parent_list(:,6)));
    parent_name = cell2mat(parent_list(cell2mat(parent_list(:,6))==max(cell2mat(parent_list(:,6))),2));
    if (size(parent_name,1)>1);
        parent_name = parent_name(1,:);
    end
    
    % write to excel (could you do a CSV here? it's faster)
    xlswrite([folder,parent_name,type],treeMatrix);
    
end
