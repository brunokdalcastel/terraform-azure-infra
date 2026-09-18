# Bootstrap do backend Terraform

**Status: bootstrap e backend DEV validados em sessão temporária e removidos.**
A inicialização remota usou Entra ID, sem migração de state existente.
Veja os [resultados e limites](../../docs/azure-validation-2026-09-18.md).

## Decisão e escopo

O backend tem ciclo de vida independente da aplicação: um Resource Group,
uma Storage Account Standard LRS e um container privado `tfstate`.
Não reutiliza o módulo de Storage da aplicação, pois state exige regras próprias
de acesso, recuperação e proteção contra exclusão.

Usa Microsoft Entra ID (`storage_use_azuread` no provider), com Shared Key
desabilitada. O backend DEV usa `use_azuread_auth`: autenticação do provider
e autenticação do backend são configurações distintas.
Os outputs contêm somente coordenadas e ID; não exportam chaves ou tokens.
O state do bootstrap ainda deve ser tratado como sensível, mesmo sem esses outputs.

## Validação sem Azure

Na raiz do repositório:

```bash
terraform fmt -check -recursive
terraform -chdir=bootstrap/backend init -backend=false -lockfile=readonly -input=false
terraform -chdir=bootstrap/backend validate
terraform -chdir=bootstrap/backend test
```

Terraform 1.14.3 e AzureRM 4.14.0; lock file próprio com hashes para Windows e Linux.
Os testes usam provider simulado e `command = plan`. Não verificam permissões,
disponibilidade do nome, conectividade, recuperação efetiva ou locking no Azure.

## Rede e permissões para a futura execução

O endpoint público fica habilitado, com firewall `Deny`, sem bypass e uma lista
explícita de IPv4. O default vazio é fechado: **não serve para executar o bootstrap
real sem preparar o acesso**. A configuração inicial deliberadamente não cria
Private Endpoint, NAT ou runners próprios com custo recorrente.

Antes de qualquer execução aprovada, será necessário definir um caminho de rede
suportado e os IPs públicos de saída reais. Regras IP não resolvem todos os caminhos
Azure (por exemplo tráfego originado na mesma região); não habilitar `Allow` como
correção automática. Runners hospedados no GitHub não têm um IP fixo pressuposto.

O operador precisará de permissões de gerenciamento para criar RG/Storage e
permissões de dados compatíveis com Blob Storage. Não presumir que Contributor
de gerenciamento garante acesso aos blobs. O futuro leitor/escritor do state
precisará de Storage Blob Data Contributor no menor escopo adequado, preferindo
container quando disponível. Criar/atribuir roles não faz parte desta PR.

Como os recursos da sessão foram removidos, revisar previamente com o proprietário
como conceder os acessos iniciais e considerar o tempo de propagação do RBAC.
A conta Azure, registro de Microsoft.Storage e nome globalmente disponível também
precisam ser confirmados. O provider não registra namespaces automaticamente.

## Recuperação, custo e exclusão

Blob versioning permite manter versões anteriores. Soft delete de blobs e
containers usa sete dias. Essa retenção **não expira automaticamente versões
antigas**: não há lifecycle de limpeza nesta PR. Rever volume, retenção de versões
e custo antes de aprovar a execução; nenhuma garantia de gratuidade.

`prevent_destroy` protege RG, conta e container enquanto os blocos estão presentes
na configuração. Não é um lock do Azure e não impede exclusão pelo portal ou
remoção da própria configuração. Exclusão do backend exige revisão específica,
backup e aprovação; não deve acompanhar a remoção das VMs de laboratório.

## State do bootstrap e próximos passos

O backend local resolve a dependência inicial: não é possível depender de uma
conta de Storage ainda inexistente. Seu state deve ficar fora do Git, com backup
seguro após qualquer execução futura. Sua estratégia permanente de armazenamento
será revisada antes do deploy; não descartar esse state nem misturá-lo com DEV.

A futura integração do DEV usará coordenadas deste bootstrap e uma chave própria,
como `dev.terraform.tfstate`; PROD usará outra chave. Separar chaves não representa
isolamento de permissões. A decisão de containers/contas por ambiente será revisada
quando PROD e OIDC forem preparados.

O [backend DEV](../../environments/dev/README.md) é preparado separadamente.
Nenhuma migração foi executada. Novas sessões reais exigem revisão e aprovação.

## Referências

- [AzureRM backend e autenticação](https://developer.hashicorp.com/terraform/language/backend/azurerm)
- [Storage Account no provider 4.14.0](https://github.com/hashicorp/terraform-provider-azurerm/blob/v4.14.0/website/docs/r/storage_account.html.markdown)
- [Limitações de regras de rede](https://learn.microsoft.com/azure/storage/common/storage-network-security-limitations)
