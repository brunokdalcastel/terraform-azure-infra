# Segmentação de entrada por NSG

| Destino | Origem permitida | TCP |
| --- | --- | --- |
| Web | Service tag Internet | 443 |
| App | Prefixos configurados da subnet Web | 8080, 8443 |
| App (opcional) | Hosts privados RFC1918 /32 explícitos | 22 |
| Data | Prefixos configurados da subnet App | 1433, 3306, 5432 |

Cada NSG termina com DenyAllInbound na prioridade 4096, antes da regra padrão
AllowVNetInBound do Azure. As origens e destinos internos derivam dos inputs
das subnets, sem CIDRs fixos nas regras. Os formatos dos nomes e associações
NSG/subnet são preservados. Defaults de endereçamento dos ambientes não mudam.

A regra SSH fica desabilitada por padrão e exige hosts privados /32 explícitos.
A conectividade administrativa ainda precisa ser preparada; veja [acesso às VMs](vm-access.md).
As regras podem interromper conexões entre pares e fluxos não listados em um
ambiente existente. As regras foram provisionadas e consultadas na sessão DEV;
não houve teste de tráfego entre VMs. Veja as [evidências](azure-validation-2026-09-18.md).

Não há regra de health probe para Azure Load Balancer: esse serviço não está
implementado e precisará de revisão própria se for adicionado. Permitir 443
no NSG não cria IP público, rota, aplicação ou endpoint Web.

Esta parcela trata somente entrada. As regras padrão de saída permanecem; DNS,
egress para instalar Docker e acesso a serviços serão revisados antes do deploy.
NSGs são stateful; conexões estabelecidas podem persistir após mudanças das regras.
Os testes verificam as regras declaradas com outro CIDR usando mocks; não testam
tráfego ou estado de conexões no Azure. Validação real requer aprovação final.

Referência: [NSGs e filtragem de tráfego](https://learn.microsoft.com/azure/virtual-network/network-security-group-how-it-works).

HTTP 80 foi removido por não haver aplicação ou redirecionamento que o utilize. Uma futura reintrodução exige revisão. Em infraestrutura existente, a alteração interromperia novas conexões HTTP; na sessão DEV, a configuração final foi provisionada.
