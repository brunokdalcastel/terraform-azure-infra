# Key Vault: RBAC e rede explícita

O módulo prepara RBAC e remove explicitamente access policies legadas. Nenhuma
role é concedida automaticamente ao usuário atual. As integrações de certificados
para VMs, Azure Disk Encryption e templates ARM ficam desativadas por não serem usadas.

DEV e PROD usam firewall Deny, sem bypass. A subnet App continua explicitamente
permitida; key_vault_allowed_ipv4_addresses pode listar IPv4 administrativos.
Vazio não permite operadores externos. Rede não substitui permissões de dados.

Antes de qualquer execução real, preparar identidades e permissões no escopo do
cofre, respeitando o menor privilégio. Migração de access policies para RBAC pode
interromper acesso caso roles não tenham sido preparadas e propagadas previamente.
O executor que gerencia secrets precisará das permissões correspondentes. Não
abrir a rede ou conceder Owner na subscription como solução automática.

O provider não faz purge automático em DEV/PROD. Retenção permanece sete dias;
PROD mantém purge protection e DEV mantém a configuração anterior sem essa proteção.
Mudar autenticação/rede em um cofre existente exige plano e aprovação específicos.

Esta parcela não concede roles, não acessa Azure nem testa RBAC real. Testes com
mocks verificam apenas a configuração. O endpoint público é restrito por firewall,
não é um Private Endpoint. Credenciais/state existentes continuam sensíveis.

Referência: [Key Vault no provider 4.14.0](https://github.com/hashicorp/terraform-provider-azurerm/blob/v4.14.0/website/docs/r/key_vault.html.markdown).
