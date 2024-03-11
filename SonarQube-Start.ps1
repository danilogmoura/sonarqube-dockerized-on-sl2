# Define o nome da distribuição WSL
$distroName = "sonarqube"

# Aumenta o vm.max_map_count para o valor especificado
wsl -d $distroName -- sysctl -w vm.max_map_count=262144

# Inicia o daemon do Docker na distribuição WSL
Start-Job -ScriptBlock { wsl -d $using:distroName -- dockerd }

# Aguarda um breve momento para garantir que o daemon do Docker tenha sido iniciado
Start-Sleep -Seconds 5

# Usa o docker-compose para subir os serviços definidos no arquivo docker-compose.yml
wsl -d $distroName -- docker-compose -f /root/docker-compose.yml up -d

# Informa ao usuário que o script foi concluído
Write-Output "Docker e docker-compose foram inicializados na distribuição WSL '$distroName'."
