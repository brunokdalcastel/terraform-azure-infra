# Acesso ao Storage da aplicação

Shared Key está desabilitada. Os providers DEV/PROD usam `storage_use_azuread`;
a autenticação do backend Terraform continua independente. Os containers data,
logs e backups são privados e exigem HTTPS/TLS 1.2.

O firewall usa Deny, sem bypass automático. O orquestrador permite somente a subnet
App, onde estão as VMs e já existe service endpoint Microsoft.Storage. Os nomes e
endereços Terraform dos recursos não mudam. A subnet Data não tem consumidores
implementados que justifiquem permissão de acesso ao Storage.

`storage_allowed_ipv4_addresses` nos roots permite informar IPs individuais do
executor; o default vazio não autoriza acesso externo. Ter acesso à rede não dá
permissão aos dados: identidades precisarão de roles de Blob no escopo adequado.
Nenhuma role, credencial ou infraestrutura de rede é criada nesta parcela.

Antes da execução final, revisar IP público de saída, rede e RBAC do executor e
das VMs. IP allowlist não resolve todos os caminhos Azure, incluindo serviços na
mesma região. GitHub runners não têm IP fixo pressuposto. Revisar propagação RBAC
e o acesso inicial antes de criar conta/containers. Não abrir o firewall para
contornar erros. O endpoint público restrito não equivale a Private Endpoint.

O output primary_access_key foi removido; consumidores externos que o utilizem
precisam migrar para Entra ID. Isso não significa que o provider deixará de armazenar
atributos sensíveis no state. State deve permanecer protegido. Desabilitar Shared
Key pode interromper clientes que usam chaves ou SAS assinada por chave de conta.

Em infraestrutura existente, aplicar o firewall também pode bloquear o executor
e clientes antes autorizados. Mudanças reais dependem de aprovação manual; não
foram feitas chamadas ao Azure nesta parcela. Testes simulados validam configuração,
não acesso real, RBAC ou transferência de blobs.

O bootstrap do backend não foi alterado. Retenção e versionamento do Storage da
aplicação também permanecem como antes; esta PR não implementa backup ou coleta de logs.
