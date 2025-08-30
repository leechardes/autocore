"""
Validation Middleware
Implementa validações de segurança para dados de entrada
"""

from fastapi import Request, HTTPException, status
from fastapi.responses import JSONResponse
from typing import Any, Dict, List, Optional
import re
import json
import logging
from datetime import datetime

logger = logging.getLogger(__name__)

class SecurityValidator:
    """
    Validador de segurança para dados de entrada
    Previne ataques comuns como SQL injection, XSS, etc.
    """
    
    def __init__(self):
        # Padrões suspeitos para detectar ataques
        self.sql_injection_patterns = [
            r"(\b(union|select|insert|update|delete|drop|create|alter|exec|execute)\b)",
            r"(--|#|\/\*|\*\/)",
            r"(\bor\b.*=.*\bor\b)",
            r"(\band\b.*=.*\band\b)",
            r"('|\"|`)(.*?)\1",  # Quoted strings
            r"(\bxp_|\bsp_)",     # Stored procedures
        ]
        
        self.xss_patterns = [
            r"<script[^>]*>.*?</script>",
            r"<.*?(on\w+)=.*?>",  # Event handlers
            r"javascript:",
            r"vbscript:",
            r"<iframe[^>]*>.*?</iframe>",
            r"<object[^>]*>.*?</object>",
            r"<embed[^>]*>",
        ]
        
        # Compile patterns for performance
        self.compiled_sql_patterns = [re.compile(pattern, re.IGNORECASE) for pattern in self.sql_injection_patterns]
        self.compiled_xss_patterns = [re.compile(pattern, re.IGNORECASE) for pattern in self.xss_patterns]
        
        # Fields that should not be validated (e.g., passwords, hashes)
        self.excluded_fields = {
            "password", "hash", "token", "secret", "key", "signature",
            "csrf_token", "api_key", "authorization"
        }
    
    def validate_string(self, value: str, field_name: str = "") -> tuple[bool, Optional[str]]:
        """
        Valida string contra padrões maliciosos
        
        Returns:
            (is_valid: bool, error_message: str or None)
        """
        if not isinstance(value, str):
            return True, None
        
        # Skip validation for excluded fields
        if field_name.lower() in self.excluded_fields:
            return True, None
        
        # Check for SQL injection patterns
        for pattern in self.compiled_sql_patterns:
            if pattern.search(value):
                return False, f"Possível SQL injection detectado no campo '{field_name}'"
        
        # Check for XSS patterns
        for pattern in self.compiled_xss_patterns:
            if pattern.search(value):
                return False, f"Possível XSS detectado no campo '{field_name}'"
        
        # Check for excessively long strings (potential DoS)
        if len(value) > 10000:  # 10KB limit
            return False, f"Campo '{field_name}' excede o limite de tamanho (10KB)"
        
        return True, None
    
    def validate_dict(self, data: Dict[str, Any], prefix: str = "") -> tuple[bool, Optional[str]]:
        """
        Recursivamente valida dicionário
        
        Returns:
            (is_valid: bool, error_message: str or None)
        """
        for key, value in data.items():
            field_path = f"{prefix}.{key}" if prefix else key
            
            # Validate key name
            if not re.match(r'^[a-zA-Z_][a-zA-Z0-9_]*$', key):
                if not re.match(r'^[a-zA-Z_][a-zA-Z0-9_\-\.]*$', key):  # Allow hyphens and dots for some cases
                    return False, f"Nome de campo inválido: '{key}'"
            
            # Validate value based on type
            if isinstance(value, str):
                is_valid, error = self.validate_string(value, field_path)
                if not is_valid:
                    return False, error
            
            elif isinstance(value, dict):
                is_valid, error = self.validate_dict(value, field_path)
                if not is_valid:
                    return False, error
            
            elif isinstance(value, list):
                for i, item in enumerate(value):
                    if isinstance(item, str):
                        is_valid, error = self.validate_string(item, f"{field_path}[{i}]")
                        if not is_valid:
                            return False, error
                    elif isinstance(item, dict):
                        is_valid, error = self.validate_dict(item, f"{field_path}[{i}]")
                        if not is_valid:
                            return False, error
        
        return True, None
    
    def validate_vehicle_data(self, data: Dict[str, Any]) -> tuple[bool, Optional[str]]:
        """
        Validações específicas para dados de veículos
        """
        # Validate plate format
        if "plate" in data:
            plate = data["plate"]
            if isinstance(plate, str):
                # Brazilian plate format validation
                normalized_plate = plate.upper().replace(' ', '').replace('-', '')
                if not re.match(r'^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$', normalized_plate):
                    return False, "Formato de placa inválido. Use formato brasileiro (ABC1234 ou ABC1D23)"
        
        # Validate chassis format
        if "chassis" in data:
            chassis = data["chassis"]
            if isinstance(chassis, str):
                normalized_chassis = chassis.upper().replace(' ', '')
                if len(normalized_chassis) != 17:
                    return False, "Chassi deve ter exatamente 17 caracteres"
                if any(char in normalized_chassis for char in ['I', 'O', 'Q']):
                    return False, "Chassi não pode conter as letras I, O ou Q"
        
        # Validate RENAVAM
        if "renavam" in data:
            renavam = data["renavam"]
            if isinstance(renavam, str):
                renavam_digits = re.sub(r'\D', '', renavam)
                if len(renavam_digits) != 11:
                    return False, "RENAVAM deve ter exatamente 11 dígitos"
        
        # Validate years
        current_year = datetime.now().year
        if "year_manufacture" in data:
            year = data["year_manufacture"]
            if isinstance(year, int) and (year < 1900 or year > current_year + 1):
                return False, f"Ano de fabricação inválido: {year}"
        
        if "year_model" in data:
            year = data["year_model"] 
            if isinstance(year, int) and (year < 1900 or year > current_year + 1):
                return False, f"Ano do modelo inválido: {year}"
        
        # Validate odometer
        if "odometer" in data:
            odometer = data["odometer"]
            if isinstance(odometer, (int, float)) and odometer < 0:
                return False, "Quilometragem não pode ser negativa"
            if isinstance(odometer, (int, float)) and odometer > 5000000:  # 5M km limit
                return False, "Quilometragem excede limite máximo (5.000.000 km)"
        
        return True, None

# Global validator instance
security_validator = SecurityValidator()

async def validation_middleware(request: Request, call_next):
    """
    FastAPI middleware para validação de segurança
    """
    
    # Only validate POST, PUT, PATCH requests with body
    if request.method in ["POST", "PUT", "PATCH"]:
        try:
            # Get request body
            body = await request.body()
            
            if body:
                try:
                    # Parse JSON body
                    json_data = json.loads(body.decode())
                    
                    # Validate JSON structure
                    is_valid, error = security_validator.validate_dict(json_data)
                    if not is_valid:
                        logger.warning(f"Security validation failed for {request.url.path}: {error}")
                        return JSONResponse(
                            status_code=status.HTTP_400_BAD_REQUEST,
                            content={
                                "error": "Validation Error",
                                "message": error,
                                "code": "SECURITY_VALIDATION_FAILED"
                            }
                        )
                    
                    # Vehicle-specific validation for vehicle endpoints
                    if "/api/vehicles" in str(request.url.path):
                        is_valid, error = security_validator.validate_vehicle_data(json_data)
                        if not is_valid:
                            logger.warning(f"Vehicle validation failed for {request.url.path}: {error}")
                            return JSONResponse(
                                status_code=status.HTTP_400_BAD_REQUEST,
                                content={
                                    "error": "Vehicle Validation Error",
                                    "message": error,
                                    "code": "VEHICLE_VALIDATION_FAILED"
                                }
                            )
                
                except json.JSONDecodeError:
                    # Invalid JSON
                    logger.warning(f"Invalid JSON in request to {request.url.path}")
                    return JSONResponse(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        content={
                            "error": "Invalid JSON",
                            "message": "Corpo da requisição contém JSON inválido",
                            "code": "INVALID_JSON"
                        }
                    )
                
                except Exception as e:
                    logger.error(f"Error in validation middleware: {e}")
                    # Continue processing - don't block on validation errors
            
            # Recreate request with original body
            async def receive():
                return {
                    "type": "http.request",
                    "body": body,
                    "more_body": False
                }
            
            request._receive = receive
            
        except Exception as e:
            logger.error(f"Error reading request body in validation middleware: {e}")
            # Continue processing
    
    # Continue to next middleware/endpoint
    response = await call_next(request)
    return response

def validate_vehicle_input(data: Dict[str, Any]) -> tuple[bool, Optional[str]]:
    """
    Função utilitária para validar dados de veículos diretamente
    """
    # General validation
    is_valid, error = security_validator.validate_dict(data)
    if not is_valid:
        return False, error
    
    # Vehicle-specific validation
    return security_validator.validate_vehicle_data(data)