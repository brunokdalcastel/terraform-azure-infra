# Segmentação de entrada por NSG

| Destino | Origem permitida | TCP |
| --- | --- | --- |
| Web | Service tag Internet | 80, 443 |
| App | Prefixos configurados da subnet Web | 8080, 8443 |
| Data | Prefixos configurados da subnet App | 1433, 3306, 5432 |

Cada NSG termina com DenyAllInbound na prioridade 4096, antes da regra padrão
AllowVNetInBound do Azure. As origens e destinos internos derivam dos inputs
das subnets, sem CIDRs fixos nas regras. Os formatos dos nomes e associações
NSG/subnet são preservados. Defaults de endereçamento dos ambientes não mudam.

Não há regra SSH habilitada. O caminho administrativo será preparado em outra
parcela com origem explícita; o projeto ainda não está pronto para acesso real
às VMs. Em um ambiente existente, esta alteração pode interromper novas conexões
SSH, acesso entre pares na mesma camada e fluxos não listados. Não foi aplicada.

Não há regra de health probe para Azure Load Balancer: esse serviço não está
implementado e precisará de revisão própria se for adicionado. Permitir 80/443
no NSG não cria IP público, rota, aplicação ou endpoint Web.

Esta parcela trata somente entrada. As regras padrão de saída permanecem; DNS,
egress para instalar Docker e acesso a serviços serão revisados antes do deploy.
NSGs são stateful; conexões estabelecidas podem persistir após mudanças das regras.
Os testes verificam as regras declaradas com outro CIDR usando mocks; não testam
tráfego ou estado de conexões no Azure. Validação real requer aprovação final.

Referência: [NSGs e filtragem de tráfego](https://learn.microsoft.com/azure/virtual-network/network-security-group-how-it-works).
