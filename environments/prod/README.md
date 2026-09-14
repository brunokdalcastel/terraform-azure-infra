# PROD — ambiente demonstrativo, não provisionado

Este root reutiliza os mesmos módulos do DEV, com inputs e lock file próprios.
Aceita somente `environment = "prod"`, gera nomes com sufixo `prod` e declara
backend AzureRM com chave `prod.terraform.tfstate`. DEV usa outra chave.
As coordenadas exemplificadas apontam ao mesmo container do bootstrap: isso
separa os arquivos de state, mas não isola permissões entre ambientes.

## Validação local

Na raiz do repositório, sem conta Azure:

```bash
terraform -chdir=environments/prod init -backend=false -lockfile=readonly -input=false
terraform -chdir=environments/prod validate
terraform -chdir=environments/prod test
```

O CI inclui PROD em sua matriz. Testes usam mocks e somente planos simulados.
Não executar inicialização remota, plan real ou apply nesta fase.
O exemplo de backend não é carregado automaticamente. Coordenadas reais ficam
em arquivo `.tfbackend` ignorado; nunca incluir credenciais.

## Políticas atuais

- Zero VMs por padrão; até uma VM B1s/B2s para testes futuros aprovados.
- Storage Standard LRS: política de laboratório, sem alta disponibilidade regional.
- O ambiente `prod` ativa no módulo existente proteção contra purge e firewall
  Deny do Key Vault. O provider não faz purge automático ao destruir.
- O provider bloqueia remoção de Resource Group com recursos ainda presentes.
  Isso não impede um destroy que remova primeiro todos os recursos gerenciados.
- Os limites do DEV são mantidos deliberadamente: chamar o ambiente de PROD
  demonstra separação de configuração, não maturidade operacional já validada.

## Pendências antes de qualquer execução real

Não há state remoto inicializado, OIDC, credenciais ou isolamento RBAC provisionados.
Rede, acesso do executor ao Key Vault, permissões, preços e quota precisam de revisão.
Storage agora exige Entra ID e rede explícita; RBAC ainda precisa de preparação.
As VMs usam senha. O CIDR padrão coincide com DEV; não planejar peering/conectividade
entre ambientes sem revisar endereçamento. Esses ajustes ficam para outra parcela.

Zero VMs não significa custo zero. A proteção contra purge do Key Vault afeta
remoção e reutilização do nome durante a retenção: considerar isso no plano de
encerramento do laboratório. Testes simulados não comprovam recuperação ou deploy.

Inicialização remota e eventual migração dependem de aprovação manual na etapa final,
com backup de qualquer state existente e conferência da chave exclusiva de PROD.
Não apontar PROD para `dev.terraform.tfstate`, nem reaproveitar state DEV.
