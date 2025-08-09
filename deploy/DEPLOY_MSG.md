  Quero configurar o make pra informar vai iniciar o PI com database/seeds/seed_development.py ou database/seeds/seed_raspberry_pi.py, no make deploy, o padrão vai ser seed_raspberry_pi, mas quero que você faça uma lista das opções do que tem na pasta pra escolher, se der enter direto escolhe a opção 1 que é a defualt.

  Temos também algumas mensagens de warnig, talvez seja interessante atualizar alguns pacotes pra teste.

  Esse erro ainda persiste "ERROR: Pipe to stdout was broken"

  Ainda mostra 
  
  ==========================================
      VERIFICAÇÕES DE CONECTIVIDADE
  ==========================================

🦟 MQTT: ❌ Falha na conexão
🔌 Backend API (porta 8081): ❌ Não respondendo (código: 404)
📱 Frontend (porta 8080): ✅ OK


==========================================
     CONFIGURAÇÃO DE REDE
==========================================

🌐 Interfaces de rede:
wlan0            UP             10.0.10.119/24 fe80::d21c:c34d:a403:80f0/64 

🔗 Portas abertas:
  0.0.0.0:1883 - 1901/mosquitto
  0.0.0.0:8080 - 2138/node
  0.0.0.0:8081 - 2116/python3
  :::1883 - 1901/mosquitto

==========================================
     LOGS DE ERROS RECENTES
==========================================

⚠️ Últimos erros do sistema (se houver):
-- Journal begins at Sat 2025-08-09 18:03:15 BST, ends at Sat 2025-08-09 18:14:55 BST. --
-- No entries --
==========================================
           RESUMO EXECUTIVO
==========================================

✅ INSTALAÇÃO CONCLUÍDA COM SUCESSO!

📊 Todos os 4 serviços estão rodando
🌐 Sistema acessível em: http://10.0.10.119:3000 - Aqui informa a porta errada.

Fora isso tudo deu certo.

  DEPRECATION: Wheel filename 'jedi-0.8.1_final0-py3-none-any.whl' is not correctly normalised. Future versions of pip will raise the following error:
  Invalid wheel filename (invalid version): 'jedi-0.8.1_final0-py3-none-any'
  
   pip 25.3 will enforce this behaviour change. A possible replacement is to rename the wheel to use a correctly normalised name (this may require updating the version in the project metadata). Discussion can be found at https://github.com/pypa/pip/issues/12938
  DEPRECATION: Wheel filename 'jedi-0.8.0_final0-py3-none-any.whl' is not correctly normalised. Future versions of pip will raise the following error:
  Invalid wheel filename (invalid version): 'jedi-0.8.0_final0-py3-none-any'
  
   pip 25.3 will enforce this behaviour change. A possible replacement is to rename the wheel to use a correctly normalised name (this may require updating the version in the project metadata). Discussion can be found at https://github.com/pypa/pip/issues/12938

   WARNING: The candidate selected for download or install is a yanked version: 'email-validator' candidate (version 2.1.0 at https://www.piwheels.org/simple/email-validator/email_validator-2.1.0-py3-none-any.whl#sha256=b0eacf06411cd35a4154505ac57ec303af86d24132417c18c6d6939522a94203 (from https://www.piwheels.org/simple/email-validator/) (requires-python:>=3.7))
   Reason for being yanked: <none given>





 é, acho que temos que discutir antes de executar, porque a ideia desse é     
ser apenas a interface, o usuário vai ver apenas os botões, ao clica em uma  
macro vai fazer o envio por MQTT e o gateway se encarrega pela logica e      
acionamentos, no app não temos nada relacionado a configuração processo,     
inclusão, alteração nada, apenas clicar e enviar a mensagem.  