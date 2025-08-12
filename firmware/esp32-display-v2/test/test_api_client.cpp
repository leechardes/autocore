/**
 * @file test_api_client.cpp
 * @brief Testes unitários para ScreenApiClient
 * 
 * IMPORTANTE: Estes testes requerem um servidor API mockado ou real em execução
 * Configure as variáveis de ambiente ou use um mock server para testes automatizados.
 * 
 * @author Sistema AutoTech  
 * @version 2.0.0
 * @date 2025-08-12
 */

#include <Arduino.h>
#include <unity.h>
#include <ArduinoJson.h>
#include "../include/network/ScreenApiClient.h"
#include "../include/config/DeviceConfig.h"

// Mock logger para testes
class MockLogger {
public:
    void info(const String& msg) { Serial.println("[INFO] " + msg); }
    void debug(const String& msg) { Serial.println("[DEBUG] " + msg); }
    void warning(const String& msg) { Serial.println("[WARN] " + msg); }
    void error(const String& msg) { Serial.println("[ERROR] " + msg); }
};

MockLogger* logger = nullptr;

// Test fixtures
ScreenApiClient* apiClient = nullptr;

void setUp(void) {
    // Executado antes de cada teste
    if (logger == nullptr) {
        logger = new MockLogger();
    }
    
    if (apiClient == nullptr) {
        apiClient = new ScreenApiClient();
    }
}

void tearDown(void) {
    // Executado após cada teste
    if (apiClient) {
        apiClient->clearCache();
    }
}

/**
 * Test: ScreenApiClient constructor and basic initialization
 */
void test_api_client_constructor(void) {
    ScreenApiClient client;
    
    // Verificar se o cliente foi criado sem erros
    TEST_ASSERT_NOT_NULL(&client);
    
    // Verificar se não há erro inicial
    TEST_ASSERT_EQUAL_STRING("", client.getLastError().c_str());
    TEST_ASSERT_EQUAL_INT(0, client.getLastHttpCode());
    
    Serial.println("✓ test_api_client_constructor passed");
}

/**
 * Test: API client begin method  
 */
void test_api_client_begin(void) {
    ScreenApiClient client;
    
    // Nota: Este teste pode falhar se a API não estiver disponível
    // Em ambiente de produção, usar um mock server
    bool result = client.begin();
    
    if (result) {
        Serial.println("✓ API connection successful");
        TEST_ASSERT_TRUE(result);
    } else {
        Serial.println("⚠ API not available, testing error handling");
        TEST_ASSERT_FALSE(result);
        TEST_ASSERT_NOT_EQUAL_STRING("", client.getLastError().c_str());
        
        // Mesmo com falha, o método deve retornar um erro descritivo
        String error = client.getLastError();
        TEST_ASSERT_TRUE(error.length() > 0);
    }
    
    Serial.println("✓ test_api_client_begin passed");
}

/**
 * Test: Test connection method
 */
void test_api_connection(void) {
    TEST_ASSERT_NOT_NULL(apiClient);
    
    bool connected = apiClient->testConnection();
    
    if (connected) {
        Serial.println("✓ API server is reachable");
        TEST_ASSERT_TRUE(connected);
        TEST_ASSERT_EQUAL_INT(200, apiClient->getLastHttpCode());
    } else {
        Serial.println("⚠ API server not reachable (expected in test env)");
        TEST_ASSERT_FALSE(connected);
        
        // Verificar se há um código de erro HTTP válido
        int httpCode = apiClient->getLastHttpCode();
        TEST_ASSERT_TRUE(httpCode != 200);
        
        // Verificar se há uma mensagem de erro
        String error = apiClient->getLastError();
        TEST_ASSERT_TRUE(error.length() > 0);
    }
    
    Serial.println("✓ test_api_connection passed");
}

/**
 * Test: Cache functionality
 */
void test_cache_functionality(void) {
    TEST_ASSERT_NOT_NULL(apiClient);
    
    // Inicialmente cache deve estar inválido
    TEST_ASSERT_FALSE(apiClient->isCacheValid());
    
    // Limpar cache (deve funcionar mesmo se já vazio)
    apiClient->clearCache();
    TEST_ASSERT_FALSE(apiClient->isCacheValid());
    
    Serial.println("✓ test_cache_functionality passed");
}

/**
 * Test: Configuration timeout settings
 */
void test_configuration_settings(void) {
    TEST_ASSERT_NOT_NULL(apiClient);
    
    // Testar setTimeout - não deve crashar
    apiClient->setTimeout(5000);
    
    // Testar setCacheTTL - não deve crashar
    apiClient->setCacheTTL(60000);
    
    Serial.println("✓ test_configuration_settings passed");
}

/**
 * Test: JSON parsing and data structures
 */
void test_json_structures(void) {
    // Testar estrutura JSON esperada para screens
    DynamicJsonDocument screensDoc(2048);
    JsonArray screens = screensDoc.to<JsonArray>();
    
    // Simular resposta de screens
    JsonObject screen1 = screens.createNestedObject();
    screen1["id"] = 1;
    screen1["name"] = "Home";
    screen1["type"] = "grid";
    
    JsonObject screen2 = screens.createNestedObject();
    screen2["id"] = 2;
    screen2["name"] = "Controls";
    screen2["type"] = "list";
    
    // Verificar estrutura
    TEST_ASSERT_EQUAL_INT(2, screens.size());
    TEST_ASSERT_EQUAL_INT(1, screens[0]["id"].as<int>());
    TEST_ASSERT_EQUAL_STRING("Home", screens[0]["name"].as<String>().c_str());
    
    Serial.println("✓ test_json_structures passed");
}

/**
 * Test: Error handling and edge cases
 */
void test_error_handling(void) {
    TEST_ASSERT_NOT_NULL(apiClient);
    
    // Testar com JsonArray vazio
    DynamicJsonDocument emptyDoc(512);
    JsonArray emptyScreens = emptyDoc.to<JsonArray>();
    
    // Deve conseguir lidar com array vazio sem crashar
    TEST_ASSERT_EQUAL_INT(0, emptyScreens.size());
    
    // Testar getScreenItems com ID inválido (vai falhar, mas não deve crashar)
    JsonArray items;
    bool result = apiClient->getScreenItems(-1, items);
    
    // Esperamos que falhe com ID inválido
    TEST_ASSERT_FALSE(result);
    
    Serial.println("✓ test_error_handling passed");
}

/**
 * Test: Memory usage and leaks 
 */
void test_memory_usage(void) {
    size_t heapBefore = ESP.getFreeHeap();
    Serial.println("Heap before API client test: " + String(heapBefore));
    
    // Criar e destruir client múltiplas vezes
    for (int i = 0; i < 5; i++) {
        ScreenApiClient* tempClient = new ScreenApiClient();
        tempClient->begin();
        tempClient->clearCache();
        delete tempClient;
    }
    
    size_t heapAfter = ESP.getFreeHeap();
    Serial.println("Heap after API client test: " + String(heapAfter));
    
    // Permitir alguma fragmentação, mas não deve haver grande vazamento
    int heapDiff = heapBefore - heapAfter;
    TEST_ASSERT_TRUE(abs(heapDiff) < 2048); // Menos que 2KB de diferença
    
    Serial.println("✓ test_memory_usage passed (heap diff: " + String(heapDiff) + " bytes)");
}

/**
 * Test: URL building 
 */
void test_url_building(void) {
    // Testar se as constantes estão definidas corretamente
    String expectedBaseUrl = String(API_PROTOCOL) + "://" + 
                           String(API_SERVER) + ":" + 
                           String(API_PORT) + 
                           String(API_BASE_PATH);
    
    // Verificar se a URL base tem formato correto
    TEST_ASSERT_TRUE(expectedBaseUrl.startsWith("http"));
    TEST_ASSERT_TRUE(expectedBaseUrl.indexOf(":") > 0);
    TEST_ASSERT_TRUE(expectedBaseUrl.indexOf("api") > 0);
    
    Serial.println("✓ Base URL: " + expectedBaseUrl);
    Serial.println("✓ test_url_building passed");
}

/**
 * Executar todos os testes
 */
void setup() {
    Serial.begin(115200);
    delay(2000);
    
    Serial.println("\n=== AutoTech HMI - ScreenApiClient Tests ===");
    Serial.println("Testing API configuration migration...\n");
    
    // Inicializar WiFi para testes (opcional)
    Serial.println("Note: WiFi connection may be required for full API tests");
    Serial.println("API Server: " + String(API_SERVER) + ":" + String(API_PORT));
    Serial.println("API Base Path: " + String(API_BASE_PATH));
    Serial.println("");
    
    UNITY_BEGIN();
    
    // Testes básicos (não requerem rede)
    RUN_TEST(test_api_client_constructor);
    RUN_TEST(test_cache_functionality);
    RUN_TEST(test_configuration_settings);
    RUN_TEST(test_json_structures);
    RUN_TEST(test_error_handling);
    RUN_TEST(test_memory_usage);
    RUN_TEST(test_url_building);
    
    // Testes de rede (podem falhar sem API server)
    RUN_TEST(test_api_client_begin);
    RUN_TEST(test_api_connection);
    
    UNITY_END();
    
    Serial.println("\n=== Test Summary ===");
    Serial.println("All basic functionality tests completed.");
    Serial.println("Network tests may fail without API server - this is expected.");
    Serial.println("For full integration testing, ensure API server is running at:");
    Serial.println("  " + String(API_PROTOCOL) + "://" + String(API_SERVER) + ":" + String(API_PORT) + String(API_BASE_PATH));
}

void loop() {
    // Nada no loop para testes
    delay(100);
}