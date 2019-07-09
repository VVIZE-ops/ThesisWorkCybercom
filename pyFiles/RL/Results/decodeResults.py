import statistics

a= [77,14648.0,2.8225883999999986,71,13703.0,2.592512899999998,52,9816.0,2.1257920999999995,61,11580.0,2.2312648999999993,37,6967.0,1.9357893999999995,63,11942.0,2.3530492999999995,77,14676.0,2.515527799999998,51,9753.0,1.8578850999999998,53,10066.0,2.180355200000001,52,10029.0,2.126917599999999,]

meanRounds = a[0::3]
meanPackets = a[1::3]
meanEnergy = a[2::3]

print(f"Rounds: {meanRounds}")
print(f"Packets: {meanPackets}")
print(f"Energy: {meanEnergy} \n")

meanRounds =  statistics.mean(meanRounds)
meanPackets = statistics.mean(meanPackets)
meanEnergy =statistics.mean(meanEnergy)

print(f"Mean Rounds: {meanRounds}")
print(f"Mean Packets: {meanPackets}")
print(f"Mean Energy: {meanEnergy}")