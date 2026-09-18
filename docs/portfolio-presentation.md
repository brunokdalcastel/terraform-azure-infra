# Apresentação e defesa do portfólio

## Abertura de um minuto

“Desenvolvi um laboratório de infraestrutura Azure com Terraform, módulos
reutilizáveis e mudanças revisadas por Pull Requests. Configurei CI com validação,
testes simulados, lint e verificações de segurança. Em uma sessão autorizada,
provisionei o backend e o DEV sem máquinas virtuais, validei acesso com Entra ID,
RBAC, firewall e recuperação de blobs. Um novo plan não indicou mudanças.
Depois removi os recursos e conferi o inventário da assinatura. O foco do projeto
é demonstrar infraestrutura reproduzível, decisões de segurança e controle do
ciclo de vida; PROD e OIDC ainda são evoluções planejadas.”

Use essa fala como guia. Este é um laboratório de portfólio; não atribua a ele
experiência de operação de uma aplicação em produção.

## Demonstração de cinco minutos, sem deploy

| Tempo | O que mostrar | O que explicar |
| --- | --- | --- |
| 0–1 min | [README](../README.md) e [arquitetura](architecture.md) | DEV/PROD no código, módulos e ausência de aplicação ou banco implantado |
| 1–2 min | [Backend](../bootstrap/backend/README.md) e [DEV](../environments/dev/README.md) | State remoto, autenticação Entra ID e ciclo de vida separado do backend |
| 2–3 min | [PR #19](https://github.com/brunokdalcastel/terraform-azure-infra/pull/19) e seus checks | Evidências revisáveis, CI e diferença entre mocks e testes reais |
| 3–4 min | [Relatório da sessão](azure-validation-2026-09-18.md) | Negação antes de RBAC, acesso após role, firewall e recuperação de blob |
| 4–5 min | Encerramento do relatório e [triagem](security-triage.md) | Limpeza, retenção do Key Vault, custo ainda sujeito a atualização e próximos testes |

Abra as páginas antes da entrevista. A demonstração usa código e evidências
sanitizadas; não depende de recursos ativos. Não abra state, tfvars reais, planos
salvos ou telas com credenciais. Se pedirem um deploy ao vivo, explique que ele
exige nova revisão de custo, permissões e autorização.

## Perguntas para treinar

**Qual problema o projeto resolve?**

Organiza a criação e remoção de infraestrutura em código versionado, com parâmetros,
revisão por PR e validações repetíveis. Não entrega uma aplicação de negócio pronta.

**Por que separar o bootstrap da aplicação?**

O backend guarda o state usado para administrar o DEV. Ele precisa existir antes
da inicialização remota e sobreviver até a remoção da aplicação e exportação do
state final. As proteções prevent_destroy continuam no código versionado; a limpeza
autorizada usou uma cópia isolada com essas proteções desativadas.

**Owner não pode acessar tudo?**

Na sessão, o usuário com Owner recebeu negação ao tentar acessar dados. Foram
necessárias roles específicas: Storage Blob Data Contributor no container e
Key Vault Secrets Officer no cofre. Elas foram temporárias e removidas no final.
Isso demonstrou a separação entre administrar recursos e acessar seus dados.

**Como comprovou o locking?**

Observei o state leased/locked durante o apply. Também adquiri um lease em blob
sintético e confirmei que uma escrita sem o lease falhou; após liberá-lo, a escrita
funcionou. Não executei dois applies concorrentes, portanto não afirmo ter feito
esse ensaio completo.

**Testou recuperação de desastre?**

Recuperei uma versão de blob sintético e fiz delete/undelete com comparação de
hash. Isso comprova esses mecanismos de blobs, mas não um restore completo do
state nem metas de RPO/RTO. Esse exercício continua pendente.

**Como validou a rede sem VMs?**

Conferi as regras dos NSGs e testei o firewall do Storage retirando temporariamente
o IP autorizado. Após propagação, houve negação; restaurar a regra restabeleceu o
acesso. Não testei tráfego entre subnets nem SSH.

**Por que zero VMs e por que não manter tudo ligado?**

O escopo inicial validava infraestrutura e acesso a serviços sem precisar de compute.
Remover o laboratório reduziu exposição e consumo contínuo. Zero VMs não significa
custo zero: Storage e operações também precisam ser considerados.

**O orçamento impede cobrança?**

Não. O orçamento mensal de R$ 50 gera alertas. Na sessão, o spending limit da
assinatura estava On; é um controle separado. O inventário ficou vazio, mas o
consumo já realizado pode aparecer depois. Não prometo custo final zero.

**CI verde significa infraestrutura segura e funcionando?**

Não. Mocks verificam comportamentos planejados sem Azure. O Checkov bloqueia um
conjunto selecionado de verificações; outros findings estão documentados na triagem.
Permissões, propagação e comportamento real exigiram testes na assinatura.

**DEV e PROD estão isolados? OIDC está funcionando?**

Há roots e chaves de state distintos no código. Só DEV foi executado; isolamento
de permissões contra PROD ainda não foi comprovado. Existe um template inativo de
plan manual com OIDC, mas não uma integração OIDC operacional.

**Como usou IA no projeto?**

“Usei o Codex como apoio para implementar, validar e documentar mudanças. Revisei
as decisões e autorizei a execução Azure. Na apresentação, separo o que consigo
explicar e demonstrar do que ainda preciso estudar ou validar.”

Adapte essa resposta à sua participação real. Treine explicando uma PR, uma regra
de rede e uma evidência sem depender de uma resposta pronta.

## Critério de preparação para a entrevista

Você está pronto para demonstrar esta etapa quando conseguir explicar o caminho
DEV → módulos → recursos, a função do state, uma falha de permissão observada e
como comprovou a limpeza. Termine com uma evolução concreta: validar OIDC com
permissões mínimas e execução manual aprovada, antes de ampliar o escopo.

Pendências operacionais: conferir o custo após atualização do faturamento e, em
uma consulta autorizada após a data prevista, verificar a retenção do Key Vault.
Este roteiro não agenda consultas nem autoriza novas operações Azure.
