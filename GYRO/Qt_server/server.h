#ifndef SERVER_H
#define SERVER_H

#include <stdio.h>
#include <stdlib.h>
#include <winsock2.h>
#include <windows.h>
#include <iostream>
#include <fstream>
#include "pthread.h"
#include <ctime>
#include <unistd.h>

#include <QMainWindow>
#include <QThread>
#include <QTimer>
#include <QRegExpValidator>
#include <QString>
#include <QFileDialog>
#include <QDir>
#include <QDebug>

#include <receiver.h>
#include <writter.h>
#include <led.h>

#define IP_ADDR "192.168.0.113"
#define IP_PORT 5000
//#define BUFFER_SIZE 1445
#define STORAGE_SIZE 230400000

using namespace std;

QT_BEGIN_NAMESPACE
namespace Ui { class Server; }
QT_END_NAMESPACE



class Server : public QMainWindow
{
    Q_OBJECT

    int initServer();

    void checkFile();
    void validateTimeStr();
    void setIndicatorsDefaultState();
    void reset();

public:
    Server(QWidget *parent = nullptr);
    ~Server();

public slots:
    void start();
    void stop();
    void changeTime();
    void ledGo();
    void ledEnd();
    //void selectFile(const QString &);
    //int control();

private slots:

    void on_startButton_clicked();

    void on_stopButton_clicked();

    //void on_resetButton_clicked();

    void on_timeEdit_textChanged(const QString &arg1);

    void on_selectFileButton_clicked();

    void writtingFinished();

    void writtingStarted();
    void writtingUGOL();

    void on_selectFile2Button_clicked();

    void on_pushButton_2_clicked();

private:

    ofstream file;
    ifstream file_chek;
    QFileDialog * fileDialogWindow;

    Ui::Server *ui;

    bool initialized;

    SOCKET serverSocket;

    int bytesReceived;
    long long totalBytes;
    long long totalDatagrams;

    int delay;
    unsigned short receiveCounter;
    unsigned short writeCounter;

    char * buffer;

    bool received;
    bool done;
    bool rcv_stop;

    int time;

    QString timeStr;
    QString fileName;
    QString fileDirName;
    QString fileName5;
    QString port;
    QString ip;

    QTimer receiveTimer;
    QTimer viewChangeTimer;

    QThread writtingThread;
    QThread receivingThread;

    Receiver * receiver;
    Writter * writter;

    QRegExpValidator timeValidator;
};
#endif // SERVER_H
