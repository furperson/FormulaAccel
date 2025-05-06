#Golden model for QAccel 
#Input A,B,C,D
#Output Q
import random

def get_calc(A,B,C,D):
    return ((A-B)*(1+3*C)-4*D)/2


if int(input("1 - выполнить единичное вычисление \n2 - создать тестовый файл \nваш выбор : ")) == 1 : 
    A = int(input("введите A: "))
    B = int(input("введите B: "))
    C = int(input("введите C: "))
    D = int(input("введите D: "))
    qs = "{:.2f}".format(get_calc(A,B,C,D))
    print(qs)
else: 
    pth = input("Введите имя файла: ")
    f = open(pth+".txt","w")
    cnt = int(input("введите кол-во тестовых вычислений : "))

    for i in range(cnt) :
        A = random.randrange(0, 2**32)
        B = random.randrange(0, 2**32)
        C = random.randrange(0, 2**32)
        D = random.randrange(0, 2**32)
        Q = get_calc(A,B,C,D)
        qs = int(Q)
        f.write(str(A)+" "+str(B)+" "+str(C)+" "+str(D)+" "+str(qs)+ "\n")
