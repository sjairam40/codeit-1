def IsPrime(x):
    returnVal = True

    for i in range(2,int(x)):

        if (int(x) % i)==0:

            returnVal=False
            break

    return returnVal

###################################3


sum=2


for i in range(3,2000000):

    if IsPrime(i):

        print("adding " + str(i))

        sum = sum + i

print(sum)