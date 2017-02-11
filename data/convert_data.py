
# -----------------------------------------------------------------------------
# - Partition oritinal Iris data set in iris.txt to training set (train.dat)
#   and testing set (test.dat)
#
# - Convert original data set to hexadecimal format that is readable by Verilog
#    (X) _  (XX)  _  (XX)  _  (XX)  _  (XX)
#     |      ||       ||       ||       ||
#   label_feature1_feature2_feature3_feature4
#
# - You need to set the number of training samples (3~149)
# 
# - You need to MANUALLY set TRAIN_SIZE and TEST_SIZE in tb_knn.sv
# -----------------------------------------------------------------------------


import os
from random import shuffle


# count total number of samples
with open('iris.txt') as fp:
    n = 0
    for line in fp:
        line = line.strip('\r\n')
        if len(line) != '':
            n += 1

# shuffle indices of samples
indices = range(n)
shuffle(indices)


# ratio for training
x = input('Set the number of training samples? (3<=TRAIN_SIZE<150)? ')
x = int(round(x))

print '-----------------------------------------'
if x < 3:
    print 'Error: Too few training samples!'
elif x > n-1:
    print 'Error: Too many training samples!'
else:
    print 'TRAIN_SIZE: ' + str(x)
    print 'TEST_SIZE:  ' + str(n-x)
    print 'You need to MANUALLY set TRAIN_SIZE and TEST_SIZE in tb_knn.sv!'
print '-----------------------------------------'


trainindices = indices[0:x]
trainindices.sort()


# files for write
ftrain = open('train.dat', 'w')
ftest = open('test.dat', 'w')


# read, change format, and write
with open('iris.txt') as fp:
    i = 0
    for line in fp:
        line = line.strip('\r\n')
        data = line.split(',')
        
        if len(data) > 0 and len(data) != 5:
            print 'Error: No Enough Features!'
            exit(1)
        else:
            # extract and numerate label
            if data[4] == 'Iris-setosa':
                label = 1
            elif data[4] == 'Iris-versicolor':
                label = 2
            elif data[4] == 'Iris-virginica':
                label = 3
            else:
                label = 0
                print 'Error: Unknown Label Name!'
                exit(1)

            # extract features and convert to integer
            if i in trainindices:
                ftrain.write(format(label,'01x'))
                for s in data[:4]:
                    feature = int(10 * float(s))
                    ftrain.write('_' + format(feature,'02x'))
                ftrain.write('\n') 
            else:
                ftest.write(format(label,'01x'))
                for s in data[:4]:
                    feature = int(10 * float(s))
                    ftest.write('_' + format(feature,'02x'))
                ftest.write('\n')            
            i += 1
        

ftrain.close()
ftest.close()
