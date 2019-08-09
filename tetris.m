% Initialize

global piece pieces_types all_pieces running interface plane max_column max_row 
max_row = 23; max_column = 15; 
plane = zeros(max_row,max_column); 
interface = figure; initialize_window();
load_pieces();
running = true;

% Game loop

generate_a_piece();
while running
	move();
	pause(0.5);
	game_over();
end

clear_memory();
disp("Game Over!");


%	_________________
%
%	Functions Section
%	_________________
%

function initialize_window()
	global plane interface

	set(interface,'NumberTitle','off',...
	'Name','Tetris',...
	'MenuBar','none',...
	'KeyPressFcn',@direction,...
	'CloseRequestFcn',@game_exit,...
	'position',[200 200 360 520],...
	'CurrentObject',imagesc(plane));
	axis off

end

function render()
	global plane interface

	set(interface,'CurrentObject',imagesc(plane));
	axis off

end

function load_pieces()
	global pieces_types all_pieces

	pieces_types = struct('long_flat',[2,2,2,2,2],...
	'left_l',[0,2; 0,2; 2,2],...
	'right_l',[2,0; 2,0; 2,2],...
	'left_zig',[0,2,2; 2,2,0],...
	'right_zig',[2,2,0; 0,2,2],...
	'shooter',[0,2,0; 2,2,2],...
	'square',[2,2; 2,2],...
	'left_corner',[0,2; 2,2],...
	'right_corner',[2,0; 2,2]);
	all_pieces = {'long_flat','left_l','right_l','left_zig','right_zig','square','shooter','left_corner','right_corner'};

end

function game_exit(~,evt)
	global running

	running = false;
	delete(gcf);
	return;
	
end

function clear_memory()
	clear all
	clc
end

function ans =member(a,b)
	ans = find(ismember(a,b));
end

function ans = empty(a,b)
	ans = isempty(member(a,b));
end

function generate_a_piece()
	global plane piece pieces_types all_pieces max_column

	piece = pieces_types.(string(all_pieces(randi(9))));
	centre = floor(floor(max_column/2)-size(piece,2)/2)+1;
	for a = 1:1:size(piece,1)
		for b = 1:1:size(piece,2)
			plane(a,b+centre) = piece(a,b);
			if plane(a,b+centre) > 2
				plane(a,b+centre) = 1;
			end
		end
	end
	render();
	
end

function move()
	global plane max_column max_row

	full_row();
	initial = member(plane,2);
	final = initial+1;
	border = [max_row:max_row:max_column*max_row];
	if ismember(initial,border) == 0
		if ~empty(plane(final),1)
			plane(member(plane,2)) = 1;
			generate_a_piece();
		else
			plane(initial) = 0;
			plane(final) = 2;
		end
	else
		plane(member(plane,2)) = 1;
		generate_a_piece();
	end
	render();

end

function direction(~,evt)
	global piece plane max_column max_row

	k = evt.Key;
	switch k
		case 'uparrow'
			piece = rot90(piece);
			halt = false;
			topl = member(plane,2);
			shift_h = 0;
			shift_v = 0;

			if ~empty(size(piece),5)
				[topl_x,topl_y] = ind2sub([max_row,max_column],topl(3));
				if topl(2)-topl(1) == 1
					shift_h =-2;
					shift_v =-1;
				else
					shift_h = 0;
				end
			else
				[topl_x,topl_y] = ind2sub([max_row,max_column],topl(1));
			end

			for a = topl_x:1:size(piece,1)+topl_x-1
				for b = topl_y:1:size(piece,2)+topl_y-1
					if a > size(plane,1) || b > size(plane,2)
						halt = true;
						break
					elseif plane(a+shift_v,b+shift_h) == 1
						halt = true;
					end
				end
			end

			if ~halt
				plane(ismember(plane,2)) = 0;

				for a = topl_x:1:size(piece,1)+topl_x-1
					for b = topl_y:1:size(piece,2)+topl_y-1
						plane(a+shift_v,b+shift_h) = piece(a-topl_x+1,b-topl_y+1);
					end
				end
			end
		case 'leftarrow'
			arrow_key(-1);
		case 'rightarrow'
			arrow_key(1);
		case 'downarrow'
			move();
	end
	render();

end

function arrow_key(k);
	global max_row max_column plane

	if k > 0
		border = [max_row*(max_column-1)+1:1:max_column*max_row];
	else
		border = [1:1:max_row];
	end

	initial = member(plane,2);
	final = initial+k*max_row;

	if ismember(initial,border) == 0 & empty(plane(final),1) ~= 0
		plane(initial) = 0;
		plane(final) = 2;
	end
end

function full_row()
	global plane max_column max_row

	for n = 1:1:max_row
		if plane(n,:) == ones(1,max_column)
			plane(1:n,:) = [zeros(1,max_column); plane(1:n-1,:)];
			pause(0.1);
		end
	end
	render();

end

function game_over();
	global plane
	
	if empty(plane(2,:),1) ~= 1
		game_exit();
	end
end