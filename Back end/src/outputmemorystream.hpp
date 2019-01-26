#ifndef OUTPUTMEMORYSTREAM_H
#define OUTPUTMEMORYSTREAM_H

#define STREAM_ENDIANNESS 0
#define PLATFORM_ENDIANNESS 0

#include <iostream>
#include <string>
#include <vector>
#include "ByteSwap.hpp"
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <memory>

class OutputMemoryStream {
  public:
    OutputMemoryStream(): mBuffer(nullptr), mHead(0), mCapacity(0) {ReallocBuffer(32);}
    ~OutputMemoryStream(){std::free(mBuffer);}
    const char* GetBufferPtr() const { return mBuffer;}
    uint32_t GetLength() const { return mHead;}
    void Write(const void* inData, size_t inByteCount);
    template< typename T > void Write( T inData )
    {
  		static_assert( std::is_arithmetic< T >::value ||
  					  std::is_enum< T >::value,
  					  "Generic Write only supports primitive data types" );

  		if( STREAM_ENDIANNESS == PLATFORM_ENDIANNESS )
  		{
  			Write( &inData, sizeof( inData ) );
  		}
  		else
  		{
  			T swappedData = ByteSwap( inData );
  			Write( &swappedData, sizeof( swappedData ) );
  		}
    }

    void Write( const std::string& inString )
  	{
  		size_t elementCount = inString.size();
  		Write( elementCount );
  		Write( inString.data(), elementCount * sizeof(char));
  	}
    template< typename T > void Write(const std::vector<T>& inVector);
    void Write(const cv::Mat& mat);
  private:
    void ReallocBuffer(uint32_t inNewLenght);
    char* mBuffer;
    uint32_t mHead;
    uint32_t mCapacity;
};

#endif
