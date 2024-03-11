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
wsl --import $distroName $distroPath $alpineFilePath

# Remover o arquivo tar.gz após a importação
Remove-Item $alpineFilePath

# Testar a instalação
wsl -d $distroName -- echo "`r`nAlpine Linux $version $architecture instalado com sucesso!"

# Instalando o Docker
wsl -d $distroName -- sysctl -w vm.max_map_count=262144

wsl -d $distroName -- apk update 
wsl -d $distroName -- apk upgrade 

wsl -d $distroName -- apk add docker
Start-Sleep -Seconds 5

wsl -d $distroName -- dockerd &
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
        Write-Host "Versão do Cliente: $clientVersion" -ForegroundColor Green
        Write-Host "Versão do Servidor: $serverVersion" -ForegroundColor Green
    }
}
catch {
    Write-Host "`r`nOcorreu um erro ao tentar executar o comando 'docker version' no WSL." -ForegroundColor Red
    Write-Host "Erro: $_" -ForegroundColor Red
}

# Instalando o Docker Compose
wsl -d $distroName -- apk add docker docker-cli-compose

# Copia o arquivo docker-compose.yml para a pasta /root do Alpine
wsl -d $distroName -- cp ./compose/docker-compose.yml /root/docker-compose.yml

# wsl -d $distroName -- 
wsl -d $distroName -- ls /root

# Iniciando o SonarQube com o Docker Compose
wsl -d sonarqube -- docker-compose -f /root/docker-compose.yml up -d

# Simulação da saída do comando, substitua essa parte pela captura real do seu comando docker-compose
$output = @"
[+] Running 7/7
 ✔ Network root_default                Created
 ✔ Volume "root_sonarqube_db"          Created
 ✔ Volume "root_sonarqube_data"        Created
 ✔ Volume "root_sonarqube_extensions"  Created
 ✔ Volume "root_sonarqube_logs"        Created
 ✔ Container sonarqube_db              Started
 ✔ Container sonarqube                 Started
"@

# Separa as linhas e verifica apenas as últimas 7
$lines = $output -split "`n" | Select-Object -Last 7

# Variável para manter o status de sucesso
$allSuccessful = $true

foreach ($line in $lines) {
    if (-not($line -match "✔")) {
        $allSuccessful = $false
        Write-Host "`r`nFalha detectada na linha: $line" -ForegroundColor Red
    }
}

if ($allSuccessful) {
    Write-Host "`r`nTodos os serviços (networks, volumes, containers) foram criados ou iniciados com sucesso." -ForegroundColor Green
}
else {
    Write-Host "`r`nAlguns serviços não foram iniciados corretamente." -ForegroundColor Red
    exit
}


Write-Host "`r`nInstalação concluida, o serviço está ON, quando precisar reiniciar user o script 'SonarQube-Start.ps1' " -ForegroundColor Green