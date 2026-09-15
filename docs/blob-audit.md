# Auditoria de blobs preparada

DEV, PROD e bootstrap aceitam `audit_workspace_id`, ID completo de um Log Analytics
existente e aprovado. O default null não cria diagnostic settings. Nenhum workspace
é criado por esta mudança; não há promessa de custo zero quando habilitada.

Com um destino explícito, a configuração envia StorageRead, StorageWrite e
StorageDelete do serviço `/blobServices/default` para tabelas dedicadas. O escopo
é o serviço Blob da conta inteira, incluindo os containers declarados no projeto.
Não configura logging de Queue nem auditoria de Key Vault.

## Antes de habilitar no Azure

Escolher workspace, região, permissões e retenção no destino. Estimar ingestão e
armazenamento de logs; definir orçamento e responsáveis. O bootstrap deve usar um
destino independente da aplicação, para não criar dependência circular do state.
Fornecer o ID apenas no arquivo local de variáveis da etapa aprovada.

Não configurar bypass de firewall automaticamente para atender ao scanner.
Categorias disponíveis, acesso ao destino e ingestão efetiva precisam de verificação
real. O operador deve realizar uma leitura/escrita/exclusão de objeto de teste e
confirmar registros em StorageBlobLogs após a execução aprovada, respeitando latência.
Ausência de logs deve impedir declarar auditoria operacional.

Desabilitar a configuração remove a coleta futura; retenção e eliminação do histórico
continuam sob controle do workspace. Uma auditoria desativada não corrige o finding
CKV2_AZURE_21. A preparação não equivale a logs entregues.

## Evidência local

Testes com mocks verificam zero diagnósticos por padrão e, quando habilitado,
destino explícito, recurso Blob e as três categorias. Não acessam Azure.

Referência: [diagnostic settings no provider fixado](https://github.com/hashicorp/terraform-provider-azurerm/blob/v4.14.0/website/docs/r/monitor_diagnostic_setting.html.markdown).
