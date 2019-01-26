#ifndef MAIN
#define MAIN
#include <iostream>
#include <vector>
#include <string>
#include "socketaddress.hpp"
#include "tcpsocket.hpp"
#include "outputmemorystream.hpp"
#include "inputmemorystream.hpp"
#include <thread>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/opencv.hpp>
#include <math.h>
#include <iomanip>
#include <ctime>
#include <fstream>

bool isContinueExecution = true;
const double horizontalFov = 1.1327247; //64.900347 degrees
const double verticalFov = 0.687336; //39.381454 degrees

struct AircraftGeoLocation{
  double latitude;
  double longitude;
  double heading;
  double altitude;
};

struct Location {
  double latitude;
  double longitude;
};
bool windowMade = false;
char *imageSharedMemory;
char* newImageFlagSharedMemory;
char* boundingBoxesReadyFlagSharedMemory;
char* boundingBoxesSharedMemory;
char* boundingBoxSize;
int* boundingBoxesStringSizeSharedMemory;

double radians(double degrees){
  return degrees * (M_PI / 180.000000);
}

double degrees(double radians){
  return radians * (180.000000 / M_PI);
}

Location calculateVincentysDirectWithLatitude(double lat, double lon, double distance, double initialBearing){
  
  const double φ1 = radians(lat);
  const double λ1 = radians(lon);
  const double α1 = radians(initialBearing);
  const double s = distance;
  
  const double a = 6378137.0;
  const double b = 6356752.314245;
  const double f = 0.0033528106647756;
  
  const double sinα1 = sin(α1);
  const double cosα1 = cos(α1);
  
  const double tanU1 = (1 - f) * tan(φ1);
  const double cosU1 = 1.0 / sqrt((1 + tanU1*tanU1));
  const double sinU1 = tanU1 * cosU1;
  
  const double σ1 = atan2(tanU1, cosα1);
  const double sinα = cosU1 * sinα1;
  const double cosSqα = 1 - sinα*sinα;
  const double uSq = cosSqα * (a*a - b*b) / (b*b);
  const double A = 1 + uSq/16384*(4096+uSq*(-768+uSq*(320-175*uSq)));
  const double B = uSq/1024 * (256+uSq*(-128+uSq*(74-47*uSq)));
  
  double cos2σM, sinσ, cosσ, Δσ;
  
  double σ = s / (b*A);
  double diff_σ;
  int iterations = 0;
  
  do{
    cos2σM = cos(2*σ1 + σ);
    sinσ = sin(σ);
    cosσ = cos(σ);
    Δσ = B*sinσ*(cos2σM+B/4*(cosσ*(-1+2*cos2σM*cos2σM) - B/6*cos2σM*(-3+4*sinσ*sinσ)*(-3+4*cos2σM*cos2σM)));
    diff_σ = σ;
    σ = s / (b*A) + Δσ;
    iterations += 1;
  }while(fabs(σ-diff_σ) > 1e-12 && iterations < 100);
  double x = sinU1*sinσ - cosU1*cosσ*cosα1;
  double φ2 = atan2(sinU1*cosσ + cosU1*sinσ*cosα1, (1-f)*sqrt(sinα*sinα + x*x));
  double λ = atan2(sinσ*sinα1, cosU1*cosσ - sinU1*sinσ*cosα1);
  double C = f/16*cosSqα*(4+f*(4-3*cosSqα));
  double L = λ - (1-C) * f * sinα * (σ + C*sinσ*(cos2σM+C*cosσ*(-1+2*cos2σM*cos2σM)));
  double λ2 = fmod((λ1 + L+3 * M_PI), (2*M_PI)) - M_PI;  // normalise to -180..+180
  double α2 = atan2(sinα, -x);
  α2 = fmod((α2 + 2*M_PI), (2*M_PI)); // normalise to 0..360
  
  double calculatedLatiude = degrees(φ2);
  double calculatedLongitude = degrees(λ2);
  // std::cout << calculatedLatiude << std::endl;
  // std::cout << calculatedLongitude << std::endl;
  std::cout << "calculateVincentysDirectWithLatitude" << std::endl;
  std::cout << std::setprecision (9) << calculatedLongitude << std::endl;
  std::cout << std::setprecision (9) << calculatedLatiude << std::endl;

  Location location;
  location.latitude = calculatedLatiude;
  location.longitude = calculatedLongitude;
  return location;
}

void displayImage(cv::Mat image){
    if(windowMade){
      cv::imshow( "Display window", image); // Show our image inside it.
    }
    else{
      windowMade = true;
      cv::namedWindow("Display window", cv::WINDOW_AUTOSIZE);
      cv::imshow( "Display window", image); // Show our image inside it.
    }
    if(cv::waitKey(30) >= 0) return;
    //cv::waitKey(0);
}

// Shared memory functions
int allocImageSharedMemory(){
  int shmid;
  // give your shared memory an id, anything will do
  key_t key = 12345666;
  // Setup shared memory, 11 is the size
  //if ((shmid = shmget(key, image.elemSize() * image.total(), IPC_CREAT | 0666)) < 0)
  if ((shmid = shmget(key, 3 * 90000, IPC_CREAT | 0666)) < 0)
  {
    printf("%s\n",strerror(errno));
    std::cout << errno << std::endl;
    printf("Error getting shared memory id\n");
    exit(1);
  }

  // Attached shared memory
  imageSharedMemory = (char *) shmat(shmid, NULL, 0);
  if (imageSharedMemory == (char *) -1)
  {
    printf("Error attaching shared memory id");
    exit(1);
  }

  return shmid;
}

int allocBoundingBoxesStringSizeSharedMemory(){
  int shmid;
  // give your shared memory an id, anything will do
  key_t key = 1234566677;
  // Setup shared memory, 11 is the size
  if ((shmid = shmget(key, 4, IPC_CREAT | 0666)) < 0)
  {
    printf("%s\n",strerror(errno));
    std::cout << errno << std::endl;
    printf("Error getting shared memory id\n");
    exit(1);
  }

  // Attached shared memory
  boundingBoxesStringSizeSharedMemory = (int *) shmat(shmid, NULL, 0);
  if (boundingBoxesStringSizeSharedMemory == (int *) -1)
  {
    printf("Error attaching shared memory id");
    exit(1);
  }

  return shmid;
}

int allocNewImageFlagSharedMemory(){
  int shmid;
  // give your shared memory an id, anything will do
  key_t key = 1234567;
  // Setup shared memory, 11 is the size
  //if ((shmid = shmget(key, image.elemSize() * image.total(), IPC_CREAT | 0666)) < 0)
  if ((shmid = shmget(key, 35, IPC_CREAT | 0666 )) < 0)
  {
    printf("%s\n",strerror(errno));
    std::cout << errno << std::endl;
    printf("Error getting shared memory id\n");
    exit(1);
  }

  // Attached shared memory
  newImageFlagSharedMemory = (char *) shmat(shmid, NULL, 0);
  if (newImageFlagSharedMemory == (char *) -1)
  {
    printf("Error attaching shared memory id");
    exit(1);
  }

  return shmid;
}

int allocBoundingBoxesReadyFlagSharedMemory(){
  int shmid;
  // give your shared memory an id, anything will do
  key_t key = 12345678;	
  // Setup shared memory, 11 is the size
  //if ((shmid = shmget(key, image.elemSize() * image.total(), IPC_CREAT | 0666)) < 0)
  if ((shmid = shmget(key, 35, IPC_CREAT | 0666)) < 0)
  {
    printf("%s\n",strerror(errno));
    std::cout << errno << std::endl;
    printf("Error getting shared memory id\n");
    exit(1);
  }

  // Attached shared memory
  boundingBoxesReadyFlagSharedMemory = (char *) shmat(shmid, NULL, 0);
  if (boundingBoxesReadyFlagSharedMemory == (char *) -1)
  {
    printf("Error attaching shared memory id");
    exit(1);
  }

  return shmid;
}

int allocBoundingBoxesSharedMemory(){
  int shmid;
  // give your shared memory an id, anything will do
  key_t key = 12345678910;
  // Setup shared memory, 11 is the size
  //if ((shmid = shmget(key, image.elemSize() * image.total(), IPC_CREAT | 0666)) < 0)
  if ((shmid = shmget(key, 10000, IPC_CREAT | 0666)) < 0)
  {
    printf("%s\n",strerror(errno));
	    std::cout << errno << std::endl;
    printf("Error getting shared memory id\n");
    exit(1);
  }
  // Attached shared memory
  boundingBoxesSharedMemory = (char *) shmat(shmid, NULL, 0);
  if (boundingBoxesSharedMemory == (char *) -1)
  {
    printf("Error attaching shared memory id");
    exit(1);
  }

  return shmid;
}

void deallocSharedMemory(int sharedMemoryShmid){
  shmdt((const void*) sharedMemoryShmid);
  shmctl(sharedMemoryShmid, IPC_RMID, NULL);
}

void writeImageToSharedMemory(cv::Mat image){
  std::cout << "elemSize: " << image.elemSize() << std::endl;
  std::cout << "total: " << image.total() << std::endl;

  memcpy(imageSharedMemory, image.data, image.elemSize() * image.total());
}

void writeNewImageFlagToSharedMemory(int flag){
  memcpy(newImageFlagSharedMemory, &flag, 4);
}

void writeBoundingBoxesReadyFlagToSharedMemory(int flag){
  memcpy(boundingBoxesReadyFlagSharedMemory, &flag, 4);
}

void clearBoundingBoxesStringSizeSharedMemory(){
  memset(boundingBoxesStringSizeSharedMemory, 0, 4);
}

void clearBoundingBoxesSharedMemory(){
  memset(boundingBoxesSharedMemory, 0, 10000);
}

void writeBoundingBoxesToSharedMemory(std::string boundingBoxes){
  memcpy(boundingBoxesSharedMemory, &boundingBoxes, boundingBoxes.size());
}

int readBoundingBoxesReadySharedMemoryFlag(){
  return (int) *boundingBoxesReadyFlagSharedMemory;
}

int readBoundingBoxesStringSizeSharedMemory(){
  return (int) *boundingBoxesStringSizeSharedMemory;
}

int readNewImageFlagSharedMemory(){
  return (int) *newImageFlagSharedMemory;
}

std::string readBoundingBoxesSharedMemory(int stringSize){
  std::string boundingBoxes;
  std::cout << "bounding box string size is: " << stringSize << std::endl;
  boundingBoxes.assign(boundingBoxesSharedMemory, stringSize);
  return boundingBoxes;
}

// Networking functions
cv::Mat receiveImageFromClient(TCPSocket client){

  size_t bufsize = 12;
  char* buffer = (char*) std::malloc(bufsize);
  InputMemoryStream i = InputMemoryStream(buffer, bufsize);
  size_t receivedBytes = 0;
  while(receivedBytes < 12){
    receivedBytes += client.Receive(buffer + receivedBytes, bufsize*sizeof(char) - receivedBytes);
  }
  int request;
  i.Read(request);
  isContinueExecution = (request == 1);
  size_t imgSize;
  i.Read(imgSize);
  std::cout << imgSize << std::endl;
  size_t bufsize2 = imgSize + 8;
  char* buffer2 = (char*) std::malloc(bufsize2);
  InputMemoryStream i2 = InputMemoryStream(buffer2, bufsize2);
  size_t image_received = 0;
  while (image_received < bufsize2){
    image_received += client.Receive(buffer2 + image_received, (bufsize2*sizeof(char)) - image_received);
  }
  cv::Mat image;
  i2.Read(image);
  //cv::resize(image, image, cv::Size(300,300));

  return image;
}

AircraftGeoLocation receiveGeoDataFromClient(TCPSocket client){
  double aircraftLatitude, aircraftLongitude, aircraftHeading, aircraftAltitude;
  const size_t aircraftGeoInfoBufferSize = sizeof(double)*4;
  char* aircraftGeoInfoBuffer = (char*) std::malloc(aircraftGeoInfoBufferSize);
  InputMemoryStream aircraftGeoInfoInputMemoryStream = InputMemoryStream(aircraftGeoInfoBuffer, aircraftGeoInfoBufferSize);
  size_t receivedaircraftGeoInfoBytes = 0;
  while(receivedaircraftGeoInfoBytes < aircraftGeoInfoBufferSize){
    receivedaircraftGeoInfoBytes += client.Receive(aircraftGeoInfoBuffer + receivedaircraftGeoInfoBytes, aircraftGeoInfoBufferSize - receivedaircraftGeoInfoBytes);
  }
  aircraftGeoInfoInputMemoryStream.Read(aircraftLatitude);
  aircraftGeoInfoInputMemoryStream.Read(aircraftLongitude);
  aircraftGeoInfoInputMemoryStream.Read(aircraftHeading);
  aircraftGeoInfoInputMemoryStream.Read(aircraftAltitude);
  AircraftGeoLocation aircraftGeoLocation;
  aircraftGeoLocation.latitude = aircraftLatitude;
  aircraftGeoLocation.longitude = aircraftLongitude;
  aircraftGeoLocation.altitude = aircraftAltitude;
  aircraftGeoLocation.heading = aircraftHeading;
  std::cout << "aircraftLatitude: " << std::setprecision (9) << aircraftLatitude << std::endl;
  std::cout << "aircraftLongitude: " << std::setprecision (9) << aircraftLongitude << std::endl;
  std::cout << "aircraftHeading: " << aircraftHeading << std::endl;
  std::cout << "aircraftAltitude: " << aircraftAltitude << std::endl;
  return aircraftGeoLocation;
}

void waitForBoundingBoxes(){
  int isBoundingBoxesReady = readBoundingBoxesReadySharedMemoryFlag();
  while(isBoundingBoxesReady != 1){
    isBoundingBoxesReady = readBoundingBoxesReadySharedMemoryFlag();
  }
  return;
}

void sendBoundingBoxesToClient(TCPSocket client, std::string boundingBoxes){
  std::cout << boundingBoxes << std::endl;
  OutputMemoryStream outputMemoryStream = OutputMemoryStream();
  outputMemoryStream.Write(boundingBoxes);
  size_t sentBytes = client.Send(outputMemoryStream.GetBufferPtr(), outputMemoryStream.GetLength());
  std::cout << "Sent bytes to client: " << sentBytes << std::endl;
}

Location computeObjectLocation(AircraftGeoLocation aircraftGeoLocation, double boundingBoxMinY, double boundingBoxMinX, double boundingBoxMaxY, double boundingBoxMaxX){
  double objectYLocation = ((boundingBoxMaxY - boundingBoxMinY)/2.0) + boundingBoxMinY;
  double objectXLocation = ((boundingBoxMaxX - boundingBoxMinX)/2.0) + boundingBoxMinX;
  double deltaY = objectYLocation - 360;
  double deltaX = objectXLocation - 640;
  double centerToObjectDistancePx = sqrt(pow(deltaX,2) + pow(deltaY,2));
  std::cout << "compute location at xmin: " << boundingBoxMinX/1280.0 << std::endl;
  std::cout << "compute location at ymin: " << boundingBoxMinY/720.0 << std::endl;
  std::cout << "compute location at xmax: " << boundingBoxMaxX/1280.0 << std::endl;
  std::cout << "compute location at ymax: " << boundingBoxMaxY/720.0 << std::endl;
  //double horizontalPlaneMeterLength = aircraftGeoLocation.altitude * 1.271688;

  double horizontalMeterPerPixel = aircraftGeoLocation.altitude * 0.00099350625;

  double centerToObjectDistanceMeter = centerToObjectDistancePx * horizontalMeterPerPixel;

  double aVecY = 360;
  double bVecX = 640 - objectXLocation;
  double bVecY = 360 - objectYLocation;
  double aDotB = aVecY*bVecY;
  double lengthA = 360;
  double lengthB = sqrt(pow(bVecX, 2) + pow(bVecY, 2));
  double cosAlpha = aDotB/(lengthA*lengthB);
  double boundingBoxCenterToHeadingAngleRad = acos(cosAlpha);
  double bearingDeg;
  if(objectXLocation < 640 && objectYLocation < 360){
    bearingDeg = aircraftGeoLocation.heading - degrees(boundingBoxCenterToHeadingAngleRad);
  }
  else if(objectXLocation < 640 && objectYLocation >= 360){
    bearingDeg = aircraftGeoLocation.heading - degrees(boundingBoxCenterToHeadingAngleRad);
  }
  else if(objectXLocation >= 640 && objectYLocation < 360){
    bearingDeg = aircraftGeoLocation.heading + degrees(boundingBoxCenterToHeadingAngleRad);
  }
  else if(objectXLocation >= 640 && objectYLocation >= 360){
    bearingDeg = aircraftGeoLocation.heading + degrees(boundingBoxCenterToHeadingAngleRad);
  }

  std::cout << "bearingDeg is: " << bearingDeg << std::endl;
  std::cout << "cosAlpha is: " << cosAlpha << std::endl;
  std::cout << "alpha is: " << degrees(boundingBoxCenterToHeadingAngleRad) << std::endl;

  Location location = calculateVincentysDirectWithLatitude(aircraftGeoLocation.latitude, aircraftGeoLocation.longitude, centerToObjectDistanceMeter, bearingDeg);

  return location;
};

std::string getFinalizedDetectionString(const std::string boundingBoxesString, AircraftGeoLocation aircraftGeoLocation){

  std::vector<double> xMins;
  std::vector<double> yMins;
  std::vector<double> xMaxs;
  std::vector<double> yMaxs;
  std::vector<double> predictions;
  std::vector<double> scores;

  int i = 0;
  std::string element;
  for(char c : boundingBoxesString){
    if(c == '-'){
      i = 0;
      scores.push_back(std::stod(element));
      element = "";
      continue;
    }
    if(c != ':'){
      element += c;
    }
    else if(c == ':'){
      switch(i){
        case 0:
          std::cout << "yMins\n";
          yMins.push_back(std::stod(element));
          break;
        case 1:
          std::cout << "xMins\n";
          xMins.push_back(std::stod(element));
          break;
        case 2:
          std::cout << "yMaxs\n";
          yMaxs.push_back(std::stod(element));
          break;
        case 3:
          std::cout << "xMaxs\n";
          xMaxs.push_back(std::stod(element));
          break;
        case 4:
          std::cout << "predictions\n";
          predictions.push_back(std::stod(element));
          break;
      }
      element = "";
      i++;
      i %= 6;
    }
  }
  std::string clientString = "";
  const int boundingBoxCount = yMins.size();
  for(int j = 0; j < boundingBoxCount; j++){
    std::cout << "j: " << j << std::endl;
    //Location objectLocation = computeObjectLocation(aircraftGeoLocation, 520.0, 940.0, 560.0, 980.0);
    Location objectLocation = computeObjectLocation(aircraftGeoLocation, yMins.at(j)*720.0, xMins.at(j)*1280.0, yMaxs.at(j)*720.0, xMaxs.at(j)*1280.0);
    clientString = clientString + std::to_string(yMins.at(j)) + ":" + std::to_string(xMins.at(j)) + ":" + std::to_string(yMaxs.at(j)) + ":" + std::to_string(xMaxs.at(j)) + ":" + std::to_string(predictions.at(j)) + ":" + std::to_string(scores.at(j)) + ":" + std::to_string(objectLocation.latitude) + ":" + std::to_string(objectLocation.longitude) + "-";
  }

  return clientString;
}

void write_log(std::string logLine, AircraftGeoLocation aircraftGeoLocation){
  std::ofstream log("log.txt", std::ios_base::app | std::ios_base::out);
  auto t = std::time(nullptr);
  auto ts = *std::localtime(&t);
  log << std::put_time(&ts, "%d-%m-%Y %H-%M-%S") << " --- " << logLine << " aircraftLatitude: "<<  std::setprecision (9) << aircraftGeoLocation.latitude << " aircraftLongitude:" << std::setprecision (9) << aircraftGeoLocation.longitude << " aircraftAltitude: " << aircraftGeoLocation.altitude << " aircraftHeading: " << aircraftGeoLocation.heading << "\n";;
  log.close();
//  std::string imageName = std::to_string(imageCounter) + ".jpg";
//  cv::imwrite(imageName, image);
}

bool handleClient(TCPSocket client){
  cv::Mat image = receiveImageFromClient(client);
  AircraftGeoLocation aircraftGeoLocation = receiveGeoDataFromClient(client);
  int isImageReadyFlag = readNewImageFlagSharedMemory();
  if(isImageReadyFlag == 0){
    writeImageToSharedMemory(image);
    writeNewImageFlagToSharedMemory(1);
    waitForBoundingBoxes();
    int boundingBoxesStringSize = readBoundingBoxesStringSizeSharedMemory();
    std::string boundingBoxes = readBoundingBoxesSharedMemory(boundingBoxesStringSize);
    //std::cout << "boundingBoxes: " << boundingBoxes << std::endl;
    std::string clientString = getFinalizedDetectionString(boundingBoxes, aircraftGeoLocation);
    //std::cout << "clientString: " << clientString << std::endl;
    //write_log(clientString, aircraftGeoLocation);
    sendBoundingBoxesToClient(client, clientString);
    clearBoundingBoxesSharedMemory();
    clearBoundingBoxesStringSizeSharedMemory();
    writeBoundingBoxesReadyFlagToSharedMemory(0);
    return isContinueExecution;
  }
  else if(isImageReadyFlag == 1){
    return isContinueExecution;
  }
}

// Main
int main(){
  int imageSharedMemoryShmid = allocImageSharedMemory();
  int newImageFlagSharedMemoryShmid = allocNewImageFlagSharedMemory();
  int boundingBoxesReadyFlagSharedMemoryShmid = allocBoundingBoxesReadyFlagSharedMemory();
  int boundingBoxesSharedMemoryShmid = allocBoundingBoxesSharedMemory();
  int boundingBoxesStringSizeShmid = allocBoundingBoxesStringSizeSharedMemory();
  
  writeNewImageFlagToSharedMemory(0);
  writeBoundingBoxesReadyFlagToSharedMemory(0);

  const int portNum = 1500;
  const int userLimit = 1;
  TCPSocket server = TCPSocket();
  std::cout << "\n=> Socket server has been created..." << std::endl;
  SocketAddress serverAddress = SocketAddress(INADDR_ANY, portNum);
  server.Bind(serverAddress);
  std::cout << "Waiting for connection." << std::endl;

  while(true){
    std::cout << "Start over.\n";
    server.Listen(userLimit);
    TCPSocketPtr clientPtr = server.Accept(serverAddress);
    std::cout << "Connected to client.\n";
    TCPSocket* clientSocketPtr = clientPtr.get();
    TCPSocket client = *clientSocketPtr;
    while(isContinueExecution){
      std::cout << isContinueExecution << std::endl;
      isContinueExecution = handleClient(client);
    }
    std::cout << "client close" << std::endl;
    client.Close();
  }

  deallocSharedMemory(boundingBoxesStringSizeShmid);
  deallocSharedMemory(imageSharedMemoryShmid);
  deallocSharedMemory(newImageFlagSharedMemoryShmid);
  deallocSharedMemory(boundingBoxesReadyFlagSharedMemoryShmid);
  deallocSharedMemory(boundingBoxesSharedMemoryShmid);

  return 0;
}

#endif
