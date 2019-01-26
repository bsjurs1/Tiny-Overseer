#include "outputmemorystream.hpp"

void OutputMemoryStream::ReallocBuffer(uint32_t inNewLength){
	mBuffer = static_cast<char*>(std::realloc(mBuffer, inNewLength));
	mCapacity = inNewLength;
}

void OutputMemoryStream::Write( const void* inData,
							   size_t inByteCount )
{
	uint32_t resultHead = mHead + static_cast< uint32_t >(inByteCount);
	if( resultHead > mCapacity )
	{
		ReallocBuffer(std::max(mCapacity + int(inByteCount), std::max( mCapacity * 2, resultHead )));
	}
	std::memcpy( mBuffer + mHead, inData, inByteCount);
	mHead = resultHead;
}

template< typename T > void OutputMemoryStream::Write(const std::vector<T>& inVector){
	size_t elementCount = inVector.size();
	Write(elementCount);
	for(const T& element : inVector){
		Write(element);
	}
}

void OutputMemoryStream::WriteImage(const uint8_t* data, const int size){
	int numberOfElements = size/sizeof(uint8_t);
	for(int i = 0; i < numberOfElements; i++){
		uint8_t elem = *( data + (i * sizeof(uint8_t)));
		this->Write(elem);
	}
}

void OutputMemoryStream::Write(const cv::Mat& mat){
	std::vector<unsigned char> buf;
	cv::imencode(".jpg", mat, buf);
	Write(buf);
}

