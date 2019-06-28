# -*- coding: utf-8 -*-
import random
import math
import gym
import gym_WSN
import LEACHtest
import numpy as np
from collections import deque
from keras.models import Sequential
from keras.layers import Dense
from keras.optimizers import Adam
import csv
import nodePlacementGeneration  # Generates node placement and saves to csv file

import sys
sys.path.append("..")  # Adds higher directory to python modules path.
from setParams import *
from plotEnv import *
from EnvironmentEngine import *

import matplotlib.pyplot as plt


class DQNAgent:
    def __init__(self, state_size, action_size):
        self.state_size = state_size
        self.action_size = action_size
        self.memory = deque(maxlen=10000)
        self.gamma = 0.8 #0.9    # discount rate
        self.epsilon_min = 0.05
        self.epsilon = 0.05 # exploration rate
        self.epsilon_decay = 0.9999
        self.learning_rate = 0.01
        self.model = self._build_model()

    def _build_model(self):
        # Neural Net for Deep-Q learning Model
        model = Sequential()
        # Add layers to NN model
        model.add(Dense(24, input_dim=self.state_size, activation='relu'))
        model.add(Dense(48, activation='relu'))
        #model.add(Dense(36, activation='relu'))
        model.add(Dense(self.action_size, activation='linear'))
        #model.compile(loss='mae', optimizer=Adam(lr=self.learning_rate))
        return model

    def remember(self, state, action, reward, next_state, done):
        self.memory.append((state, action, reward, next_state, done))

    def act(self, state):
        if np.random.rand() <= self.epsilon:
            return random.randrange(self.action_size)  # Returns a random action in the action space
        act_values = self.model.predict(state)
        return np.argmax(act_values[0])  # Returns the action that is predicted to yield the most reward

    def replay(self, batch_size):
        minibatch = random.sample(self.memory, batch_size)
        for state, action, reward, next_state, done in minibatch:
            target = reward

            if not done:
                target = (reward + self.gamma *
                          np.amax(self.model.predict(next_state)[0]))
            target_f = self.model.predict(state)
            target_f[0][action] = target
            self.model.fit(state, target_f, epochs=1, verbose=0)
        if self.epsilon > self.epsilon_min:
            self.epsilon *= self.epsilon_decay

    def load(self, name):
        self.model.load_weights(name)
        self.model.compile(loss='mae', optimizer=Adam(lr=self.learning_rate))  # Compile NN


if __name__ == "__main__":
    env = gym.make('WSN-v0')
    state_size = env.observation_space.shape[0]  # Get amount of states (Amount of states = 2 + 2*numNodes)
    action_size = env.action_space.n
    agent = DQNAgent(state_size, action_size)  # Create an instance of the agent

    '''
    # If node placement needs to be hardcoded 
    env.EE.nodes[0].xPos = 130
    env.EE.nodes[0].yPos = 130

    env.EE.nodes[1].xPos = 170
    env.EE.nodes[1].yPos = 130

    env.EE.nodes[2].xPos = 130
    env.EE.nodes[2].yPos = 170

    env.EE.nodes[3].xPos = 170
    env.EE.nodes[3].yPos = 170

        
    env.EE.nodes[0].xPos = 250
    env.EE.nodes[0].yPos = 20

    env.EE.nodes[1].xPos = 250
    env.EE.nodes[1].yPos = 60

    env.EE.nodes[2].xPos = 210
    env.EE.nodes[2].yPos = 20

    env.EE.nodes[3].xPos = 210
    env.EE.nodes[3].yPos = 60
    '''

    times = 1

    for tests in range(20):
        nodePlacementGeneration.run()  # Generate new node placement and save in csv file
        LEACHtest.run()  # Run LEACH comparison

        # Run WSN env with plotting after training
        agent.load("./save/wsn-dqn-new.h5")  # Load weights from file
        avrRnd = []

        with open('nodePlacement.csv') as nodePlacement_file:  # Load the new node placement
            csv_reader = csv.reader(nodePlacement_file, delimiter=',')
            row_count = 0

            for row in csv_reader:
                i = 0
                rowVec = []

                for element in row:
                    rowVec.append(float(element))

                if row_count == 0:
                    for valueX in rowVec:
                        env.EE.nodes[i].xPos = valueX
                        i += 1
                if row_count == 1:
                    for valueY in rowVec:
                        env.EE.nodes[i].yPos = valueY
                        i += 1
                row_count += 1


        # Set default values
        done = False
        batch_size = 32
        rnd = 0
        state = env.reset()  # Reset env to a random state
        env.EE.sink.xPos = int(xSize / 2)
        env.EE.sink.yPos = int(ySize / 2)

        # Format state such that it can be used for training
        for i in range(2, numNodes + 2):
            state[i] = state[i][1]
        state = np.reshape(state, [1, state_size])
        while not done:

            rnd += 1
            action = agent.act(state)
            next_state_temp, reward, done, _ = env.step(action)

            next_state = [next_state_temp[0], next_state_temp[1]]
            for i in range(numNodes):
                next_state.append(next_state_temp[2][i][1])
            for ii in range(numNodes):
                next_state.append(next_state_temp[3][ii])
            next_state = np.array(next_state)
            next_state = np.reshape(next_state, [1, state_size])
            agent.remember(state, action, reward, next_state, done)
            state = next_state

            if done:
                #print(f"Episode: {episodes+1}/{5}, e: {agent.epsilon}, rnd: {rnd} \n")
                #print(f"Data Packets Received Sink: {env.EE.sink.dataRec / 1000} \n")
                energyList = []
                for i in range(numNodes):
                    energyList.append(env.EE.nodes[i].getEC())
                #print(f"Energy consumed: {sum(energyList)}")
                break

            if len(agent.memory) > batch_size:
                agent.replay(batch_size)

            #env.render()

        print(f"Times: {times}")
        times += 1
        with open('RLresults.txt', 'a', newline='') as f:
            f.write(str(env.EE.rnd) + ",")
            f.write(str(env.EE.sink.dataRec / 1000) + ",")
            f.write(str(sum(energyList)))


        avrRnd.append("RL: " + str(rnd))

    #print(f"avrRnd: {avrRnd}")
    #print(f"Mean Rounds: {sum(avrRnd) / len(avrRnd)}")
