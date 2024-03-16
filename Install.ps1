# Definindo variáveis básicas
$version = "v3.19"
$architecture = "x86_64" # Pode ser alterado para "armhf", "aarch64", etc.
$modelBase = "alpine-minirootfs-3.19.1"
$model = "${modelBase}-${architecture}"
$baseUrl = "https://dl-cdn.alpinelinux.org/alpine"

# Combinando as variáveis para formar o URL de download
$alpineUrl = "$baseUrl/$version/releases/$architecture/${model}.tar.gz"

# Variáveis de diretório e nome de arquivo
$distroName = "sonarqube"
$wslFolderPath = "$env:USERPROFILE\.wsl"
$alpineFileName = "${model}.tar.gz"

# Verificar se a pasta .wsl existe, se não, criá-la
if (-not (Test-Path $wslFolderPath)) {
    New-Item -ItemType Directory -Force -Path $wslFolderPath
}

# Caminho completo para salvar o arquivo Alpine
$alpineFilePath = Join-Path -Path $wslFolderPath -ChildPath $alpineFileName

# Baixar o Alpine Linux
Invoke-WebRequest -Uri $alpineUrl -OutFile $alpineFilePath

# Criar o diretório para a distro dentro de .wsl, se não existir
$distroPath = Join-Path -Path $wslFolderPath -ChildPath $distroName
if (-not (Test-Path $distroPath)) {
    New-Item -ItemType Directory -Force -Path $distroPath
}

# Importar a imagem baixada para o WSL
wsl --import $distroName $distroPath $alpineFilePath > $null

# Remover o arquivo tar.gz após a importação
Remove-Item $alpineFilePath

# Testar a instalação
Write-Host "Alpine Linux $version $architecture instalado com sucesso!" -ForegroundColor Green

# Instalando o Docker
Write-Host "Atualizando o sistema e instalando o Docker..." -ForegroundColor Green
wsl -d $distroName -- sysctl -w vm.max_map_count=262144 > $null

wsl -d $distroName -- apk update > $null
wsl -d $distroName -- apk upgrade > $null

wsl -d $distroName -- apk add docker > $null
Start-Sleep -Seconds 5

# Inicia o daemon do Docker na distribuição WSL
Start-Job -ScriptBlock { wsl -d $using:distroName -- dockerd } > $null
Start-Sleep -Seconds 5

# Executa o comando 'docker version' no WSL e captura a saída
try {
    $dockerVersionOutput = wsl -d $distroName -- docker version
    
    # Convertendo a saída em uma lista para facilitar a busca
    $dockerVersionLines = $dockerVersionOutput -split "`n"
    $clientCheck = $dockerVersionLines -match "Client:"
    $serverCheck = $dockerVersionLines -match "Server:"

    if (-not $clientCheck) {
        Write-Host "`r`nO cliente Docker não iniciou corretamente." -ForegroundColor Red
        exit
    }
    elseif (-not $serverCheck) {
        Write-Host "`r`nO serviço Docker não subiu corretamente." -ForegroundColor Red
        exit
    }
    else {
        Write-Host "`r`nTanto o cliente quanto o serviço Docker estão funcionando corretamente." -ForegroundColor Green
        # Exibindo a versão do cliente e do servidor
        $clientVersion = $dockerVersionLines | Where-Object { $_ -match "Version:.*" } | Select-Object -First 1
        $serverVersion = $dockerVersionLines | Where-Object { $_ -match "Version:.*" } | Select-Object -Last 1
        Write-Host "Versão do Cliente: $clientVersion" -ForegroundColor Yellow
        Write-Host "Versão do Servidor: $serverVersion" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "`r`nOcorreu um erro ao tentar executar o comando 'docker version' no WSL." -ForegroundColor Red
    Write-Host "Erro: $_" -ForegroundColor Red
}

# Instalando o Docker Compose
wsl -d $distroName -- apk add docker docker-cli-compose > $null

# Copia o arquivo docker-compose.yml para a pasta /root do Alpine
wsl -d $distroName -- cp ./compose/docker-compose.yml /root/docker-compose.yml

Write-Host "`r`nInstalação concluída. O Docker e o Docker Compose foram instalados e o SonarQube está pronto para ser inicializado." -ForegroundColor Green
write-host "Baixando todos os containers do SonarQube... Aguarde um momento...`r`n" -ForegroundColor Yellow

wsl -d $distroName -- docker-compose -f /root/docker-compose.yml up -d *> $null
Start-Sleep -Seconds 60

# Obtém a lista de contêineres Docker em execução
$containers = wsl -d $distroName -- docker ps --format "{{.Names}}:{{.Status}}"

# Inicializa as variáveis de status
$sonarqubeUp = $false
$sonarqubeDbUp = $false

# Itera sobre cada contêiner para verificar os nomes e status
foreach ($container in $containers) {
    if ($container -like "sonarqube:*Up*") {
        $sonarqubeUp = $true
    }
    elseif ($container -like "sonarqube_db:*Up*") {
        $sonarqubeDbUp = $true
    }
}

# Verifica se ambos os contêineres estão com o status 'Up'
if ($sonarqubeUp -and $sonarqubeDbUp) {
    Write-Host "Os contêineres 'sonarqube' e 'sonarqube_db' estão rodando." -ForegroundColor Green
}
else {
    Write-Host "Um ou ambos os contêineres 'sonarqube' e 'sonarqube_db' NÃO estão rodando." -ForegroundColor Red
}

Write-Host "Instalação concluida e o SonarQube foi inicializado http://localhost:9000/`r`nQuando precisar reiniciar user o script 'SonarQube-Start.ps1'`r`n" -ForegroundColor Green