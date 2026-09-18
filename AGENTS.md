# Regras do projeto

Este é um portfólio de engenharia Terraform/Azure para apresentar e defender em entrevistas.
Leia PROJECT_PLAN.md e implemente uma mudança lógica por branch/PR.
Documente decisões, evidências de validação e limitações reais. Não apresente
funcionalidades planejadas como implementadas ou infraestrutura como testada sem evidência.

## Autorização atual

- Implementação e validações locais/CI estão autorizadas.
- A conta Azure foi criada. A sessão autorizada de backend e DEV sem VMs em
  18/09/2026 foi encerrada com limpeza; veja docs/azure-validation-2026-09-18.md.
- Novas execuções contra Azure (incluindo plan remoto, apply, destroy, import e
  alterações de permissões) exigem autorização explícita do proprietário.
- Merge de código não autoriza deploy. Futuros workflows de deploy devem exigir
  acionamento manual e aprovação; não adicionar apply automático após merge.
- Não commitar secrets, states, planos salvos ou arquivos com valores reais.
- Não prometer gratuidade. Custos, região e SKU devem ser verificados antes do deploy.

## Validação sem Azure

Use a versão em .terraform-version. Execute na raiz terraform fmt -check -recursive;
em environments/dev use terraform init -backend=false -lockfile=readonly -input=false
e terraform validate. Esses comandos não exigem conta Azure; init baixa providers.
Preserve o lock file do root module. Reporte falhas e limitações sem marcar PASS indevidamente.

O bootstrap/backend é um root module independente. Também validar com init
-backend=false -lockfile=readonly, validate e terraform test. Os testes de ambos
os roots usam mocks e somente command=plan; não substituir por providers reais.

environments/prod segue a mesma validação offline e possui lock file e chave de
state próprios. Não inicializar seu backend remoto nesta etapa.
