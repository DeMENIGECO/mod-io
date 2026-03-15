@echo off
title MODDER.IO
echo ===================
echo      MODDER.IO
echo ===================
echo.

:: Inizializza file password se non esiste
if not exist password.hash (
    for /f %%A in ('powershell -command "$s='modder123';$h=[System.BitConverter]::ToString((New-Object Security.Cryptography.SHA256Managed).ComputeHash([Text.Encoding]::UTF8.GetBytes($s))).Replace('-','');echo $h"') do set initpass=%%A
    echo %initpass%>password.hash
)

:main
set /p command=>> 

if "%command%"=="help" goto help
if "%command%"=="mod --init" goto init_mod
if "%command%"=="mod change --password" goto ch_password
if "%command%"=="modder.io --information" goto information
echo Comando non valido
goto main

:confirm
:: Controlla password prima di azioni sensibili
set /p pass=Inserisci password: 

for /f %%A in ('powershell -command "$s='%pass%';$h=[System.BitConverter]::ToString((New-Object Security.Cryptography.SHA256Managed).ComputeHash([Text.Encoding]::UTF8.GetBytes($s))).Replace('-','');echo $h"') do set inputhash=%%A

set /p savedhash=<password.hash

if "%inputhash%"=="%savedhash%" (
    echo Accesso consentito
    goto :eof
) else (
    echo Password errata
    pause
    exit
)

:help
echo help                      : Mostra questo menu
echo mod --init                : Inizia una mod
echo mod change --password     : Cambia/aggiungi password
echo modder.io --information   : Mostra le informazioni su Modder.IO
echo.
goto main

:init_mod
call :confirm
echo.
echo ===== Inizio MOD =====

:: Chiedi nome dispositivo
set /p disp=Inserisci nome dispositivo: 

:: Chiedi file zip da estrarre
set /p zip=Inserisci il nome del file zip da estrarre (con estensione .zip): 

:: Crea cartella temporanea
set tempdir=%LOCALAPPDATA%\modderio-temp\%zip%
if not exist "%tempdir%" mkdir "%tempdir%"

:: Estrai lo zip
echo Estraggo lo zip nel percorso temporaneo...
powershell -Command "Expand-Archive -Path '%zip%' -DestinationPath '%tempdir%' -Force"

:: Chiedi lettera del dispositivo e cartella di destinazione
set /p lettera_disp=Inserisci la lettera del dispositivo (es: E:): 
set /p disp_perc=Scegli la cartella di destinazione nel dispositivo (lascia vuoto per root): 

set percourse=%lettera_disp%\%disp_perc%

:: Copia dei file estratti nel dispositivo
echo Copio i file estratti nel dispositivo...
xcopy "%tempdir%\*" "%percourse%\" /E /I /Y

echo Operazione completata!
pause
goto main

:ch_password
call :confirm

echo Cambia password
set /p oldpass=Inserisci password attuale: 

for /f %%A in ('powershell -command "$s='%oldpass%';$h=[System.BitConverter]::ToString((New-Object Security.Cryptography.SHA256Managed).ComputeHash([Text.Encoding]::UTF8.GetBytes($s))).Replace('-','');echo $h"') do set oldhash=%%A
set /p savedhash=<password.hash

if not "%oldhash%"=="%savedhash%" (
    echo Password errata.
    pause
    goto main
)

set /p newpass=Nuova password: 

for /f %%A in ('powershell -command "$s='%newpass%';$h=[System.BitConverter]::ToString((New-Object Security.Cryptography.SHA256Managed).ComputeHash([Text.Encoding]::UTF8.GetBytes($s))).Replace('-','');echo $h"') do set newhash=%%A

echo %newhash%>password.hash
echo Password cambiata con successo.
pause
goto main

:information
echo DeMENIGECO Modder.IO [Versione 1 26M3 - 1.0.0]
echo Tutti i diritti riservati
echo Password predefinita: modder123
pause
goto main
