% Allow user to input size of image, color map, directory to save image
close all
clearvars

prompt = {'Enter size of image (x, y):',...
    'Enter colormap name (See https://www.mathworks.com/help/matlab/ref/colormap.html for list):',...
    'Path of directory to save image:'};
dlgtitle = 'Required Inputs';
dims = [1 67];
definput = {'80, 60','hsv','~/Desktop/'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

axis_dim=flip(str2num(answer{1}));
color_map=answer{2};
cm=colormap(color_map);
dir=answer{3};

clearvars dlgtitle dims definput prompt answer


% Begin random walk
% Walkers will start away from an edge and will stop once they reach an
%   edge. They will also not be allowed to walk on a location that has
%   previously been walked by a different walker.

area_of_image=axis_dim(1)*axis_dim(2);
max_steps=area_of_image;
max_walkers=ceil(sqrt(area_of_image));
walker=1;
temp=1;
cm_num=1;
if max_walkers < length(cm)
    cm_scale=length(cm)/max_walkers;
else
    cm_scale=1;
end
step=[[-1 -1];[0 -1];[1 -1];[-1 0];[0 0];[1 0];[-1 1];[0 1];[1 1]];


% Add two to each dimension for ease in calculation. True walking region is
%   centered in the matrix (i.e., one extra column and row at both ends).
walker_matrix=zeros(axis_dim+2);
for i=1:max_walkers
    % Each walker must start away from the edge at a location not having
    %   already been walked
    start=[ceil(rand*(axis_dim(1)-3))+3,ceil(rand*(axis_dim(2)-3))+3];
    while walker_matrix(start(1),start(2)) ~= 0
        start=[ceil(rand*(axis_dim(1)-3))+3,ceil(rand*(axis_dim(2)-3))+3];
    end
    current_loc=start;
    walking_path=current_loc;
    
    % Walker will now walk till they can take no more steps or reach an
    %   edge
    for j=1:max_steps
        
        % Select neighboring locations that the walker can travel to speed
        %   up process. Also do not allow walker to stand still.
        neighbor_loc=find(walker_matrix(current_loc(1)-1:current_loc(1)+1,current_loc(2)-1:current_loc(2)+1) == 0);
        neighbor_loc=neighbor_loc(neighbor_loc ~= 5);
        
        if isempty(neighbor_loc) 
            break
        end
        
        % Pick one of the open neighboring cells to step to.
        step_loc=ceil(rand*length(neighbor_loc));
        new_loc=current_loc+step(neighbor_loc(step_loc),:);
        
        % Stop the walker if they exit the walking region
        if new_loc(1) < 2 || new_loc(2) < 2 || new_loc(1) > axis_dim(1)-1 || new_loc(2) > axis_dim(2)-1
            break
        end
        
%         % If the walker steps onto a previously walked space by a different
%         %   walker, then try stepping somewhere else.
%         while walker_matrix(new_loc(1),new_loc(2)) ~= 0
%             step_loc=ceil(rand*length(neighbor_loc));
%             new_loc=current_loc+step(neighbor_loc(step_loc),:);
%             if new_loc(1) < 1 || new_loc(2) < 1 || new_loc(1) > axis_dim(1) || new_loc(2) > axis_dim(2)
%                 break
%             end
%         end
%         if new_loc(1) < 1 || new_loc(2) < 1 || new_loc(1) > axis_dim(1) || new_loc(2) > axis_dim(2)
%             break
%         end
        current_loc=new_loc;
        walking_path=[walking_path;current_loc];
    end
    
    for j=1:size(walking_path,1)
        walker_matrix(walking_path(j,1),walking_path(j,2))=walker;
    end
    
    % Plot the walked path
    hold on
    plot(walking_path(:,1),walking_path(:,2),'Color',cm(ceil(cm_num*cm_scale),:))
    cm_num=cm_num+1;
    if mod(i,length(cm)) == 0
        cm_num=1;
    end
    
    walker=walker+1;
    clearvars walking_path
end

% Clean up figure layout for saving
set(gca,'XColor', 'none','YColor','none','Position',[0 0 1 1],'Xlim',[1 axis_dim(1)],'Ylim',[1 axis_dim(2)])
%set(gcf, 'Position',  [100, 100, 2000, 1500])
saveas(gcf,[dir,'Random_walk_art.png'])
