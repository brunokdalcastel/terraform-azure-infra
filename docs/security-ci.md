# Política inicial de segurança no CI

Checkov 3.2.495 está fixado em `.github/requirements-security.txt`. A configuração
`.checkov.yml` executa análise Terraform sem downloads de diretrizes externas.
Não usa credenciais Azure ou API key do scanner.

| ID bloqueante | Regressão detectada |
| --- | --- |
| CKV_AZURE_34 | Container Storage com acesso público |
| CKV_AZURE_35 | Regra padrão de rede Storage configurada como Allow |
| CKV_AZURE_44 | Versão TLS do Storage abaixo de TLS 1.2 |

Somente falhas nesses IDs bloqueiam por política; erros de execução também não
são ignorados. Os outros findings permanecem no relatório, sem supressões.
Isso não configura proteção de branch obrigatória no GitHub.

## Reprodução

Em ambiente Python 3.12 isolado, na raiz do repositório:

```bash
python -m pip install -r .github/requirements-security.txt
checkov --directory . --config-file .checkov.yml
```

No Windows, definir `PYTHONUTF8=1` antes da execução para ler os arquivos UTF-8.
Dependências transitivas não possuem lock completo nesta parcela.

## Evidência e limites

Baseline local: 49 checks aprovados, 20 findings não bloqueantes, zero skips e
zero erros de parsing; exit 0. Três configurações inseguras temporárias, uma por
regra, verificam retorno 1 e o ID esperado. Nenhum recurso foi provisionado.

A regra CKV_AZURE_35 pode retornar UNKNOWN quando falta o bloco de rede: ela não
garante por si só a presença do firewall. Os testes Terraform existentes verificam
a configuração declarada. A regra de HTTPS CKV_AZURE_3 desta versão inspeciona o
atributo antigo e não foi incluída no bloqueio; não tratamos seu PASS como evidência
do atributo atual. O escopo não cobre toda a segurança Azure.

Os 20 findings restantes precisam de triagem em parcelas próprias; não representam
exceções aprovadas nem ausência de risco. Novas regras bloqueantes exigem revisar
o código avaliado e testar uma regressão deliberada antes de ampliar a lista.

Referência: [semântica oficial de hard/soft fail](https://www.checkov.io/2.Basics/Hard%20and%20soft%20fail.html).
