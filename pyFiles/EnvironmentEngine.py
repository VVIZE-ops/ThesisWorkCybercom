import numpy as np
import random
from setParams import *
from Sink import *
from Node import *

class EnvironmentEngine:
    '''
    EnvironmentEngine acts as an interactive environment where input signals controlling the sink position and
    packet rate of each cluster head node.
    '''
    def __init__(self):
        '''
        The __init__ method is the class constructor and initializes the variables
        '''

        self.sink = Sink(xSize, ySize)  # Creates an instance of sink class
        self.nodes = []  # Create an empty list to hold the nodes
        # Initializes a node for each node in WSN
        if energyMode == "rand":
            for i in range(numNodes):
                self.nodes.append(Node(i, random.random() * xSize, random.random() * ySize, maxNrj * random.random()))
        elif energyMode == "distr":
            for i in range(numNodes):
                self.nodes.append(Node(i, random.random() * xSize, random.random() * ySize, maxNrj))
        else:
            print("The choice of energy mode is invalid! \n")


        self.rnd = 1  # Round number
        self.states = []
        self.nodesAlive = []  # Contains the amount of nodes that are alive after each round
        self.EClist = []  # List that  contains the energy consumed after each round
        self.PackReclist = []  # List that contains the data packets received for the sink after each round
        self.meanEClist = []  # List that contains the mean energy consumed after each round
        self.deadNodes = []  # Contains the amount of dead nodes after each round
        self.posNodes = []  # The position of the nodes

        tempNRJ = 0
        for node in self.nodes:  # Iterate over all nodes
            tempNRJ += node.nrjCons
            if node.alive:  # If node is still alive
                self.nodesAlive.append(node)
            else:  # Else node is dead
                self.deadNodes.append(node)

        nrjMean = 0
        if self.nodesAlive:  # If there are nodes alive
            nrjMean = tempNRJ / len(self.nodesAlive)  # Mean energy consumed by all nodes

        # For plotting purpose
        self.EClist.append(tempNRJ)
        self.PackReclist.append(self.sink.dataRec)
        self.meanEClist.append(nrjMean)

        for node in self.nodesAlive:  # Saves the position of all the nodes in a list
            xnd, ynd = node.getPos()
            self.posNodes.append([xnd, ynd])
        self.posNodes = np.array(self.posNodes)


    def updateEnv(self, deltaX, deltaY, packetRates):
        '''
        METHOD updateEnv

        The method moves the sink and updates the amount of packets
        that the cluster heads are to send during next transmission
        round.

        :param deltaX: Sink movement in x
        :param deltaY: Sink movement in y
        :param packetRates: Packet rates for each CH in system( is an array of IDs with corresponding PA-values)

        :return: self
        '''
        self.sink.move(deltaX, deltaY)  # Moves the sink in desired step length

        # Set the Packet Rate of all the nodes
        for i in range(len(packetRates)):
            for j in range(len(self.nodes)):
                if self.nodes[j].ID == packetRates[i][0]:
                    self.nodes[j].setPR(packetRates[i][1])

    def sinkStatus(self):
        '''
        METHOD sinkStatus
        Returns the status of the sink in terms of position and packets received.
        :return: sinkX = sink position in x,  sinkY = sink position in y, sinkDataRec = Amount of data sink has received
        '''
        sinkX, sinkY = self.sink.getPos()
        sinkDataRec = self.sink.getDataRec()
        return sinkX, sinkY, sinkDataRec

    def getStates(self):
        '''
        METHOD getStates
        Returns the current state values of the sink and each node of the system with the form:
        [sinkx, sinky, nodeVals1, nodeVals2, ....., nodeValsN] ^ T
        '''
        x, y = self.sink.getPos()
        self.states = [[x], [y]]
        for node in self.nodes:
            xN, yN = node.getPos()
            self.states.append([[xN], [yN], [node.getCHstatus()], [node.getPS()], [node.getEC()]])
        return self.states

    def cluster(self):
        '''
        METHOD cluster

        Iterates through all nodes and decides whether to be a CH or not with generateCHstatus().

        After that, it iterates through all nodes that aren't CHs and compares it's distance to sink to all distances
        to all nodes that are CHs. It uses the index js shortest to store which distance was the shortest. If no
        distance to a CH was shorter than the distance to the sink, the node simply connects to the sink.
        :return: self
        '''

        # Check if node is alive, then generate its CHs
        for i in range(len(self.nodes)):
            if self.nodes[i].alive:  # Generate CH status with BLEACH if node is alive
                self.nodes[i].generateCHstatus(f, p, self.rnd)
            else:  # If node is not alive, node cannot be CH
                self.nodes[i].CHstatus = 0

        for i in range(len(self.nodes)):  # Non-CH nodes connect to nearest CH/sink and CHs connect to sink
            if self.nodes[i].getCHstatus() == 0:  # If node is a simple node (non-CH)
                minDistance = self.nodes[i].getDistance(self.sink)  # Starts off with the distance to sink
                jshortest = -1  # jshortest starts of as a "non index" number
                for j in range(len(self.nodes)):
                    if self.nodes[j].CHstatus == 1:  # Checks all cluster head nodes
                        if minDistance > self.nodes[i].getDistance(self.nodes[j]):
                            # If distance to cluster head j was shorter than what has been measured before, make
                            # this the new minimum distance
                            minDistance = self.nodes[i].getDistance(self.nodes[j])
                            jshortest = j # Store index of this node

                if jshortest > 0:  # If a CH with in -between distance shorter than that to the sink, connect to this CH
                    self.nodes[i].connect(self.nodes[jshortest])
                else:
                    self.nodes[i].connect(self.sink)  # Otherwise connect to the sink
            else:  # If node is CH, connect to sink
                self.nodes[i].connect(self.sink)

    def communicate(self):
        '''
        METHOD COMMUNICATE

        The method simply tells all nodes that are alive to send (use sendMsg()) on whichever node is connected to it
        via the partentCH property

        If the transmission fails, an "action message" generated by the failing node is printed.
        '''
        for i in range(len(self.nodes)):
            if self.nodes[i].alive:
                outcome = self.nodes[i].sendMsg(self.sink)
                if not outcome:
                    print(f"Node {self.nodes[i].ID} failed to send to node {self.nodes[i].CHparent.ID}!\n")
                    actionmsg = self.nodes[i].getActionMsg()
                    print(str(actionmsg) + "\n")

    def iterateRound(self):
        '''
        METHOD ITERATEROUND

        The method summarizes stats for energy consumed, packets sent, and node/sink position during the current round;
        everything that is of interest to plot. It then iterates the rnd-property by one step.
        '''
        tempNRJ = 0
        self.nodesAlive = []
        self.deadNodes = []

        for node in self.nodes:
            tempNRJ += node.nrjCons
            if node.alive:
                self.nodesAlive.append(node)
            else:
                self.deadNodes.append(node)

        nrjMean = 0
        if self.nodesAlive:  # If there are nodes alive
            nrjMean = tempNRJ / len(self.nodesAlive)

        # For plotting purposes
        self.EClist.append(tempNRJ)
        self.PackReclist.append(self.sink.dataRec)
        self.meanEClist.append(nrjMean)

        self.posNodes = []
        for node in self.nodesAlive:
            xnd, ynd = node.getPos()
            self.posNodes.append([xnd, ynd])
        self.posNodes = np.array(self.posNodes)

        self.rnd += 1

    def getECstats(self):
        '''
        Returns both the sum of all energy consumed and the list of energy consumed each round
        '''
        ecList = self.EClist
        ecSUM = sum(self.EClist)

        return ecSUM, ecList

    def getPRstats(self):
        '''
        Returns both the sum of all bits received and the list of bits received each round
        '''

        prList = self.PackReclist
        prSUM = sum(self.PackReclist)
        return prSUM, prList

    def getECmeanStats(self):
        '''
        Returns a list of the mean energy consumption per node for each round.
        '''

        meanEClist = self.meanEClist
        return meanEClist

    def getDeadNodes(self):
        '''
        Returns the list of all dead nodes.
        '''
        deadList = self.deadNodes
        nDead = len(self.deadNodes)
        return nDead, deadList
