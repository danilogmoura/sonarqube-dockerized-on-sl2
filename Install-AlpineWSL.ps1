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
wsl -d $distroName -- echo "Alpine Linux $version $architecture instalado com sucesso!"

# Instalando o Docker
wsl -d $distroName -- apk update 
wsl -d $distroName -- apk upgrade 
wsl -d $distroName -- apk add docker py3-pip python3-dev libffi-dev openssl-dev gcc libc-dev rust cargo make 

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
        Write-Host "O cliente Docker não iniciou corretamente." -ForegroundColor Red
        exit
    }
    elseif (-not $serverCheck) {
        Write-Host "O serviço Docker não subiu corretamente." -ForegroundColor Red
        exit
    }
    else {
        Write-Host "Tanto o cliente quanto o serviço Docker estão funcionando corretamente." -ForegroundColor Green
        # Exibindo a versão do cliente e do servidor
        $clientVersion = $dockerVersionLines | Where-Object { $_ -match "Version:.*" } | Select-Object -First 1
        $serverVersion = $dockerVersionLines | Where-Object { $_ -match "Version:.*" } | Select-Object -Last 1
        Write-Host "Versão do Cliente: $clientVersion" -ForegroundColor Green
        Write-Host "Versão do Servidor: $serverVersion" -ForegroundColor Green
    }
}
catch {
    Write-Host "Ocorreu um erro ao tentar executar o comando 'docker version' no WSL." -ForegroundColor Red
    Write-Host "Erro: $_" -ForegroundColor Red
}

# Instalando o Docker Compose
wsl -d $distroName -- apk add docker docker-cli-compose

