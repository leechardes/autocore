"""
Rate Limiting Middleware
Implementa limitação de taxa de requisições por IP e endpoint
"""

from fastapi import Request, HTTPException, status
from fastapi.responses import JSONResponse
from typing import Dict, Optional
from datetime import datetime, timedelta
import asyncio
from collections import defaultdict, deque
import logging

logger = logging.getLogger(__name__)

class RateLimiter:
    """
    Rate limiter baseado em sliding window
    Controla requisições por IP e endpoint
    """
    
    def __init__(self):
        # Store requests per IP: {ip: deque of timestamps}
        self.requests: Dict[str, deque] = defaultdict(lambda: deque())
        # Store requests per IP+endpoint: {ip:endpoint: deque of timestamps}
        self.endpoint_requests: Dict[str, deque] = defaultdict(lambda: deque())
        
        # Rate limits configuration
        self.limits = {
            # Global limits per IP
            "global": {
                "requests": 1000,  # requests
                "window": 3600,    # seconds (1 hour)
            },
            
            # Per-minute limits
            "per_minute": {
                "requests": 60,
                "window": 60,
            },
            
            # Vehicle endpoints specific limits
            "vehicles_create": {
                "requests": 10,    # Max 10 vehicles created per hour per IP
                "window": 3600,
            },
            
            "vehicles_update": {
                "requests": 100,   # Max 100 updates per hour per IP  
                "window": 3600,
            },
            
            "vehicles_bulk": {
                "requests": 5,     # Max 5 bulk operations per hour
                "window": 3600,
            },
            
            # Search limits
            "search": {
                "requests": 200,   # 200 searches per hour
                "window": 3600,
            }
        }
    
    def _clean_old_requests(self, request_queue: deque, window_seconds: int):
        """Remove requests older than window"""
        cutoff_time = datetime.now() - timedelta(seconds=window_seconds)
        
        while request_queue and request_queue[0] < cutoff_time:
            request_queue.popleft()
    
    def _get_rate_limit_key(self, ip: str, endpoint: str) -> str:
        """Generate key for endpoint-specific rate limiting"""
        return f"{ip}:{endpoint}"
    
    def _get_endpoint_category(self, method: str, path: str) -> str:
        """Categorize endpoint for rate limiting"""
        
        # Vehicle endpoints
        if "/api/vehicles" in path:
            if method == "POST" and path.endswith("/api/vehicles"):
                return "vehicles_create"
            elif method in ["PUT", "PATCH"]:
                return "vehicles_update"  
            elif "/bulk/" in path:
                return "vehicles_bulk"
            elif "/search/" in path:
                return "search"
        
        # Default category
        return "default"
    
    def check_rate_limit(self, ip: str, method: str, path: str) -> tuple[bool, Optional[Dict]]:
        """
        Check if request should be rate limited
        
        Returns:
            (allowed: bool, limit_info: dict or None)
        """
        now = datetime.now()
        
        # Check global per-IP limit
        ip_requests = self.requests[ip]
        self._clean_old_requests(ip_requests, self.limits["global"]["window"])
        
        if len(ip_requests) >= self.limits["global"]["requests"]:
            return False, {
                "error": "Rate limit exceeded",
                "limit": self.limits["global"]["requests"],
                "window": self.limits["global"]["window"],
                "retry_after": self.limits["global"]["window"]
            }
        
        # Check per-minute limit
        self._clean_old_requests(ip_requests, self.limits["per_minute"]["window"])
        minute_requests = sum(1 for req in ip_requests if req > now - timedelta(seconds=60))
        
        if minute_requests >= self.limits["per_minute"]["requests"]:
            return False, {
                "error": "Rate limit exceeded (per minute)",
                "limit": self.limits["per_minute"]["requests"],
                "window": self.limits["per_minute"]["window"],
                "retry_after": 60
            }
        
        # Check endpoint-specific limits
        endpoint_category = self._get_endpoint_category(method, path)
        
        if endpoint_category in self.limits:
            endpoint_key = self._get_rate_limit_key(ip, endpoint_category)
            endpoint_requests = self.endpoint_requests[endpoint_key]
            
            limit_config = self.limits[endpoint_category]
            self._clean_old_requests(endpoint_requests, limit_config["window"])
            
            if len(endpoint_requests) >= limit_config["requests"]:
                return False, {
                    "error": f"Rate limit exceeded for {endpoint_category}",
                    "limit": limit_config["requests"], 
                    "window": limit_config["window"],
                    "retry_after": limit_config["window"]
                }
        
        # All checks passed - record the request
        ip_requests.append(now)
        
        if endpoint_category in self.limits:
            endpoint_key = self._get_rate_limit_key(ip, endpoint_category)
            self.endpoint_requests[endpoint_key].append(now)
        
        return True, None
    
    def get_current_usage(self, ip: str) -> Dict:
        """Get current usage stats for an IP"""
        now = datetime.now()
        ip_requests = self.requests[ip]
        
        # Clean old requests
        self._clean_old_requests(ip_requests, self.limits["global"]["window"])
        
        # Count requests in different windows
        hour_requests = len(ip_requests)
        minute_requests = sum(1 for req in ip_requests if req > now - timedelta(minutes=1))
        
        return {
            "ip": ip,
            "requests_last_hour": hour_requests,
            "requests_last_minute": minute_requests,
            "global_limit_hour": self.limits["global"]["requests"],
            "minute_limit": self.limits["per_minute"]["requests"],
            "timestamp": now.isoformat()
        }

# Global rate limiter instance
rate_limiter = RateLimiter()

async def rate_limit_middleware(request: Request, call_next):
    """
    FastAPI middleware for rate limiting
    """
    
    # Get client IP
    client_ip = request.client.host
    if request.headers.get("x-forwarded-for"):
        client_ip = request.headers.get("x-forwarded-for").split(",")[0].strip()
    elif request.headers.get("x-real-ip"):
        client_ip = request.headers.get("x-real-ip")
    
    # Check rate limit
    allowed, limit_info = rate_limiter.check_rate_limit(
        ip=client_ip,
        method=request.method,
        path=str(request.url.path)
    )
    
    if not allowed:
        logger.warning(f"Rate limit exceeded for IP {client_ip}: {limit_info}")
        
        headers = {
            "X-RateLimit-Limit": str(limit_info["limit"]),
            "X-RateLimit-Window": str(limit_info["window"]),
            "Retry-After": str(limit_info.get("retry_after", 60))
        }
        
        return JSONResponse(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            content={
                "error": limit_info["error"],
                "message": "Muitas requisições. Tente novamente mais tarde.",
                "retry_after": limit_info.get("retry_after", 60)
            },
            headers=headers
        )
    
    # Add rate limit headers to successful responses
    response = await call_next(request)
    
    usage = rate_limiter.get_current_usage(client_ip)
    response.headers["X-RateLimit-Limit"] = str(rate_limiter.limits["global"]["requests"])
    response.headers["X-RateLimit-Remaining"] = str(
        rate_limiter.limits["global"]["requests"] - usage["requests_last_hour"]
    )
    response.headers["X-RateLimit-Reset"] = str(
        int((datetime.now() + timedelta(hours=1)).timestamp())
    )
    
    return response

def get_rate_limit_status(ip: str) -> Dict:
    """Get rate limit status for debugging"""
    return rate_limiter.get_current_usage(ip)