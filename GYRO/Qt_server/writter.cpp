#include "writter.h"
#include "receiver.h"
#include <QDebug>
#include <QDir>

bool done_chk = 0;

Writter::Writter(QObject *parent) : QObject(parent) {

}

Writter::Writter(struct WriteParams _p, QObject * parent) : QObject(parent) {
    params.file = _p.file;
    params.buffer = _p.buffer;
    params.receiveCounter = _p.receiveCounter;
    params.writeCounter = _p.writeCounter;
    params.delay = _p.delay;
    params.done = _p.done;
    params.received = _p.received;
    params.totalBytes = _p.totalBytes;
}

void Writter::write() {     //чтение из буфера и запись в файл
    char tmp[2305];
    tmp[2304] = '\0';
    while (1) {
        if (((*params.writeCounter < *params.receiveCounter)
             && (*params.delay == 0))
                || (*params.delay > 0)
                ) {


            if(*params.delay > 0)
                cout << *params.delay << endl;


            memcpy(tmp, &params.buffer[*params.writeCounter * 2304], 2304);

            if((tmp[3] == static_cast<char>(1) )|| (*params.writeCounter == 100))
            {
                u[0] = tmp[4];
                u[1] = tmp[5];
                emit UGOL();
            }

            for (int i = 0; i < *params.totalBytes; i++){

                if(i > 127){
                    if(i%4 == 0){
                        (*params.file) << hex << endl << (i-123)/4 - 1<< ' ';
                    }
                }

                if(tmp[i] < 0){
                    (*params.file) << hex << (256 + static_cast<int>(tmp[i]));
                }else if(tmp[i] >= 0 && tmp[i] < 16)
                    (*params.file) << hex << '0' << static_cast<int>(tmp[i]);
                else (*params.file) << hex << static_cast<int>(tmp[i]);


                if(i > 127){
                    if(i%2 == 1){
                        (*params.file) << hex << ' ';
                    }

                    if(i%4 == 3){
                        for(int j = 124; j < 128; j++)
                        {
                            if(tmp[j] < 0){
                                (*params.file) << hex << (256 + static_cast<int>(tmp[j]));
                            }else if(tmp[j] >= 0 && tmp[j] < 16)
                                (*params.file) << hex << '0' << static_cast<int>(tmp[j]);
                            else (*params.file) << hex << static_cast<int>(tmp[j]);
                        }
                    }
                }

                if(i == 1151)
                    (*params.file) << endl << endl;

            }

            (*params.writeCounter)++;
            if(*params.writeCounter == 100){
                (*params.delay)--;
                (*params.writeCounter) = 0;
            }

        } else {
            if (!*params.received)
                usleep(50);
            else {
                break;
            }
        }
    }

    emit ledStart();

    params.file->close();

    emit ledEnd();

    (*params.done) = true;
    this->thread()->quit();
}
