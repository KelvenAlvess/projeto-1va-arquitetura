# ==============================================================================
# Script de Execução Isolada de Testes de Regressão e Estresse ABI
# Projeto: Simulador Condomínio MIPS
# ==============================================================================

[CmdletBinding()]
param(
    [string]$MarsJar = "C:\Users\felli\Downloads\Mars4_5.jar",
    [ValidateSet("todos", "geral", "stress", "dominio", "terminal", "persistencia")]
    [string]$Teste = "todos"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $MarsJar)) {
    # Procura na pasta Downloads se não estiver no caminho fixo
    $userDownloads = Join-Path $env:USERPROFILE "Downloads\Mars4_5.jar"
    if (Test-Path $userDownloads) {
        $MarsJar = $userDownloads
    } else {
        Write-Error "MARS 4.5 não encontrado em $MarsJar. Informe o caminho via -MarsJar."
        exit 1
    }
}

$WorkspaceRoot = (Get-Item $PSScriptRoot).Parent.FullName
Set-Location $WorkspaceRoot

$DataFile = Join-Path $WorkspaceRoot "condominio.dat"
$BackupFile = [System.IO.Path]::GetTempFileName()
$HadExistingData = $false

if (Test-Path $DataFile) {
    Copy-Item $DataFile $BackupFile -Force
    $HadExistingData = $true
}

$TestsToRun = @()
if ($Teste -eq "todos" -or $Teste -eq "geral") {
    $TestsToRun += @{
        Name         = "Teste Geral (teste_geral.txt)"
        IsMultiPhase = $false
        Input        = "testes\entradas\teste_geral.txt"
        Expected     = "testes\esperados\saida_teste_geral.txt"
    }
}
if ($Teste -eq "todos" -or $Teste -eq "stress") {
    $TestsToRun += @{
        Name         = "Teste de Estresse ABI (teste_stress_abi.txt)"
        IsMultiPhase = $false
        Input        = "testes\entradas\teste_stress_abi.txt"
        Expected     = "testes\esperados\saida_teste_stress_abi.txt"
    }
}
if ($Teste -eq "todos" -or $Teste -eq "dominio") {
    $TestsToRun += @{
        Name         = "Teste de Regras de Domínio (teste_dominio_regras.txt)"
        IsMultiPhase = $false
        Input        = "testes\entradas\teste_dominio_regras.txt"
        Expected     = "testes\esperados\saida_teste_dominio_regras.txt"
    }
}
if ($Teste -eq "todos" -or $Teste -eq "terminal") {
    $TestsToRun += @{
        Name         = "Teste de Terminal e Consultas (teste_terminal_consultas.txt)"
        IsMultiPhase = $false
        Input        = "testes\entradas\teste_terminal_consultas.txt"
        Expected     = "testes\esperados\saida_teste_terminal_consultas.txt"
    }
}
if ($Teste -eq "todos" -or $Teste -eq "persistencia") {
    $TestsToRun += @{
        Name         = "Teste de Ciclo de Persistência (teste_persistencia_ciclo.txt)"
        IsMultiPhase = $true
        Phases       = @(
            "testes\entradas\persistencia_fase1.txt",
            "testes\entradas\persistencia_fase2.txt",
            "testes\entradas\persistencia_fase3.txt",
            "testes\entradas\persistencia_fase4.txt"
        )
        Expected     = "testes\esperados\saida_teste_persistencia_ciclo.txt"
    }
}

if ($TestsToRun.Count -eq 0) {
    Write-Error "Nenhum teste valido selecionado para execucao."
    exit 1
}

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host " EXECUTANDO BATERIA DE TESTES ISOLADA NO MARS 4.5" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

$AllPassed = $true
$ExecutedCount = 0

try {
    foreach ($t in $TestsToRun) {
        $ExecutedCount++
        Write-Host "`n[TESTE] $($t.Name)..." -ForegroundColor Yellow

        # Garante ambiente de arquivo isolado para cada execução
        if (Test-Path $DataFile) {
            Remove-Item $DataFile -Force
        }

        $tempOut = [System.IO.Path]::GetTempFileName()

        if ($t.IsMultiPhase) {
            # Executa fases consecutivas mantendo o arquivo de dados entre elas
            $concatOut = ""
            $hasPhaseError = $false
            foreach ($phaseFile in $t.Phases) {
                $phaseTempOut = [System.IO.Path]::GetTempFileName()
                $cmd = "java -Dfile.encoding=UTF-8 -Dstdout.encoding=UTF-8 -jar `"$MarsJar`" nc src\main.asm < `"$phaseFile`" > `"$phaseTempOut`""
                $proc = Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$cmd`"" -Wait -NoNewWindow -PassThru
                if ($proc.ExitCode -ne 0) {
                    Write-Host "  -> ERRO na fase $($phaseFile): código $($proc.ExitCode)" -ForegroundColor Red
                    $hasPhaseError = $true
                }
                $concatOut += [System.IO.File]::ReadAllText($phaseTempOut)
                Remove-Item $phaseTempOut -Force
            }
            if ($hasPhaseError) {
                $AllPassed = $false
                continue
            }
            [System.IO.File]::WriteAllText($tempOut, $concatOut)
        } else {
            # Executa no MARS via cmd com codificação UTF-8
            $cmd = "java -Dfile.encoding=UTF-8 -Dstdout.encoding=UTF-8 -jar `"$MarsJar`" nc src\main.asm < `"$($t.Input)`" > `"$tempOut`""
            $proc = Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$cmd`"" -Wait -NoNewWindow -PassThru

            if ($proc.ExitCode -ne 0) {
                Write-Host "  -> ERRO: O simulador encerrou com código $($proc.ExitCode)" -ForegroundColor Red
                $AllPassed = $false
                continue
            }
        }

        $expectedText = [System.IO.File]::ReadAllText((Join-Path $WorkspaceRoot $t.Expected)).Replace("`r`n", "`n")
        $obtainedText = [System.IO.File]::ReadAllText($tempOut).Replace("`r`n", "`n")

        if ($expectedText -eq $obtainedText) {
            Write-Host "  -> SUCESSO: Saída 100% idêntica ao gabarito esperado." -ForegroundColor Green
        } else {
            Write-Host "  -> FALHA: Divergência detectada entre saída e gabarito." -ForegroundColor Red
            $AllPassed = $false

            $expLines = $expectedText.Split("`n")
            $obtLines = $obtainedText.Split("`n")
            $maxLen = [Math]::Max($expLines.Length, $obtLines.Length)
            for ($i = 0; $i -lt $maxLen; $i++) {
                $el = if ($i -lt $expLines.Length) { $expLines[$i] } else { "<FIM>" }
                $ol = if ($i -lt $obtLines.Length) { $obtLines[$i] } else { "<FIM>" }
                if ($el -ne $ol) {
                    Write-Host "     Linha $($i+1):" -ForegroundColor Magenta
                    Write-Host "       Esperado: $el" -ForegroundColor Gray
                    Write-Host "       Obtido:   $ol" -ForegroundColor White
                }
            }
        }

        if (Test-Path $tempOut) {
            Remove-Item $tempOut -Force
        }
    }
}
finally {
    # Limpa artefatos gerados pelo teste
    if (Test-Path $DataFile) {
        Remove-Item $DataFile -Force
    }
    # Restaura backup prévio se existia
    if ($HadExistingData -and (Test-Path $BackupFile)) {
        Copy-Item $BackupFile $DataFile -Force
        Remove-Item $BackupFile -Force
    } elseif (Test-Path $BackupFile) {
        Remove-Item $BackupFile -Force
    }
}

Write-Host "`n================================================================================" -ForegroundColor Cyan
if ($ExecutedCount -gt 0 -and $AllPassed) {
    Write-Host " TODOS OS TESTES PASSARAM COM SUCESSO ($ExecutedCount executados, 100% MATCH E AMBIENTE ISOLADO)" -ForegroundColor Green
    exit 0
} else {
    Write-Host " ALGUNS TESTES FALHARAM OU NENHUM TESTE FOI EXECUTADO ($ExecutedCount executados)." -ForegroundColor Red
    exit 1
}
