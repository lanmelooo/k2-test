🟦 TC – MDPO-4003 – Geração de Pix Dinâmico – Santander
DESCRIPTION

Validar que o Orquestrador envie a cobrança Pix para a API de Geração Dinâmica do Santander, receba Txid, QR Code Base64 e Payload Copia e Cola e registre a transação com status GERADO.

PRECONDITIONS

Ambiente TST

Orquestrador Pix ativo

API COBV Santander disponível

Autenticação OAuth 2.0 habilitada

Cobrança Pix válida (valor, vencimento, pagador, recebedor, juros, multa)

Cobrança inexistente previamente na base

TEST DETAILS (Cucumber)
Funcionalidade: Geração de Pix Dinâmico no Santander

  Contexto:
    Dado que exista uma requisição válida de cobrança Pix
    E que o Orquestrador tenha token OAuth 2.0 válido
    E que a API COBV do Santander esteja disponível

  Cenário: Gerar Pix Dinâmico com sucesso
    Quando o Orquestrador enviar a cobrança ao Santander
    Então o Santander deve retornar Txid, QR Code Base64 e Payload Copia e Cola
    E o Orquestrador deve registrar o status GERADO
    E deve retornar os dados ao cliente

  Cenário: Respeitar dados enviados pelo cliente
    Quando o Orquestrador montar o payload para o Santander
    Então o valor, juros, multa, pagador e recebedor devem ser respeitados

  Cenário: Santander indisponível
    Quando o Orquestrador tentar enviar a cobrança ao Santander
    Então deve retornar mensagem clara de indisponibilidade

  Cenário: Falha na autenticação OAuth
    Quando o token não puder ser obtido
    Então o Orquestrador deve falhar a geração da cobrança

🟦 TC – MDPO-4004 – Cancelamento de Pix – Santander
DESCRIPTION

Validar que o Orquestrador envie o pedido de cancelamento da cobrança Pix ao Santander, receba a confirmação e atualize o status para BAIXADO.

PRECONDITIONS

Ambiente TST

Cobrança existente com status GERADO ou PENDENTE

Txid registrado internamente

API COBV Santander ativa

Token OAuth 2.0 válido

Regra de 3 tentativas habilitada

TEST DETAILS (Cucumber)
Funcionalidade: Cancelamento de Pix no Santander

  Contexto:
    Dado que exista uma cobrança Pix ativa registrada
    E que o Orquestrador possua o Txid da cobrança
    E que a API de cancelamento do Santander esteja ativa

  Cenário: Cancelar Pix com sucesso
    Quando o Orquestrador enviar o cancelamento ao Santander
    Então o status interno deve ser atualizado para BAIXADO
    E a data/hora local deve ser registrada

  Cenário: Santander retorna Pix já pago
    Quando o Santander informar que o Pix já está pago
    Então o Orquestrador deve manter o status atual
    E devolver a mesma mensagem ao cliente

  Cenário: Santander retorna Pix já cancelado
    Quando o banco informar que o Pix já está cancelado
    Então o Orquestrador deve apenas retornar a mensagem ao cliente

  Cenário: Santander indisponível (3 tentativas)
    Quando o Santander estiver indisponível
    Então o Orquestrador deve tentar até 3 vezes
    E deve retornar erro ao cliente após falha das tentativas

🟦 TC – MDPO-4005 – Liquidação via Webhook – Santander
DESCRIPTION

Validar que o Orquestrador receba o Webhook do Santander, valide a origem, atualize o status da cobrança para PAGO e registre data/hora local.

PRECONDITIONS

Ambiente TST

Endpoint de Webhook registrado no Santander

Cobrança com status GERADO ou ATIVA

Mecanismo de autenticação da origem ativo

Message Queue configurada

Log habilitado

TEST DETAILS (Cucumber)
Funcionalidade: Processamento de Webhook de Liquidação - Santander

  Contexto:
    Dado que o endpoint de Webhook esteja configurado
    E que exista uma cobrança Pix com Txid registrado
    E que o Orquestrador valide a autenticidade das notificações

  Cenário: Processar Webhook de liquidação com sucesso
    Quando o Santander enviar o status CONCLUIDA
    Então o Orquestrador deve atualizar o status para PAGO
    E registrar data/hora local da liquidação
    E publicar evento na fila de mensagens

  Cenário: Status ATIVA não altera a transação
    Quando o Santander enviar status ATIVA
    Então o status interno deve permanecer inalterado

  Cenário: Webhook inválido
    Quando o payload estiver corrompido ou inválido
    Então o Orquestrador deve registrar erro e retornar 400

  Cenário: Falha de autenticação do Webhook
    Quando a autenticação falhar
    Então o Orquestrador deve responder 401 Unauthorized

🟦 TC – MDPO-4006 – Scheduler · Consulta de Status – Santander
DESCRIPTION

Validar que o Scheduler consulte o status das cobranças no Santander nos horários definidos e atualize corretamente o status interno conforme as regras de mapeamento.

PRECONDITIONS

Ambiente TST

Scheduler configurado (7h00 e 20h30)

Cobranças com status PENDENTE ou GERADO

Txid armazenado

Credenciais e certificados válidos

Circuit Breaker configurado

Regras de status definidas: ATIVA, CONCLUIDA, REMOVIDO_PELO_USUARIO_RECEBEDOR, REMOVIDO_PELO_PSP

TEST DETAILS (Cucumber)
Funcionalidade: Scheduler de Consulta do Status do Pix - Santander

  Contexto:
    Dado que existam cobranças pendentes ou geradas
    E que cada cobrança possua um txid do Santander
    E que o scheduler esteja configurado para executar em horários definidos

  Cenário: Atualizar para PAGO quando Santander retornar CONCLUIDA
    Quando o scheduler consultar o Santander
    Então o status interno deve ser atualizado para PAGO
    E a data/hora local deve ser registrada

  Cenário: Status ATIVA não altera
    Quando o Santander retornar ATIVA
    Então o status interno não deve ser alterado

  Cenário: Atualizar para BAIXADO quando retorno for remoção
    Quando o Santander retornar REMOVIDO_PELO_USUARIO_RECEBEDOR ou REMOVIDO_PELO_PSP
    Então o status deve ser atualizado para BAIXADO
    E registrar a data/hora local

  Cenário: Processo idempotente
    Dado que o status interno já seja finalizado
    Quando o scheduler executar nova consulta
    Então o status não deve ser modificado

  Cenário: Santander indisponível
    Quando ocorrer falha na chamada ao banco
    Então o Circuit Breaker deve impedir novas chamadas
    E o Orquestrador deve registrar erro


    ---------------------------------------------------------------------------------------------------------------


    🟦 TC — MDPO-4003 · Geração de Pix Dinâmico – Santander
Cenário	Automatizar?	Motivo
Gerar Pix Dinâmico com sucesso	⭐ Sim — essencial	Teste de contrato, determinístico
Respeitar dados enviados pelo cliente	⭐ Sim	Validação de payload perfeita para automação
Santander indisponível	⭐ Sim	Regra de fallback importante
Falha OAuth	⭐ Sim	Validar tratamento de autenticação
✅ Automatizáveis: 4 de 4
🟦 TC — MDPO-4004 · Cancelamento de Pix – Santander
Cenário	Automatizar?	Motivo
Cancelar Pix com sucesso	⭐ Sim	Fluxo crítico
Santander retorna Pix já pago	⭐ Sim	Cenário funcional e determinístico
Santander retorna Pix já cancelado	⭐ Sim	Fácil de mockar
Santander indisponível (3 tentativas)	⭐ Sim	Regra interna clara, boa para automação
✅ Automatizáveis: 4 de 4
🟦 TC — MDPO-4005 · Webhook de Liquidação – Santander
Cenário	Automatizar?	Motivo
Processar Webhook com sucesso	⚠️ Sim, com mock	Webhook real é instável, mock resolve
Status ATIVA não altera	⚠️ Sim, com mock	Determinístico
Webhook inválido	⚠️ Sim, com mock	Validação simples
Falha de autenticação	⚠️ Sim, com mock	Teste de segurança
⚠️ Automatizáveis: 4 de 4, somente com mock do Santander

Webhooks não devem ser testados via PSP real, sempre via simulação.

🟦 TC — MDPO-4006 · Scheduler / Consulta de Status – Santander
Cenário	Automatizar?	Motivo
Atualizar para PAGO	⭐ Sim, com mock	Resposta determinística
Status ATIVA não altera	⭐ Sim, com mock	Validação simples
Atualizar para BAIXADO	⭐ Sim, com mock	Regras de status
Processo idempotente	⭐ Sim, com mock	Muito importante automatizar
Santander indisponível	🔸 Não	Depende de comportamento de infra (CircuitBreaker)
⚠️ Automatizáveis: 4 de 5 (com mock)
❌ Não automatizar: 1 (CircuitBreaker real)
🧮 RESULTADO FINAL — PIX SANTANDER
Tarefa	Cenários	Automatizáveis	Observações
4003 – Geração	4	4	Tudo automatiza
4004 – Cancelamento	4	4	Tudo automatiza
4005 – Webhook	4	4 (mock)	Webhook sempre via mock
4006 – Scheduler	5	4 (mock)	Não automatizar CircuitBreaker
🎯 TOTAL

17 cenários criados

16 automatizáveis

8 essenciais (sem mock)

8 automatizáveis com mock

1 não recomendado automatizar
