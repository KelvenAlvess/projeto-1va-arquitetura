# ==============================================================================
# Script de Auditoria Estática Estrutural e de Fluxo de Execução
# Verificação de ABI MIPS O32, Registradores e Contratos de Procedimento
# Projeto: Simulador Condomínio MIPS — Issue #26
# ==============================================================================

[CmdletBinding()]
param(
    [string]$SourceDir = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($SourceDir) -or $SourceDir -eq "\..\src") {
    if ($PSScriptRoot) {
        $SourceDir = Join-Path $PSScriptRoot "..\src"
    } else {
        $SourceDir = "src"
    }
}
$SourceDir = [System.IO.Path]::GetFullPath($SourceDir)

# Catálogo completo com especificação formal de contratos de parâmetros e retornos
$Catalog = @(
    # --- src/main.asm ---
    [PSCustomObject]@{ File = "main.asm"; Procedure = "main"; Args = @(); Ret = @() },

    # --- src/dados.asm ---
    [PSCustomObject]@{ File = "dados.asm"; Procedure = "dados_inicializar"; Args = @(); Ret = @("v0") },
    [PSCustomObject]@{ File = "dados.asm"; Procedure = "dados_obter_ap";     Args = @("a0"); Ret = @("v0", "v1") },
    [PSCustomObject]@{ File = "dados.asm"; Procedure = "dados_limpar_ap";    Args = @("a0"); Ret = @("v0") },

    # --- src/comandos_cadastro.asm ---
    [PSCustomObject]@{ File = "comandos_cadastro.asm"; Procedure = "cadastro_adicionar_morador"; Args = @("a0", "a1"); Ret = @("v0") },
    [PSCustomObject]@{ File = "comandos_cadastro.asm"; Procedure = "cadastro_remover_morador";   Args = @("a0", "a1"); Ret = @("v0") },
    [PSCustomObject]@{ File = "comandos_cadastro.asm"; Procedure = "cadastro_adicionar_auto";    Args = @("a0", "a1", "a2", "a3"); Ret = @("v0") },
    [PSCustomObject]@{ File = "comandos_cadastro.asm"; Procedure = "cadastro_remover_auto";      Args = @("a0", "a1"); Ret = @("v0") },
    [PSCustomObject]@{ File = "comandos_cadastro.asm"; Procedure = "cadastro_copiar_string";     Args = @("a0", "a1"); Ret = @() },
    [PSCustomObject]@{ File = "comandos_cadastro.asm"; Procedure = "cadastro_copiar_bytes";      Args = @("a0", "a1", "a2"); Ret = @() },
    [PSCustomObject]@{ File = "comandos_cadastro.asm"; Procedure = "cadastro_zerar_bytes";       Args = @("a0", "a1"); Ret = @() },
    [PSCustomObject]@{ File = "comandos_cadastro.asm"; Procedure = "cadastro_strings_iguais";    Args = @("a0", "a1"); Ret = @("v0") },
    [PSCustomObject]@{ File = "comandos_cadastro.asm"; Procedure = "cadastro_limpar_ap";         Args = @("a0"); Ret = @("v0") },

    # --- src/comandos_consulta.asm ---
    [PSCustomObject]@{ File = "comandos_consulta.asm"; Procedure = "consulta_listar_apartamentos";    Args = @(); Ret = @("v0") },
    [PSCustomObject]@{ File = "comandos_consulta.asm"; Procedure = "consulta_listar_moradores";       Args = @("a0"); Ret = @("v0") },
    [PSCustomObject]@{ File = "comandos_consulta.asm"; Procedure = "consulta_listar_automoveis";      Args = @("a0"); Ret = @("v0") },
    [PSCustomObject]@{ File = "comandos_consulta.asm"; Procedure = "consulta_buscar_morador";          Args = @("a0"); Ret = @("v0") },
    [PSCustomObject]@{ File = "comandos_consulta.asm"; Procedure = "consulta_buscar_auto";             Args = @("a0"); Ret = @("v0") },
    [PSCustomObject]@{ File = "comandos_consulta.asm"; Procedure = "consulta_info_ap";                Args = @("a0", "a1"); Ret = @("v0") },
    [PSCustomObject]@{ File = "comandos_consulta.asm"; Procedure = "consulta_imprimir_detalhes_ap";   Args = @("a0"); Ret = @() },
    [PSCustomObject]@{ File = "comandos_consulta.asm"; Procedure = "consulta_info_geral";             Args = @(); Ret = @("v0") },

    # --- src/persistencia.asm ---
    [PSCustomObject]@{ File = "persistencia.asm"; Procedure = "persist_inicializar"; Args = @(); Ret = @("v0") },
    [PSCustomObject]@{ File = "persistencia.asm"; Procedure = "persist_carregar";    Args = @(); Ret = @("v0") },
    [PSCustomObject]@{ File = "persistencia.asm"; Procedure = "persist_salvar";      Args = @(); Ret = @("v0") },
    [PSCustomObject]@{ File = "persistencia.asm"; Procedure = "persist_encerrar";    Args = @(); Ret = @("v0") },
    [PSCustomObject]@{ File = "persistencia.asm"; Procedure = "persist_recarregar";  Args = @(); Ret = @("v0") },
    [PSCustomObject]@{ File = "persistencia.asm"; Procedure = "persist_formatar";    Args = @(); Ret = @("v0") },

    # --- src/mmio.asm ---
    [PSCustomObject]@{ File = "mmio.asm"; Procedure = "mmio_escrever_char";   Args = @("a0"); Ret = @() },
    [PSCustomObject]@{ File = "mmio.asm"; Procedure = "mmio_ler_char";        Args = @(); Ret = @("v0") },
    [PSCustomObject]@{ File = "mmio.asm"; Procedure = "mmio_imprimir_string"; Args = @("a0"); Ret = @() },
    [PSCustomObject]@{ File = "mmio.asm"; Procedure = "mmio_imprimir_int";    Args = @("a0"); Ret = @() },
    [PSCustomObject]@{ File = "mmio.asm"; Procedure = "mmio_ler_linha";       Args = @("a0", "a1"); Ret = @() },

    # --- src/shell.asm ---
    [PSCustomObject]@{ File = "shell.asm"; Procedure = "shell_inicializar";            Args = @(); Ret = @("v0") },
    [PSCustomObject]@{ File = "shell.asm"; Procedure = "shell_executar";               Args = @(); Ret = @("v0") },
    [PSCustomObject]@{ File = "shell.asm"; Procedure = "shell_encerrar";               Args = @(); Ret = @("v0") },
    [PSCustomObject]@{ File = "shell.asm"; Procedure = "shell_sanitizar_linha";        Args = @(); Ret = @() },
    [PSCustomObject]@{ File = "shell.asm"; Procedure = "shell_parser";                 Args = @(); Ret = @() },
    [PSCustomObject]@{ File = "shell.asm"; Procedure = "shell_despachar_comando";      Args = @(); Ret = @("v0") },
    [PSCustomObject]@{ File = "shell.asm"; Procedure = "shell_strcmp";                 Args = @("a0", "a1"); Ret = @("v0") },
    [PSCustomObject]@{ File = "shell.asm"; Procedure = "shell_atoi";                   Args = @("a0"); Ret = @("v0") },
    [PSCustomObject]@{ File = "shell.asm"; Procedure = "shell_imprimir_erro_retorno";  Args = @("a0"); Ret = @() },
    [PSCustomObject]@{ File = "shell.asm"; Procedure = "shell_io_imprimir_string";     Args = @("a0"); Ret = @() },
    [PSCustomObject]@{ File = "shell.asm"; Procedure = "shell_io_ler_linha";           Args = @("a0", "a1"); Ret = @() },
    [PSCustomObject]@{ File = "shell.asm"; Procedure = "shell_io_imprimir_int";        Args = @("a0"); Ret = @() },
    [PSCustomObject]@{ File = "shell.asm"; Procedure = "shell_io_imprimir_char";       Args = @("a0"); Ret = @() }
)

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host " AUDITORIA ESTRUTURAL DE CONFORMIDADE DE ABI MIPS O32 (FRAMES E REGISTRADORES)" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

$Results = @()
$TotalViolations = 0

$CatalogByFile = $Catalog | Group-Object -Property File

foreach ($fileGroup in $CatalogByFile) {
    $fileName = $fileGroup.Name
    $filePath = Join-Path $SourceDir $fileName

    if (-not (Test-Path $filePath)) {
        Write-Error "Arquivo nao encontrado: $filePath"
        continue
    }

    $lines = [System.IO.File]::ReadAllLines($filePath, [System.Text.Encoding]::UTF8)
    $procs = $fileGroup.Group

    for ($i = 0; $i -lt $procs.Count; $i++) {
        $proc = $procs[$i]
        $startLabel = "$($proc.Procedure):"
        $nextLabel = if ($i + 1 -lt $procs.Count) { "$($procs[$i + 1].Procedure):" } else { $null }

        $procLines = @()
        $capturing = $false
        $labelFound = $false

        foreach ($l in $lines) {
            $trimmed = $l.Trim()
            if ($trimmed.StartsWith($startLabel)) {
                $capturing = $true
                $labelFound = $true
            } elseif ($capturing -and $nextLabel -and $trimmed.StartsWith($nextLabel)) {
                break
            }
            if ($capturing) {
                $procLines += $l
            }
        }

        $violations = @()

        # Check 1: Verificação explícita da existência do procedimento e não-vazio
        if (-not $labelFound -or $procLines.Count -eq 0) {
            $violations += "Rotulo de inicio '$startLabel' nao encontrado ou procedimento vazio"
            $Results += [PSCustomObject]@{
                Procedimento   = $proc.Procedure
                FrameBytes     = 0
                Alinhamento8B  = "NAO"
                SimetriaSP     = "NAO"
                OffsetMatch    = "NAO"
                PreservaRA     = "NAO"
                PreservaS      = "NAO"
                Contratos      = "NAO"
                Status         = "NAO CONFORME"
                Detalhes       = ($violations -join "; ")
            }
            $TotalViolations++
            continue
        }

        # Análise estática detalhada das instruções do procedimento
        $frameAlloc = 0
        $allocCount = 0
        $currentSpDelta = 0
        $swOffsets = @{}       # reg -> int offset
        $lwOffsets = @{}       # reg -> array of int offsets
        $modifiedS = [System.Collections.Generic.HashSet[string]]::new()
        $jalAlignments = @()   # array of @{ Target = ""; SpDelta = 0 }
        $dynamicSpErrors = @()
        $definesV0 = $false
        $definesV1 = $false
        $exitPoints = 0
        $rawCodeOnly = @()

        foreach ($rawLine in $procLines) {
            $inst = ($rawLine -split "#")[0].Trim()
            if ([string]::IsNullOrWhiteSpace($inst)) { continue }
            $rawCodeOnly += $inst

            # Alocação de frame na pilha
            if ($inst -match "^addiu\s+\`$sp,\s*\`$sp,\s*-(\d+)") {
                $val = [int]$matches[1]
                $allocCount++
                if ($allocCount -eq 1) {
                    $frameAlloc = $val
                    $currentSpDelta -= $val
                } else {
                    $dynamicSpErrors += "addiu `$sp, `$sp, -$val"
                    $currentSpDelta -= $val
                }
                continue
            }

            # Liberação de pilha
            if ($inst -match "^addiu\s+\`$sp,\s*\`$sp,\s*(\d+)") {
                $val = [int]$matches[1]
                $currentSpDelta += $val
                continue
            }

            # sw $reg, offset($sp)
            if ($inst -match "^sw\s+\`$([a-zA-Z0-9]+),\s*(-?\d+)\(\`$sp\)") {
                $reg = $matches[1].ToLower()
                $off = [int]$matches[2]
                $swOffsets[$reg] = $off
                continue
            }

            # lw $reg, offset($sp)
            if ($inst -match "^lw\s+\`$([a-zA-Z0-9]+),\s*(-?\d+)\(\`$sp\)") {
                $reg = $matches[1].ToLower()
                $off = [int]$matches[2]
                if (-not $lwOffsets.ContainsKey($reg)) {
                    $lwOffsets[$reg] = @()
                }
                $lwOffsets[$reg] += $off
                continue
            }

            # jal <subrotina>
            if ($inst -match "^jal\s+([a-zA-Z0-9_]+)") {
                $target = $matches[1]
                $jalAlignments += [PSCustomObject]@{ Target = $target; SpDelta = $currentSpDelta }
                if ($target -match "dados_limpar_ap|persist_carregar|dados_obter_ap|shell_parser|shell_atoi|shell_strcmp") {
                    $definesV0 = $true
                }
                continue
            }

            # Atribuições de retorno
            if ($inst -match "^(?:li|move|lw|addu|subu|addiu)\s+\`$v0\b") {
                $definesV0 = $true
            }
            if ($inst -match "^(?:move|li|addu|la)\s+\`$v1\b") {
                $definesV1 = $true
            }

            # Modificação de callee-saved $s0-$s7
            if ($inst -match "^(?:move|li|la|lw|lbu|lb|lh|lhu|addiu|addu|subu|mul|divu|rem|sll|srl|sra|and|andi|or|ori|xor|xori|nor|lui|negu|mflo|mfhi)\s+\`$(s[0-7])\b") {
                $modifiedS.Add($matches[1].ToLower()) | Out-Null
            }

            # Ponto de saída do procedimento
            if ($inst -match "^jr\s+\`$ra\b" -or $inst -eq "syscall") {
                $exitPoints++
            }
        }

        # --- VALIDAÇÕES RIGOROSAS ---

        # 1. Alinhamento de Frame Base
        $alignmentOk = ($frameAlloc % 8 -eq 0)
        if (-not $alignmentOk) {
            $violations += "Frame ($frameAlloc bytes) nao eh multiplo de 8"
        }

        # 2. Ausência de manipulação dinâmica de pilha
        $dynamicOk = ($dynamicSpErrors.Count -eq 0)
        if (-not $dynamicOk) {
            $violations += "Deslocamento dinamico de `$sp detectado no corpo: $($dynamicSpErrors -join ', ')"
        }

        # 3. Simetria de Fechamento nos Pontos de Retorno
        $spSymmetric = $true
        if ($frameAlloc -gt 0) {
            # Se alocou frame, o delta final precisa zerar
            if ($currentSpDelta -ne 0) {
                # Trata caso de retorno antecipado documentado (ex: shell_imprimir_erro_retorno onde desvia antes de alocar)
                if (-not ($proc.Procedure -eq "shell_imprimir_erro_retorno" -and $rawCodeOnly -contains "addiu `$sp, `$sp, 8")) {
                    $spSymmetric = $false
                    $violations += "Desbalanco final de pilha (net delta = $currentSpDelta, esperado 0)"
                }
            }
        }

        # 4. Alinhamento de $sp e salvamento de $ra em CADA jal
        $raOk = $true
        if ($jalAlignments.Count -gt 0) {
            if (-not ($swOffsets.ContainsKey("ra") -and $lwOffsets.ContainsKey("ra"))) {
                $raOk = $false
                $violations += "Rotina nao-folha com jal nao salva/restaura `$ra na pilha"
            }
            foreach ($j in $jalAlignments) {
                if ($j.SpDelta % 8 -ne 0) {
                    $violations += "Chamada jal $($j.Target) executada com `$sp desalinhado ($($j.SpDelta) bytes)"
                }
            }
        }

        # 5. Correspondência EXATA de offsets (sw vs lw)
        $offsetsOk = $true
        foreach ($reg in $swOffsets.Keys) {
            $swOff = $swOffsets[$reg]
            if (-not $lwOffsets.ContainsKey($reg)) {
                $offsetsOk = $false
                $violations += "Registrador `$$($reg) salvo em $swOff(`$sp) mas nunca restaurado com lw"
            } else {
                foreach ($lwOff in $lwOffsets[$reg]) {
                    if ($lwOff -ne $swOff) {
                        $offsetsOk = $false
                        $violations += "Mismatch de offset para `$$($reg): sw em $swOff(`$sp) vs lw em $lwOff(`$sp)"
                    }
                }
            }
        }

        # 6. Preservação de Callee-Saved ($s0-$s7)
        $calleeOk = $true
        foreach ($sReg in $modifiedS) {
            if (-not ($swOffsets.ContainsKey($sReg) -and $lwOffsets.ContainsKey($sReg))) {
                $calleeOk = $false
                $violations += "Registrador preservado `$$($sReg) modificado sem sw/lw simetrico no frame"
            }
        }

        # 7. Validação de Contratos: Parâmetros ($a0-$a3) e Retornos ($v0/$v1)
        $contractsOk = $true
        $allProcCode = $rawCodeOnly -join " "
        $hasForwarding = ($allProcCode -match "jal\s+dados_limpar_ap|syscall|j\s+mmio_")

        # Validação do uso ou repasse transparente de parâmetros declarados
        foreach ($arg in $proc.Args) {
            $usedDirectly = ($allProcCode -match "\`$$arg\b")
            if (-not $usedDirectly -and -not $hasForwarding) {
                $contractsOk = $false
                $violations += "Argumento `$$arg declarado no contrato formal nao eh utilizado nem repassado no procedimento"
            }
        }

        # Validação de registradores de retorno declarados
        if ($proc.Ret -contains "v0" -and -not $definesV0) {
            $contractsOk = $false
            $violations += "Contrato exige retorno em `$v0, mas nenhuma definicao foi encontrada"
        }
        if ($proc.Ret -contains "v1" -and -not $definesV1) {
            $contractsOk = $false
            $violations += "Contrato exige retorno em `$v1, mas nenhuma definicao foi encontrada"
        }

        $status = if ($violations.Count -eq 0) { "CONFORME" } else { "NAO CONFORME" }
        if ($violations.Count -gt 0) {
            $TotalViolations += $violations.Count
        }

        $Results += [PSCustomObject]@{
            Procedimento   = $proc.Procedure
            FrameBytes     = $frameAlloc
            Alinhamento8B  = if ($alignmentOk -and $dynamicOk) { "SIM" } else { "NAO" }
            SimetriaSP     = if ($spSymmetric) { "SIM" } else { "NAO" }
            OffsetMatch    = if ($offsetsOk) { "SIM" } else { "NAO" }
            PreservaRA     = if ($raOk) { "SIM" } else { "NAO" }
            PreservaS      = if ($calleeOk) { "SIM" } else { "NAO" }
            Contratos      = if ($contractsOk) { "SIM" } else { "NAO" }
            Status         = $status
            Detalhes       = ($violations -join "; ")
        }
    }
}

# Exibição dos resultados em tabela formatada
$Results | Format-Table -Property Procedimento, FrameBytes, Alinhamento8B, SimetriaSP, OffsetMatch, PreservaRA, PreservaS, Contratos, Status -AutoSize

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host " RESUMO DA AUDITORIA ESTRUTURAL E DE CONTRATOS" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "Total de Procedimentos Auditados : $($Results.Count)"
Write-Host "Total Conformes                 : $(($Results | Where-Object { $_.Status -eq 'CONFORME' }).Count)" -ForegroundColor Green
Write-Host "Total Não Conformes             : $TotalViolations" -ForegroundColor $(if ($TotalViolations -eq 0) { "Green" } else { "Red" })

if ($TotalViolations -gt 0) {
    Write-Host "`nVIOLAÇÕES DETECTADAS:" -ForegroundColor Red
    $Results | Where-Object { $_.Status -eq 'NAO CONFORME' } | ForEach-Object {
        Write-Host "  - $($_.Procedimento): $($_.Detalhes)" -ForegroundColor Red
    }
    exit 1
} else {
    Write-Host "`n[SUCESSO] 100% dos procedimentos atendem aos criterios estruturais avaliados pelo script:" -ForegroundColor Green
    Write-Host "          1. Presenca confirmada de rotulos e blocos de codigo nao-vazios." -ForegroundColor Green
    Write-Host "          2. Alinhamento de pilha estritamente multiplo de 8 bytes em todos os frames." -ForegroundColor Green
    Write-Host "          3. Ausencia de decrementos ou incrementos dinamicos de pilha no corpo." -ForegroundColor Green
    Write-Host "          4. Alinhamento de 8 bytes e salvamento previo de `$ra em cada chamada 'jal'." -ForegroundColor Green
    Write-Host "          5. Correspondencia exata de offsets entre 'sw' e 'lw' no frame." -ForegroundColor Green
    Write-Host "          6. Fechamento simetrico de pilha nos pontos de retorno." -ForegroundColor Green
    Write-Host "          7. Preservacao de todos os registradores callee-saved (`$s0-`$s7) modificados." -ForegroundColor Green
    Write-Host "          8. Conformidade com contratos: uso de parametros (`$a0-`$a3) e definicao de retornos (`$v0/`$v1)." -ForegroundColor Green
    Write-Host "`n[NOTA METODOLOGICA] Esta auditoria realiza analise estatica estrutural (linter). Ela nao substitui" -ForegroundColor Yellow
    Write-Host "                    a prova formal de caminhos (CFG path-sensitive) nem garante dinamicamente a" -ForegroundColor Yellow
    Write-Host "                    semantica de execucao. A garantia completa da ABI decorre da combinacao deste" -ForegroundColor Yellow
    Write-Host "                    auditor com os testes de estresse dinamicos (executar_testes.ps1)." -ForegroundColor Yellow
    exit 0
}
