# Acesso administrativo às VMs

Novas VMs usam chave pública RSA OpenSSH fornecida pelo operador. Não são geradas
senhas, chaves privadas ou secrets de compute. O default continua zero VMs.
Para habilitar uma VM, fornecer admin_ssh_public_key e admin_source_cidrs, uma
lista de hosts privados RFC1918 /32 aprovados. A regra SSH opcional só permite
TCP 22 desses hosts para App; Web/Data não recebem regra administrativa.

Isso prepara autenticação e filtragem, não entrega conectividade. O operador
precisará estar no host privado permitido e ter um caminho de rede aprovado
até a VM. Nenhum IP público, Bastion, VPN, peering ou jump host foi criado.
Não presumir que o IP privado doméstico do notebook funciona por Internet.
A estratégia real será decidida com custos e segurança antes do deploy final.

Os arquivos mock_rsa.pub são fixtures de testes, sem chave privada persistida,
gerados em memória. Nunca usar essa chave pública para deploy: não há chave
privada correspondente disponível. Não versionar chaves privadas do operador.

## Compatibilidade e segredos antigos

Trocar senha por chave pode exigir substituição da VM, conforme o plano/provider.
Não foi executado plano real. A chave privada permanece sob controle do operador.
Os outputs admin_password_secret_id são mantidos como null por compatibilidade.

Blocos removed com destroy=false substituem os antigos moved de senha/secret.
Em uma futura aplicação aprovada, eles deixam de gerenciar credenciais legadas
sem apagá-las implicitamente. Não executamos essa operação. Um secret existente
poderá permanecer no Key Vault e precisará de revogação/limpeza separada aprovada.
Backups antigos do state podem conter senhas; esta mudança não apaga o histórico.

O Key Vault continua no projeto como componente para futuros segredos de aplicação,
sem depender de senha de VM para justificar seu uso. O grant de roles para a
identidade das VMs não faz parte desta parcela.

Saída, instalação do Docker e acesso real por SSH não foram validados no Azure.
Testes simulados verificam apenas chave, ausência de senha/IP público e regras.
