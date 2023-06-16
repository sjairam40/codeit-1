
def triangle_num_generator():
    """ return the next triangle number on each call
        Nth triangle number is defined as SUM([1...N]) """
    n = 1
    s = 0
    while 1:
        s += n
        n += 1
        yield s

def triangle_num_naive(n):
    """ return the nth triangle number using the triangle generator """
    tgen = triangle_num_generator()
    ret = 0
    for i in range(n):
        ret = tgen.next()
    return ret

def divisor_gen(n):
    """ finds divisors by using a quadrativ sieve """
    divisors = []
    # search from 1..sqrt(n)
    for i in xrange(1, int(n**0.5) + 1):
        if n % i is 0:
            yield i
            if i is not n / i:
                divisors.insert(0, n / i)
    for div in divisors:
        yield div

def divisors(n):
    return [d for d in divisor_gen(n)]

num_divs = 0
i = 1
while num_divs < 500:
    i += 1
    tnum = triangle_num_naive(i)
    divs = divisors(tnum)
    num_divs = len(divs)

print tnum
# 76576500

