#include "tcpsocket.hpp"
#define INVALID_SOCKET  (SOCKET)(~0)

TCPSocket::TCPSocket(){
  mSocket = socket(AF_INET, SOCK_STREAM, 0);
  //std::cout << "TCPSocket()" << std::endl;
  if(mSocket < 0){
    std::cout << "\nError establishing socket..." << strerror(errno) << std::endl;
    exit(1);
  }
}

int TCPSocket::Connect(const SocketAddress &inAddress){
  sockaddr_in socketAddress = inAddress.GetSocketAddress();
	//std::cout << "Connect()" << std::endl;
  int err = connect(mSocket, (struct sockaddr *) &socketAddress, inAddress.GetSize());
  if(err < 0){
    std::cout << "Error. TCPSocket::Connect " << strerror(errno) << std::endl;
    return err;
  }
  return 0;
}

int TCPSocket::Listen(int inBackLog){
  int err = listen(mSocket, inBackLog);
	std::cout << "Listen()" << std::endl;
  if(err < 0){
    std::cout << "Error. TCPSocket::Listen" << strerror(errno) << std::endl;
    return err;
  }
  return 0;
}

TCPSocketPtr TCPSocket::Accept(SocketAddress &inFromAddress){
  socklen_t length = inFromAddress.GetSize();
  sockaddr_in socketAddress = inFromAddress.GetSocketAddress();
	std::cout << "Accept()" << std::endl;
  SOCKET newSocket = accept(mSocket, (struct sockaddr *)&socketAddress, &length);
  if(newSocket != INVALID_SOCKET){
    return TCPSocketPtr(new TCPSocket(newSocket));
  }
  else{
    std::cout << "Error. TCPSocket::Accept" << strerror(errno) << std::endl;
    return nullptr;
  }
}

int TCPSocket::Send(const char *inData, int inLen){
	//std::cout << "Send()" << std::endl;
  int bytesSentCount = send(mSocket , reinterpret_cast<const char*> (inData), inLen, 0);
	std::cout << "Sent nr of bytes: " << bytesSentCount << std::endl;
  if(bytesSentCount < 0){
    std::cout << "Error. TCPSocket::Send" << strerror(errno) << std::endl;
    return bytesSentCount;
  }
  return bytesSentCount;
}

int TCPSocket::Receive(void *inData, int inLen){
	//std::cout << "Receive()" << std::endl;
  int bytesReceivedCount = recv(mSocket, static_cast<char*>(inData), inLen, 0);
  if(bytesReceivedCount < 0){
    std::cout << "Error. TCPSocket::Receive" << strerror(errno) << std::endl;
    return -1;
  }
  return bytesReceivedCount;
}

int TCPSocket::Bind(const SocketAddress &inToAddress){
	std::cout << "Bind()" << std::endl;
  sockaddr_in socketAddress = inToAddress.GetSocketAddress();
  int err = bind(mSocket, (struct sockaddr*) &socketAddress, inToAddress.GetSize());
  if(err != 0){
    std::cout << "Error. TCPSocket::Bind" << strerror(errno) << std::endl;
    return -1;
  }
  return 0;
}

TCPSocket::~TCPSocket(){
	std::cout << "~TCPSocket()" << std::endl;
  //close(mSocket);
}

void TCPSocket::Close(){
	close(mSocket);
}
