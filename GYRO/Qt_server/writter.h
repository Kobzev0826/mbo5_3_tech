#ifndef WRITTER_H
#define WRITTER_H

#include <fstream>
#include <ctime>
#include <unistd.h>

#include <QString>
#include <QObject>
#include <QThread>

using namespace std;

struct WriteParams {
    ofstream * file;
    char * buffer;

    unsigned short * receiveCounter;
    unsigned short * writeCounter;
    int * delay;

    bool * done;
    bool * received;
    int * totalBytes;
};

class Writter : public QObject
{
    Q_OBJECT

    struct WriteParams params;
public:
    char u[3];
    explicit Writter(QObject *parent = nullptr);
    Writter(struct WriteParams, QObject *parent = nullptr);
    int control();
    QString fileName;
    QString fileName5;
    QString fileName_Log;

    void write();
signals:
    void ledStart();
    void ledEnd();
    void UGOL();

};

#endif // WRITTER_H
