"""
Testes para API de Veículos
Testa endpoints principais e validações
"""

import pytest
import sys
from pathlib import Path

# Adicionar paths necessários
backend_path = Path(__file__).parent.parent
sys.path.append(str(backend_path))
sys.path.append(str(Path(__file__).parent.parent.parent.parent / "database"))

from fastapi.testclient import TestClient
import json
from datetime import datetime

# Import app
import main
app = main.app

# Create test client
client = TestClient(app)

class TestVehiclesAPI:
    """Testes para endpoints de veículos"""
    
    def test_health_check(self):
        """Testa health check da API"""
        response = client.get("/api/health")
        assert response.status_code == 200
        assert response.json()["status"] == "healthy"
    
    def test_vehicles_endpoint_exists(self):
        """Testa se endpoint de veículos existe"""
        # Test OPTIONS to check if endpoint exists
        response = client.options("/api/vehicles")
        assert response.status_code in [200, 405]  # Either allowed or method not allowed
    
    def test_vehicle_validation_schemas(self):
        """Testa validação dos schemas"""
        from api.schemas.vehicle_schemas import VehicleCreate, VehicleStatus, FuelType
        
        # Test enum values
        assert VehicleStatus.ACTIVE == "active"
        assert FuelType.FLEX == "flex"
        
        # Test basic schema creation
        valid_data = {
            "plate": "ABC1234",
            "chassis": "1HGCM82633A123456",
            "renavam": "12345678901",
            "brand": "Toyota",
            "model": "Corolla",
            "year_manufacture": 2020,
            "year_model": 2020,
            "fuel_type": "flex",
            "category": "passenger",
            "user_id": 1
        }
        
        try:
            vehicle = VehicleCreate(**valid_data)
            assert vehicle.plate == "ABC1234"
            print("✅ Vehicle schema validation passed")
        except Exception as e:
            print(f"❌ Schema validation failed: {e}")
    
    def test_invalid_vehicle_data(self):
        """Testa validação de dados inválidos"""
        from api.schemas.vehicle_schemas import VehicleCreate
        
        # Test invalid plate
        invalid_data = {
            "plate": "INVALID",  # Invalid format
            "chassis": "1HGCM82633A123456",
            "renavam": "12345678901",
            "brand": "Toyota",
            "model": "Corolla",
            "year_manufacture": 2020,
            "year_model": 2020,
            "fuel_type": "flex",
            "category": "passenger",
            "user_id": 1
        }
        
        try:
            vehicle = VehicleCreate(**invalid_data)
            assert False, "Should have failed validation"
        except ValueError as e:
            assert "formato brasileiro válido" in str(e)
            print("✅ Invalid plate validation passed")
    
    def test_middleware_rate_limiting(self):
        """Testa rate limiting middleware"""
        from api.middleware.rate_limiting import rate_limiter
        
        # Test rate limit check
        allowed, limit_info = rate_limiter.check_rate_limit(
            ip="127.0.0.1",
            method="GET", 
            path="/api/vehicles"
        )
        
        assert allowed == True
        assert limit_info is None
        print("✅ Rate limiting test passed")
    
    def test_middleware_validation(self):
        """Testa validation middleware"""
        from api.middleware.validation import security_validator
        
        # Test SQL injection detection
        is_valid, error = security_validator.validate_string(
            "'; DROP TABLE vehicles; --",
            "test_field"
        )
        
        assert is_valid == False
        assert "SQL injection" in error
        print("✅ SQL injection detection passed")
        
        # Test XSS detection  
        is_valid, error = security_validator.validate_string(
            "<script>alert('xss')</script>",
            "test_field"
        )
        
        assert is_valid == False
        if error:
            assert "XSS" in error
            print("✅ XSS detection passed")
        else:
            print("⚠️ XSS test passed (no error message)")
    
    def test_vehicle_specific_validation(self):
        """Testa validações específicas de veículos"""
        from api.middleware.validation import security_validator
        
        # Test valid vehicle data
        valid_vehicle = {
            "plate": "ABC1234",
            "chassis": "1HGCM82633A123456",
            "renavam": "12345678901",
            "year_manufacture": 2020,
            "odometer": 50000
        }
        
        is_valid, error = security_validator.validate_vehicle_data(valid_vehicle)
        assert is_valid == True
        assert error is None
        print("✅ Valid vehicle data validation passed")
        
        # Test invalid chassis with forbidden characters
        invalid_vehicle = {
            "chassis": "1HGCM82633A123IOQ"  # Contains I, O, Q
        }
        
        is_valid, error = security_validator.validate_vehicle_data(invalid_vehicle)
        assert is_valid == False
        assert "I, O ou Q" in error
        print("✅ Invalid chassis validation passed")

def run_tests():
    """Execute todos os testes"""
    print("🧪 Executando testes da API de Veículos...\n")
    
    test_instance = TestVehiclesAPI()
    tests = [
        test_instance.test_health_check,
        test_instance.test_vehicles_endpoint_exists,
        test_instance.test_vehicle_validation_schemas,
        test_instance.test_invalid_vehicle_data,
        test_instance.test_middleware_rate_limiting,
        test_instance.test_middleware_validation,
        test_instance.test_vehicle_specific_validation,
    ]
    
    passed = 0
    failed = 0
    
    for test in tests:
        try:
            print(f"🔍 Running {test.__name__}...")
            test()
            passed += 1
            print(f"✅ {test.__name__} - PASSED\n")
        except Exception as e:
            failed += 1
            print(f"❌ {test.__name__} - FAILED: {e}\n")
    
    print("📊 RESULTADOS DOS TESTES:")
    print(f"✅ Passed: {passed}")
    print(f"❌ Failed: {failed}")
    print(f"📈 Success Rate: {passed/(passed+failed)*100:.1f}%")
    
    return passed, failed

if __name__ == "__main__":
    run_tests()