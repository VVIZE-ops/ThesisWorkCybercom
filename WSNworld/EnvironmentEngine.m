classdef EnvironmentEngine
    %ENVIRONMENTENGINE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sink
        nodes
        params
    end
    
    methods
        function obj = EnvironmentEngine()
            %ENVIRONMENTENGINE Construct an instance of this class
            %   Detailed explanation goes here
            [parameters, env] = setup();
            obj.params = parameters;
            obj.sink = env{1}{1};
            obj.nodes = env{2};
        end
        
        function obj = updateEnv(obj, deltaX, deltaY, packetRates)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.sink = obj.sink.move(deltaX, deltaY);
        end
        
        function [sinkX, sinkY, sinkDataRec] = sinkStatus(obj)
            
        end
        
    end
end


% [params, env] = setup();
% 
% while (params.dead_nodes ~= numNodes) 
%     % Run algorithm until all nodes are dead
%     
%     % Get CH status for each node st the beginning of each round
%     for i = 1:params.operating_nodes;
%         env.node(i) = env.node(i).generateCHstatus(f, p, params.rnd);
%     end
%     
%     % Connect non-CH to closest CH 
%     
%     % Send data to CH or mobile sink
%     
%     % Update energy of every node with consumed and generated energy
%     
%     % Update the amount of operating nodes and dead nodes 
%     
%     
%     params.rnd = params.rnd + 1; % Increment round counter 
% end 