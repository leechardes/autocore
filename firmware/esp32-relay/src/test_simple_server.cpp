// Teste simples de servidor web
#include <WiFi.h>
#include <WebServer.h>

WebServer testServer(8080);

void handleTestRoot() {
    Serial.println("Requisição recebida em /");
    testServer.send(200, "text/html", "<h1>ESP32 Relay Test Server</h1><p>Servidor funcionando!</p>");
}

void setupTestServer() {
    Serial.println("Iniciando servidor de teste na porta 8080");
    
    testServer.on("/", handleTestRoot);
    
    testServer.begin();
    Serial.println("Servidor de teste iniciado! Acesse http://192.168.4.1:8080");
}

void handleTestServer() {
    testServer.handleClient();
}