# Controle de custos do laboratório

## Decisão

DEV inicia com `vm_count = 0`. É necessário escolher explicitamente `1` para
incluir uma VM. Os SKUs permitidos são `Standard_B1s` e `Standard_B2s`, candidatos
para testes pequenos, sem promessa de gratuidade ou disponibilidade regional.
Outros SKUs exigem mudança da política em PR. Storage DEV fica em Standard LRS.

Esses limites pertencem ao ambiente DEV. Os módulos reutilizáveis não limitam a
quantidade de VMs a uma: outros ambientes precisam definir suas próprias políticas.

## O que zero VMs significa

O plano deixa de incluir VMs, NICs, senha aleatória e secret de compute. Resource
Group, rede, Storage e Key Vault continuam no código. Portanto zero VMs não é
custo zero caso o restante seja provisionado. No estado atual, nenhum comando
contra Azure é autorizado e nenhuma conta é necessária para os testes locais.

| Categoria | Recursos e tratamento |
| --- | --- |
| Base | Resource Group, VNet, subnets e NSGs; confirmar serviços associados |
| Consumo variável | Storage, operações do Key Vault e tráfego; medir após deploy aprovado |
| Temporário | VM, disco de SO e diagnósticos; usar somente durante testes aprovados |
| Não provisionado | Bastion, NAT Gateway, Firewall, AKS, bancos gerenciados |

Parar o sistema operacional não equivale a desalocar a VM; discos podem continuar
gerando cobrança mesmo após desalocação. Não há automação de shutdown/destroy nesta PR.
Veja [preços de VMs](https://azure.microsoft.com/pricing/details/virtual-machines/linux/)
e [preços de discos](https://azure.microsoft.com/pricing/details/managed-disks/).

## Limites da validação

Os testes em `environments/dev/tests` usam providers simulados e somente `plan`.
Eles verificam defaults, propagação de configuração e rejeição de inputs fora da
política. Não consultam Azure e não comprovam preços, quotas ou disponibilidade.
Referência: [Terraform provider mocking](https://developer.hashicorp.com/terraform/language/tests/mocking).

## Antes da execução final aprovada

Revisar assinatura/benefícios, região, disponibilidade do SKU, preço por hora,
discos, armazenamento, operações, tráfego, tempo de teste e plano de remoção.
Configurar orçamento e alertas quando houver conta; alertas não são um teto de gastos.
Apresentar o plano real e a estimativa ao proprietário antes de executar.

## Compatibilidade com infraestrutura existente

O default mudou de uma VM D2s_v3 para zero VMs. Em um ambiente já provisionado,
essa alteração pode propor destruição. Redefinir `vm_count = 1` e revisar o SKU
antes de qualquer plano/aplicação real. Mudança de SKU também pode afetar a VM.
Os blocos `moved` preservam os endereços da senha e do secret quando compute
continua habilitado; não evitam destruição quando a quantidade muda para zero.
Nenhuma migração real ou alteração de state foi executada nesta etapa.

## Para defender em entrevista

O controle é preventivo: defaults conservadores e validação impedem expansão
acidental pelo arquivo de variáveis. A revisão por PR torna mudanças da política
visíveis. Essa política de código complementa, mas não substitui, budgets, alertas,
Azure Policy e medição de consumo em um ambiente real.
