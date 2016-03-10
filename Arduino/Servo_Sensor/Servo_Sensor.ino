// Controlling a servo position using a potentiometer (variable resistor) 
// by Michal Rinott <http://people.interaction-ivrea.it/m.rinott> 


#include <Servo.h> 

#define NUMBER_SAMPLES 10
#define SENSOR_MIN_VALUE 100
#define SENSOR_MAX_VALUE 500

int sensorPin = A0;
int values[NUMBER_SAMPLES];
Servo myservo;  // create servo object to control a servo 
int val;    // variable to read the value from the analog pin 
 
 
 
 
void setup() 
{ 
  Serial.begin(9600);
  myservo.attach(3);  // attaches the servo on pin 9 to the servo object 
} 





 
void loop() 
{ 
  
  
  // SERVO
  
  int tmp = 0;
  if( Serial.available() )
  {
    tmp = Serial.parseInt();          // reads the value of the potentiometer (value between 0 and 1023) 
  }
  if( tmp > 0 )
  {
    val = map(tmp, 0, 1023, 0, 179);     // scale it to use it with the servo (value between 0 and 180) @
    myservo.write(val);                  // sets the servo position according to the scaled value 
    delay(15);                           // waits for the servo to get there 
  }
  
  
  
  
  // SENSOR
  
  //shift register
  for (int i=0; i<NUMBER_SAMPLES-1; i++)
  {
    values[i] = values[i+1];
  }
  values[NUMBER_SAMPLES-1] = analogRead(sensorPin);
  
  //mean value
  long valueToSend = 0;
  for (int i=0; i<NUMBER_SAMPLES; i++)
  {
    valueToSend += values[i];
  }
  int mean = valueToSend/NUMBER_SAMPLES;
  mean = min(  max(mean,SENSOR_MIN_VALUE)  ,  SENSOR_MAX_VALUE  );
  mean = map(mean, SENSOR_MIN_VALUE, SENSOR_MAX_VALUE, 0, 1024);
  Serial.println(mean);
    
    
    
} 
