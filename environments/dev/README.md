# Backend remoto DEV — configuração preparada

`backend.tf` declara AzureRM com autenticação Entra ID e chave
`dev.terraform.tfstate`, no container `tfstate`. As coordenadas do Storage são
parciais; `backend.tfbackend.example` contém apenas exemplos, não é carregado
automaticamente e não contém credenciais. Uma futura cópia `backend.tfbackend`
com os nomes reais fica ignorada pelo Git.

**Nenhum Storage foi provisionado, nenhum state foi migrado e o locking real não
foi testado.** O bootstrap mantém seu backend local independente.

## Validação permitida agora

Na raiz do repositório:

```bash
terraform fmt -check -recursive
terraform -chdir=environments/dev init -backend=false -lockfile=readonly -input=false
terraform -chdir=environments/dev validate
terraform -chdir=environments/dev test
```

O CI mantém esses mesmos comandos, com providers simulados nos testes. Eles não
autenticam no backend nem comprovam acesso, persistência ou locking no Azure.
Não executar `init` sem `-backend=false` nesta etapa.

## Decisões e limites

- Autenticação do backend é independente do provider AzureRM. Não colocar chaves,
  SAS ou client secrets em HCL, arquivo de backend ou argumentos de CLI.
- OIDC será configurado em outra parcela. Nenhum login é feito por esta mudança.
- A chave identifica DEV; outro ambiente precisará de chave própria. Chaves
  diferentes não isolam permissões dentro do mesmo container.
- A identidade futura precisará de acesso aos blobs, preferindo Storage Blob
  Data Contributor no container. A configuração de rede do bootstrap também
  precisa permitir o caminho do executor. Nada disso está provisionado.

## Condições para a etapa final

Após aprovação manual, será necessário provisionar o bootstrap, confirmar as
coordenadas e revisar autenticação, permissões e rede. O arquivo de coordenadas
será fornecido à inicialização por `-backend-config`; não usar os placeholders.

Se houver state local real, preservar backup seguro e revisar sua origem, destino
e conteúdo antes de uma migração aprovada. Não usar `-reconfigure` como substituto
da migração, não forçar cópia e não apagar o state antigo durante esta preparação.
Se não houver state, a inicialização futura será de um backend novo, sem migração.

Aceite futuro: confirmar persistência no blob correto, locking entre execuções
concorrentes e recuperação. Remover ou reverter o bloco HCL não traz state remoto
de volta automaticamente; qualquer retorno exigirá revisão específica.

Referência: [backend AzureRM](https://developer.hashicorp.com/terraform/language/backend/azurerm).
