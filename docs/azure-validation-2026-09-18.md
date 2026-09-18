# Validação real Azure — 18/09/2026

Sessão temporária em Brazil South, somente backend e DEV sem VM. Terraform 1.14.3,
AzureRM 4.14.0. Autenticação interativa local via Azure CLI e Entra ID; sem Shared Key.
Não houve deploy PROD, OIDC, Log Analytics ou teste de SSH. Este relatório sanitizado
não inclui subscription IDs, IP do operador, credenciais, dados de pagamento ou state.

## Resultados observados

| Verificação | Resultado real |
| --- | --- |
| Bootstrap | 3 recursos criados; novo plan retornou No changes |
| Controles do backend | Standard LRS, HTTPS, TLS 1.2, Shared Key desabilitada, firewall Deny e container privado confirmados por leitura Azure |
| Separação controle/dados | Usuário com Owner não conseguiu listar blobs antes da role de dados |
| Backend Entra ID | Após role no container, init remoto do DEV funcionou sem chave de Storage |
| Exclusão mútua | Lease em blob sintético impediu escrita concorrente com LeaseIdMissing; escrita voltou após liberar lease |
| Lock do Terraform | Durante apply, o blob de state foi observado como leased/locked |
| Versionamento | Versão anterior de blob sintético baixada com conteúdo esperado |
| Provisionamento DEV | 18 entradas gerenciadas no state, incluindo dois random strings; sem compute |
| Idempotência DEV | Novo plan retornou No changes, exit 0 |
| NSG | Web permite 443 e bloqueia restantes; App permite 8080/8443 da subnet Web. Não foi teste de tráfego entre VMs |
| Key Vault RBAC | ForbiddenByRbac antes da role; escrita/leitura de secret fictício após role temporária no cofre |
| Storage RBAC | Negação antes da role no container data; upload/download depois da atribuição, com hashes iguais |
| Acesso anônimo | Solicitação sem credenciais ao blob existente retornou HTTP 409, sem entregar conteúdo |
| Recuperação Blob | Blob de teste excluído, recuperado por undelete e baixado com hash igual ao original |
| Firewall Storage DEV | Retirada temporária do IP permitiu observar negação de rede após propagação; regra restaurada e leitura voltou a funcionar |

## Limites da evidência

O teste de lease isolado e a observação do lock real não equivalem a ensaio de dois
applies concorrentes. A recuperação de versão sintética não comprova DR completo
ou RPO/RTO de state. Não houve teste de identidade diferente tentando acessar state
PROD. Negação anônima não comprova isoladamente RBAC ou todos os caminhos de rede.
Uma propagação de firewall/RBAC pode atrasar a mudança percebida pelo cliente.

OIDC, aprovação técnica de environments, workflow apply, auditoria de blobs para
Log Analytics e acesso SSH privado continuam pendentes. Nenhum deles é apresentado
como operacional. Os testes locais anteriores continuam sendo evidência separada.

## Encerramento

DEV: destroy plan revisado com 18 exclusões; aplicação concluiu 18 destroyed.
State final sem recursos gerenciados preservado fora do Git. As duas roles de dados
do DEV foram removidas. A role do container de backend foi removida após exportar
o state final. Limpeza do backend usa cópia isolada com prevent_destroy desativado;
o código versionado mantém suas três proteções.

Backend: state local final sem recursos gerenciados, sincronizado com o diretório
original. O Network Watcher criado automaticamente também foi removido.
As consultas finais de grupos e recursos ativos da assinatura retornaram listas
vazias. Nenhuma VM, Storage ou rede do laboratório permaneceu ativa.

O Key Vault permanece como registro soft-deleted, com expurgo previsto pelo Azure
para 25/09/2026; não foi realizado purge manual. Backups locais de state foram
preservados com acesso restrito, fora do Git.

O orçamento mensal de R$ 50 continua configurado até 01/09/2027 e o spending limit
da assinatura foi confirmado como On. O gasto retornado pelo orçamento era R$ 0
na consulta de encerramento, sujeito ao atraso de faturamento. Orçamento é alerta,
não bloqueio. Inventário vazio não significa que o consumo da sessão não será
contabilizado posteriormente; o custo final deve ser conferido após atualização.
