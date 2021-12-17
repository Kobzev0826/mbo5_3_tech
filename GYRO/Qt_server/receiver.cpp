#include "receiver.h"
#include <QDebug>
#include <ctime>
//#include <QTime>
#include <QElapsedTimer>


Receiver::Receiver(QObject *parent) : QObject(parent) {

}

Receiver::Receiver(struct ReceiveParams _p, QObject * parent) : QObject(parent) {
    params.serverSocket = _p.serverSocket;
    params.bytesReceived = _p.bytesReceived;
    params.totalBytes = _p.totalBytes;
    params.totalDatagrams = _p.totalDatagrams;
    params.buffer = _p.buffer;
    params.receiveCounter = _p.receiveCounter;
    params.delay = _p.delay;
    params.term = _p.term;
    triggered = false;
}

void Receiver::receive() {                  //Прием датаграмм
    QElapsedTimer startTime;
    double  endTime;

    listen(*params.serverSocket, 1);

    sockaddr_in client_addr;
    int client_addr_size = sizeof(client_addr);
    while(!(*params.term)){
            (*params.bytesReceived) = recvfrom(*params.serverSocket, params.buffer + (*params.receiveCounter * 2304), 2304, 0, (sockaddr *)&client_addr, &client_addr_size);
            if(*params.bytesReceived == SOCKET_ERROR){
                if (WSAGetLastError() == 2304) break;
                cout << "Package not accepted: " << WSAGetLastError() << endl;
                continue;
            }

            if (!(*params.totalBytes)) {
                triggered = true;
                emit startReceiving();
                startTime.start();
            }

             endTime = startTime.elapsed();

            (*params.totalBytes) += *params.bytesReceived;
            (*params.totalDatagrams)++;

            (*params.receiveCounter)++;
            if (*params.receiveCounter == 100) {
                (*params.delay)++;
                (*params.receiveCounter) = 0;
            }
    }



    cout << endTime << " " << "startTime" << endl;

    if (!triggered){
        emit startReceiving();
        emit endReceiving();
    }
}
