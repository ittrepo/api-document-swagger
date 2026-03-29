@echo off
REM ITT API Documentation Build Wrapper for Windows
REM This script runs the PowerShell documentation builder.

Powershell.exe -ExecutionPolicy Bypass -File .\scripts\build-all-docs.ps1
pause
