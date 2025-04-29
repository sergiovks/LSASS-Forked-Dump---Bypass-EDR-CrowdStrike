![Banner do Projeto](Assets/Banner.jpg)


# Análise Técnica - "LSASS Forked Dump - PoC"

Criar uma cópia (fork) do processo lsass.exe e gerar seu dump de memória sem interagir diretamente com o processo original, reduzindo a detecção por ferramentas defensivas essa técnica foi desenvolvida e testada em abiemtes com "CrowdStrike", destaco que nessa PoC meu foco foi criar um processo simplificado onde o atacante pode capturar as cerdencias do dump sem ter acionamento do EDR, o CrowdStike e outros EDRs monitoram processos primcipais dificultando atividades de ganho de acesso, exfiltração e credential access.

# Descrição do Cenário

Esta prova de conceito demonstra a clonagem do processo LSASS via NtCreateProcessEx para realizar um dump de memória sem acionar EDRs. O clone é utilizado para contornar hooks e políticas de proteção em tempo real, permitindo a extração de credenciais de forma silenciosa. O cenário onde a PoC foi feita inclui acesso remoto dentro do ambiente sem ter a necessidade de acesso direto por rdp ou contato direto com o dispositivo nessa PoC foi utilizado Evil-WinRM e Powershell em ambiente Windows com CrowdStrike ativo.

# A História do Ataque Silencioso – LSASS Forked Dump vs. CrowdStrike

Era um dia chuvoso no laboratório da Escola Hack3r. O operador Red Team “wtechsec” acabava de receber uma missão: simular o acesso inicial a um servidor Windows corporativo protegido por CrowdStrike e extrair credenciais sem acionar nenhum alarme.

Após semanas estudando o comportamento dos sensores do Falcon, wtechsec sabia que qualquer tentativa direta de acessar a memória do LSASS causaria alerta imediato. Mimikatz, procdump, Pypykatz – tudo já estava na lista negra do EDR. Mas ele tinha um plano...

Conectando-se via **Evil-WinRM**, wtechsec ganhou acesso ao servidor como um administrador local comprometido:

# evil-winrm -i IP-ALVO -u USER -p SENHA ou -H HASH

No silêncio da sessão remota, wtechsec carregou sua criação: um script PowerShell artesanal, que clonava o processo LSASS usando a obscura syscall NtCreateProcessEx. O plano era simples e engenhoso:
# Clonar o LSASS para um novo processo fora da vigilância direta do CrowdStrike.
# Realizar o dump nesse clone com MiniDumpWriteDump, escapando dos ganchos e alertas comportamentais.

O script rodou. Nenhum alerta. Nenhum bloqueio. Apenas um dump limpo, salvo em **C:\Users\Public\forked_lsass.dmp.**

wtechsec sorriu. Ele sabia o que tinha em mãos. Um bypass real, discreto e funcional. O dump foi exfiltrado com calma. Ao analisá-lo localmente com o Mimikatz, ele recuperou as credenciais de domínio de um administrador sênior.
O domínio era dele.

**E o CrowdStrike? Silencioso como a noite.**




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



