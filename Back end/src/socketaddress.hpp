#ifndef SOCKETADDRESS_H
#define SOCKETADDRESS_H
#include <iostream>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <unistd.h>
#include <netdb.h>
#include <memory>

class SocketAddress {
  public:
    SocketAddress(uint32_t inAddress, uint16_t inPort);
    SocketAddress(const sockaddr_in& inSockAddr);
    SocketAddress();
    sockaddr_in GetSocketAddress() const;
    socklen_t GetSize() const;
  private:
    sockaddr_in server_addr;
};

typedef std::shared_ptr<SocketAddress> SocketAddressPtr;

#endif
