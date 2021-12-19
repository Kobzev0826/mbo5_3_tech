import matplotlib.pyplot as plt
import numpy as np

def file_Convert(name_read, name_write):
    file = open(name_read, 'r')
    file_w = open(name_write, 'w')

    i=0
    counter_p=0
    while True:
        line = file.readline()
        if not line:
            break
        A = line.split(' ')
        if len(A) >3:
            file_w.write(A[1] + ' ' + A[2]+'\n')

            if i != 0:
                if (int(A[3],16) - counter_p > 1):
                    print('error', A[3], int(A[3],16)- counter_p)

            counter_p = int(A[3], 16)
            i = i + 1
        #DATA_1.append(int(A[1],16))


    file.close()
    file_w.close()
    print('END!')
    #return DATA_1


# открывает чистый файл и выводит данные по 1 каналу
def plot_data (file):
    file = open(file, 'r')
    DATA_1 = []
    DATA_2 = []
    while True:
        line = file.readline()
        if not line:
            break
        A = line.split(' ')
        DATA_1.append(int(A[0], 16))# / 2047) * 2.5)
        DATA_2.append(int(A[1], 16))
    X=np.linspace(0,len(DATA_1),len(DATA_1))

    plt.figure()
    #fig, ax1,ax2 = plt.subplots(2, 1, num='ADC_1')
    plt.subplot(2,1,1)
    plt.plot(X,DATA_1,'b')
    plt.grid(which='major')

    plt.subplot(2, 1, 2)
    plt.plot(X,DATA_2,'r')
    plt.grid(which='major')

    plt.show()


def setting_convert(name,name_w):
    string = '00 00 00 00 00 55 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00'
    string_2 = '00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00'
    file = open(name, 'r')
    string_1=str()
    while True:
        line = file.readline()
        if not line:
            break

        data = line.split()
        if len(data) ==1:
            print(str((data[0]))[2:4])
            string_1 = string_1 + ' ' + str(data[0])[0:2] + ' ' + str(data[0])[2:4]


    file.close()
    file_w = open(name_w,'w')
    file_w.write(string + string_1 + string_2)


if __name__ == '__main__':
    file = 'output.dat' # входной файл дампа
    file_w = 'output_adc_and_convolution.txt' #ыходной чистый файл с сырыми данными
    #file_Convert(file, file_w) # конвертирование записанного файла
    plot_data(file_w) # отображение "чистого" файла
    #setting_convert('opora.txt','opora.hex')