# Configuração do Alpine Linux no WSL para SonarQube

Este script automatiza o processo de configuração para executar o SonarQube dentro do Ambiente de Subsistema do Windows para Linux (WSL), utilizando o Alpine Linux como distribuição base. Ele também instala o Docker e o Docker Compose para facilitar a implantação em contêineres do SonarQube.

## Pré-requisitos

Antes de executar este script, certifique-se de ter o seguinte:

- O Subsistema do Windows para Linux (WSL) habilitado em seu computador com Windows.
- O PowerShell instalado em seu computador com Windows.
- Acesso à internet para baixar o Alpine Linux e os pacotes do Docker.

## Instruções

1. **Baixe o Script**: Copie o script fornecido neste repositório.

2. **Abra o PowerShell**: Inicie o PowerShell com privilégios de administrador.

3. **Execute o Script**: Execute o script no PowerShell. Você pode fazer isso navegando até o diretório onde o script está salvo e executando-o usando `.\nome_do_script.ps1`.

4. **Siga as Instruções na Tela**: O script solicitará as ações necessárias, como confirmar a instalação e fornecer permissões administrativas.

5. **Verifique a Instalação**: Após a conclusão do script, verifique se o SonarQube e o Docker estão instalados corretamente, seguindo as instruções fornecidas.

## Visão Geral do Script

O script realiza as seguintes tarefas:

- Baixa a versão especificada do Alpine Linux do repositório oficial do Alpine Linux.
- Configura a distribuição do Alpine Linux dentro do ambiente WSL.
- Instala o Docker e o Docker Compose para facilitar a execução do SonarQube em contêineres.
- Verifica a instalação bem-sucedida do Docker e do Docker Compose.

## Observações

- Certifique-se de ter espaço em disco suficiente disponível para baixar e configurar o Alpine Linux e o Docker.
- O script é testado com o PowerShell em ambientes Windows. A compatibilidade com outras plataformas não é garantida.

## Aviso Legal

Este script é fornecido como está, sem qualquer garantia. Use por sua própria conta e risco. Certifique-se de revisar o script e entender suas ações antes de executá-lo.

## Licença

Este script está licenciado sob a [Licença MIT](LICENSE).

---
*Este README foi gerado com base no script fornecido. Por favor, verifique sua precisão e relevância antes de utilizá-lo em seu repositório.*
