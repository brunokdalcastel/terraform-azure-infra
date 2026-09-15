# Triagem dos findings de segurança

Data: 2026-09-15. Baseline Checkov 3.2.495 da parcela de segurança: 49 checks
aprovados, 20 findings, zero skips e zero erros de parsing. A PR #14 passou no CI.
Esta triagem reaproveita o relatório local existente; não é um novo scan.

São **20 ocorrências de 11 regras**, não 20 vulnerabilidades independentes.
O scan agrega módulos compartilhados: essa contagem não equivale a inventário
de recursos implantados ou evidência separada de DEV e PROD. Nenhum recurso foi
provisionado. Os IDs e contagens são conferidos no [inventário](security-findings.csv).

## Classificação e tratamento

“Decisão do laboratório” significa proposta fundamentada para revisão, não uma
exceção de segurança aprovada para deploy. Todos os findings continuam visíveis.
O proprietário revisará os riscos antes da primeira execução; não há skips novos.

| Regra | Ocorrências e alvo | Classificação | Evidência e próximo tratamento |
| --- | --- | --- | --- |
| CKV_AZURE_36 | 2: Storage da aplicação e state | Decisão do laboratório | Ambos usam bypass None. Não habilitar serviços confiáveis apenas para satisfazer o scanner; adicionar exceção somente para integração identificada e revisada. |
| CKV_AZURE_59 | 2: Storage da aplicação e state | Depende da estratégia de acesso Azure | O check exige public_network_access_enabled=false; não trata apenas acesso anônimo. Endpoint público está habilitado com firewall Deny e containers privados. Validar rede do executor e decidir acesso público restrito versus Private Endpoint antes de provisionar. |
| CKV_AZURE_33 | 2: Storage da aplicação e state | Aplicabilidade a confirmar | O check trata logging do serviço Queue. O projeto não declara filas. Confirmar que Queue não será usado; se houver uso, preparar auditoria apropriada. Não confundir com logging de blobs. |
| CKV_AZURE_206 | 2: Storage da aplicação e state | Decisão do laboratório | Código usa LRS; a regra exige uma das opções GRS/RAGRS/GZRS/RAGZRS. Não significa ausência de replicação. Rever recuperação regional e custo antes de aceitar LRS, especialmente para state. |
| CKV_AZURE_160 | 1: NSG Web | Correção de código proposta | Há Allow de Internet para TCP 80 sem aplicação ou redirecionamento implementados. Próxima PR deve remover essa permissão não utilizada e ajustar os testes de rede; qualquer reintrodução exige caso de uso explícito. |
| CKV_AZURE_110 | 1: Key Vault | Decisão por ambiente pendente | Purge protection está desligada em DEV e ligada em PROD. Rever a escolha de DEV antes de criar o cofre; teste com mocks já verifica a opção de PROD, mas não há evidência Azure. |
| CKV_AZURE_42 | 1: Key Vault | Mesmo tratamento de CKV_AZURE_110 | A implementação do check exige purge protection. Retenção de sete dias no código não satisfaz essa condição. Tratar junto à regra anterior, sem contabilizar como decisão independente. |
| CKV2_AZURE_32 | 1: Key Vault | Depende da estratégia de acesso Azure | Private Endpoint não implementado. Firewall Deny não é equivalente. Definir conectividade, DNS, executor e custo antes de decidir a solução. |
| CKV2_AZURE_33 | 2: Storage da aplicação e state | Depende da estratégia de acesso Azure | Private Endpoints não implementados. Tratar com CKV_AZURE_59; não desligar o endpoint público sem preparar o caminho de acesso ao state. |
| CKV2_AZURE_1 | 2: Storage da aplicação e state | Decisão do laboratório | CMK não está configurada. O finding não prova armazenamento sem criptografia. Não adicionar gestão de chaves apenas para obter PASS; justificar requisitos e dependências de recuperação, sobretudo do state, antes de adotar CMK. |
| CKV2_AZURE_21 | 4: containers state, data, logs e backups | Lacuna de auditoria a tratar | Não há configuração de auditoria de leitura de blobs. Um container chamado logs não implementa logging. Preparar desenho de diagnóstico, destino e retenção em PR própria; estimar custo e validar a entrega real somente na etapa Azure aprovada. |

## Evidências do repositório

- [Storage da aplicação](../modules/storage/main.tf) e [bootstrap](../bootstrap/backend/main.tf): firewall, acesso público, replicação e containers.
- [Rede](../modules/network/main.tf): permissão HTTP; [testes de rede](../environments/dev/tests/network.tftest.hcl).
- [Key Vault](../modules/security/main.tf) e [testes](../environments/dev/tests/key_vault.tftest.hcl): proteção por ambiente.
- [Política do scanner](security-ci.md): três IDs bloqueantes e limites conhecidos.

## Ordem das próximas parcelas

1. Remover HTTP de entrada sem uso, com teste de regressão e PR própria.
2. Preparar auditoria de blobs e revisar proteção de recuperação por ambiente.
3. Definir rede do executor e permissões antes de OIDC e execução manual.

Esta PR apenas registra a triagem: não corrige os recursos, não aceita riscos
automaticamente e não altera a lista de regras bloqueantes. O encerramento de um
item deve apontar a PR de tratamento e, quando necessário, evidência real aprovada.

## Preparação posterior à triagem

HTTP 80 removido na PR #16. Auditoria de blobs agora possui [configuração opcional](blob-audit.md), ainda desativada por padrão; a validação real continua pendente. O inventário acima preserva o baseline histórico.
