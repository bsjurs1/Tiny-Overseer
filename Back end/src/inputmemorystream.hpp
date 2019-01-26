#ifndef INPUTMEMORYSTREAM_H
#define INPUTMEMORYSTREAM_H
#include <iostream>
#include <string>
#include <vector>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <memory>

class InputMemoryStream {
  public:
    InputMemoryStream(char* inBuffer, uint32_t inByteCount): mBuffer(inBuffer), mCapacity(inByteCount), mHead(0){};
    ~InputMemoryStream(){std::free(mBuffer); mBuffer = NULL;}
    uint32_t GetRemainingDataSize() const { return mCapacity - mHead;}
    void Read(void* outData, uint32_t inByteCount);
    template< typename T > void Read( T& outData )
  	{
  		static_assert( std::is_arithmetic< T >::value ||
  					   std::is_enum< T >::value,
  					   "Generic Read only supports primitive data types" );
  		Read( &outData, sizeof( outData ) );
  	}
    void Read(std::string& outString){
      size_t elementCount;
      Read(elementCount);
      char chars[elementCount];
  		Read(chars, elementCount*sizeof(char));
      outString = (std::string) chars;
      outString.resize(elementCount);
    }
    template<typename T> void Read(std::vector<T>& outVector);
    void Read(cv::Mat& mat);
    void Read(std::vector<unsigned char> &outVector);
  private:
    char* mBuffer;
    uint32_t mHead;
    uint32_t mCapacity;
};

#endif
