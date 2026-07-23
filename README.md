# DevOps Lab EC2 Spot com Acesso via SSM (VPC Default)

Este projeto contém a configuração do Terraform para provisionar um laboratório de testes DevOps e Kubernetes (Kind) na AWS utilizando uma instância **EC2 Spot** (`c7g.2xlarge`) com arquitetura ARM64 (Graviton3).

Esta infraestrutura foi simplificada ao máximo, rodando na **VPC Default** da sua conta AWS e utilizando apenas o **AWS Systems Manager (SSM)** para acesso e redirecionamento de portas (Port Forwarding).

## Como Funciona a Persistência?

1. **Comportamento de Interrupção (`Stop`):** No arquivo [main.tf](file:///Users/alex/workspace/poc-machine/main.tf), a opção `instance_interruption_behavior` está definida como `"stop"`. Se a AWS precisar recuperar a instância, ela apenas desligará a máquina em vez de destruí-la.
2. **Não Exclusão do EBS (`delete_on_termination = false`):** O volume root (EBS) de 30GB está configurado para não ser deletado quando a instância for encerrada, salvando seu progresso.

## Segurança Máxima: Ingress Zero

Como toda a comunicação é feita através do agente SSM (que se conecta de forma ativa e síncrona com os endpoints da AWS), a instância **não precisa de nenhuma porta de entrada aberta** na internet.
* O Security Group criado no arquivo [main.tf](file:///Users/alex/workspace/poc-machine/main.tf) possui **zero regras de entrada (Ingress)**.
* Ninguém na internet (nem mesmo você) consegue realizar conexões diretas de rede para a instância, blindando-a completamente contra ataques e escaneamentos de portas.

## Arquivos do Projeto

* [providers.tf](file:///Users/alex/workspace/poc-machine/providers.tf): Configuração do provider AWS.
* [variables.tf](file:///Users/alex/workspace/poc-machine/variables.tf): Definição de variáveis como região, tipo de instância e tamanho do volume.
* [main.tf](file:///Users/alex/workspace/poc-machine/main.tf): Coleta de dados da VPC Default, perfil IAM para SSM, Security Group blindado (sem portas de entrada) e a instância Spot.
* [init.sh](file:///Users/alex/workspace/poc-machine/init.sh): Script de inicialização automática que instala Docker, Terraform, Kind e Kubectl.
* [outputs.tf](file:///Users/alex/workspace/poc-machine/outputs.tf): Comandos para terminal SSM e Port Forwarding.

## Como Executar

1. Inicialize o Terraform:
   ```bash
   terraform init
   ```

2. Aplique a configuração:
   ```bash
   terraform apply
   ```

## Acesso e Port Forwarding

Após subir a instância, você pode interagir com ela da sua máquina local usando o AWS CLI com o plugin do Session Manager instalado:

### 1. Acessar o Terminal da Instância (Shell)
```bash
aws ssm start-session --target <id-da-instancia>
```

### 2. Fazer Port Forwarding do Kubernetes (Kind) para sua Máquina Local
Para mapear a API do Kubernetes (porta 6443) da EC2 diretamente para o `localhost:6443` da sua máquina física sem abrir nenhuma porta de entrada na AWS:
```bash
aws ssm start-session \
  --target <id-da-instancia> \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["6443"],"localPortNumber":["6443"]}'
```
Dessa forma, você consegue rodar o `kubectl` do seu próprio computador apontando para `https://localhost:6443` de forma 100% segura.
