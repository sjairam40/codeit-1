#By listing the first six prime numbers: 2, 3, 5, 7, 11, and 13, we can see that the 6th prime is 13.
#What is the 10001st prime number?


def check_prime(num):
    if num > 2 and num % 2 == 0:
        return False
    else:
        # I tried using a generator here, but it is slower by a noticeable amount.
        for i in xrange(3, int(math.sqrt(num)) + 1, 2):
            if num % i == 0:
                return False
        return True


# this function will be re-written. Right now it works but its too ugly.
def find_10001st_prime():
    num, count = 1, 0
    
    while True:
        if check_prime(num):
            count += 1
            if count == 10001:
                return num

        num += 1

print find_10001st_prime()


# answer: 104729 is the 10,001st prime.