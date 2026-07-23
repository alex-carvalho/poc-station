# DevOps Lab EC2 Spot com Acesso via Tailscale (Amazon Linux 2023)

Este projeto contém a configuração do Terraform para provisionar um laboratório de testes DevOps e Kubernetes (Kind) na AWS utilizando uma instância **EC2 Spot** (`c7g.2xlarge`) com o sistema operacional **Amazon Linux 2023 (AL2023)** em arquitetura ARM64 (Graviton3).

A infraestrutura utiliza o **Tailscale** para criar uma rede privada e criptografada entre a sua máquina local e a instância EC2. Isso elimina a necessidade de chaves SSH, de expor portas na AWS e de configurar credenciais locais da AWS para fazer port forward.

## Como Funciona a Persistência?

1. **Comportamento de Interrupção (`Stop`):** No arquivo [main.tf](file:///Users/alex/workspace/poc-machine/main.tf), a opção `instance_interruption_behavior` está definida como `"stop"`. Se a AWS precisar recuperar a instância, ela apenas desligará a máquina em vez de destruí-la.
2. **Não Exclusão do EBS (`delete_on_termination = false`):** O volume root (EBS) de 30GB está configurado para não ser deletado quando a instância for encerrada, salvando seu progresso.

## Segurança Máxima

Como o tráfego é roteado de forma criptografada pelo Tailscale (que inicia uma conexão de saída segura a partir da EC2), a instância **não precisa de nenhuma porta de entrada aberta** na internet.
* O Security Group criado no arquivo [main.tf](file:///Users/alex/workspace/poc-machine/main.tf) possui **zero regras de entrada (Ingress)**.
* Ninguém na internet consegue realizar conexões de rede para a instância, mantendo-a totalmente invisível.

## Arquivos do Projeto

* [providers.tf](file:///Users/alex/workspace/poc-machine/providers.tf): Configuração do provider AWS.
* [variables.tf](file:///Users/alex/workspace/poc-machine/variables.tf): Definição de variáveis como região, tipo de instância, tamanho do volume e a chave de autenticação do Tailscale.
* [main.tf](file:///Users/alex/workspace/poc-machine/main.tf): Coleta de dados da VPC Default, busca da AMI do Amazon Linux 2023 via Parameter Store, perfil IAM para SSM (como canal de suporte), Security Group blindado e a instância Spot.
* [init.sh](file:///Users/alex/workspace/poc-machine/init.sh): Script de inicialização automática que instala Docker, Terraform, Kind, Kubectl, clona o repositório sandbox do usuário e configura o Tailscale em ambiente AL2023.
* [outputs.tf](file:///Users/alex/workspace/poc-machine/outputs.tf): Comando para conexão via SSM Session Manager.

## Passo a Passo para Configuração

### 1. Preparar o Tailscale (Na sua máquina)
1. Crie uma conta gratuita em [tailscale.com](https://tailscale.com).
2. Baixe e instale o cliente do Tailscale no seu computador local e faça login com a sua conta.
3. No painel web do Tailscale (Admin Console), acesse: **Settings** -> **Keys** -> Clique em **Generate auth key...**.
4. Configure a chave com as seguintes opções:
   * **Reusable:** Marcado (permite reuso da chave caso precise recriar a EC2).
   * **Ephemeral:** Marcado (recomendado para instâncias Spot; remove automaticamente o nó do seu painel do Tailscale quando a instância for desligada/destruída).
5. Clique em **Generate key** e copie a chave gerada (ela começa com `tskey-auth-...`).

### 2. Configurar e Executar o Terraform (No AWS CloudShell)
Se você estiver rodando o Terraform diretamente do **AWS CloudShell** para não ter credenciais na sua máquina local:

1. Clone o seu repositório no CloudShell.
2. Inicialize o Terraform:
   ```bash
   terraform init
   ```
3. Crie um arquivo `terraform.tfvars` na pasta do projeto e adicione a chave do Tailscale que você copiou:
   ```hcl
   tailscale_auth_key = "tskey-auth-sua-chave-aqui"
   ```
4. Aplique a configuração:
   ```bash
   terraform apply
   ```

### 3. Acessar a Instância
* Cerca de 2 minutos após o Terraform concluir o `apply`, a instância aparecerá no seu painel web do Tailscale e no aplicativo local do seu computador.
* Ela receberá um IP privado do Tailscale (ex: `100.x.y.z`).
* A partir do terminal da sua máquina local (com o Tailscale conectado), você pode acessar a EC2 por meio do usuário padrão `ec2-user` ou usar diretamente o IP privado da VPN para se conectar com o Kubernetes (Kind) no endereço `https://IP-DO-TAILSCALE:6443`.
