# Apresentação do portfólio

## Abertura de um minuto

“Preparei uma infraestrutura Azure em Terraform, com módulos reutilizáveis,
ambientes separados e evolução por PRs. O foco foi tornar mudanças revisáveis:
defaults conservadores de custo, testes simulados e verificações de qualidade e
segurança no CI. Ainda não fiz deploy: separei explicitamente o que o código
garante do que precisa de conta, rede e validação real no Azure.”

## Demonstração

1. Mostrar no README o estado real e os módulos. Explicar que três subnets não
   representam uma aplicação completa em produção.
2. Abrir uma PR de segurança e seus testes: por exemplo, remoção de HTTP ou SSH
   somente por chave e hosts privados explícitos.
3. Mostrar um CI aprovado e explicar fmt, validate, mocks, TFLint e a lista limitada
   de checks bloqueantes. Mostrar a triagem, incluindo riscos ainda não resolvidos.
4. Explicar separação dos states e ciclo de vida do bootstrap. Apontar que locking
   remoto e recuperação ainda não foram testados.
5. Encerrar com o plano de ativação manual e evidências que serão coletadas após
   criar a assinatura. Não apresentar o template OIDC como autenticação já funcionando.

## Decisões para defender

- Por que zero VMs? Exige intenção explícita antes de incluir compute; não elimina
  custos dos outros serviços.
- Por que não eliminar todos os alertas? Alguns exigem contexto e custo; evitar
  supressões sem análise é parte da revisão. Check verde não significa seguro por completo.
- Por que backend separado? O state tem ciclo de vida e recuperação diferentes da aplicação.
- Por que não fazer deploy após merge? Aprovar código não aprova custo e operação.
- O que falta comprovar? OIDC, permissões, conectividade, locking, recuperação,
  entrega de logs e comportamento dos recursos reais.

Use somente capturas e resultados reais, sem IDs sensíveis, state, chaves ou planos
salvos. Depois da execução aprovada, acrescente evidências e atualize esta narrativa.
