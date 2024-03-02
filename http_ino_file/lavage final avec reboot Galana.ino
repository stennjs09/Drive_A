#include <WiFi.h>
#include <HTTPClient.h>
const char *ssid = "GALANA-PHAROS-EXT";
const char *password = "galana2022";

const int pinRelay = 32;
const int temoinLed = 2;
bool continueFetching = true;
int compteur = 0;
int erreurServer = 0;
void setup() {
  Serial.begin(115200);
  pinMode(pinRelay, OUTPUT);
  pinMode(temoinLed, OUTPUT);
  delay(500);
  connectToWiFi();

  while (continueFetching) {
    getDataFromServeur();
    delay(5000);
  }
}

void loop() {
  connectToWiFi();
}

void getDataFromServeur() {
  if ((WiFi.status() == WL_CONNECTED)) {
    HTTPClient http;
    const char *url = "http://192.168.88.18:8084/API2/148.php?ApiKey=PDS461332324SHKJD&temp_esp";
    http.begin(url);

    int httpCode = http.GET();
    if (httpCode > 0) {
      if (httpCode == HTTP_CODE_OK) {
        String payload = http.getString();
        compteur = 0;
        erreurServer = 0;

        payload.trim();  // Supprime les espaces au début et à la fin
        payload = payload.substring(payload.indexOf('"') + 1, payload.lastIndexOf('"'));


        Serial.println("Réponse du serveur temps lavage : " + payload);

        int countdownTime = payload.toInt();

        Serial.print("Temps de lavage: ");
        Serial.println(countdownTime);

        if (countdownTime > 0) {
          continueFetching = false;
          Serial.println("Compteur demarre...");

          for (int i = countdownTime * 60 ; i >= 0; i--) {

            digitalWrite(pinRelay, HIGH);// EFA

            if (i % 60 == 0 && i != 0) {

              EnvoiDonee(i / 60);

            } else if (i == 0) {
              EnvoiZero();
            }
            if (WiFi.status() != WL_CONNECTED) {
              Serial.println("Wifi deconnecte!");
              digitalWrite(temoinLed, LOW);//EFA
              connectToWiFi();
            }
            delay(1000);
          }
          digitalWrite(pinRelay, LOW);//EFA
        }
      }
    } else {
      Serial.println("Verifier le connexion au serveur!");
      erreurServer ++;
      if (erreurServer == 6) {
        ESP.restart();
      }

    }
    http.end();
  } else {
    Serial.println("Verifier le connexion Wifi!");
    digitalWrite(temoinLed, LOW);//EFA
    connectToWiFi();
  }
}

void connectToWiFi() {
  Serial.println("Connexion au WiFi...");

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    digitalWrite(temoinLed, LOW);//EFA
    delay(1000);

    compteur ++ ;
    if (compteur > 10) {
      ESP.restart();
    }


  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("Wifi connectée");
    digitalWrite(temoinLed, HIGH);// EFA
  }
}

void EnvoiDonee(int donnee) {

  HTTPClient http;
  String url = "http://192.168.88.18:8084/API2/147.php?ApiKey=X5464FD4654E3WEF&field1=" + String(donnee) + ",ok";
  http.begin(url);
  int httpCode = http.GET();

  if (httpCode == HTTP_CODE_OK) {

    Serial.print("Temps restant : ");
    Serial.println(donnee);

  } else {
    Serial.print("Echec de l'envoi de : ");
    Serial.println(donnee + "ok");
  }
  http.end();

}
void EnvoiZero() {

  HTTPClient http;
  String url = "http://192.168.88.18:8084/API2/147.php?ApiKey=X5464FD4654E3WEF&field1=0,ok";
  http.begin(url);
  int httpCode = http.GET();

  if (httpCode == HTTP_CODE_OK) {

    Serial.println("Temps ecoule!");
    continueFetching = true;

  } else {
    Serial.println("Echec de l'envoi de 0");
    EnvoiZero();
    delay(1000);
  }
  http.end();

}