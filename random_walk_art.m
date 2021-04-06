% Allow user to input size of image, color map, directory to save image
close all
clearvars

prompt = {'Enter size of box region (x, y)',...
    'Enter colormap name (See https://www.mathworks.com/help/matlab/ref/colormap.html for list)',...
    'Invert color map (y or n)',...
    'Enter line thickness',...
    'Background color as normalized RGB triplet',...
    'Path of directory to save image',...
    'Resolution of image in dpi'};
dlgtitle = 'Required Inputs';
dims = [1 67];
definput = {'200, 150','hsv','n','1','0 0 0','~/Desktop/','300'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

axis_dim = str2num(answer{1});
color_map = answer{2};
if isequal(answer{3},'y')
    invert_cm=1;
else
    invert_cm=0;
end
thickness = str2num(answer{4})*0.5;
backgrd_color=str2num(answer{5});
dir = answer{6};
res = answer{7};

clearvars dlgtitle dims definput prompt answer

fig=figure('Visible', 'off');

% Determine the number of walkers and how many steps each will take.
area_of_image = axis_dim(1)*axis_dim(2);
max_walkers = ceil((area_of_image)^(1/2.2));
max_steps = area_of_image/max_walkers*floor(log10(area_of_image));


% Generate size and inversion of colormap
if invert_cm == 1
    cm = flipud(colormap([color_map,'(',num2str(max_walkers),')']));
else
    cm = colormap([color_map,'(',num2str(max_walkers),')']);
end

% Possible new locations surrounding the current location
% Do not allow for diagonal steps later, but here for convience
step = [[-1 -1];[0 -1];[1 -1];[-1 0];[0 0];[1 0];[-1 1];[0 1];[1 1]];


% Add two to each dimension for ease in calculation. True walking region is
%   centered in the matrix (i.e., one extra column and row at both ends).
walker_matrix = zeros(axis_dim+2);
walker_matrix(:,1)=1;
walker_matrix(1,:)=1;
walker_matrix(:,axis_dim(2)+2)=1;
walker_matrix(axis_dim(1)+2,:)=1;

% Walkers will start away from an edge and will stop once they reach an
%   edge. They will also not be allowed to walk on a location that has
%   previously been walked by a different walker.
% Begin random walk
for i = 1:max_walkers
    
    % Each walker must start away from the edge at a location not having
    %   already been walked
    starting_loc=find(walker_matrix == 0);
    [startx,starty]=ind2sub(size(walker_matrix),starting_loc(ceil(rand*length(starting_loc))));
    start=[startx,starty];
    current_loc = start;
    walking_path = current_loc;
    
    % Walker will now walk till they can take no more steps
    for j = 1:max_steps
        
        % Select neighboring locations that the walker can travel to speed
        %   up process. Also do not allow walker to stand still.
        neighbor_loc = find(walker_matrix(current_loc(1)-1:current_loc(1)+1,current_loc(2)-1:current_loc(2)+1) == 0);
        % Odd locations will be diagonals and current location
        neighbor_loc = neighbor_loc(mod(neighbor_loc,2) == 0);
        
        % If at an edge, do not allow to walk out of walking region.
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
                 
        current_loc = new_loc;
        walking_path = [walking_path; current_loc];
    end
    
    % Record locations walker has walked
    for j = 1:size(walking_path,1)
        walker_matrix(walking_path(j,1),walking_path(j,2)) = 1;
    end
    
    % Plot the walked path
    hold on
    plot(walking_path(:,1),walking_path(:,2),'Color',cm(i,:),'LineWidth',thickness)
    
    clearvars walking_path
end

% Clean up figure layout for saving
resolution=['-r',res];
set(gca,'XColor', 'none','YColor','none','Position',[0 0 1 1],'Xlim',[1 axis_dim(1)+2],'Ylim',[1 axis_dim(2)+2],'Color',backgrd_color)
set(gcf,'Color',backgrd_color,'InvertHardCopy', 'off','Position',  [0, 1000, axis_dim(1), axis_dim(2)])
print(fig,[dir,'Random_walk_art.png'],'-dpng',resolution)