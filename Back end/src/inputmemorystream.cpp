#include "inputmemorystream.hpp"
const uint32_t kMaxPacketSize = 1470;

void InputMemoryStream::Read( void* outData, uint32_t inByteCount ){
	uint32_t resultHead = mHead + inByteCount;
	if(resultHead > mCapacity)
	{
    std::cout << "InputMemoryStream::Read()" << std::endl;
	}
	memcpy( outData, mBuffer + mHead, inByteCount );
	mHead = resultHead;
}

void InputMemoryStream::Read(std::vector<unsigned char> &outVector){
	size_t elementCount;
	Read(elementCount);
	outVector.resize(elementCount);
	for(unsigned char& element : outVector){
		Read(element);
	}
}

template<typename T> void InputMemoryStream::Read(std::vector<T> &outVector){
	size_t elementCount;
	Read(elementCount);
	outVector.resize(elementCount);
	for(const T& element : outVector){
		Read(element);
	}
}

void InputMemoryStream::Read(cv::Mat& mat){
	std::vector<unsigned char> buf;
	Read(buf);
	mat = cv::imdecode(buf, CV_LOAD_IMAGE_COLOR);
}
