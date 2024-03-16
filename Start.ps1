# Define o nome da distribuição WSL
$distroName = "sonarqube"

# Aumenta o vm.max_map_count para o valor especificado
wsl -d $distroName -- sysctl -w vm.max_map_count=262144 > $null

# Inicia o daemon do Docker na distribuição WSL
Start-Job -ScriptBlock { wsl -d $using:distroName -- dockerd } > $null

# Aguarda um breve momento para garantir que o daemon do Docker tenha sido iniciado
Start-Sleep -Seconds 5

# Usa o docker-compose para subir os serviços definidos no arquivo docker-compose.yml
$output = wsl -d sonarqube -- docker-compose -f /root/docker-compose.yml up -d 2>&1
$lines = $output -split "`n"
Start-Sleep -Seconds 5

# Variável para manter o status de sucesso
$allSuccessful = $true
Write-Host

foreach ($line in $lines) {
    if (-not($line -match "Starting$" -or $line -match "Created$" -or $line -match "Started$")) {
        $allSuccessful = $false
        Write-Host "Falha detectada na linha: $line" -ForegroundColor Red
    }
}

if ($allSuccessful) {
    Write-Host "Todos os serviços foram iniciados com sucesso." -ForegroundColor Green
}
else {
    Write-Host "`r`nAlguns serviços não foram iniciados corretamente." -ForegroundColor Red
    exit
}

# Informa ao usuário que o script foi concluído
Write-Host "SonarQube inicializado. http://localhost:9000/`r`n" -ForegroundColor Green
