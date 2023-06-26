def IsPrime(x):
    returnVal = True

    for i in range(2,int(x)):

        if (int(x) % i)==0:

            returnVal=False
            break

    return returnVal

###################################3


sum=2

# Modified 2 MIL to 200 K

for i in range(3,200000):

    if IsPrime(i):

        print("adding " + str(i))

        sum = sum + i

print(sum)