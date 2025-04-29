![Banner do Projeto](Assets/Designer.jpeg)


# ATtyni85_Exfiltration

Um projeto para exfiltração de dados usando dispositivos ATtiny85, configurados para simular am ataque HID (Human Interface Device) atrelado a engenharia social e técnicas de exfiltração usando comandos no powershell e webhooks.

# Descrição do Cenário

Um operador de Red Team foca em um ataque presencial, onde utiliza técnicas de engenharia social para manipular o alvo. O objetivo é convencer a vítima a inserir e validar suas credenciais em um script malicioso, simulando um ataque realista.

## Etapas do Ataque ##

# Reconhecimento Prévio (Reconnaissance)
- Coleta de informações sobre o alvo:
- Identificar as rotinas do indivíduo ou grupo (ex.: hábitos, horários, preferências).
- Obter dados de contexto (e-mail corporativo, setor de trabalho, hierarquia interna).
- Mapeamento de tecnologias utilizadas no ambiente (ex.: dispositivos de login, sistemas operacionais).

# Definir o método de contato direto:
- Presencial: Abordagem na área de trabalho ou em um local público.
- Digital: Configuração de dispositivos como USB Rubber Ducky, ATtyni85 = digispark ou ferramentas semelhantes.

# Preparação do script malicioso:
- Desenvolver um script convincente que simule um login legítimo.
- Incorporar coleta e envio seguro das credenciais (ex.: envio via e-mail ou armazenado localmente para exfiltração posterior).

# Personalização do ataque:
- Usar elementos que reforcem a confiança, como logos, formulários, ou mensagens relacionadas à empresa.

# Execução do Ataque
- Uso de sensos psicológicos.
- Urgência: "Precisamos resolver esse problema agora ou sua conta será bloqueada!"
- Colaboração: "Estamos testando uma nova atualização de segurança. Você poderia me ajudar a validar sua conta?"
- Autoridade: "Sou do time de TI e estamos enfrentando problemas de autenticação no sistema."
- Confiança: "Recebi uma solicitação do seu gerente pedindo ajuda com isso."
- Simular empatia para relaxar a vítima e evitar desconfianças.

# Ação da Vítima:
- O atacante fornece um dispositivo ou formulário, que pode ser.
- Um computador ou tablet configurado com o script malicioso.
- Um link falso enviado para o e-mail da vítima (caso combinado com abordagens online).

# Coleta das Credenciais:
- Assim que a vítima insere suas informações, o script.
- Armazena localmente os dados para exfiltração.
- Envia os dados para o operador em tempo real.
- Pós-execução

## Validação do Sucesso ##

Testar as credenciais obtidas para garantir acesso ao sistema alvo.
Limpeza:
Apagar vestígios do script ou da interação para evitar detecção.
Relatório:
Registrar o processo e os resultados para o cliente (caso seja uma simulação contratada).
---

## 📋 Funcionalidades

- Abre o PowerShell: O script usa o atalho Win + R para abrir o "Executar" e em seguida executa o PowerShell com uma janela de tamanho ajustado para 30 colunas e 10 linhas.

- Solicita as credenciais: O comando $host.ui.PromptForCredential solicita ao usuário que insira suas credenciais (usuário e senha).

- Aguarda a interação do usuário: O script aguarda até que o usuário insira suas credenciais e clique em "OK", com o comando Start-Sleep -s 10 para dar tempo ao usuário.

- Extrai as credenciais: O PowerShell obtém as credenciais inseridas pode ser user de domínio ou local e armazena os dados de nome de usuário e senha nas variáveis $user e $pass.

- Envia os dados para o webhook: O script utiliza Invoke-WebRequest para enviar os dados via HTTP POST para o webhook especificado (substitua o URL com o seu próprio webhook).

- Finaliza e faz a limpeza: O script finaliza a execução e realiza a limpeza de arquivos temporários, além de acender um LED como um sinal de término do processo.

## 🚀 Configuração

### 1. Requisitos
- ATtiny85 - Digispark).
- Software para upload do script (Arduino IDE).

### 2. Links - CONFIGURAÇÃO COMPLETA NO TUTORIAL EM VIDEO ###

# WebHook
- https://webhook.site/
# Digistamp
- https://raw.githubusercontent.com/digistump/arduino-boards-index/master/package_digistump_index.json
# Arquivo de tradução ABNT2
- https://github.com/jcldf/digisparkABNT2/blob/master/scancode-ascii-table.h
  
- O arquivo scancode-ascii-table.h deve ser colocado dentro do diretório C:\Users\USUÁRIO\AppData\Local\Arduino15\packages\digistump\hardware\avr\1.6.7\libraries\DigisparkKeyboard

  #### Tutorial em video ###

[![Assista ao vídeo no YouTube](https://img.youtube.com/vi/rCtWvcGW0go/hqdefault.jpg)](https://www.youtube.com/watch?v=rCtWvcGW0go)



