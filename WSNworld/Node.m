classdef Node
    %{
    NODE Summary: class that represents a simple sensor node in a WSN
    
    The node is supposed to work together with a large amount of other 
    nodes as well as a mobile sink. It stores information about it's 
    position and the data and energy aggregated while functional (having
    energy > 0).
    %}
    
    properties
        params      % "real world" parameters
        ID          % Node's ID, expressed as a number
        xPos        % Node's position in x and y
        yPos
        pSize       % Preset packet size of each message
        PA          % Packet amount = amount of packets sent each transmission round
        energy      % Current amount of energy [J] residing in node
        maxEnergy   % Max amount of energy [J] that can be stored in node
        SoC         % State of Charge = energy/maxEnergy
        CHparent    % Reference to current cluster head
        CHstatus    % Cluster head status. 1 if cluster head, 0 if not
        alive       % Boolean value indicating whether node has energy > 0 or not 
        dtr         % Distance to eventual receiver
        dataRec     % Total Data received
        PS          % Packets sent
        nrjCons     % Total Energy consumed
        actionMsg   % String containing information about connection and sending progress
        CHflag      % 
    end
    
    methods
        
        function obj = Node(id, x, y, nrj, parameters)
        %{
        Constructor: takes in arguments for id, position, size of packages
        that get sent during transmission, starting energy level of node,
        maximum amount of energy that can be stored by the node
        (which also lead to the current state of charge of the node)
        
        Initial amount of packets sent during each transmission is set to
        1, cluster head status is set to 0 = NOT CLUSTER HEAD.
        If node starts of with energy it is seen as alive.
        %}
            obj.params = parameters;
            obj.ID = id;
            obj.xPos = x;
            obj.yPos = y;
            obj.pSize = parameters.ps;
            obj.PA = 1;
            obj.energy = nrj;
            obj.maxEnergy = parameters.maxNrj;
            obj.SoC = obj.energy/obj.maxEnergy;
            obj.CHstatus = 0;
            obj.CHparent = [];
            obj.dataRec = 0;
            obj.PS = 0;
            obj.nrjCons = 0;
            obj.actionMsg = '';
            obj.CHflag = 0;
            
            if(obj.energy > 0)
                obj.alive = true;
            else
                obj.alive = false;
            end
            
        end
        
        function packRec = getDataRec(obj)
           packRec = obj.dataRec; 
        end
        
        function ps = getPS(obj)
           ps = obj.PS;
        end
        
        function eneCons = getEC(obj)
           eneCons = obj.nrjCons; 
        end
        
        function [x, y] = getPos(obj)
           x = obj.xPos;
           y = obj.yPos;
        end
        
        function msg = getActionMsg(obj)
            msg = obj.actionMsg;   
        end
        
        function CHS = getCHstatus(obj)
           CHS = obj.CHstatus; 
        end
        
        function obj = clearConnection(obj)
        % Sets the CHparent reference to null
            obj.CHparent = [];
        end
        
        function distance = getDistance(obj, node)
            distance = sqrt((obj.xPos-node.xPos)^2 + (obj.yPos-node.yPos)^2);
        end
        
        function obj = updateSoC(obj)
           obj.SoC = obj.energy/obj.maxEnergy;
        end
        
        function ener = getEnergy(obj)
            ener = obj.energy;
        end
        
        function obj = connect(obj, node)               
        %{
        Connection here adds another node object as a CH reference to
        this object and is stored in CHparent. If the connection fails
        due to the target node being dead, or not being a CH, or if this 
        node is already a CH, an error message is printed out.
        %}    
            if(node.alive)
                obj.CHparent = node;
                obj.actionMsg = ['Node ',num2str(obj.ID),' of type ', num2str(obj.CHstatus), ' connected successfully to target node ', num2str(node.ID), ' of type ', num2str(node.CHstatus),'.'];
            else
               if(~node.alive)
                   obj.actionMsg = ['Node ',num2str(obj.ID), ' failed to connect; target node ', num2str(node.ID) ,' is dead.\n'];
               elseif(node.CHstatus == 0)
                   obj.actionMsg = ['Node ',num2str(obj.ID), ' failed to connect; target node ', num2str(node.ID) ,' is not a CH.\n'];
                   
               end 
            end             
        end
        
        
        
        function [nodes, sink, outcome] = sendMsg(obj, nodes, sink)
        %{
         The node "sends message" to a target node. The function subtracts
         energy from this node corresponding to the amount of data packets
         sent. It also subtracts energy from the receiving node based on
         the same premises.
            
         This is done by manipulating the input nodes-list.
        %}
            outcome = false;         
            if(~isempty(obj.CHparent))
                tempP = obj.params;     % Takes the system parameters and converts them to a simpler format
                k = obj.PA*obj.pSize;   % k = the amount of bits that are sent 

                ETx = tempP.Eelec*k + tempP.Eamp * k * obj.getDistance(obj.CHparent)^2;   % Calculates the energy that will be spent by transmitting signal
                ERx=(tempP.Eelec+tempP.EDA)*k;                      % Calculates the energy that will be spent by receiving signal
                for it=1:length(nodes)
                    if(obj.CHparent.ID == nodes(it).ID)
                        if(nodes(it).alive)
                            if(obj.CHstatus == 0)
                                obj.PA = 1;             % Makes sure that a node that is not a CH (e.g. not directly controlled) wont send more than one packet
                            end
                            obj.energy = obj.energy - ETx;                      % Energy is subtracted before data is transmitted since a power failure should result in a faulty transmission
                            obj.updateSoC();                                    % State of charge has to be updated after every energy use...
                            nodes(it).energy = nodes(it).energy - ERx;
                            nodes(it).updateSoC();
                            obj.nrjCons = obj.nrjCons + ETx;                    % Energy cost is also added to the nodes total energy consumed
                            nodes(it).nrjCons = nodes(it).nrjCons + ERx;

                            if(obj.energy >= 0 && nodes(it).energy >= 0)             % If no power failure was had, data has been transmitted and received
                                obj.actionMsg = ['Node ',num2str(obj.ID),' of type', num2str(obj.CHstatus), ' successfully sent to target node ', num2str(nodes(it).ID), ' of type ', num2str(nodes(it).CHstatus),'.'];
                                obj.PS = obj.PS + k;
                                nodes(it).dataRec = nodes(it).dataRec + k;    
                                outcome = true;
                            end
                            if(obj.energy < 0)
                                obj.actionMsg = ['Node ',num2str(obj.ID), ' failed to transmit; ran out of energy while sending to node ', num2str(nodes(it).ID) ,'.\n'];
                                obj.nrjCons = obj.nrjCons + obj.energy;         % Corrects the energy consumed by taking away the "negative" energy that isnt consumed for real
                                obj.energy = 0;
                                obj.updateSoC();
                                obj.alive = false;
                            end
                            if(nodes(it).energy < 0)
                                obj.actionMsg = ['Failed to transmit: node ' ,num2str(nodes(it).ID), ' ran out of energy while receiving from node ',num2str(obj.ID), '.\n', nodes(it).ID, obj.ID];
                                nodes(it).nrjCons = nodes(it).nrjCons + nodes(it).energy;
                                nodes(it).energy = 0;
                                nodes(it).updateSoC();
                                nodes(it).alive = false;
                            end
                        else
                            if(~nodes(it).alive)
                                obj.actionMsg = ['Node ',num2str(obj.ID), ' failed to transmit; target node ', num2str(nodes(it).ID) ,' is dead.\n'];
                            elseif(nodes(it).CHstatus == 0)
                                obj.actionMsg = ['Node ',num2str(obj.ID), ' failed to transmit; target node ', num2str(nodes(it).ID) ,' is not a CH.\n'];
                            end 
                        end

                    end
                end
                
                if(obj.CHparent.ID == sink.ID)
                    if(obj.CHstatus == 0)
                                obj.PA = 1;             % Makes sure that a node that is not a CH (e.g. not directly controlled) wont send more than one packet
                    end
                    obj.energy = obj.energy - ETx;                      % Energy is subtracted before data is transmitted since a power failure should result in a faulty transmission
                    obj.updateSoC();                                    % State of charge has to be updated after every energy use...
                    sink.energy = sink.energy - ERx;
                    sink.updateSoC();
                    obj.nrjCons = obj.nrjCons + ETx;                    % Energy cost is also added to the nodes total energy consumed
                    sink.nrjCons = sink.nrjCons + ERx;
                    
                    if(obj.energy >= 0 && sink.energy >= 0)             % If no power failure was had, data has been transmitted and received
                        obj.actionMsg = ['Node ',num2str(obj.ID), ' successfully sent to sink ', num2str(sink.ID) ,'!\n'];
                        obj.PS = obj.PS + k;
                        sink.dataRec = sink.dataRec + k;    
                        outcome = true;
                    end
                    if(obj.energy < 0)
                        obj.actionMsg = ['Node ',num2str(obj.ID), ' failed to transmit; ran out of energy while sending to sink ', num2str(sink.ID) ,'.\n'];
                        obj.nrjCons = obj.nrjCons + obj.energy;         % Corrects the energy consumed by taking away the "negative" energy that isnt consumed for real
                        obj.energy = 0;
                        obj.updateSoC();
                        obj.alive = false;
                    end
                    if(sink.energy < 0)
                        obj.actionMsg = ['Sink ',num2str(sink.ID), ' failed to receive; ran out of energy while receiving from node ', num2str(obj.ID) ,'.\n'];
                        sink.nrjCons = sink.nrjCons + sink.energy;
                        sink.energy = 0;
                        sink.updateSoC();
                        sink.alive = false;
                    end
                end       
            else
                nodes.actionMsg = ['Failed to transmit: Not connected to a receiver.\n'];  
            end    
            for iter=1:length(nodes)
                    if(obj.ID == nodes(iter).ID)
                        nodes(iter) = obj;
                    end
            end
        end
        
        function obj = setPR(obj, desiredPR)
        %{ 
         Sets the amount of packets sent during coming transmissions.
         The number of desired packet rate is supposed to be a whole
         number so that only whole packages are sent.
       
         THOUGHT - maybe this ought to be rounded instead for more
         dynamic control signal options? For example if the controller deems
         that the packet rate should be 1.9, maybe it shouldnt stay on 1
         but rather jump up to 2
        %}
           if(desiredPR == floor(desiredPR))
               obj.PA = desiredPR;
           else
               fprintf('Desired packet rate was not a whole number.')
           end
            
        end
        
        function obj = generateNRJ(obj)
        %{ 
        Function that makes the node generate energy based on a value
        stated in params. The nrjGenFac is simply a factor multiplied with
        the max amount of energy that can be stored in the node.
        
        So if we for example have a max energy amount of 2J and a factor of
        0.1, we can at most harvest 0.2J each time this function is called.
        This value is multiplied with a random value between {0:1}
        to make it more "natural".
        %}
            maxNrjGenerated = obj.maxEnergy*obj.params.nrjGenFac;
            nrj_generated = rand(1)*maxNrjGenerated;
            obj.energy = obj.energy + nrj_generated;
           
            %Energy stored in node can't exceed the max energy stored
            if (obj.energy > obj.maxEnergy)
               obj.energy = obj.maxEnergy; 
            end
            
            obj = obj.updateSoC();
            
        end
        
        function obj = generateCHstatus(obj, f, p, rnd)
            if(mod(rnd, 1/p) == 0)
                obj.CHflag = 0;
            end
            randVal = rand(1);
            t=(p/(1-p*(mod(rnd,1/p))));          
            if(f<1)             %If we want to try without BLEACH, we simply set f>1
                t=(1-f)*(p/(1-p*(mod(rnd,1/p))))*obj.SoC + ...
                    (1/(1-(1-f)*(p/(1-p*(mod(rnd,1/p))))))*f*(p/(1-p*(mod(rnd,1/p))));
            end
            %If t is bigger than the randomized value, this node becomes a
            %CH
            if(t>randVal && obj.CHflag == 0)
                obj.CHstatus = 1;
                obj.CHflag = 1;
            else
                obj.CHstatus = 0;
            end
            %fprintf('t = %d, randVal = %d, which results in CHS = %d \n', t, randVal, obj.CHstatus);
        end
    end
end

