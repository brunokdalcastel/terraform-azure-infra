# TFLint

O CI usa TFLint 0.64.0 com o preset recommended do ruleset Terraform incluído no binário. A configuração exige essa versão. A action de instalação está fixada por commit.

Na raiz do repositório, com TFLint 0.64.0 instalado:

```powershell
tflint --init
tflint --recursive --config "$PWD/.tflint.hcl" --format compact
```

Em Bash, use `--config "$(pwd)/.tflint.hcl"`. O caminho absoluto compartilha a mesma configuração entre os diretórios. A execução recursiva cobre roots e módulos; call_module_type=none evita percorrer novamente os módulos a partir de cada chamada. Não requer autenticação Azure ou inicialização do backend.

Qualquer finding retorna falha no job TFLint; não há force, soft-fail ou regras suprimidas. Tornar esse check obrigatório para merge depende da proteção de branch no GitHub, não configurada nesta parcela.

Esta etapa verifica regras genéricas Terraform. Não inclui ruleset AzureRM e não substitui validate, testes com mocks, Checkov ou validação real de permissões e conectividade.

O primeiro lint identificou o input environment sem uso no módulo Storage. Ele foi removido; o orquestrador não o enviava. Consumidores externos desse módulo precisam deixar de passar esse argumento. Não há mudança de configuração dos recursos.

Referências: [configuração oficial](https://github.com/terraform-linters/tflint/blob/v0.64.0/docs/user-guide/config.md) e [instalação no CI](https://github.com/terraform-linters/setup-tflint).
