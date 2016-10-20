%% 2009 -12 AA
% creating a virtual room using parameters (room) set in setExperimentPars.m
% such as room size and base distance and radius.

% 2010-05 AA: introduced an option of drawing bases randomly to the right
% or the left of the room. OPT1 =0 central bases OPT1 = 1 randomized side
% bases. Default = 0;

% 2011-11 MK: rewriting the code for the T-maze construction


function Room = getRoomData (Exp)


%% main room related

% x-y-z coordinates of vertices in 3D mouse room
% x<0 to the left of origin
% y<0 below the origin
% z<0 farther away from origin

x1=Exp.corridorWidth/2;
x2=Exp.roomWidth/2;
z1=Exp.roomLength-Exp.corridorWidth;
z2=Exp.roomLength;
yf=-1*Exp.roomHeight; % floor coordinate
yc=2*Exp.roomHeight; % ceiling coordinate

txFactor=100;
txFloorFactor=400;

v= [-x1 yf 0;... % these are vertices of the beginning plane
    -x1 yc 0;...
    x1 yc 0;...
    x1 yf 0;...
    
    -x1 yf -z1;... % end-of-corridor plane
    -x1 yc -z1;...
    x1 yc -z1;...
    x1 yf -z1;...
    
    -x2 yf -z1;... % end-of-corridor plane - far vertices
    -x2 yc -z1;...
    x2 yc -z1;...
    x2 yf -z1;...
    
    -x2 yf -z2;... % back wall plane
    -x2 yc -z2;...
    x2 yc -z2;...
    x2 yf -z2;...

    -x1 yf -z2;... % small back wall plane (only in front of the main corridor)
    -x1 yc -z2;...
    x1 yc -z2;...
    x1 yf -z2;...

    -x1 yf -z2;... % COPY OF small back wall plane (only in front of the main corridor)
    -x1 yc -z2;...
    x1 yc -z2;...
    x1 yf -z2];
v=v';

% vStim= [-x1, yf, -z2-1;...% left side stimulus
%     -3*x1, yf, -z2-1;...
%     -3*x1, 3*yc, -z2-1;...
%     -x1, 3*yc, -z2-1;...
%     
%     x1, yf, -z2-1;...% right side stimulus
%     3*x1, yf, -z2-1;...
%     3*x1, 3*yc, -z2-1;...
%     x1, 3*yc, -z2-1];
% vStim=vStim';

% clockwise (determines the fromt of a wall) order of vertices of
% rectangular walls

order= [4 3 2 1;... % start wall
    1 2 6 5;... % left corridor wall
    8 7 3 4;... % right corridor wall
    5 6 10 9;... % left branch back wall
    12 11 7 8;... % right branch back wall
    9 10 14 13;... % left branch end wall
    16 15 11 12;... % right branch end wall
    13 14 18 17;...   % back wall (left part)
    21 22 23 24;...   % back wall (central part)
    20 19 15 16;...   % back wall (right part)
    9 13 16 12;...   % side corridor floor
    1 5 8 4;...   % main corridor floor
    2 6 7 3;...   % main corridor ceiling
    10 14 15 11];   % side corridor ceiling

Room.nOfWalls = size(order, 1); 

% now defining the texture coordinates for every vertex (x,y pairs)
wrapVertices= [...
    x1 yf;... 
    x1 yc;... 
    -x1 yc;... 
    -x1 yf;... 
    x1+z1 yf;... 
    x1+z1 yc;... 
    -x1-z1 yc;... 
    -x1-z1 yf;... 
    x2+z1 yf;... 
    x2+z1 yc;... 
    -x2-z1 yc;... 
    -x2-z1 yf;... 
    x2+z2 yf;... 
    x2+z2 yc;... 
    -x2-z2 yc;... 
    -x2-z2 yf;... 
    2*x2-x1+z2 yf;... 
    2*x2-x1+z2 yc;... 
    -2*x2+x1-z2 yc;... 
    -2*x2+x1-z2 yf;... 
    ];

% new version
wrapVertices= [...
    x1 yf;... 
    x1 yc;... 
    4*x2-x1+2*z2 yc;... 
    4*x2-x1+2*z2 yf;... 
    x1+z1 yf;... 
    x1+z1 yc;... 
    4*x2-x1+2*z2-z1 yc;... 
    4*x2-x1+2*z2-z1 yf;... 
    x2+z1 yf;... 
    x2+z1 yc;... 
    3*x2+2*z2-z1 yc;... 
    3*x2+2*z2-z1 yf;... 
    x2+z2 yf;... 
    x2+z2 yc;... 
    3*x2+z2 yc;... 
    3*x2+z2 yf;... 
    2*x2-x1+z2 yf;... 
    2*x2-x1+z2 yc;... 
    2*x2+x1+z2 yc;... 
    2*x2+x1+z2 yf;... 
    ];

% newest version
% to make the stimulus identical on both side and without sharp edges
% the grating will start now from vertices 17-18 on the left
% and from vertices 19-20 on the right with gray value (so that there is no
% sharp edge) and will flow to vertices 1-2 on the left and 3-4 on the
% right
wrapVertices= [...
    2*(x2-x1)+z2 yf;... 
    2*(x2-x1)+z2 yc;... 
    2*(x2-x1)+z2 yc;... 
    2*(x2-x1)+z2 yf;... 
    2*(x2-x1)+z2-z1 yf;... 
    2*(x2-x1)+z2-z1 yc;... 
    2*(x2-x1)+z2-z1 yc;... 
    2*(x2-x1)+z2-z1 yf;... 
    (x2-x1)+z2-z1 yf;... 
    (x2-x1)+z2-z1 yc;... 
    (x2-x1)+z2-z1 yc;... 
    (x2-x1)+z2-z1 yf;... 
    x2-x1 yf;... 
    x2-x1 yc;... 
    x2-x1 yc;... 
    x2-x1 yf;... 
    0 yf;... 
    0 yc;... 
    0 yc;... 
    0 yf;... 
    -x1 yf;... 
    -x1 yc;... 
    x1 yc;... 
    x1 yf;... 
    ];


wrapVertices=wrapVertices/txFactor;

wrap=cell(Room.nOfWalls, 1);
% this is for the walls' textures
for iWall=1:length(wrap)-4
    wrap{iWall}=[];
    for iVertex=1:4
        wrap{iWall}=[wrap{iWall}; wrapVertices(order(iWall, iVertex), :)];
    end
end
% !!! Correction for the back wall need to be inserted !!!
% here is the correction:
% bckInd=8; % index for the back wall
% wrap{bckInd}(3, :)=wrap{bckInd}(2, :)+[2*x2, 0]/txFactor;
% wrap{bckInd}(4, :)=wrap{bckInd}(1, :)+[2*x2, 0]/txFactor;

% now tiling the floor and the ceiling
for iWall=Room.nOfWalls-3:Room.nOfWalls
    wrap{iWall}=[];
    for iVertex=1:4
%         v([1, 3], order(iWall, iVertex));
        wrap{iWall}=[wrap{iWall}; v([1, 3], order(iWall, iVertex))'/txFloorFactor];
    end
end


% orderStim=[1 2 3 4;...
%     8 7 6 5];
% plotting for debugging purposes
% orderCirc=[order, order(:,1)];
% for iWall=1:Room.nOfWalls
%     plot3(v(1, orderCirc(iWall, :)), v(2, orderCirc(iWall, :)), -v(3, orderCirc(iWall, :)));
%     hold on;
% end
% xlabel('x');
% ylabel('y');
% zlabel('-z');
% axis equal

% wrapX = Exp.roomWidth/300;
% wrapY = Exp.roomHeight/300;
% wrapZ = Exp.roomLength/300;


%Room.wrap(Room.wrap<1)=1;

Room.normals = [];
for i=1:Room.nOfWalls
    
    n = cross((v(:,order(i,2))-v(:,order(i,1))),(v(:,order(i,3))-v(:,order(i,2))));
%     n = n./sqrt(n(1)^2+n(2)^2+n(3)^2);
    n = n./norm(n);    
    Room.normals = [Room.normals; n'];
end

% Room.normalsStim=[];
% for i=1:size(orderStim, 1)
%     
%     n = cross((vStim(:,orderStim(i,2))-vStim(:,orderStim(i,1))),(vStim(:,orderStim(i,3))-vStim(:,orderStim(i,2))));
% %     n = n./sqrt(n(1)^2+n(2)^2+n(3)^2);
%     n = n./norm(n);    
%     Room.normalsStim = [Room.normalsStim; n'];
% end

% room size is 2*width, 2*height, 1*length
% I choose to have coordinates of the room as follows:
% -width<x<width -height<y<height -length<z<0


% v(1,:) = v(1,:)*Exp.roomWidth;
% v(2,:) = v(2,:)*Exp.roomHeight;
% v(3,:) = v(3,:)*Exp.roomLength;

Room.v = v;
Room.order = order;
Room.wrap=wrap;
% Room.textures=textures;
% Room.vStim=vStim;
% Room.orderStim=orderStim;

end


