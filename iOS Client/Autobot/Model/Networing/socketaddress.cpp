#include "socketaddress.hpp"

SocketAddress::SocketAddress(uint32_t inAddress, uint16_t inPort){
  server_addr.sin_family = AF_INET;
  server_addr.sin_addr.s_addr = htonl(inAddress);
  server_addr.sin_port = htons(inPort);
  std::cout << "created socketaddress with: " << std::endl;
  std::cout << "IP: " << server_addr.sin_addr.s_addr << std::endl;
  std::cout << "Port: " << htons(server_addr.sin_port) << std::endl;
  std::cout << "Sin Family: " << server_addr.sin_family << std::endl;
}

SocketAddress::SocketAddress(char* inAddress, uint16_t inPort){
	server_addr.sin_family = AF_INET;
	struct sockaddr_in antelope;
	inet_aton(inAddress, &antelope.sin_addr); // store IP in antelope
	server_addr.sin_addr = antelope.sin_addr;
	server_addr.sin_port = htons(inPort);
	std::cout << "created socketaddress with: " << std::endl;
	std::cout << "IP: " << server_addr.sin_addr.s_addr << std::endl;
	std::cout << "Port: " << htons(server_addr.sin_port) << std::endl;
	std::cout << "Sin Family: " << server_addr.sin_family << std::endl;
}

SocketAddress::SocketAddress(const sockaddr_in& inSockAddr){
  server_addr = inSockAddr;
}

SocketAddress::SocketAddress(){
  server_addr.sin_family = AF_INET;
  server_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  server_addr.sin_port = htons(1500);
}

sockaddr_in SocketAddress::GetSocketAddress() const{
  return server_addr;
}

socklen_t SocketAddress::GetSize() const {
  return sizeof(server_addr);
}
