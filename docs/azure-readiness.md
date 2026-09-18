# Ponto de parada antes do Azure

O código pode ser revisado sem assinatura. Este documento não autoriza execução.
Este roteiro registra a preparação original. A assinatura foi criada e uma sessão
temporária de backend e DEV foi executada e encerrada em 18/09/2026: veja
[resultados e limitações](azure-validation-2026-09-18.md). OIDC e PROD não foram executados.

## Preparado em código

DEV/PROD separados, backend e bootstrap, zero VMs por padrão, chave SSH, regras
de rede, RBAC do Key Vault, Storage restrito, auditoria opcional de blobs e CI com
fmt/validate/mocks/TFLint/Checkov. Veja [triagem de segurança](security-triage.md).
O [modelo de plan manual](templates/azure-plan.yml.example) está inativo, fora de
`.github/workflows`. Ele nunca executa apply, não salva plano nem publica artefato.

## Sequência depois de criar a assinatura

1. Confirmar tenant/subscription, benefícios, preços e região. Orçar recursos base,
   logs, discos, tráfego e retenção; zero VMs não significa custo zero. Definir data
   de remoção e plano de recuperação antes de qualquer deploy.
2. Decidir o caminho de rede do operador e do runner para Storage/state e Key Vault.
   Os defaults de firewall fechados não permitem presumir acesso. Runner hospedado
   não tem IP fixo pressuposto. Não liberar todas as redes para fazer o pipeline passar.
   Se não houver caminho aprovado, usar execução manual controlada do operador e
   adiar a ativação do modelo; não criar runner/NAT/Private Endpoint automaticamente.
3. Revisar a [recuperação](recovery-decision.md), os findings e o destino de auditoria.
   Escolher workspace e retenção antes de fornecer audit_workspace_id.
4. Preparar identidades e permissões de controle e dados com escopo mínimo. O
   bootstrap é uma operação privilegiada inicial separada da identidade do pipeline.
   Criar RG e criar recursos dentro de RG exigem escopos diferentes: definir isso
   explicitamente, sem conceder Owner da assinatura como atalho. A identidade de
   plan precisa de leitura dos recursos e acesso ao state compatível com locking;
   a de aplicação terá permissões distintas, revisadas após o plano.
5. Com aprovação específica, provisionar bootstrap, guardar seu state local em
   local protegido e testar recuperação. Só então inicializar backends de DEV/PROD;
   qualquer migração de state existente exige backup, plano e aprovação separados.
6. Configurar OIDC e proteções abaixo. Ativar o template em PR própria após verificar
   o CI do commit, rede e autorização. Executar primeiro plan do DEV, mantendo zero VMs.
7. Apresentar alterações e custos ao proprietário. Somente após aprovação explícita
   preparar a aplicação e, em seguida, verificar recursos, logs, acesso e locking.
   PROD não deve ser provisionado apenas para completar o portfólio.

## Contrato OIDC e GitHub

Criar os environments dev-plan e prod-plan com revisores obrigatórios e restrição
à branch main. Confirmar que esses controles estão disponíveis e realmente ativos
no repositório. Acionamento manual não equivale a aprovação de environment.

Para cada identidade, a federação deve usar issuer
`https://token.actions.githubusercontent.com`, audience `api://AzureADTokenExchange`
e subject exato `repo:brunokdalcastel/terraform-azure-infra:environment:dev-plan`
ou o correspondente prod-plan, sem wildcard. Validar configurações customizadas de
subject antes de assumir esse formato. Não criar client secret permanente.

Variáveis de cada environment: AZURE_CLIENT_ID, AZURE_TENANT_ID,
AZURE_SUBSCRIPTION_ID, PROJECT_NAME, PROJECT_OWNER, AZURE_LOCATION,
BACKEND_RESOURCE_GROUP e BACKEND_STORAGE_ACCOUNT. AZURE_EXECUTION_ENABLED deve
permanecer ausente/false no repositório até a aprovação de ativação. O template
usa OIDC pelo provider/backend Terraform e concede id-token:write só ao job de plan.

O primeiro modelo usa os defaults de acesso/auditoria e zero VMs. Ele não migra
state, não faz bootstrap e não configura workloads completos. Novos inputs reais
devem ser revisados junto à estratégia de rede; não colar tfvars secretos no YAML.
Restringir acesso aos logs e nunca exportar state ou planos sensíveis como artefatos
públicos do portfólio. Revisar outputs não marcados sensitive antes do primeiro plan.

## Aplicação futura

Não há workflow de apply ativo ou pronto para ativar nesta parcela. Seu desenho
depende do transporte privado do plano e das proteções reais disponíveis. Após
a assinatura, escolher entre aplicação manual pelo operador ou workflow protegido.
Em ambos os casos, aplicar exatamente o plano revisado: se estado, código ou
variáveis mudarem, gerar novo plano e obter nova aprovação. Não replanejar e aplicar
automaticamente após a revisão. Uma aplicação falha exige nova análise, não destroy
ou force-unlock automático. Destruição é uma autorização separada.

## Evidências que ainda faltam

Autenticação OIDC real; RBAC de dados/controle; acesso do runner ao backend; locking
com concorrência controlada; recuperação de state; plano aprovado; eventual
provisionamento; consultas dos logs; custos observados; conectividade privada SSH
se uma VM for habilitada. Até isso existir, apresentar o projeto como preparado e
testado estaticamente, não como plataforma Azure operacional.

Referências: [OIDC Azure no GitHub](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-azure)
e [claims OIDC](https://docs.github.com/en/actions/reference/security/oidc).
