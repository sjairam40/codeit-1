#!/bin/python3

import math
import os
import random
import re
import sys

def ordered_configuration(configuration):
    # Write your code here
    stringBarCode = configuration        
    mySeperatedBarList = stringBarCode.split('|')
    firstFourString(mySeperatedBarList.str())

    #print (mySeperatedBarList)

    #for element in seperatedBarCode:
    #    print(element, end=' ')
    # print("\n")

def firstFourString(string):
    sampleStr = string
    # Get First 4 character of a string in python
    first_chars = sampleStr[0:4]
    second_chars = sampleStr[5,15]
    print('First 4 character : ', second_chars)
    
if __name__ == '__main__':
    testString='0001LAJ5KBX9H8|0003UKURNK403F|0002MO6K1Z9WFA|0004OWRXZFMS2C'
    ordered_configuration(testString)