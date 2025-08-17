import React, { useState, useEffect, useRef } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
// ScrollArea substituído por div com overflow
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { 
  Activity, Wifi, WifiOff, Send, Filter, Trash2, Download, 
  Play, Pause, Search, Copy, CheckCircle2, XCircle, 
  ArrowUpCircle, ArrowDownCircle, Clock, Radio, Power, PowerOff,
  ToggleLeft, ToggleRight, Settings, Cpu, RefreshCw, HelpCircle
} from 'lucide-react';
import { toast } from 'sonner';
import api from '@/lib/api';
import mqttService from '@/services/mqttService';
import HelpButtonTest from '@/components/HelpButtonTest';

const MQTTMonitorPage = () => {
  const [connected, setConnected] = useState(false);
  const [messages, setMessages] = useState([]);
  const [filteredMessages, setFilteredMessages] = useState([]);
  const [filter, setFilter] = useState('');
  const [typeFilter, setTypeFilter] = useState('all');
  const [deviceFilter, setDeviceFilter] = useState('all');
  const [isPaused, setIsPaused] = useState(false);
  const [stats, setStats] = useState({
    total: 0,
    received: 0,
    sent: 0,
    devices: new Set()
  });
  
  // Estados para conformidade MQTT v2.2.0
  const [protocolStats, setProtocolStats] = useState({
    v2_2_0: 0,
    legacy: 0,
    invalid: 0,
    compliance_rate: 0
  });
  
  // WebSocket
  const ws = useRef(null);
  const messagesEndRef = useRef(null);
  
  // Publish form
  const [publishTopic, setPublishTopic] = useState('');
  const [publishPayload, setPublishPayload] = useState('');
  const [publishQos, setPublishQos] = useState('1');
  
  // Simulator state
  const [simulatorBoards, setSimulatorBoards] = useState([]);
  const [activeSimulators, setActiveSimulators] = useState([]);
  const [selectedBoard, setSelectedBoard] = useState(null);
  const [boardChannels, setBoardChannels] = useState([]);
  const [loadingSimulator, setLoadingSimulator] = useState(false);
  const [togglingChannel, setTogglingChannel] = useState(null);
  const [heartbeatIntervals, setHeartbeatIntervals] = useState({});
  
  // Ref para manter selectedBoard acessível no WebSocket
  const selectedBoardRef = useRef(null);
  useEffect(() => {
    selectedBoardRef.current = selectedBoard;
  }, [selectedBoard]);
  
  // Templates MQTT v2.2.0 conformes
  const templates = mqttService.getTemplates();
  
  useEffect(() => {
    // Conectar imediatamente
    connectWebSocket();
    
    return () => {
      if (ws.current) {
        ws.current.close();
      }
      
      // Limpar todos os heartbeats ao desmontar
      Object.values(heartbeatIntervals).forEach(intervalId => {
        clearInterval(intervalId);
      });
    };
  }, []);
  
  useEffect(() => {
    // Auto-scroll para última mensagem
    if (!isPaused && messagesEndRef.current) {
      messagesEndRef.current.scrollIntoView({ behavior: 'smooth' });
    }
  }, [messages, isPaused]);
  
  // Limpeza automática de mensagens antigas para evitar problemas de memória
  useEffect(() => {
    const cleanupInterval = setInterval(() => {
      setMessages(prev => {
        if (prev.length > 500) {
          return prev.slice(-500);
        }
        return prev;
      });
      
      setFilteredMessages(prev => {
        if (prev.length > 500) {
          return prev.slice(-500);
        }
        return prev;
      });
    }, 60000); // Limpar apenas a cada 60 segundos
    
    return () => clearInterval(cleanupInterval);
  }, []);
  
  useEffect(() => {
    // Aplicar filtros
    let filtered = [...messages];
    
    // Filtro de texto
    if (filter) {
      filtered = filtered.filter(msg => 
        msg.topic.toLowerCase().includes(filter.toLowerCase()) ||
        msg.payload.toLowerCase().includes(filter.toLowerCase())
      );
    }
    
    // Filtro de tipo
    if (typeFilter !== 'all') {
      filtered = filtered.filter(msg => msg.message_type === typeFilter);
    }
    
    // Filtro de dispositivo
    if (deviceFilter !== 'all') {
      filtered = filtered.filter(msg => msg.device_uuid === deviceFilter);
    }
    
    setFilteredMessages(filtered);
  }, [messages, filter, typeFilter, deviceFilter]);
  
  const updateProtocolStats = (protocolVersion) => {
    setProtocolStats(prev => {
      let newStats = { ...prev };
      
      if (!protocolVersion) {
        newStats.invalid += 1;
      } else if (protocolVersion === '2.2.0') {
        newStats.v2_2_0 += 1;
      } else if (protocolVersion.startsWith('2.')) {
        newStats.legacy += 1;
      } else {
        newStats.invalid += 1;
      }
      
      const total = newStats.v2_2_0 + newStats.legacy + newStats.invalid;
      newStats.compliance_rate = total > 0 ? newStats.v2_2_0 / total : 0;
      
      return newStats;
    });
  };
  
  const validateProtocolVersion = (version) => {
    if (!version) return false;
    const [major] = version.split('.');
    return major === '2';
  };
  
  const renderProtocolBadge = (version, isValid) => {
    if (!version) {
      return <Badge variant="destructive">No Version</Badge>;
    }
    if (version === '2.2.0') {
      return <Badge variant="default" className="bg-green-500">v2.2.0 ✓</Badge>;
    }
    if (isValid) {
      return <Badge variant="secondary">{version}</Badge>;
    }
    return <Badge variant="destructive">{version} ✗</Badge>;
  };

  const connectWebSocket = () => {
    // Prevenir múltiplas conexões
    if (ws.current && ws.current.readyState === WebSocket.CONNECTING) {
      return;
    }
    
    if (ws.current && ws.current.readyState === WebSocket.OPEN) {
      return;
    }
    
    // Usar a mesma porta do frontend para evitar CORS
    const host = window.location.hostname;
    // Usar variável de ambiente ou fallback para produção
    const wsPort = import.meta.env.VITE_API_PORT || '5000';
    const wsUrl = `ws://${host}:${wsPort}/ws/mqtt`;
    
    try {
      // Criar WebSocket sem headers extras
      ws.current = new WebSocket(wsUrl);
    } catch (error) {
      console.error('Erro ao criar WebSocket:', error);
      toast.error('Erro ao conectar WebSocket');
      return;
    }
    
    ws.current.onopen = () => {
      setConnected(true);
      toast.success('Conectado ao Monitor MQTT');
    };
    
    ws.current.onerror = (error) => {
      console.error('WebSocket error:', error);
      console.error('ReadyState:', ws.current.readyState);
      console.error('URL:', ws.current.url);
      toast.error('Erro na conexão WebSocket');
    };
    
    ws.current.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        
        // Debug - ver mensagem recebida (comentar em produção)
        
        // Debug detalhado para mensagens MQTT (remover depois que estiver funcionando)
        // if (data.type === 'mqtt_message' && data.data) {
        //   const msgData = data.data;
        //     topic: msgData.topic,
        //     message_type: msgData.message_type,
        //     payload: msgData.payload
        //   });
        //   
        //   // Verificar se é relacionado a relés
        //   if (msgData.topic && (msgData.topic.includes('relay') || msgData.message_type === 'relay_state')) {
        //   }
        // }
        
        if (data.type === 'mqtt_status') {
          setConnected(data.data.status === 'connected');
        } else if (data.type === 'mqtt_message' && !isPaused) {
          const msg = data.data;
          
          // Garantir que a mensagem tem todos os campos necessários
          // Extrair protocol_version do payload se não estiver no nível superior
          let parsedPayload = msg.payload;
          if (typeof msg.payload === 'string') {
            try {
              parsedPayload = JSON.parse(msg.payload);
            } catch (e) {
              parsedPayload = msg.payload;
            }
          }
          
          const processedMsg = {
            ...msg,
            timestamp: msg.timestamp || new Date().toISOString(),
            topic: msg.topic || 'unknown',
            payload: parsedPayload || {},
            message_type: msg.message_type || msg.type || 'message',
            direction: msg.direction || 'received',
            qos: msg.qos !== undefined ? msg.qos : 0,
            protocol_version: msg.protocol_version || (parsedPayload && parsedPayload.protocol_version) || null,
            device_uuid: mqttService.extractDeviceUuid(msg.topic, parsedPayload)
          };
          
          setMessages(prev => {
            // Manter últimas 500 mensagens para não sobrecarregar o DOM
            const newMessages = [...prev.slice(-499), processedMsg]; // Manter máximo 500
            return newMessages;
          });
          
          // Atualizar stats
          setStats(prev => {
            const newDevices = new Set(prev.devices);
            if (processedMsg.device_uuid) {
              newDevices.add(processedMsg.device_uuid);
            }
            
            // Limitar número de dispositivos para evitar crescimento infinito
            if (newDevices.size > 20) {
              newDevices.clear();
              if (processedMsg.device_uuid) {
                newDevices.add(processedMsg.device_uuid);
              }
            }
            
            return {
              total: prev.total + 1,
              received: processedMsg.direction === 'received' ? prev.received + 1 : prev.received,
              sent: processedMsg.direction === 'sent' ? prev.sent + 1 : prev.sent,
              devices: newDevices
            };
          });
          
          // Atualizar estatísticas de conformidade
          updateProtocolStats(processedMsg.protocol_version);
          
          // Atualizar estado dos canais se for mensagem de estado de relé
          if (processedMsg.message_type === 'relay_state' && processedMsg.topic.includes('/relays/state')) {
            try {
              const payloadData = typeof processedMsg.payload === 'string' 
                ? JSON.parse(processedMsg.payload) 
                : processedMsg.payload;
              
              const currentSelectedBoard = selectedBoardRef.current;
              
              if (payloadData.channels && payloadData.board_id === currentSelectedBoard) {
                // Atualizar estado dos canais com base na mensagem MQTT
                setBoardChannels(prevChannels => 
                  prevChannels.map(channel => ({
                    ...channel,
                    simulated_state: payloadData.channels[channel.channel_number.toString()] || false
                  }))
                );
              }
            } catch (e) {
              console.error('Erro atualizando estado dos canais:', e);
            }
          }
        } else if (data.type === 'history') {
          setMessages(data.data);
          setStats({
            total: data.data.length,
            received: data.data.filter(m => m.direction === 'received').length,
          sent: data.data.filter(m => m.direction === 'sent').length,
          devices: new Set(data.data.filter(m => m.device_uuid).map(m => m.device_uuid))
        });
        }
      } catch (error) {
        console.error('Erro processando mensagem WebSocket:', error);
        console.error('Dados recebidos:', event.data);
      }
    };
    
    ws.current.onerror = (error) => {
      console.error('WebSocket erro:', error);
      const port = import.meta.env.VITE_API_PORT || '5000';
      toast.error(`Erro na conexão WebSocket - Verifique se o backend está rodando na porta ${port}`);
      setConnected(false);
    };
    
    ws.current.onclose = (event) => {
      setConnected(false);
      
      // Só reconectar se não foi fechamento intencional
      if (event.code !== 1000) {
        toast.warning('Conexão WebSocket perdida - Reconectando em 5s...');
        
        // Reconectar após 5 segundos
        setTimeout(() => {
          if (!ws.current || ws.current.readyState === WebSocket.CLOSED) {
            connectWebSocket();
          }
        }, 5000);
      }
    };
  };
  
  const publishMessage = async () => {
    if (!publishTopic || !publishPayload) {
      toast.error('Preencha tópico e payload');
      return;
    }
    
    try {
      let payload;
      try {
        payload = JSON.parse(publishPayload);
      } catch {
        payload = publishPayload;
      }
      
      const result = await mqttService.publish(publishTopic, payload, { qos: parseInt(publishQos) });
      
      if (result.success) {
        toast.success('Mensagem publicada com conformidade v2.2.0!');
      } else {
        toast.error('Erro ao publicar: ' + result.error);
      }
    } catch (error) {
      toast.error('Erro ao publicar: ' + error.message);
    }
  };
  
  const loadTemplate = (template) => {
    setPublishTopic(template.topic);
    setPublishPayload(JSON.stringify(template.payload, null, 2));
    toast.success('Template v2.2.0 carregado');
  };
  
  const clearMessages = async () => {
    // Limpar no backend também
    try {
      const apiPort = import.meta.env.VITE_API_PORT || '5000';
      const response = await fetch(`http://${window.location.hostname}:${apiPort}/api/mqtt/clear`, {
        method: 'POST'
      });
      if (response.ok) {
        setMessages([]);
        setFilteredMessages([]);
        setStats({ total: 0, received: 0, sent: 0, devices: new Set() });
        setProtocolStats({ v2_2_0: 0, legacy: 0, invalid: 0, compliance_rate: 0 });
        toast.success('Histórico limpo no servidor e localmente');
      }
    } catch (error) {
      console.error('Erro ao limpar histórico:', error);
      // Limpar apenas localmente se falhar
      setMessages([]);
      setFilteredMessages([]);
      setStats({ total: 0, received: 0, sent: 0, devices: new Set() });
      setProtocolStats({ v2_2_0: 0, legacy: 0, invalid: 0, compliance_rate: 0 });
      toast.warning('Limpo apenas localmente');
    }
  };
  
  const exportMessages = () => {
    const dataStr = JSON.stringify(messages, null, 2);
    const dataUri = 'data:application/json;charset=utf-8,'+ encodeURIComponent(dataStr);
    
    const exportFileDefaultName = `mqtt-messages-${new Date().toISOString()}.json`;
    
    const linkElement = document.createElement('a');
    linkElement.setAttribute('href', dataUri);
    linkElement.setAttribute('download', exportFileDefaultName);
    linkElement.click();
    
    toast.success('Mensagens exportadas');
  };
  
  const copyMessage = async (msg) => {
    try {
      // Debug - ver estrutura da mensagem
      
      // Formatar a mensagem completa para copiar
      const timestamp = msg.timestamp ? new Date(msg.timestamp).toLocaleString('pt-BR') : 'N/A';
      const payload = msg.payload ? formatPayload(msg.payload) : '';
      const messageType = msg.message_type || msg.type || 'unknown';
      const topic = msg.topic || 'N/A';
      const qos = msg.qos !== undefined ? msg.qos : 0;
      
      const formattedMessage = `=== MQTT Message ===
Tipo: ${messageType}
Tópico: ${topic}
QoS: ${qos}
Timestamp: ${timestamp}

Payload:
${payload}
==================`;
      
      
      // Tentar usar a API moderna primeiro
      if (navigator.clipboard && window.isSecureContext) {
        await navigator.clipboard.writeText(formattedMessage);
        toast.success('Mensagem copiada para área de transferência');
      } else {
        // Fallback para browsers que não suportam clipboard API ou contexto não seguro
        const textArea = document.createElement('textarea');
        textArea.value = formattedMessage;
        textArea.style.position = 'fixed';
        textArea.style.left = '-999999px';
        textArea.style.top = '0';
        document.body.appendChild(textArea);
        textArea.focus();
        textArea.select();
        
        const successful = document.execCommand('copy');
        document.body.removeChild(textArea);
        
        if (successful) {
          toast.success('Mensagem copiada para área de transferência');
        } else {
          toast.error('Erro ao copiar mensagem');
        }
      }
    } catch (error) {
      console.error('Erro ao copiar:', error);
      toast.error('Erro ao copiar mensagem: ' + error.message);
    }
  };
  
  const getMessageTypeColor = (type) => {
    const colors = {
      'announce': 'bg-green-500',
      'status': 'bg-blue-500',
      'telemetry': 'bg-purple-500',
      'command': 'bg-orange-500',
      'response': 'bg-yellow-500',
      'relay': 'bg-pink-500',
      'relay_status': 'bg-pink-500',
      'relay_state': 'bg-rose-500',     // Estado dos relés
      'relay_command': 'bg-amber-500',   // Comandos de relé para ESP32
      'macro_status': 'bg-violet-500',   // Status de macros
      'state_save': 'bg-teal-500',       // Save state
      'state_restore': 'bg-teal-600',    // Restore state
      'mode_change': 'bg-lime-500',      // Mudança de modo
      'system_command': 'bg-red-500',    // Comandos do sistema
      'discovery': 'bg-cyan-500',
      'gateway_status': 'bg-indigo-500'
    };
    return colors[type] || 'bg-gray-500';
  };
  
  const formatPayload = (payload) => {
    // Se já for um objeto, formata diretamente
    if (typeof payload === 'object' && payload !== null) {
      return JSON.stringify(payload, null, 2);
    }
    
    // Se for string, tenta fazer parse
    if (typeof payload === 'string') {
      try {
        const obj = JSON.parse(payload);
        return JSON.stringify(obj, null, 2);
      } catch {
        // Se não for JSON válido, retorna como está
        return payload;
      }
    }
    
    // Para outros tipos, converte para string
    return String(payload);
  };
  
  // Simulator functions
  const loadSimulatorBoards = async () => {
    try {
      const boards = await api.getSimulatorBoards();
      setSimulatorBoards(boards);
      
      const simulators = await api.listRelaySimulators();
      setActiveSimulators(simulators);
    } catch (error) {
      console.error('Erro carregando simuladores:', error);
      toast.error('Erro ao carregar simuladores');
    }
  };
  
  const createSimulator = async (boardId) => {
    setLoadingSimulator(true);
    try {
      const result = await api.createRelaySimulator(boardId);
      toast.success('Simulador criado com sucesso!');
      
      // Recarregar lista
      await loadSimulatorBoards();
      
      // Selecionar a placa criada
      setSelectedBoard(boardId);
      await loadBoardChannels(boardId);
    } catch (error) {
      console.error('Erro criando simulador:', error);
      toast.error('Erro ao criar simulador');
    } finally {
      setLoadingSimulator(false);
    }
  };
  
  const removeSimulator = async (boardId) => {
    try {
      await api.removeRelaySimulator(boardId);
      toast.success('Simulador removido');
      
      // Recarregar lista
      await loadSimulatorBoards();
      
      if (selectedBoard === boardId) {
        setSelectedBoard(null);
        setBoardChannels([]);
      }
    } catch (error) {
      console.error('Erro removendo simulador:', error);
      toast.error('Erro ao remover simulador');
    }
  };
  
  const loadBoardChannels = async (boardId) => {
    try {
      const channels = await api.getBoardChannelsWithState(boardId);
      setBoardChannels(channels);
    } catch (error) {
      console.error('Erro carregando canais:', error);
    }
  };
  
  const toggleChannel = async (boardId, channelNumber) => {
    try {
      // Marcar canal como carregando
      setTogglingChannel(channelNumber);
      
      await api.toggleRelayChannel(boardId, channelNumber);
      
      // Recarregar estado dos canais após resposta
      await loadBoardChannels(boardId);
      
      toast.success(`Canal ${channelNumber} alternado - Estado atualizado do simulador`);
    } catch (error) {
      console.error('Erro alternando canal:', error);
      toast.error('Erro ao alternar canal');
    } finally {
      // Limpar estado de carregando
      setTogglingChannel(null);
    }
  };
  
  const pressChannel = async (boardId, channelNumber, state) => {
    try {
      if (state) {
        // Ligando - envia estado inicial com flag momentâneo
        await api.post(`/simulators/relay/${boardId}/channel/${channelNumber}/set`, { 
          state: true, 
          is_momentary: true 
        });
        
        // Inicia envio de heartbeats a cada 500ms
        const intervalId = setInterval(async () => {
          try {
            await api.post(`/simulators/relay/${boardId}/channel/${channelNumber}/heartbeat`);
          } catch (error) {
            console.error('Erro enviando heartbeat:', error);
            // Se falhar, para o heartbeat
            clearInterval(intervalId);
          }
        }, 500); // Envia heartbeat a cada 500ms
        
        // Armazena o interval para poder cancelar depois
        setHeartbeatIntervals(prev => ({
          ...prev,
          [channelNumber]: intervalId
        }));
        
        toast.success(`Canal ${channelNumber} pressionado - Enviando heartbeats`);
      } else {
        // Desligando - para heartbeat e envia OFF
        const intervalId = heartbeatIntervals[channelNumber];
        if (intervalId) {
          clearInterval(intervalId);
          setHeartbeatIntervals(prev => {
            const newIntervals = { ...prev };
            delete newIntervals[channelNumber];
            return newIntervals;
          });
        }
        
        await api.post(`/simulators/relay/${boardId}/channel/${channelNumber}/set`, { 
          state: false, 
          is_momentary: true 
        });
        
        toast.info(`Canal ${channelNumber} liberado`);
      }
      
      // Recarregar estado dos canais
      await loadBoardChannels(boardId);
      
    } catch (error) {
      console.error('Erro definindo estado do canal:', error);
      toast.error('Erro ao controlar canal');
      
      // Limpar heartbeat em caso de erro
      const intervalId = heartbeatIntervals[channelNumber];
      if (intervalId) {
        clearInterval(intervalId);
      }
    }
  };
  
  const resetBoard = async (boardId) => {
    try {
      await api.resetRelaySimulator(boardId);
      await loadBoardChannels(boardId);
      toast.success('Todos os canais resetados');
    } catch (error) {
      console.error('Erro resetando simulador:', error);
      toast.error('Erro ao resetar simulador');
    }
  };
  
  // Load simulators on mount
  useEffect(() => {
    loadSimulatorBoards();
  }, []);
  
  // Unique devices for filter
  const uniqueDevices = Array.from(stats.devices);
  
  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Monitor MQTT</h1>
          <p className="text-muted-foreground">
            Monitor em tempo real das mensagens MQTT do sistema
          </p>
        </div>
        <div className="flex items-center gap-2">
          <Button 
            variant="outline"
            size="sm"
            onClick={() => alert('Ajuda do Monitor MQTT\n\n• Use os filtros para encontrar mensagens específicas\n• Pause para parar a rolagem automática\n• Clique em uma mensagem para ver detalhes\n• Use o simulador de relés para testar comandos\n• Exporte logs importantes com o botão Download')}
            className="gap-2"
          >
            <HelpCircle className="h-4 w-4" />
            Ajuda
          </Button>
          
          <Badge variant={connected ? "success" : "destructive"} className="gap-1">
            {connected ? <Wifi className="h-3 w-3" /> : <WifiOff className="h-3 w-3" />}
            {connected ? 'Conectado' : 'Desconectado'}
          </Badge>
          
          <Badge variant="outline" className="gap-1">
            <Activity className="h-3 w-3" />
            {stats.total} mensagens
          </Badge>
          
          {uniqueDevices.length > 0 && (
            <Badge variant="outline" className="gap-1">
              <Radio className="h-3 w-3" />
              {uniqueDevices.length} ESP32
            </Badge>
          )}
          
          {protocolStats.v2_2_0 > 0 && (
            <Badge variant="default" className="gap-1 bg-green-500">
              <CheckCircle2 className="h-3 w-3" />
              {protocolStats.v2_2_0} v2.2.0
            </Badge>
          )}
          
          {protocolStats.invalid > 0 && (
            <Badge variant="destructive" className="gap-1">
              <XCircle className="h-3 w-3" />
              {protocolStats.invalid} inválidas
            </Badge>
          )}
        </div>
      </div>
      
      <Tabs defaultValue="monitor" className="space-y-4">
        <TabsList className="grid w-full grid-cols-5">
          <TabsTrigger value="monitor">Monitor</TabsTrigger>
          <TabsTrigger value="publish">Publicar</TabsTrigger>
          <TabsTrigger value="protocol">Protocolo</TabsTrigger>
          <TabsTrigger value="simulators">Simuladores</TabsTrigger>
          <TabsTrigger value="stats">Estatísticas</TabsTrigger>
        </TabsList>
        
        {/* Monitor Tab */}
        <TabsContent value="monitor" className="space-y-4">
          {/* Controls */}
          <Card>
            <CardHeader className="pb-3">
              <div className="flex items-center justify-between">
                <CardTitle>Mensagens MQTT</CardTitle>
                
                <div className="flex items-center gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setIsPaused(!isPaused)}
                  >
                    {isPaused ? <Play className="h-4 w-4" /> : <Pause className="h-4 w-4" />}
                    {isPaused ? 'Continuar' : 'Pausar'}
                  </Button>
                  
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={clearMessages}
                  >
                    <Trash2 className="h-4 w-4" />
                    Limpar
                  </Button>
                  
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={exportMessages}
                  >
                    <Download className="h-4 w-4" />
                    Exportar
                  </Button>
                </div>
              </div>
            </CardHeader>
            
            <CardContent className="space-y-4">
              {/* Filters */}
              <div className="flex items-center gap-2">
                <div className="relative flex-1">
                  <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                  <Input
                    placeholder="Filtrar mensagens..."
                    value={filter}
                    onChange={(e) => setFilter(e.target.value)}
                    className="pl-8"
                  />
                </div>
                
                <Select value={typeFilter} onValueChange={setTypeFilter}>
                  <SelectTrigger className="w-[180px]">
                    <SelectValue placeholder="Tipo" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">Todos os tipos</SelectItem>
                    <SelectItem value="announce">Announce</SelectItem>
                    <SelectItem value="status">Status</SelectItem>
                    <SelectItem value="telemetry">Telemetria</SelectItem>
                    <SelectItem value="command">Comando</SelectItem>
                    <SelectItem value="response">Resposta</SelectItem>
                    <SelectItem value="relay">Relé</SelectItem>
                    <SelectItem value="relay_status">Relé Status</SelectItem>
                    <SelectItem value="relay_state">Estado Relés</SelectItem>
                    <SelectItem value="relay_command">Comando Relés</SelectItem>
                    <SelectItem value="macro_status">Macro Status</SelectItem>
                    <SelectItem value="state_save">Save State</SelectItem>
                    <SelectItem value="state_restore">Restore State</SelectItem>
                    <SelectItem value="mode_change">Mudança Modo</SelectItem>
                    <SelectItem value="system_command">Sistema</SelectItem>
                    <SelectItem value="discovery">Discovery</SelectItem>
                    <SelectItem value="gateway_status">Gateway Status</SelectItem>
                  </SelectContent>
                </Select>
                
                <Select value={deviceFilter} onValueChange={setDeviceFilter}>
                  <SelectTrigger className="w-[180px]">
                    <SelectValue placeholder="Dispositivo" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">Todos</SelectItem>
                    {uniqueDevices.map(device => (
                      <SelectItem key={device} value={device}>{device}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              
              {/* Messages */}
              <div className="h-[500px] w-full rounded-md border p-4 overflow-y-auto">
                <div className="space-y-2">
                  {filteredMessages.map((msg, index) => (
                    <div
                      key={index}
                      className="rounded-lg border bg-card p-3 text-card-foreground shadow-sm"
                    >
                      <div className="flex items-start justify-between">
                        <div className="space-y-1 flex-1">
                          <div className="flex items-center gap-2 flex-wrap">
                            <Badge className={`${getMessageTypeColor(msg.message_type || msg.type)} text-white`}>
                              {msg.message_type || msg.type || 'unknown'}
                            </Badge>
                            
                            {msg.direction === 'sent' ? (
                              <ArrowUpCircle className="h-4 w-4 text-green-500" title="Enviado" />
                            ) : (
                              <ArrowDownCircle className="h-4 w-4 text-blue-500" title="Recebido" />
                            )}
                            
                            <span className="font-mono text-sm font-semibold">{msg.topic || 'N/A'}</span>
                            
                            {msg.device_uuid && (
                              <Badge variant="outline" className="text-xs">{msg.device_uuid}</Badge>
                            )}
                            
                            {renderProtocolBadge(msg.protocol_version, validateProtocolVersion(msg.protocol_version))}
                          </div>
                          
                          <div className="mt-2">
                            <pre className="text-xs bg-muted p-3 rounded overflow-x-auto max-h-[300px]">
                              {formatPayload(msg.payload)}
                            </pre>
                          </div>
                          
                          <div className="flex items-center gap-4 text-xs text-muted-foreground">
                            <span className="flex items-center gap-1">
                              <Clock className="h-3 w-3" />
                              {new Date(msg.timestamp).toLocaleTimeString()}
                            </span>
                            <span>QoS: {msg.qos}</span>
                          </div>
                        </div>
                        
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={(e) => {
                            e.stopPropagation();
                            copyMessage(msg);
                          }}
                          title="Copiar mensagem"
                        >
                          <Copy className="h-4 w-4" />
                        </Button>
                      </div>
                    </div>
                  ))}
                  
                  {filteredMessages.length === 0 && (
                    <div className="text-center text-muted-foreground py-8">
                      {messages.length === 0 
                        ? 'Nenhuma mensagem recebida ainda'
                        : 'Nenhuma mensagem corresponde aos filtros'}
                    </div>
                  )}
                  
                  <div ref={messagesEndRef} />
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
        
        {/* Publish Tab */}
        <TabsContent value="publish" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Publicar Mensagem MQTT</CardTitle>
              <CardDescription>
                Envie mensagens de teste para o broker MQTT
              </CardDescription>
            </CardHeader>
            
            <CardContent className="space-y-4">
              {/* Quick Templates */}
              <div>
                <Label>Templates Rápidos</Label>
                <div className="grid grid-cols-2 gap-2 mt-2">
                  {Object.entries(templates).map(([key, template]) => (
                    <Button
                      key={key}
                      variant="outline"
                      size="sm"
                      onClick={() => loadTemplate(template)}
                    >
                      {key.replace(/([A-Z])/g, ' $1').trim()}
                    </Button>
                  ))}
                </div>
              </div>
              
              {/* Topic */}
              <div className="space-y-2">
                <Label htmlFor="topic">Tópico</Label>
                <Input
                  id="topic"
                  placeholder="autocore/devices/test-esp32/command"
                  value={publishTopic}
                  onChange={(e) => setPublishTopic(e.target.value)}
                />
              </div>
              
              {/* Payload */}
              <div className="space-y-2">
                <Label htmlFor="payload">Payload (JSON)</Label>
                <Textarea
                  id="payload"
                  placeholder='{"command": "test"}'
                  value={publishPayload}
                  onChange={(e) => setPublishPayload(e.target.value)}
                  rows={10}
                  className="font-mono text-sm"
                />
              </div>
              
              {/* QoS */}
              <div className="space-y-2">
                <Label htmlFor="qos">QoS Level</Label>
                <Select value={publishQos} onValueChange={setPublishQos}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="0">0 - At most once</SelectItem>
                    <SelectItem value="1">1 - At least once</SelectItem>
                    <SelectItem value="2">2 - Exactly once</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              
              {/* Publish Button */}
              <Button 
                onClick={publishMessage} 
                className="w-full"
                disabled={!connected}
              >
                <Send className="mr-2 h-4 w-4" />
                Publicar Mensagem
              </Button>
            </CardContent>
          </Card>
        </TabsContent>
        
        {/* Protocol Tab */}
        <TabsContent value="protocol" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Conformidade MQTT v2.2.0</CardTitle>
              <CardDescription>
                Validação e estatísticas de conformidade com o protocolo v2.2.0
              </CardDescription>
            </CardHeader>
            
            <CardContent className="space-y-4">
              {/* Protocol Stats */}
              <div className="grid gap-4 md:grid-cols-4">
                <div className="text-center p-4 border rounded-lg bg-green-50 dark:bg-green-900/20">
                  <div className="text-2xl font-bold text-green-600">{protocolStats.v2_2_0}</div>
                  <div className="text-sm text-green-700">v2.2.0 Conformes</div>
                </div>
                <div className="text-center p-4 border rounded-lg bg-yellow-50 dark:bg-yellow-900/20">
                  <div className="text-2xl font-bold text-yellow-600">{protocolStats.legacy}</div>
                  <div className="text-sm text-yellow-700">v2.x Legacy</div>
                </div>
                <div className="text-center p-4 border rounded-lg bg-red-50 dark:bg-red-900/20">
                  <div className="text-2xl font-bold text-red-600">{protocolStats.invalid}</div>
                  <div className="text-sm text-red-700">Inválidas</div>
                </div>
                <div className="text-center p-4 border rounded-lg bg-blue-50 dark:bg-blue-900/20">
                  <div className="text-2xl font-bold text-blue-600">
                    {Math.round(protocolStats.compliance_rate * 100)}%
                  </div>
                  <div className="text-sm text-blue-700">Taxa Conformidade</div>
                </div>
              </div>
              
              {/* Validation Tools */}
              <div className="space-y-4">
                <h3 className="text-lg font-semibold">Ferramentas de Validação</h3>
                
                <div className="grid gap-4 md:grid-cols-2">
                  <div className="space-y-2">
                    <Label>Templates v2.2.0</Label>
                    <div className="grid grid-cols-2 gap-2">
                      {Object.entries(templates).map(([key, template]) => (
                        <Button
                          key={key}
                          variant="outline"
                          size="sm"
                          onClick={() => loadTemplate(template)}
                          className="text-left justify-start"
                        >
                          {key.replace(/([A-Z])/g, ' $1').trim()}
                        </Button>
                      ))}
                    </div>
                  </div>
                  
                  <div className="space-y-2">
                    <Label>Estrutura de Tópicos v2.2.0</Label>
                    <div className="text-xs space-y-1 font-mono bg-muted p-3 rounded">
                      <div>✅ autocore/devices/[uuid]/relays/set</div>
                      <div>✅ autocore/telemetry/relays/data</div>
                      <div>✅ autocore/discovery/announce</div>
                      <div>✅ autocore/gateway/status</div>
                      <div>❌ autocore/devices/[uuid]/telemetry</div>
                      <div>❌ autocore/devices/[uuid]/relay/command</div>
                    </div>
                  </div>
                </div>
                
                <div className="space-y-2">
                  <Label>Campos Obrigatórios v2.2.0</Label>
                  <div className="grid gap-2 md:grid-cols-3">
                    <div className="text-xs bg-muted p-3 rounded">
                      <div className="font-semibold mb-1">Todos os Payloads:</div>
                      <div>• protocol_version: "2.2.0"</div>
                      <div>• timestamp: ISO 8601</div>
                    </div>
                    <div className="text-xs bg-muted p-3 rounded">
                      <div className="font-semibold mb-1">Telemetria:</div>
                      <div>• uuid: device_uuid</div>
                      <div>• event: event_type</div>
                    </div>
                    <div className="text-xs bg-muted p-3 rounded">
                      <div className="font-semibold mb-1">Comandos Relé:</div>
                      <div>• channel: number</div>
                      <div>• state: boolean</div>
                      <div>• function_type: string</div>
                      <div>• user: string</div>
                    </div>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
        
        {/* Stats Tab */}
        <TabsContent value="stats" className="space-y-4">
          <div className="grid gap-4 md:grid-cols-3">
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Total de Mensagens</CardTitle>
                <Activity className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stats.total}</div>
              </CardContent>
            </Card>
            
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Mensagens Recebidas</CardTitle>
                <ArrowDownCircle className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stats.received}</div>
              </CardContent>
            </Card>
            
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Mensagens Enviadas</CardTitle>
                <ArrowUpCircle className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stats.sent}</div>
              </CardContent>
            </Card>
          </div>
          
          <Card>
            <CardHeader>
              <CardTitle>Dispositivos Ativos</CardTitle>
              <CardDescription>
                Dispositivos que enviaram mensagens durante esta sessão
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="flex flex-wrap gap-2">
                {uniqueDevices.length > 0 ? (
                  uniqueDevices.map(device => (
                    <Badge key={device} variant="secondary">
                      {device}
                    </Badge>
                  ))
                ) : (
                  <p className="text-muted-foreground">Nenhum dispositivo detectado ainda</p>
                )}
              </div>
            </CardContent>
          </Card>
          
          <Card>
            <CardHeader>
              <CardTitle>Distribuição de Mensagens</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-2">
                {Object.entries(
                  messages.reduce((acc, msg) => {
                    const type = msg.message_type || 'unknown';
                    acc[type] = (acc[type] || 0) + 1;
                    return acc;
                  }, {})
                ).map(([type, count]) => (
                  <div key={type} className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <Badge className={`${getMessageTypeColor(type)} text-white`}>
                        {type}
                      </Badge>
                    </div>
                    <span className="font-mono">{count}</span>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>
        
        {/* Simulators Tab */}
        <TabsContent value="simulators" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Simuladores de Placa de Relé</CardTitle>
              <CardDescription>
                Simule o comportamento de placas de relé ESP32 via MQTT
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              {/* Board Selection */}
              <div className="grid gap-4 md:grid-cols-2">
                <div>
                  <Label>Placas Disponíveis</Label>
                  <div className="space-y-2 mt-2">
                    {simulatorBoards.map((board) => (
                      <div key={board.board_id} className="flex items-center justify-between p-3 border rounded-lg">
                        <div>
                          <div className="font-medium">{board.device_name}</div>
                          <div className="text-sm text-muted-foreground">
                            {board.total_channels} canais • {board.board_model}
                          </div>
                        </div>
                        <div className="flex items-center gap-2">
                          {board.has_simulator ? (
                            <>
                              <Badge variant={board.simulator_connected ? "success" : "secondary"}>
                                {board.simulator_connected ? 'Conectado' : 'Desconectado'}
                              </Badge>
                              <Button
                                size="sm"
                                variant="outline"
                                onClick={() => {
                                  setSelectedBoard(board.board_id);
                                  loadBoardChannels(board.board_id);
                                }}
                              >
                                <Settings className="h-4 w-4" />
                              </Button>
                              <Button
                                size="sm"
                                variant="destructive"
                                onClick={() => removeSimulator(board.board_id)}
                              >
                                <Trash2 className="h-4 w-4" />
                              </Button>
                            </>
                          ) : (
                            <Button
                              size="sm"
                              onClick={() => createSimulator(board.board_id)}
                              disabled={loadingSimulator}
                            >
                              <Power className="h-4 w-4 mr-1" />
                              Criar Simulador
                            </Button>
                          )}
                        </div>
                      </div>
                    ))}
                    
                    {simulatorBoards.length === 0 && (
                      <div className="text-center py-8 text-muted-foreground">
                        Nenhuma placa de relé configurada no sistema.
                        Configure uma placa na tela de Relés primeiro.
                      </div>
                    )}
                  </div>
                </div>
                
                {/* Channel Control */}
                {selectedBoard && (
                  <div>
                    <div className="flex items-center justify-between mb-2">
                      <Label>Controle de Canais - Placa #{selectedBoard}</Label>
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => resetBoard(selectedBoard)}
                      >
                        <RefreshCw className="h-4 w-4 mr-1" />
                        Reset Todos
                      </Button>
                    </div>
                    <div className="grid grid-cols-4 gap-2 mt-2">
                      {boardChannels.map((channel) => {
                        const isToggling = togglingChannel === channel.channel_number;
                        const isMomentary = channel.function_type === 'momentary';
                        const isPulse = channel.function_type === 'pulse';
                        
                        // Determinar o tipo de botão
                        const buttonProps = isMomentary ? {
                          // Para momentâneo - liga no mouse down, desliga no mouse up
                          onMouseDown: () => pressChannel(selectedBoard, channel.channel_number, true),
                          onMouseUp: () => pressChannel(selectedBoard, channel.channel_number, false),
                          onMouseLeave: () => channel.simulated_state && pressChannel(selectedBoard, channel.channel_number, false),
                          onTouchStart: () => pressChannel(selectedBoard, channel.channel_number, true),
                          onTouchEnd: () => pressChannel(selectedBoard, channel.channel_number, false),
                        } : {
                          // Para toggle - alterna no click
                          onClick: () => toggleChannel(selectedBoard, channel.channel_number)
                        };
                        
                        return (
                          <Button
                            key={channel.id}
                            variant={channel.simulated_state ? "default" : "outline"}
                            size="sm"
                            className="h-28 flex flex-col items-center justify-center gap-1 relative select-none"
                            disabled={isToggling}
                            {...buttonProps}
                          >
                            {/* Tipo do relé no topo esquerdo */}
                            <div className={`absolute top-1 left-1 px-1 py-0.5 rounded text-[9px] font-medium ${
                              isMomentary ? 'bg-orange-500 text-white' :
                              isPulse ? 'bg-purple-500 text-white' :
                              'bg-blue-500 text-white'
                            }`}>
                              {isMomentary ? 'MOM' : isPulse ? 'PLS' : 'TGL'}
                            </div>
                            
                            {/* Estado ON/OFF no topo direito */}
                            <div className={`absolute top-1 right-1 px-1.5 py-0.5 rounded text-[10px] font-bold transition-colors ${
                              isToggling 
                                ? 'bg-yellow-500 text-white animate-pulse'
                                : channel.simulated_state 
                                  ? 'bg-green-500 text-white' 
                                  : 'bg-gray-200 text-gray-600 dark:bg-gray-700 dark:text-gray-400'
                            }`}>
                              {isToggling ? '...' : channel.simulated_state ? 'ON' : 'OFF'}
                            </div>
                            
                            {/* Indicador de Heartbeat para momentâneos */}
                            {isMomentary && heartbeatIntervals[channel.channel_number] && (
                              <div className="absolute bottom-1 right-1 w-2 h-2 bg-red-500 rounded-full animate-pulse" 
                                   title="Heartbeat ativo" />
                            )}
                            
                            {/* Ícone do tipo */}
                            {isToggling ? (
                              <RefreshCw className="h-5 w-5 animate-spin" />
                            ) : isMomentary ? (
                              channel.simulated_state ? (
                                <Power className="h-5 w-5 text-green-500" />
                              ) : (
                                <PowerOff className="h-5 w-5" />
                              )
                            ) : (
                              channel.simulated_state ? (
                                <ToggleRight className="h-5 w-5" />
                              ) : (
                                <ToggleLeft className="h-5 w-5" />
                              )
                            )}
                            
                            <span className="text-xs font-medium">CH{channel.channel_number}</span>
                            <span className="text-xs opacity-75">{channel.name}</span>
                            
                            {/* Indicador visual para momentâneo */}
                            {isMomentary && (
                              <span className="text-[9px] text-muted-foreground">Segure</span>
                            )}
                          </Button>
                        );
                      })}
                    </div>
                    
                    {/* Simulator Info */}
                    <div className="mt-4 p-3 bg-muted rounded-lg">
                      <div className="text-sm space-y-1">
                        <div className="flex justify-between">
                          <span className="text-muted-foreground">Canais Ativos:</span>
                          <span className="font-medium">
                            {boardChannels.filter(c => c.simulated_state).length} / {boardChannels.length}
                          </span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-muted-foreground">Tópico Estado:</span>
                          <code className="text-xs bg-background px-1 rounded">
                            autocore/devices/{simulatorBoards.find(b => b.board_id === selectedBoard)?.device_uuid}/relays/state
                          </code>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-muted-foreground">Tópico Comando:</span>
                          <code className="text-xs bg-background px-1 rounded">
                            autocore/devices/{simulatorBoards.find(b => b.board_id === selectedBoard)?.device_uuid}/relays/set
                          </code>
                        </div>
                      </div>
                    </div>
                  </div>
                )}
              </div>
              
              {/* Active Simulators Summary */}
              {activeSimulators.length > 0 && (
                <div className="mt-4">
                  <Label>Simuladores Ativos</Label>
                  <div className="grid gap-2 md:grid-cols-3 mt-2">
                    {activeSimulators.map((sim) => (
                      <Card key={sim.board_id}>
                        <CardHeader className="pb-2">
                          <CardTitle className="text-sm">Placa #{sim.board_id}</CardTitle>
                        </CardHeader>
                        <CardContent>
                          <div className="text-xs space-y-1">
                            <div className="flex justify-between">
                              <span>UUID:</span>
                              <code className="font-mono">{sim.device_uuid.slice(0, 8)}...</code>
                            </div>
                            <div className="flex justify-between">
                              <span>Canais:</span>
                              <span>{sim.active_channels} ON / {sim.inactive_channels} OFF</span>
                            </div>
                            <div className="flex justify-between">
                              <span>Status:</span>
                              <Badge variant={sim.is_connected ? "success" : "destructive"} className="text-xs">
                                {sim.is_connected ? 'Online' : 'Offline'}
                              </Badge>
                            </div>
                          </div>
                        </CardContent>
                      </Card>
                    ))}
                  </div>
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
};

export default MQTTMonitorPage;