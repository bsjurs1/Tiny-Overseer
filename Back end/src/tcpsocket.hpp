#ifndef TCPSOCKET_H
#define TCPSOCKET_H
#include <iostream>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <unistd.h>
#include <netdb.h>
#include <set>
#include "socketaddress.hpp"
#include <memory>

typedef int SOCKET;

class TCPSocket {
  public:
    TCPSocket();
    ~TCPSocket();
    int Connect(const SocketAddress &inAddress);
    int Bind(const SocketAddress& inToAddress);
    int Listen(int inBackLog = 32);
    std::shared_ptr<TCPSocket> Accept(SocketAddress& inFromAddress);
    int Send(const char* inData, int inLen);
    int Receive(void* inData, int inLen);
    SOCKET getMSocket() {return mSocket;}
    void Close();
  private:
    TCPSocket(SOCKET inSocket) : mSocket(inSocket) {}
    SOCKET mSocket;
};

typedef std::shared_ptr<TCPSocket> TCPSocketPtr;

#endif
