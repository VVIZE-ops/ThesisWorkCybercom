clc, clear all, close all

hrz = [1,3,5,7,9];
v = [2,5,10];

drh10v10 = mean([33788000, 35759000, 36084000, 36102000, 37592000, 35289000, 31823000, 35086000]);
MPCppJh10v10 = mean([8747, 8892, 8788, 8867, 9175, 8880, 9195, 8721]);

MPCppJh8v10 = mean([8848, 9000, 8716, 9071, 8705, 8978, 8832, 8702]);

MPCppJh6v10 = mean([8915, 8981, 8807, 8959, 8676, 8939, 9155, 8729]);

MPCppJh4v10 = mean([8641, 8805, 8642, 8469, 8520, 8836, 8761, 8878]);

MPCppJh2v10 = mean([7271, 7241, 7818, 6350, 7316, 6974, 6965, 7033]);

MPCPPJv10 = [MPCppJh2v10, MPCppJh4v10, MPCppJh6v10, MPCppJh8v10, MPCppJh10v10];

plot(hrz, MPCPPJv10)



MPCppJh10v5 = mean([8757, 8567, 8748, 8771, 8449, 8711, 8638, 8574]);
MPCppJh8v5 = mean([8615, 8580, 8745, 8745, 8675, 8765, 8587, 8945]);
MPCppJh6v5 = mean([8717, 8858, 8503, 8669, 8731, 8794, 8686, 8789]);
MPCppJh4v5 = mean([8508, 8683,8858, 8591, 8544, 8726, 8678, 8659]);
MPCppJh2v5 = mean([7389, 6736, 6630, 6679, 6243, 6886, 6466, 6483]);

MPCPPJv5 = [MPCppJh2v5, MPCppJh4v5, MPCppJh6v5, MPCppJh8v5, MPCppJh10v5];
plot(hrz, MPCPPJv5)

MPCppJh10v2 = mean([7543, 7569, 7803, 8173, 7980, 7775, 8136, 8218]);
MPCppJh8v2 = mean([7786, 7872, 7944, 7906, 7797, 7872, 7817, 7853]);
MPCppJh6v2 = mean([7946, 7302, 7936, 7082, 7391, 8216, 7882, 7312]);
MPCppJh4v2 = mean([8001, 7440, 7708, 7919, 7937, 8155, 8492, 8134]);
MPCppJh2v2 = mean([6664, 6713, 6653, 6697, 6485, 6761, 6486, 6486]);


MPCPPJv2 = [MPCppJh10v2, MPCppJh8v2, MPCppJh6v2, MPCppJh4v2, MPCppJh2v2];

MPCall = [MPCPPJv2; MPCPPJv5; MPCPPJv10];
surfl(hrz, v, MPCall)
xlabel('Horizon Length')
ylabel('Sink Speed')
zlabel('PPJ')

LEACHMEANPPJ = mean([6740, 6942, 6803, 6956, 7057, 6978, 7034, 6786, ...
6872, 7087, 6711, 7142, 6736, 6927, 6766, 6760, 6918, 7052, 6809, 6924, ...
6807, 6927, 7254, 6866, 6724, 7002, 6808, 6669, 6738, 6940, 6914, 6829, ...
6934, 6756, 7107, 6786, 6918, 6820, 6914, 6821]);




