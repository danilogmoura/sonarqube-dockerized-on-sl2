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