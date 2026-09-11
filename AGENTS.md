# Regras do projeto

Este é um portfólio de engenharia Terraform/Azure para apresentar e defender em entrevistas.
Leia PROJECT_PLAN.md e implemente uma mudança lógica por branch/PR.
Documente decisões, evidências de validação e limitações reais. Não apresente
funcionalidades planejadas como implementadas ou infraestrutura como testada sem evidência.

## Autorização atual

- Implementação e validações locais/CI estão autorizadas.
- O proprietário ainda vai criar a conta Azure para este projeto.
- Não executar comandos contra Azure, autenticação Azure, plan com acesso Azure,
  bootstrap, migração de state, apply, destroy, import ou alterações de permissões.
- A execução Azure fica para a etapa final, após aprovação manual explícita do proprietário.
- Merge de código não autoriza deploy. Futuros workflows de deploy devem exigir
  acionamento manual e aprovação; não adicionar apply automático após merge.
- Não commitar secrets, states, planos salvos ou arquivos com valores reais.
- Não prometer gratuidade. Custos, região e SKU devem ser verificados antes do deploy.

## Validação sem Azure

Use a versão em .terraform-version. Execute na raiz terraform fmt -check -recursive;
em environments/dev use terraform init -backend=false -lockfile=readonly -input=false
e terraform validate. Esses comandos não exigem conta Azure; init baixa providers.
Preserve o lock file do root module. Reporte falhas e limitações sem marcar PASS indevidamente.
