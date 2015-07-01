#include "limits.h"

#define GET_TEMP    "get_temp"
#define TOGGLE_DOOR "toggle_door"

#define TEMP_PIN 0   // analog read
#define DOOR_PIN 13  // digital write

void setup() {
  Serial.begin(9600);
  pinMode(DOOR_PIN, OUTPUT);
  digitalWrite(DOOR_PIN, LOW);
}

#define BUFMAX 32
char buf[BUFMAX];
int buflen = 0;

#define DOOR_DURATION 5000  // 5 seconds
bool doorToggled = false;
unsigned long doorToggledAt;

void loop() {
  while (Serial.available()) {
    char c = Serial.read();
    if (c == '\n') {
      buf[buflen] = '\0';
      if (!strcmp(GET_TEMP, buf)) {
        getTemp();
      } else if (!strcmp(TOGGLE_DOOR, buf)) {
        startToggleDoor();
      }
      buflen = 0;
    } else {
      buf[buflen] = c;
      buflen++;
      if (buflen >= BUFMAX) {
        // avoid buffer overflow by resetting buffer
        buflen = 0;
      }
    }
  }
  if (doorToggled && (millis() - doorToggledAt > DOOR_DURATION))
    endToggleDoor();
}

void getTemp() {
  int a_read = analogRead(TEMP_PIN);
  double v = a_read * 5.0 / 1023;
  double c = v * 100 - 50;
  Serial.println(c);
}

void startToggleDoor() {
  if (!doorToggled) {
    doorToggled = true;
    doorToggledAt = millis();
    digitalWrite(DOOR_PIN, HIGH);
  }
}

void endToggleDoor() {
  doorToggled = false;
  digitalWrite(DOOR_PIN, LOW);
}

