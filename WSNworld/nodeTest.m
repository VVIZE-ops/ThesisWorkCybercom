clc, clear all, close all

parameters = struct;
parameters.ps = 200;
parameters.maxNrj = 2;
parameters.Eelec = 50*10^(-9);
parameters.Eamp = 100*10^(-12);
parameters.EDA = 5*10^(-9);
parameters.f = 0.6;
parameters.p = 0.05;
parameters.nrjGenFac = 0.1;

a = Node(1, 1, 2, 2, parameters);    % Normal non-CH node
b = Node(2, 80, 90, 1, parameters);    % Normal non-CH node

c = Node(3, 8, 9, 0.5, parameters);    % Normal CH node
c.CHstatus = 1;

d = Node(4, 11, 12, 0, parameters);    % Normal dead node

e = Node(5, 15, 16, 0, parameters);    % dead CH node
e.CHstatus = 1;

f = Node(6, 17, 2, 0.0000001, parameters);  %NEAR dead normal node

g = Node(7, 18, 3, 0.0000001, parameters);  %NEAR dead normal node

nodes = [a b c d e f g];



sink = Sink(100,100);
%{
Testing the send function
%}
fprintf('A energy: %d, B energy: %d \n', nodes(1).energy, nodes(2).energy);
[a] = a.connect(b);
[nodes,sink, result] = a.sendMsg(nodes, sink);     % Normal to normal
[nodes,sink, result] = a.sendMsg(nodes, sink);     % Normal to normal
[nodes,sink, result] = a.sendMsg(nodes, sink);     % Normal to normal
[nodes,sink, result] = a.sendMsg(nodes, sink);     % Normal to normal
[nodes,sink, result] = a.sendMsg(nodes, sink);     % Normal to normal
fprintf('A energy: %d, B energy: %d \n', nodes(1).energy, nodes(2).energy);
 disp(result);                   % Boolean return
 
[b] = b.connect(a); 
[nodes,sink, result] = b.sendMsg(nodes,sink);     % Normal to normal reversed
  
[a] = a.connect(c);
[nodes,sink, result] = a.sendMsg(nodes,sink);     % Normal to CH

[c] = c.connect(b);
[nodes,sink, result] = c.sendMsg(nodes,sink);     % CH to normal (fails)
disp(result);           
%
[a] = a.connect(d);
[nodes,sink, result] = a.sendMsg(nodes,sink);     % Normal to dead normal
disp(result);     
[a] = a.connect(e);
[nodes,sink, result] = a.sendMsg(nodes,sink);     % Normal to dead CH
% 

[f] = f.connect(a);
[nodes,sink, result] = f.sendMsg(nodes,sink);     % NEAR dead normal to normal node

[g] = g.connect(f);
[nodes,sink, result] = g.sendMsg(nodes,sink);     % NEAR dead normal to NEAR dead normal node
% 
% %Testing the CHstatus function
% %                       f           p           rnd
a.generateCHstatus(parameters.f, parameters.p, 19);
% 
a.getDistance(b);
a.getDistance(c);
a.getDistance(d);
% 
b.CHstatus = 1;
a.connect(b);

