![Banner del Proyecto](Assets/Banner.jpg)

**Creado por:** Willian Oliveira  
**Traducido por:** sezio (sergiovks)  

# Análisis Técnico - "LSASS Forked Dump - PoC"

Crear una copia (fork) del proceso `lsass.exe` y generar su volcado de memoria sin interactuar directamente con el proceso original, reduciendo la detección por herramientas defensivas. Esta técnica fue desarrollada y probada en entornos con "CrowdStrike". Destaco que en esta PoC mi objetivo fue crear un proceso simplificado donde el atacante pueda capturar las credenciales del volcado sin activar el EDR. CrowdStrike y otros EDRs monitorean procesos clave, dificultando actividades como escalada de privilegios, exfiltración y acceso a credenciales.

**La técnica clona el proceso LSASS en un nuevo proceso utilizando `NtCreateProcessEx`.**

**La mayoría de los EDRs (como CrowdStrike) monitorean llamadas directas a LSASS o a la API `MiniDumpWriteDump` dentro del contexto del LSASS original.**

**Al ejecutar el volcado sobre el clon, el proceso malicioso evade la detección comportamental estándar.**

**Durante las pruebas con CrowdStrike en modo de protección total (Prevent Mode), no se generaron alertas.**

# Descripción del Escenario

El escenario de la PoC incluye acceso remoto al entorno sin necesidad de conexión directa por RDP o contacto físico con el dispositivo. En esta PoC se utilizó **Evil-WinRM** y PowerShell en un entorno Windows con CrowdStrike activo. El script puede ser modificado y adaptado a otros escenarios.

# La Historia del Ataque Silencioso – LSASS Forked Dump vs. CrowdStrike (con un toque de humor)

Era un día lluvioso en el laboratorio de la Escola Hack3r. El operador del Red Team “wtechsec” acababa de recibir una misión: simular el acceso inicial a un servidor Windows corporativo protegido por CrowdStrike y extraer credenciales sin activar ninguna alarma.

Tras semanas estudiando el comportamiento de los sensores del Falcon, wtechsec sabía que cualquier intento directo de acceder a la memoria del LSASS causaría una alerta inmediata. Mimikatz, procdump, Pypykatz: todos ya estaban en la lista negra del EDR. Pero él tenía un plan...

Conectándose vía **Evil-WinRM**, wtechsec obtuvo acceso al servidor como un administrador local comprometido:

En el silencio de la sesión remota, wtechsec ejecutó su creación: un script artesanal en PowerShell que clonaba el proceso LSASS utilizando la oscura syscall `NtCreateProcessEx`. El plan era simple e ingenioso:  
**Clonar LSASS en un nuevo proceso fuera del alcance directo de la vigilancia de CrowdStrike.**  
**Realizar el volcado de memoria en ese clon utilizando `MiniDumpWriteDump`, evadiendo los hooks y las alertas comportamentales.**

El script se ejecutó.  
Sin alertas.  
Sin bloqueos.  
Solo un volcado limpio, guardado en **C:\Users\Public\forked_lsass.dmp.**

wtechsec sonrió. Sabía lo que tenía en las manos. Un bypass real, discreto y funcional. El volcado fue exfiltrado con calma. Al analizarlo localmente con Mimikatz, recuperó las credenciales de dominio de un administrador senior.  
El dominio era suyo.

**¿Y CrowdStrike? Silencioso como la noche.**

![Banner del Proyecto](Assets/Banner.png)

# Requisitos del Ataque
- Credenciales de administrador local o con permisos equivalentes.
- Uso de WinRM – Evil-WinRM, PowerShell remoto o shell inverso, dependiendo del nivel de compromiso y orquestación.
- Objetivo: Windows 10, 11 y versiones Server.
- CrowdStrike activo en el objetivo u otro EDR que monitoree procesos y bloquee volcados manuales.
- Máquina atacante con pypykatz, evil-winrm, netexec y un editor de texto para modificar el script si es necesario.

# Etapas del Ataque

### 1. Acceso Inicial
- El atacante utiliza **Evil-WinRM** para conectarse remotamente al host comprometido.

### 2. Carga del archivo PoC_Lsass.PS1
- El atacante transfiere el script PowerShell de la PoC (LSASS Forked Dump).

### 3. Ejecución del script Lsass_Forked.PS1
- El atacante ejecuta el script a través de la sesión remota con Evil-WinRM.

### 4. Volcado generado
- Se crea un volcado del proceso clonado de LSASS en:

### 5. Exfiltración
- El volcado puede descargarse vía WinRM para análisis posterior con herramientas como **pypykatz**: se probó con versiones 0.6.11 y 0.6.6.

![Ejecución](Assets/Ejecución.png)

#### Tutorial en video

[![PoC Lsass Dump - YouTube](https://img.youtube.com/vi/1fABpuAMF-A/hqdefault.jpg)](https://youtu.be/1fABpuAMF-A)
