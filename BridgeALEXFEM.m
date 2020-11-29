
clear all; clc;

P = -49.05;
E = 10.392e9;
A = [2.223e-5; 3.175e-5; 2.354e-5; 2.354e-5; 2.223e-5; 2.615e-5; 2.615e-5; 3.81e-5; 2.54e-5];
L = [0.05; 0.2; 0.071; 0.071; 0.1; 0.112; 0.112; 0.1; 0.15];
theata = [90; 0; 45; 135; 0; 26.56505117707799; 153.43494882292202; 0; 0];
tempF = zeros(9,1);
tempF(3) = P;

% K coeffients
k = E.*A./L;

% Generate K Matricies
C = cosd(theata);
S = sind(theata);
CS = C.*S;

         
k1 = getStiffnessMatrix(1, k, 1, 3, C, S, CS);
k2 = getStiffnessMatrix(2, k, 1, 4, C, S, CS);
k3 = getStiffnessMatrix(3, k, 4, 5, C, S, CS);
k4 = getStiffnessMatrix(4, k, 2, 5, C, S, CS);
k5 = getStiffnessMatrix(5, k, 2, 4, C, S, CS);
k6 = getStiffnessMatrix(6, k, 1, 6, C, S, CS);
k7 = getStiffnessMatrix(7, k, 4, 6, C, S, CS);
k8 = getStiffnessMatrix(8, k, 3, 6, C, S, CS);
k9 = getStiffnessMatrix(9, k, 5, 6, C, S, CS);

K = k1 + k2 + k3+ k4 + k5 + k6 + k7 + k8 + k9;
u = [K(2:4, 2:4), K(2:4, 7:12); K(7:12, 2:4), K(7:12, 7:12)]\tempF;

U = [0; u(1:3);0;0; u(4:9)];

F = K * U;

fe1 = getMemberForce(1, k, 3, 1, C, S, U);
fe2 = getMemberForce(2, k, 4, 1, C, S, U);
fe3 = getMemberForce(3, k, 5, 4, C, S, U);
fe4 = getMemberForce(4, k, 5, 2, C, S, U);
fe5 = getMemberForce(5, k, 2, 4, C, S, U);
fe6 = getMemberForce(6, k, 6, 1, C, S, U);
fe7 = getMemberForce(7, k, 6, 4, C, S, U);
fe8 = getMemberForce(8, k, 6, 3, C, S, U);
fe9 = getMemberForce(9, k, 5, 6, C, S, U);


Fe = [fe1; fe2; fe3; fe4; fe5; fe6; fe7; fe8; fe9];

fprintf('Nodal Displacements:\n');
j = 1;
for i = 1:2:length(U)
    fprintf('u%ix = %.3f P/EA\n', j, U(i));
    fprintf('u%iy = %.3f P/EA\n', j, U(i+1));
    j = j+1;
end

fprintf('\nNodal Forces:\n');
j = 1;
for i = 1:2:length(F)
    fprintf('f%ix = %.3f P\n', j, F(i));
    fprintf('f%iy = %.3f P\n', j, F(i+1));
    j = j+1;
end

fprintf('\nMember Forces:\n');
for i = 1:length(Fe)
    fprintf('f(%i) = %.3f P\n', i, Fe(i));
end


function memberForce = getMemberForce(kIndex, k, node2, node1, C, S, U)
    memberForce = k(kIndex) * ((U(node2 * 2 - 1)-U(node1 * 2 - 1))*C(kIndex) + (U(node2*2)-U(node1*2))*S(kIndex));
end
         
function stiffnessMatrix = getStiffnessMatrix(kIndex, kMatrix, node1, node2, C, S, CS)
    stiffnessMatrix0 = zeros(12);
    
    stiffnessMatrix0((node1 - 1)*2 + 1, (node1 - 1)*2 + 1) = C(kIndex)^2;
    stiffnessMatrix0((node1)*2, (node1 - 1)*2 + 1) = CS(kIndex);
    stiffnessMatrix0((node1 - 1)*2 + 1, (node1)*2) = CS(kIndex);
    stiffnessMatrix0((node1)*2, (node1)*2) = S(kIndex)^2;
    
    stiffnessMatrix0((node1 - 1)*2 + 1, (node2 - 1)*2 + 1) = -C(kIndex)^2;
    stiffnessMatrix0((node1)*2, (node2 - 1)*2 + 1) = -CS(kIndex);
    stiffnessMatrix0((node1 - 1)*2 + 1, (node2)*2) = -CS(kIndex);
    stiffnessMatrix0((node1)*2, (node2)*2) = -S(kIndex)^2;
    
    stiffnessMatrix0((node2 - 1)*2 + 1, (node1 - 1)*2 + 1) = -C(kIndex)^2;
    stiffnessMatrix0((node2)*2, (node1 - 1)*2 + 1) = -CS(kIndex);
    stiffnessMatrix0((node2 - 1)*2 + 1, (node1)*2) = -CS(kIndex);
    stiffnessMatrix0((node2)*2, (node1)*2) = -S(kIndex)^2;
    
    stiffnessMatrix0((node2 - 1)*2 + 1, (node2 - 1)*2 + 1) = C(kIndex)^2;
    stiffnessMatrix0((node2)*2, (node2 - 1)*2 + 1) = CS(kIndex);
    stiffnessMatrix0((node2 - 1)*2 + 1, (node2)*2) = CS(kIndex);
    stiffnessMatrix0((node2)*2, (node2)*2) = S(kIndex)^2;
    
    stiffnessMatrix = kMatrix(kIndex) *stiffnessMatrix0;
    
end