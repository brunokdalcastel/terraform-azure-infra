# Contribuindo

Obrigado pelo interesse em contribuir com este projeto!

## Como Contribuir

1. Faça um fork do repositório
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Faça commit das suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. Faça push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## Padrões de Código

### Terraform

- Use `terraform fmt` antes de commitar
- Siga a [convenção de nomenclatura do Azure](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- Documente todas as variáveis e outputs
- Use `validation` blocks para validar inputs

### Commits

Use mensagens de commit descritivas:

```
feat: adiciona suporte a múltiplas regiões
fix: corrige erro na criação do NSG
docs: atualiza README com novos exemplos
refactor: simplifica módulo de network
```

## Estrutura de Branches

- `main` - Código estável e testado
- `develop` - Desenvolvimento ativo
- `feature/*` - Novas funcionalidades
- `fix/*` - Correções de bugs

## Reportando Bugs

Ao reportar um bug, inclua:

1. Versão do Terraform (`terraform version`)
2. Versão do Azure Provider
3. Descrição do problema
4. Passos para reproduzir
5. Output do erro (se aplicável)

## Sugestões

Sugestões são bem-vindas! Abra uma issue descrevendo sua ideia.
