% FEM Sample Truss

% Clear Command Window and Workspace
clear all, clc;

% Knowns
P = -17;
E = 10.392e+09;
A = 0.01524*0.001588;
L = [0.05; 0.07; 0.16; 0.15; 0.11; 0.16; 0.11; 0.16; 0.07]; %L array is hand calculated befrore simulation.
n = {[0,1], [0,2], [0,3], [1,3], [2,3], [2,4], [3,4], [3,5], [4,5]}; 
theata = [pi/2; atan(-1/7); atan(6/15); atan(1/15); atan(7/8); 0; atan(7/-8); atan(-6/15); atan(1/7)]; %theata array is hand calculated befrore simulation.

% K coeffients
k = E.*A./L;

% Generate K Matricies
C = cos(theata);
S = sin(theata);
CS = C.*S; %".*" is a known function in matlab which multiplies matrix C and S element by element and returns the result in CS

% Matrices needed to solve for forces and displacements
tempF = [0; 0; 0; 0; 0; 0; 0; 0; P];


ts(4, 4, 9) = 0;

for i=1:9
    ts(:, :, i) = k(i)*[ C(i)^2, CS(i), -C(i)^2, -CS(i);
                        CS(i), S(i)^2, -CS(i), -S(i)^2;
                       -C(i)^2, -CS(i), C(i)^2, CS(i);
                       -CS(i), -S(i)^2, CS(i), S(i)^2];
end

ke(12,12,9) = 0;

%making all the matrices into 18x18 for addition
for i=1:9
    %Top left
    ke((n{i}(1)+1)*2-1 : (n{i}(1)+1)*2,(n{i}(1)+1)*2-1 : (n{i}(1)+1)*2 ,i) = ts(1:2, 1:2, i);
    %Bottom Left
    ke((n{i}(1)+1)*2-1 : (n{i}(1)+1)*2,(n{i}(2)+1)*2-1 : (n{i}(2)+1)*2, i) = ts(1:2, 3:4, i);
    %Top Right
    ke((n{i}(2)+1)*2-1 : (n{i}(2)+1)*2,(n{i}(1)+1)*2-1 : (n{i}(1)+1)*2 ,i) = ts(3:4, 1:2, i);
    %Bottom Left
    ke((n{i}(2)+1)*2-1 : (n{i}(2)+1)*2,(n{i}(2)+1)*2-1 : (n{i}(2)+1)*2, i) = ts(3:4, 3:4, i);  
end

K1 = ke(:,:,1);
K2 = ke(:,:,2);
K3 = ke(:,:,3);
K4 = ke(:,:,4);
K5 = ke(:,:,5);
K6 = ke(:,:,6);
K7 = ke(:,:,7);
K8 = ke(:,:,8);
K9 = ke(:,:,9);
K = K1 + K2 + K3 + K4 + K5 + K6 + K7 + K8 + K9;

u = [K(2, 2), K(2, 5:12); K(5,2), K(5, 5:12); K(6, 2), K(6, 5:12); K(7, 2), K(7, 5:12); K(8,2), K(8, 5:12); K(9,2), K(9, 5:12);K(10,2), K(10, 5:12);K(11,2), K(11, 5:12);K(12,2), K(12, 5:12) ]\tempF;

U = [0; u(1); 0; 0; u(2); u(3); u(4); u(5); u(6); u(7); u(8); u(9)];

F = K * U;

Fe = zeros(9, 1);

for i=1:9
    Fe(i) = k(i)*((U((n{i}(2)+1)*2-1)-U((n{i}(1)+1)*2-1))*C(i)+(U((n{i}(2)+1)*2)-U((n{i}(1)+1)*2))*S(i))
end

fprintf('Nodal Displacements:\n');
j = 1;
for i = 1:2:length(U)
    fprintf('u%ix = %.9f m\n', j, U(i));
    fprintf('u%iy = %.9f m\n', j, U(i+1));
    j = j+1;
end

fprintf('\nNodal Forces:\n');
j = 1;
for i = 1:2:length(F)
    fprintf('f%ix = %.3f N\n', j, F(i));
    fprintf('f%iy = %.3f N\n', j, F(i+1));
    j = j+1;
end

fprintf('\nMember Forces:\n');
for i = 1:length(Fe)
    fprintf('f(%i) = %.3f N\n', i, Fe(i));
end


% % Solve member forces
% fe1 = k(1) * ((U(3)-U(1))*C(1) + (U(4)-U(2))*S(1));
% fe2 = k(2) * ((U(5)-U(3))*C(2) + (U(6)-U(4))*S(2));
% fe3 = k(3) * ((U(5)-U(2))*C(3) + (U(6)-U(1))*S(3));

% u = [K(3,3), K(3,5:6); K(5,3), K(5,5:6); K(6,3), K(6,5:6)] \ [0; P; 0];
% t = zeroes(18);
% for i=1:9
%     k{i} = zero(18);
%     for j=1:2 % for node 1
% 
%             t((n{i}(1)+1)*2-1,(n{i}(1)+1)*2-1) = C(i)^2;
%             t((n{i}(1)+1)*2,(n{i}(1)+1)*2-1) = CS(i);
%             
%             t((n{i}(1)+1)*2-1,(n{i}(1)+1)*2) = CS(1);
%             t((n{i}(1)+1)*2,(n{i}(1)+1)*2) = S(1)^2;
%  
%         
%         
%     end
%     
% 
% 
% end
% Calculating the stiffness matrix for member 1
% k1 = k(1) * [C(1)^2, CS(1), -C(1)^2, -CS(1), 0, 0;
%              CS(1), S(1)^2, -CS(1), -S(1)^2, 0, 0;
%              -C(1)^2, -CS(1), C(1)^2, CS(1), 0, 0;
%              -CS(1), -S(1)^2, CS(1), S(1)^2, 0, 0;
%              0, 0, 0, 0, 0, 0;
%              0, 0, 0, 0, 0, 0];
% 
% % Calculating the stiffness matrix for member 2
% k2 = k(2) * [0, 0, 0, 0, 0, 0;
%              0, 0, 0, 0, 0, 0;
%              0, 0, C(2)^2, CS(2), -C(2)^2, -CS(2);
%              0, 0, CS(2), S(2)^2, -CS(2), -S(2)^2;
%              0, 0, -C(2)^2, -CS(2), C(2)^2, CS(2);
%              0, 0, -CS(2), -S(2)^2, CS(2), S(2)^2];
%              
% % Calculating the stiffness matrix for member 3
% k3 = k(3) * [C(3)^2, CS(3), 0, 0, -C(3)^2, -CS(3);
%              CS(3), S(3)^2, 0, 0, -CS(3), -S(3)^2;
%              0, 0, 0, 0, 0, 0;
%              0, 0, 0, 0, 0, 0;
%              -C(3)^2, -CS(3), 0, 0, C(3)^2, CS(3);
%              -CS(3), -S(3)^2, 0, 0, CS(3), S(3)^2];
% 
% %assembling the global stiffness matrix 
% K = k1 + k2 + k3;
% 
% % Solve for unknown displacements (u2x, u3x, u3y)
% u = [K(3,3), K(3,5:6); K(5,3), K(5,5:6); K(6,3), K(6,5:6)] \ [0; P; 0];
% 
% % Create entire displacemnet matrix U (u1x = u1y = u2y = 0)
% U = [0; 0; u(1); 0; u(2); u(3)];
% 
% % Solve reation forces
% F = K * U;
% 
% % Solve member forces
% fe1 = k(1) * ((U(3)-U(1))*C(1) + (U(4)-U(2))*S(1));
% fe2 = k(2) * ((U(5)-U(3))*C(2) + (U(6)-U(4))*S(2));
% fe3 = k(3) * ((U(5)-U(2))*C(3) + (U(6)-U(1))*S(3));
% 
% Fe = [fe1;fe2;fe3];

% Format and print results
% fprintf('Nodal Displacements:\n');
% j = 1;
% for i = 1:2:length(U)
%     fprintf('u%ix = %.3f P/EA\n', j, U(i));
%     fprintf('u%iy = %.3f P/EA\n', j, U(i+1));
%     j = j+1;
% end
% 
% fprintf('\nNodal Forces:\n');
% j = 1;
% for i = 1:2:length(F)
%     fprintf('f%ix = %.3f P\n', j, F(i));
%     fprintf('f%iy = %.3f P\n', j, F(i+1));
%     j = j+1;
% end
% 
% fprintf('\nMember Forces:\n');
% for i = 1:length(Fe)
%     fprintf('f(%i) = %.3f P\n', i, Fe(i));
% end
