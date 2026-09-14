# Convenções de nomes e tags

O orquestrador mantém `project_name-environment` como prefixo. Não houve mudança
nos formatos ou nos sufixos aleatórios de Storage/Key Vault.

| Recurso | Formato |
| --- | --- |
| Resource Group | rg-{projeto}-{ambiente} |
| VNet | vnet-{projeto}-{ambiente} |
| Subnet / NSG | snet/nsg-{camada}-{projeto}-{ambiente} |
| VM | vm-{índice}-{projeto}-{ambiente} |
| Storage | st{prefixo sem hífens}{sufixo aleatório de 6 caracteres} |
| Key Vault | kv-{prefixo sem hífens}{sufixo aleatório de 4 caracteres} |

O projeto deve começar com letra minúscula e conter apenas letras minúsculas,
números e hífens, com até 20 caracteres totais e 9 desconsiderando hífens.
O limite garante que Storage tenha no máximo 24 caracteres mesmo em staging:
2 (st) + 9 (projeto) + 7 (staging) + 6 (sufixo). Não garante disponibilidade global.
O bootstrap mantém suas próprias regras e nome explícito de Storage.

As tags efetivas são Environment, Project, ManagedBy e Owner, mais common_tags
opcionais dos roots DEV/PROD. Os nomes reservados, inclusive CreatedAt, são
ignorados nas tags extras independentemente da caixa. Isso evita sobrescrita da
governança. Tags são propagadas pelos módulos nos recursos que suportam tags.
Não usar senhas ou dados pessoais sensíveis em tags.

CreatedAt foi removida porque timestamp() mudava em cada execução. Não usamos
ignore_changes para esconder diferenças: o mapa agora deriva apenas de inputs
estáveis. Datas de criação podem ser consultadas no histórico operacional futuro.

Para instalações existentes, os formatos dos nomes válidos não mudam. Projetos
que violem as novas regras terão a validação bloqueada e precisarão de revisão;
não renomear automaticamente. Remover CreatedAt pode gerar uma atualização de
tags no próximo plano real. Nenhum plano real ou alteração Azure foi executado.

Os testes simulados conferem mapa completo de tags, precedência e nomes. Não
comprovam disponibilidade global de nomes nem propagação efetiva no Azure.
