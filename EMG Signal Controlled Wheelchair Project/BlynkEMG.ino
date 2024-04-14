/*
  MOTOR controlling & current feedback
  Turns an LED on for one second, then off for one second, repeatedly.
*/
/* Modes:
   0 = stop
   1 = Forward
   2 = Left
   3 = Right
*/
/* del = max difference of time between left and right hand pulse
   pulsewidth  is nessessary so that MC do not take multiple inputs from single pulse
   the time is in ms
*/
#define BLYNK_TEMPLATE_ID "TMPLTzUwc1KR"
#define BLYNK_TEMPLATE_NAME "EMG Wheelchair"
#define BLYNK_AUTH_TOKEN "yM1LFR7bOkuEKAqaOxAUdXNhFyGIEeq-"
char auth[] = "yM1LFR7bOkuEKAqaOxAUdXNhFyGIEeq-";

#include <WiFi.h>
#include <WiFiClient.h>
#include <BlynkSimpleEsp32.h>
WiFiClient  client;

// Motor Control variables-DO NOT CHANGE
const unsigned int Motor_PWM_Freq = 30000;
const unsigned int MRight_PWM_Channel = 0;
const unsigned int MLeft_PWM_Channel = 1;
const unsigned int Motor_PWM_Resolution = 8; // 0 to 255 for 8 bits
unsigned int Motor_PWM_DutyCycle = 150;
const int del = 1000; //to calculate the difference of the delay between the left and right emg
unsigned long previousMillis = 0;
unsigned long currentMillis = 0;
bool EMG_L = 0;
bool EMG_R = 0;

//Pins-CAN CHANGE ONLY THIS
uint8_t MLeft_PIN = 32; // PWMA Pin Motor
uint8_t MRight_PIN = 33; // PWMB Pin Motor
const int EMG_Left = 5;//EMG input
const int EMG_Right = 18;//EMG input


//Wifi settings
const char* ssid = "Cherry";   // your network SSID (name)
const char* pass = "cherry123";   // your network password

//Ultrasonic settings
#define echo 3
#define trig 2
long tym;
int dist;

void Motor_Control_Setup()
{
  ledcSetup(MLeft_PWM_Channel, Motor_PWM_Freq, Motor_PWM_Resolution);
  ledcSetup(MRight_PWM_Channel, Motor_PWM_Freq, Motor_PWM_Resolution);
  ledcAttachPin(MLeft_PIN, MLeft_PWM_Channel); ////GPIO32 //LED1_Pin// PWM_A // Motor Control ClockWise // Attach the LED PWM Channel to the GPIO Pin
  ledcAttachPin(MRight_PIN, MRight_PWM_Channel); ////GPIO35 //LED2_Pin// PWM_B // Motor Control ClockWise // Attach the LED PWM Channel to the GPIO Pin
  int flag = 0;//flag is odd it will move forward and if flag is even it will stop
}

//---------------------------------------------------------------------Forward--------------------------------------------------------------------------------------

void Movement()
{
  Serial.println("Inside movement");
  if (flag % 2 == 1) {
    ledcWrite(MRight_PWM_Channel, 50);
    ledcWrite(MLeft_PWM_Channel, 50);
    Blynk.virtualWrite(V0, 50);
    Blynk.virtualWrite(V1, 50);
  }
  else {
    NoMovement();
  }
}

//---------------------------------------------------------------------Right--------------------------------------------------------------------------------------

void RightMovement()
{
  Serial.println("Inside right");
  ledcWrite(MRight_PWM_Channel, 0);
  ledcWrite(MLeft_PWM_Channel, 50);
  Blynk.virtualWrite(V0, 0);
  Blynk.virtualWrite(V1, 50);
  delay(500);
}

//-----------------------------------------------------------------------Left------------------------------------------------------------------------------------

void LeftMovement()
{
  Serial.println("Inside left");
  ledcWrite(MRight_PWM_Channel, 50);
  ledcWrite(MLeft_PWM_Channel, 0);
  Blynk.virtualWrite(V0, 50);
  Blynk.virtualWrite(V1, 0);
  delay(500);
}

//-----------------------------------------------------------------------No Motion------------------------------------------------------------------------------------

void NoMovement()
{
  Serial.println("Inside none");
  ledcWrite(MRight_PWM_Channel, 0);
  ledcWrite(MLeft_PWM_Channel, 0);
  Blynk.virtualWrite(V0, 0);
  Blynk.virtualWrite(V1, 0);
}

//--------------------------------------------------------------------------Check Distance---------------------------------------------------------------------------------

int checkdist() {
  digitalWrite(trig, LOW); // Clears the trig Pin condition
  delayMicroseconds(10);
  digitalWrite(trig, HIGH); //activates the trig Pin
  delayMicroseconds(10);
  digitalWrite(trig, LOW); //deactivates the trig Pin
  tym = pulseIn(echo, HIGH); // Calculating the distance
  dist = (tym * 0.034) / 2; // Speed of sound wave divided by 2
  return dist;
}
//--------------------------------------------------------------------------Setup---------------------------------------------------------------------------------

void setup() {
  WiFi.mode(WIFI_STA);
  Blynk.begin(auth, ssid, pass);
  Serial.begin(115200);
  pinMode(trig, OUTPUT);
  pinMode(echo, INPUT);
  // initialize digital pin LED_BUILTIN as an output.
  pinMode(MLeft_PIN, OUTPUT);
  pinMode(MRight_PIN, OUTPUT);
  Motor_Control_Setup();
}

//--------------------------------------------------------------------------Loop---------------------------------------------------------------------------------

void loop()
{
  Blynk.run();
  int i = 0;
  if (WiFi.status() != WL_CONNECTED) {
    Serial.print("Attempting to connect");
    while (WiFi.status() != WL_CONNECTED) {
      WiFi.begin(ssid, pass);
      delay(5000);
    }
    Serial.println("\nConnected.");
  }
  while (i <= 5) { //get accurate inputs
    bool prevEMG_L = digitalRead(EMG_Left);
    bool prevEMG_R = digitalRead(EMG_Right);
    delay(100);
    EMG_L = digitalRead(EMG_Left);
    EMG_R = digitalRead(EMG_Right);
    if (EMG_L != prevEMG_L || EMG_R != prevEMG_R) {
      prevEMG_L = EMG_L;
      prevEMG_R = EMG_R;
    }
    else {
      break;
    }
    i++;
  }
  //for proper input delays, find the optimal delay
  //Test with dummy values--- EMG_L =0; EMG_R =0;

  bool res = EMG_L ^ EMG_R;

  //put ultrasonic here
  
  if (res == 1) {
      if (EMG_L == 1) {
        Serial.println("Left");
        if (checkdist() >= 150) {
          LeftMovement();
        }
      }
      else {
        Serial.println("Right");
        if (checkdist() >= 150) {
          RightMovement();
        }
      }
    }

    else {
      flagp = flag;
      if (EMG_R == 1 && EMG_L == 1) {
        flag++;
      
      if (flagp != flag) {
        Serial.println("Movement");
        Movement();
      }
      else {
        Serial.println("No reading");
        NoMovement();
      }
      }
    }
}
}
