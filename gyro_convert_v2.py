import matplotlib.pyplot as plt
import numpy as np


# функция строит графики на одном поле
# param = 1 только данные от АЦП
# param = 2 добавляется на график угловая скорость
# param = 3 только угловая скорость
def plot_one_graph(DATA_0=[],DATA_1=[],DATA_2=[], DATA_log=[], param=0):
    print('-----START plot------------')
    t=10** (-6)
    Voltage = float(2.5/4095)
    plt.figure()
    if int(param) == 3:
        plt.plot(DATA_log, 'black')

    elif int(param) == 2:
        plt.plot(DATA_0, DATA_log, 'black')
        plt.plot(DATA_0, DATA_1, 'b')
        plt.plot(DATA_0, DATA_2, 'r')
    elif int(param) == 1:
        plt.plot([x*t for x in DATA_0], [x * Voltage for x in DATA_1], 'b')
        plt.plot([x*t for x in DATA_0], [x * Voltage for x in DATA_2], 'r')
        plt.xlabel('t')
        plt.ylabel('Напряжение [В]')
    else:
        print('BAD parameter')

    plt.grid(which='major')
    plt.show()


def plot_2_graph(DATA_0=[],DATA_1=[],DATA_2=[]):
    plt.figure()

    plt.subplot(2, 1, 1)
    plt.plot(DATA_0, DATA_1, 'b')
    plt.grid(which='major')
    plt.xlabel('t')
    #plt.title('сырой поток')
    plt.ylabel('Напряжение [В]')
    # plt.ylim(top=2.5,bottom=0)

    plt.subplot(2, 1, 2)
    plt.plot(DATA_0, DATA_2, 'r')
    plt.grid(which='major')
    #plt.title('результат свертки')
    plt.xlabel('t')
    plt.ylabel('Напряжение [В]')

    plt.show()

def data_log_cnt(file):
    print('-------START PARSING ' + str(file) + ' file----------')
    DATA=[]
    file_log = open(file, 'r')
    while True:
        line = file_log.readline().split()
        if not line:
            break
        DATA+= [float(int(str(line[5]) + str(line[6]),16)) * 100] * 256
    return DATA
    print('-------PARSING ' + str(file) + ' file successfull----------')
    file_log.close()


def data_log_speed(file,V,K):
    print('-------START PARSING ' + str(file) + ' file----------')
    DATA=[]
    file_log = open(file, 'r')
    while True:
        line = file_log.readline().split()
        if not line:
            break
        DATA.append(float(int(str(line[5]) + str(line[6]),16)))#*10**(-6)*V*K)
    file_log.close()
    print('-------PARSING ' + str(file) + ' file successfull----------')
    for elem in DATA:
        print(elem, elem *10**(-6)*V*K)
    return [x*10**(-6)*V*K for x in DATA]


def pars_A_file(A):
    print('-------START PARSING ' + str(A) + ' file----------')
    DATA_0 = []
    DATA_1 = []
    DATA_2 = []
    file = open(A, 'r')
    while True:
        line = file.readline().split()
        if not line:
            break
        '''if len( line[1])==1:
            line[1] = '0'+line[1]
        if len( line[2])==1:
            line[2] = '0'+line[2]'''
        DATA_1.append(float(int(line[1],16) ))
        DATA_2.append(float(int(line[2],16) ))
        DATA_0.append(float(int(line[0],16)))
    file.close()
    print('-------PARSING ' + str(A) + ' file successfull----------')
    return DATA_0,DATA_1,DATA_2


def plot_file(file_A,file_log, param, plot_mode,V,K):
    DATA_0 = []
    DATA_1 = []
    DATA_2 = []
    DATA_log = []
    if int(param) == 3:
        DATA_log = data_log_speed(file_log,V,K)
        if int(plot_mode)==1:
            plot_one_graph( DATA_log=DATA_log, param=param)

    elif int(param) == 1:
        DATA_0, DATA_1, DATA_2 = pars_A_file(file_A)
        if int(plot_mode) == 1:
            plot_one_graph(DATA_0=DATA_0, DATA_1=DATA_1, DATA_2=DATA_2, param=param)
        elif int(plot_mode) == 0:
            plot_2_graph(DATA_0=DATA_0, DATA_1=DATA_1, DATA_2=DATA_2)
    elif int(param) == 2:
        DATA_log = data_log_cnt(file_log)
        DATA_0, DATA_1, DATA_2 = pars_A_file(file_A)
        if int(plot_mode) == 1:
            plot_one_graph(DATA_0=DATA_0, DATA_1=DATA_1, DATA_2=DATA_2, DATA_log=DATA_log, param=param)
        elif int(plot_mode) == 0:
            plot_2_graph(DATA_0=DATA_0, DATA_1=DATA_1, DATA_2=DATA_2)
    else:
        print('BAD param')


# param = 1 только данные от АЦП
# param = 2 добавляется на график угловая скорость
# param = 3 только угловая скорость
if __name__ == '__main__':
    # inputparameters of laser
    V= 1* 10 ** 9 #скорость перестройки лазера GHz/sec
    K= 3.3 * 10 **(-3) #масштабный коэффициент
    file_A = 'A1.dat'
    log_file='log.dat'
    print(K*V*10**(-6))
    mode = 1
    PLOT = 0
    plot_file(file_A, file_log=log_file, param=mode, plot_mode=PLOT, V=V, K=K)





