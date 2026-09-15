# Revisão de recuperação antes do deploy

Esta revisão mantém o código atual e registra as decisões pendentes de operação.
Não aprova risco de perda de dados nem executa restore, purge ou migração.

| Componente | Configuração atual | Decisão necessária antes de uso real |
| --- | --- | --- |
| State | Storage LRS, versionamento, soft delete de blobs/containers por sete dias | Definir cópia protegida, acesso de emergência e teste de restauração/locking. LRS não é estratégia de recuperação regional. |
| Bootstrap | State local; prevent_destroy em recursos do backend | Definir custódia e backup fora do Git. prevent_destroy não impede remoção pelo portal ou remoção de blocos do código. |
| Storage da aplicação | LRS, soft delete por um dia, sem versionamento | Somente dados descartáveis de laboratório até escolher retenção, recuperação e orçamento adequados. Container backups não constitui backup implementado. |
| Key Vault DEV | Sete dias, purge protection desligada | Não armazenar segredos importantes antes de rever proteção contra purge. Essa escolha continua pendente, não é recomendação para produção. |
| Key Vault PROD | Sete dias, purge protection ligada | Validar recuperação e impacto na limpeza/nome antes de criar. Não confundir exclusão recuperável com purge. |
| Auditoria | Destino externo opcional, desabilitado por padrão | Definir retenção no workspace e responsáveis por consulta/recuperação; diagnóstico não substitui backup dos dados. |

A primeira execução deve usar somente dados de teste. Mudanças de proteção e
retenção devem ser apresentadas em plano antes de qualquer aplicação. O runbook
de restore real será fechado com IDs, permissões e testes da assinatura; não declarar
RPO/RTO atingidos com base apenas em configuração e mocks.

Evidências: [bootstrap](../bootstrap/backend/main.tf), [Storage](../modules/storage/main.tf)
e [Key Vault](../modules/security/main.tf).
