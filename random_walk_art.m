% Allow user to input size of image, color map, directory to save image
close all
clear all

prompt = {'Enter size of box region (x, y)',...
    'Enter colormap name (See https://www.mathworks.com/help/matlab/ref/colormap.html for list)',...
    'Invert color map (y or n)',...
    'Background color as normalized RGB triplet',...
    'Path of directory to save image',...
    'Resolution of image in dpi'};
dlgtitle = 'Required Inputs';
dims = [1 67];
definput = {'200, 150','hsv','n','0 0 0','~/Desktop/','300'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

axis_dim = str2num(answer{1});
color_map = answer{2};
if isequal(answer{3},'y')
    cm = flipud(colormap(color_map));
else
    cm = colormap(color_map);
end
backgrd_color=str2num(answer{4});
dir = answer{5};
res = answer{6};

clearvars dlgtitle dims definput prompt answer

fig=figure(1);


% Walkers will start away from an edge and will stop once they reach an
%   edge. They will also not be allowed to walk on a location that has
%   previously been walked by a different walker.
area_of_image = axis_dim(1)*axis_dim(2);
max_walkers = min([ceil(sqrt(area_of_image)), 64]);
max_steps = area_of_image/max_walkers*ceil(log10(area_of_image));
walker = 1;
cm_num = 1;
if max_walkers < length(cm)
    cm_scale = length(cm)/max_walkers;
else
    cm_scale = 1;
end

% Possible new locations surrounding the current location
% Do not allow for diagonal steps later, but here for convience
step = [[-1 -1];[0 -1];[1 -1];[-1 0];[0 0];[1 0];[-1 1];[0 1];[1 1]];


% Add two to each dimension for ease in calculation. True walking region is
%   centered in the matrix (i.e., one extra column and row at both ends).
walker_matrix = zeros(axis_dim+2);
walker_matrix(:,1)=-1;
walker_matrix(1,:)=-1;
walker_matrix(:,axis_dim(2)+2)=-1;
walker_matrix(axis_dim(1)+2,:)=-1;

% Begin random walk
for i = 1:max_walkers
    
    % Each walker must start away from the edge at a location not having
    %   already been walked
    starting_loc=find(walker_matrix == 0);
    [startx,starty]=ind2sub(size(walker_matrix),starting_loc(ceil(rand*length(starting_loc))));
    start=[startx,starty];
    current_loc = start;
    walking_path = current_loc;
    
    % Walker will now walk till they can take no more steps or reach an
    %   edge
    for j = 1:max_steps
        
        % Select neighboring locations that the walker can travel to speed
        %   up process. Also do not allow walker to stand still.
        neighbor_loc = find(walker_matrix(current_loc(1)-1:current_loc(1)+1,current_loc(2)-1:current_loc(2)+1) == 0);
        neighbor_loc = neighbor_loc(mod(neighbor_loc,2) == 0);
        
        % If at an edge, do not allow to walk out of walking region
        if current_loc(1)-1 == 1
            neighbor_loc = neighbor_loc(neighbor_loc ~= 4);
        end
        if current_loc(2)-1 == 1
            neighbor_loc = neighbor_loc(neighbor_loc ~= 2);
        end
        if current_loc(1)+1 == axis_dim(1)+2
            neighbor_loc = neighbor_loc(neighbor_loc ~= 6);
        end
        if current_loc(2)+1 == axis_dim(2)+2
            neighbor_loc = neighbor_loc(neighbor_loc ~= 8);
        end
        
        % If the walker cannot take a step, then end their walk
        if isempty(neighbor_loc) 
            break
        end
        
        % Pick one of the open neighboring cells and step to it.
        step_loc = ceil(rand * length(neighbor_loc));
        new_loc = current_loc + step(neighbor_loc(step_loc),:);
         
        % Stop the walker if they exit the walking region
%         if new_loc(1) < 2 || new_loc(2) < 2 || new_loc(1) > axis_dim(1)-1 || new_loc(2) > axis_dim(2)-1
%             bread
%         end
        
        current_loc = new_loc;
        walking_path = [walking_path; current_loc];
    end
    
    % Record locations walker has walked
    for j = 1:size(walking_path,1)
        walker_matrix(walking_path(j,1),walking_path(j,2)) = walker;
    end
    
    % Plot the walked path
    hold on
    plot(walking_path(:,1),walking_path(:,2),'Color',cm(ceil(cm_num*cm_scale),:))
    cm_num = cm_num + 1;
    
    walker = walker + 1;
    clearvars walking_path
end

% Clean up figure layout for saving
resolution=['-r',res];
set(gca,'XColor', 'none','YColor','none','Position',[0 0 1 1],'Xlim',[1 axis_dim(1)+2],'Ylim',[1 axis_dim(2)+2],'Color',backgrd_color)
set(gcf,'Color',backgrd_color,'InvertHardCopy', 'off')
print(fig,[dir,'Random_walk_art.png'],'-dpng',resolution)