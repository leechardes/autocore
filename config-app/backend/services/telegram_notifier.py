#!/usr/bin/env python3
"""
Serviço de notificações via Telegram para AutoCore
"""

import os
import requests
import json
from typing import Optional, Dict, Any
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

class TelegramNotifier:
    def __init__(self, token: Optional[str] = None, chat_id: Optional[str] = None):
        """
        Inicializa o notificador do Telegram
        
        Args:
            token: Token do bot (ou pega do .env)
            chat_id: ID do chat/grupo (ou pega do .env)
        """
        self.token = token or os.getenv("TELEGRAM_BOT_TOKEN")
        self.chat_id = chat_id or os.getenv("TELEGRAM_CHAT_ID")
        self.enabled = bool(self.token and self.chat_id)
        
        if self.enabled:
            logger.info(f"Telegram notifier habilitado para chat_id: {self.chat_id}")
        else:
            logger.warning("Telegram notifier desabilitado - configure TELEGRAM_BOT_TOKEN e TELEGRAM_CHAT_ID")
    
    def send_message(self, text: str, parse_mode: str = "HTML") -> bool:
        """
        Envia mensagem simples
        
        Args:
            text: Texto da mensagem
            parse_mode: HTML ou Markdown
            
        Returns:
            True se enviou com sucesso
        """
        if not self.enabled:
            logger.debug("Telegram desabilitado - mensagem não enviada")
            return False
            
        url = f"https://api.telegram.org/bot{self.token}/sendMessage"
        
        payload = {
            "chat_id": self.chat_id,
            "text": text,
            "parse_mode": parse_mode
        }
        
        try:
            response = requests.post(url, json=payload, timeout=10)
            if response.status_code == 200:
                logger.debug("Mensagem enviada com sucesso")
                return True
            else:
                logger.error(f"Erro ao enviar mensagem: {response.text}")
                return False
        except Exception as e:
            logger.error(f"Erro ao enviar mensagem: {e}")
            return False
    
    def send_alert(self, title: str, message: str, level: str = "INFO") -> bool:
        """
        Envia alerta formatado
        
        Args:
            title: Título do alerta
            message: Mensagem do alerta
            level: INFO, WARNING, ERROR, CRITICAL
        """
        # Emojis por nível
        emojis = {
            "INFO": "ℹ️",
            "WARNING": "⚠️",
            "ERROR": "❌",
            "CRITICAL": "🚨"
        }
        
        emoji = emojis.get(level, "📢")
        timestamp = datetime.now().strftime("%H:%M:%S")
        
        text = f"""
{emoji} <b>{title}</b>

{message}

⏰ {timestamp}
        """
        
        return self.send_message(text)
    
    def notify_device_status(self, device_name: str, status: str, details: Optional[str] = None) -> bool:
        """
        Notifica mudança de status de dispositivo
        
        Args:
            device_name: Nome do dispositivo
            status: online/offline/error
            details: Detalhes adicionais
        """
        status_emojis = {
            "online": "🟢",
            "offline": "🔴",
            "error": "🟠",
            "registered": "🆕",
            "updated": "🔄"
        }
        
        emoji = status_emojis.get(status, "⚪")
        
        text = f"""
{emoji} <b>Dispositivo: {device_name}</b>
Status: <code>{status}</code>
"""
        
        if details:
            text += f"\n{details}"
            
        return self.send_message(text)
    
    def notify_relay_action(self, channel: int, action: str, device: str = "ESP32") -> bool:
        """
        Notifica ação em relé
        
        Args:
            channel: Número do canal
            action: ON/OFF/TOGGLE
            device: Nome do dispositivo
        """
        action_emojis = {
            "ON": "⚡",
            "OFF": "🔌",
            "TOGGLE": "🔄"
        }
        
        emoji = action_emojis.get(action, "🔧")
        
        text = f"""
{emoji} <b>Relé Acionado</b>

Canal: {channel}
Ação: {action}
Dispositivo: {device}
        """
        
        return self.send_message(text)
    
    def notify_mqtt_message(self, topic: str, payload: Dict[Any, Any]) -> bool:
        """
        Notifica mensagem MQTT importante
        
        Args:
            topic: Tópico MQTT
            payload: Payload da mensagem
        """
        # Filtrar apenas mensagens importantes
        important_topics = ["safety", "error", "alert", "critical"]
        
        if not any(t in topic.lower() for t in important_topics):
            return False
            
        text = f"""
📡 <b>Mensagem MQTT</b>

Tópico: <code>{topic}</code>

Dados:
<pre>{json.dumps(payload, indent=2)}</pre>
        """
        
        return self.send_message(text)
    
    def send_startup_message(self) -> bool:
        """
        Envia mensagem de inicialização do sistema
        """
        text = """
🚀 <b>AutoCore Iniciado</b>

Sistema AutoCore Config App está online!

Serviços ativos:
✅ Backend API
✅ Monitor MQTT
✅ Notificações Telegram
        """
        
        return self.send_message(text)
    
    def send_shutdown_message(self) -> bool:
        """
        Envia mensagem de desligamento do sistema
        """
        text = """
🛑 <b>AutoCore Desligando</b>

Sistema AutoCore Config App está sendo desligado.
        """
        
        return self.send_message(text)

# Instância global
telegram = TelegramNotifier()

# Funções de conveniência
def notify(text: str) -> bool:
    """Envia notificação simples"""
    return telegram.send_message(text)

def alert(title: str, message: str, level: str = "INFO") -> bool:
    """Envia alerta formatado"""
    return telegram.send_alert(title, message, level)

def device_status(device: str, status: str, details: str = None) -> bool:
    """Notifica status de dispositivo"""
    return telegram.notify_device_status(device, status, details)