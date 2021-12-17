
#include "server.h"
#include "ui_server.h"
#include <string>

Server::Server(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::Server)
{
    ui->setupUi(this);

    QString regExpTimeLine = "^[0-9]{2}:[0-5][0-9]:[0-5][0-9]$";
    QRegExp timeRegExp(regExpTimeLine);
    timeValidator.setRegExp(timeRegExp);

    ui->timeEdit->setValidator(&timeValidator);

    QString ipRange = "(?:[0-1]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])";
    QRegExp ipRegex("^" + ipRange
                    + "\\." + ipRange
                    + "\\." + ipRange
                    + "\\." + ipRange + "$");
    QRegExpValidator *ipValidator = new QRegExpValidator(ipRegex, this);
    ui->ipEdit->setValidator(ipValidator);
    ui->portEdit->setValidator(new QDoubleValidator(0,100,5,this));

    timeStr = "";
    time = 0;
    initialized = false;

    bytesReceived = 0;
    totalBytes = 0;
    totalDatagrams = 0;

    delay = 0;
    receiveCounter = 0;
    writeCounter = 0;              //bug

    buffer = new char[STORAGE_SIZE];

    received = false;
    done = true;
    rcv_stop = false;

    connect(&viewChangeTimer, &QTimer::timeout, this, &Server::changeTime);

    connect(&receiveTimer, &QTimer::timeout, this, &Server::stop);

    viewChangeTimer.setInterval(1000);
    viewChangeTimer.start();

    struct ReceiveParams rParams = {
        &serverSocket,
        &bytesReceived,
        &totalBytes,
        &totalDatagrams,
        buffer,
        &receiveCounter,
        &delay,
        &rcv_stop
    };

    struct WriteParams wParams = {
        &file,
        buffer,
        &receiveCounter,
        &writeCounter,
        &delay,
        &done,
        &received,
        &bytesReceived
    };
    fileName5 = QDir::currentPath();
    fileName = fileName5;
    ui->fileNameLineEdit->setText(fileName);
    ui->fileNameLineEdit->setToolTip(fileName);
    receiver = new Receiver(rParams);
    writter = new Writter(wParams);

    receiver->moveToThread(&receivingThread);
    writter->moveToThread(&writtingThread);

    fileDialogWindow = new QFileDialog(this);
    //connect(fileDialogWindow, &QFileDialog::fileSelected, this, &Server::selectFile);

    connect(&receivingThread, &QThread::started, ui->receiveState, &Led::startProcessing);
    connect(&receivingThread, &QThread::started, receiver, &Receiver::receive);
    connect(receiver, &Receiver::startReceiving, writter, &Writter::write);
    connect(receiver, &Receiver::startReceiving, ui->writeState, &Led::startProcessing);


    //новые кнопки->setState(OK_STATE)
    connect(receiver, &Receiver::startReceiving, this, &Server::ledGo);
    connect(receiver, &Receiver::startReceiving, this, &Server::ledGo);

    connect(receiver, &Receiver::endReceiving, this, &Server::ledEnd);
    connect(receiver, &Receiver::endReceiving, this, &Server::ledEnd);


    connect(receiver, &Receiver::startReceiving, this, &Server::writtingStarted);
    connect(writter, &Writter::UGOL, this, &Server::writtingUGOL);

    connect(&receivingThread, &QThread::finished, ui->receiveState, &Led::stopProcessing);
    connect(&writtingThread, &QThread::finished, ui->writeState, &Led::stopProcessing);
    connect(&writtingThread, &QThread::finished, this, &Server::writtingFinished);

    connect(writter, &Writter::ledStart, ui->checkState, &Led::startProcessing);
    connect(writter, &Writter::ledEnd, ui->checkState, &Led::stopProcessing);

    ui->stopButton->setDisabled(true);
    ui->infoEdit->setFocus();
/*
    ui->infoEdit->append("Вас приветствует программа приёма данных Ethernet!");
    ui->infoEdit->append("Для успешной работы сервера необходимо, чтобы ваш сетевой адаптер был настроен верно:\nIP-адрес: 172.16.4.102");
    ui->infoEdit->append("---------------------------------------------------------");
    ui->infoEdit->append("Алгоритм работы:");
    ui->infoEdit->append("1. Выберите файл для записи");
    ui->infoEdit->append("2. Введите время работы сервера");
    ui->infoEdit->append("3. Введите порт и ip приложения");
    ui->infoEdit->append("4. Нажмите кнопку \"Старт\"");
    ui->infoEdit->append("Для остановки приёма нажмите кнопку\"Стоп\"");
    ui->infoEdit->append("Когда сервер заканчивает приём, дождитесь, пока запишутся все данные в файл");
    ui->infoEdit->append("---------------------------------------------------------");
*/
}

Server::~Server()
{
    delete ui;
}

int Server::initServer()
{
    WSADATA ws;

    int err = WSAStartup(MAKEWORD(2,2), &ws);
    if (err != 0){
        ui->infoEdit->append("Ошибка инициализации Win API! Код ошибки: " + QString::number(WSAGetLastError()));
        return -1;
    }
    ui->infoEdit->append("Win API успшено инициализировано!");

    serverSocket = socket(AF_INET, SOCK_DGRAM, 0);
    if (serverSocket == INVALID_SOCKET){
        ui->infoEdit->append("Ошибка создания сокета! Код ошибки: " + QString::number(WSAGetLastError()));
        ui->sockState->setState(ERROR_STATE);
        WSACleanup();
        return -2;
    }
    ui->infoEdit->append("Сокет успешно создан!");
    ui->sockState->setState(OK_STATE);
    cout << "Socket initializing" << endl;

    sockaddr_in server_addr;
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(port.toInt());
    //server_addr.sin_addr.s_addr = inet_addr(IP_ADDR);
    server_addr.sin_addr.s_addr = inet_addr(qPrintable(ip));
    cout << port.toInt() << endl;
    cout << qPrintable(ip) << endl;


    if (bind(serverSocket, (sockaddr *) &server_addr, sizeof(server_addr)) == SOCKET_ERROR){
        ui->infoEdit->append("Ошибка привязки сокета к IP-адресу и порту! Код ошибки: " + QString::number(WSAGetLastError()));
        ui->bindState->setState(ERROR_STATE);
        closesocket (serverSocket);
        return -3;
    }
    ui->infoEdit->append("Сокет успешно привязан к IP-адресу и порту");
    ui->bindState->setState(OK_STATE);
    cout << "Binding OK" << endl;

    initialized = true;
    return 0;
}

void Server::start()
{

}

void Server::stop()
{
    receiveTimer.stop();
    received = true;
    initialized = false;
    rcv_stop = true;
    WSACancelBlockingCall();
    closesocket(serverSocket);
    receivingThread.exit();
    ui->receiveState->setState(OK_STATE);
    ui->infoEdit->append("---------------------------------------------------------");
    ui->infoEdit->append("Данные получены!");
    ui->infoEdit->append("Байт: " + QString::number(totalBytes));
    ui->infoEdit->append("Датаграм: " + QString::number(totalDatagrams));

    ui->startButton->setDisabled(false);
    ui->stopButton->setDisabled(true);
    ui->timeEdit->setReadOnly(false);

    //timeStr = "";    //Delete time in label
    validateTimeStr();
}

void Server::changeTime()
{
    if (!initialized || time == 0) return;

    time--;

    int t = time;

    QString hours = QString::number(t / 3600);
    t -= hours.toInt() * 3600;
    QString mins = QString::number(t / 60);
    t -= mins.toInt() * 60;
    QString secs = QString::number(t);

    if (hours.length() == 1) hours = "0" + hours;
    if (mins.length() == 1) mins = "0" + mins;
    if (secs.length() == 1) secs = "0" + secs;

    timeStr = hours + ":" + mins + ":" + secs;

    ui->timeEdit->setText(timeStr);
}

void Server::on_startButton_clicked()       //нажатие кнопки старт
                                            //проверка открытия файла
                                            //Запись в файл
                                            //
{

    fileName = ui->fileNameLineEdit->text() + "/output.dat";
    if(fileName == "/output.dat" || fileName == ""){
        ui->infoEdit->append("Не выбрана папка для записи файлов");
        return;
    }

    if (!done) {
        ui->infoEdit->append("Сервер еще не готов к работе! Подождите, когда завершится запись данных в файл!");
        return;
    }

    reset();
    ui->infoEdit->setFocus();
    received = false;
    rcv_stop = false;
    validateTimeStr();
    if (!time) {
        ui->infoEdit->append("Пожалуйста, укажите время, отличное от 00:00:00");
        return;
    }

    file.open(fileName.toUtf8().data(), ios::binary);
    qDebug() << fileName;
    if (!file.is_open()) {
        ui->infoEdit->append("Невозможно открыть файл для записи. Пожалуйста, выберите другой файл!");
        ui->fileState->setState(ERROR_STATE);
        return;
    }

    writter->fileName = fileName;
    qDebug() << writter->fileName << " 1 2 3";

    file << "";
    ui->infoEdit->append("Открываю файл для записи!");
    ui->fileState->setState(OK_STATE);
    port = ui->portEdit->text();
    ip = ui->ipEdit->text();
    initServer();
    done = false;
    if (!initialized) {
        done = true;
        return;
    }


    receiveTimer.start(time * 1000);

    receivingThread.start();
    writtingThread.start();

    ui->infoEdit->append("Начинаю принимать данные!");

    ui->startButton->setDisabled(true);
    ui->stopButton->setDisabled(false);
    ui->timeEdit->setReadOnly(true);
}

void Server::on_stopButton_clicked()        //Остановка работы
{
    ui->infoEdit->append("Остановка работы...");
    stop();
    ui->infoEdit->setFocus();
    ui->infoEdit->append("Проверка файла...");
}

void Server::validateTimeStr()              //Изменение строки времени
{
    int pos = 0;
    if (timeValidator.validate(timeStr, pos) != QValidator::Acceptable) {
        for (int curLength = timeStr.length(); curLength < 8; curLength++) {
            if(curLength == 2 || curLength == 5)
                timeStr += ":";
            else
                timeStr += "0";
        }
        ui->timeEdit->setText(timeStr);
    }
    QStringList timeValues = timeStr.split(":");
    time = timeValues[0].toInt() * 3600 + timeValues[1].toInt() * 60 + timeValues[2].toInt();
}

void Server::on_timeEdit_textChanged(const QString &arg1)      //-\\-
{
    if ((timeStr.length() < arg1.length()) && (arg1.length() == 2 || arg1.length() == 5))
        ui->timeEdit->setText(arg1 + ":");
    timeStr = arg1;

}


void Server::setIndicatorsDefaultState()
{
    ui->fileState->setState(DISABLE_STATE);
    ui->sockState->setState(DISABLE_STATE);
    ui->bindState->setState(DISABLE_STATE);
    ui->receiveState->setState(DISABLE_STATE);
    ui->writeState->setState(DISABLE_STATE);
    ui->checkState->setState(DISABLE_STATE);
}

void Server::reset()
{


    initialized = false;

    bytesReceived = 0;
    totalBytes = 0;
    totalDatagrams = 0;
    delay = 0;
    receiveCounter = 0;
    writeCounter = 0;
    received = false;
    rcv_stop = false;

    setIndicatorsDefaultState();
}


void Server::on_selectFileButton_clicked()     //Выбор местоположения файлов с потерями и повторами
{
    ui->fileNameLineEdit->setText(QFileDialog::getExistingDirectory(0, "open", ""));
    fileName = ui->fileNameLineEdit->text();
    qDebug() << fileName;

    fileName += "/output.dat";
    qDebug() << fileName;
}

void Server::writtingFinished()
{
    ui->writeState->setState(OK_STATE);
    ui->infoEdit->append("Данные записаны на диск!");
    ui->infoEdit->append("Работа завершена!");
    ui->infoEdit->append("---------------------------------------------------------");
    file.close();
}

void Server::writtingStarted()
{
    ui->infoEdit->append("Начинаю запись в файл!");
}

void  Server::writtingUGOL()
{ 
    char buf[5] = {0,0,0,0,0};
    itoa(writter->u[0]*256+writter->u[1],buf,16);
    ui->label_ysv->setText(QString(buf));
     ui->infoEdit->append(QString(buf));
}


void Server::on_selectFile2Button_clicked()
{
    ui->fileDirLineEdit->setText(QFileDialog::getExistingDirectory(0, "open", ""));
    fileDirName = ui->fileDirLineEdit->text();
    qDebug() << fileDirName;

    fileDirName += "/packet.hex";
    qDebug() << fileDirName;

}




void Server::on_pushButton_2_clicked()
{
    fileDirName = ui->fileDirLineEdit->text() + "/packet.hex";

    if(fileDirName == "/packet.hex" || fileDirName == ""){
        ui->infoEdit->append("Не выбраны файлы для отправки");
        return;
    }


    port = ui->portEdit->text();
    ip = ui->ipEdit->text();

    WSADATA ws;

    int err = WSAStartup(MAKEWORD(2,2), &ws);
    if (err != 0){
        ui->infoEdit->append("Ошибка инициализации Win API! Код ошибки: " + QString::number(WSAGetLastError()));
        return;
    }
    ui->infoEdit->append("Win API успшено инициализировано!");

    serverSocket = socket(AF_INET, SOCK_DGRAM, 0);
    if (serverSocket == INVALID_SOCKET){
        ui->infoEdit->append("Ошибка создания сокета! Код ошибки: " + QString::number(WSAGetLastError()));
        ui->sockState->setState(ERROR_STATE);
        WSACleanup();
        return;
    }
    ui->infoEdit->append("Сокет успешно создан!");
    ui->sockState->setState(OK_STATE);
    cout << "Socket initializing" << endl;

    sockaddr_in server_addr;
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(port.toInt());
    //server_addr.sin_addr.s_addr = inet_addr(IP_ADDR);
    server_addr.sin_addr.s_addr = inet_addr(qPrintable(ip));
    cout << port.toInt() << endl;
    cout << qPrintable(ip) << endl;


    if (bind(serverSocket, (sockaddr *) &server_addr, sizeof(server_addr)) == SOCKET_ERROR){
        ui->infoEdit->append("Ошибка привязки сокета к IP-адресу и порту! Код ошибки: " + QString::number(WSAGetLastError()));
        ui->bindState->setState(ERROR_STATE);
        closesocket (serverSocket);
        return;
    }



    ui->infoEdit->append("Сокет успешно привязан к IP-адресу и порту");

    cout << "Binding OK" << endl;

    sockaddr_in client_addr;
    client_addr.sin_addr.S_un.S_addr = inet_addr(IP_ADDR);
    client_addr.sin_family = AF_INET;
    client_addr.sin_port = htons(5000);
    int client_addr_size = sizeof(client_addr);


    char buff[528];
    FILE * f = fopen(fileDirName.toUtf8().data(),"r");
    if (!f){
        ui->infoEdit->append("Невозможно открыть файл packet.hex error");
        return;
    }

    qDebug() << f;
    for (int i = 0; i < 528; i++) {
        int in_a;
        fscanf(f,"%x",&in_a);
        qDebug() << in_a;
        buff[i] = (char)in_a;
    }
    qDebug()<<"---------";


    sendto(serverSocket, buff, sizeof(buff), 0, (sockaddr *)&client_addr, client_addr_size);

    WSACancelBlockingCall();
    closesocket(serverSocket);

    ui->receiveState->setState(OK_STATE);
    ui->infoEdit->append("---------------------------------------------------------");
    ui->infoEdit->append("Данные отправлены!");

}

void Server::ledGo()
{
    ui->goState->setState(OK_STATE);
    ui->goState_2->setState(OK_STATE);
}

void Server::ledEnd()
{
    ui->goState->setState(PROCESSING_2_STATE);
    ui->goState_2->setState(PROCESSING_2_STATE);
}
