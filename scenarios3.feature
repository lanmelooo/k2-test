🟦 TC – MDPO-4011 – API de Geração de PIX
DESCRIPTION

Validar que o endpoint de geração de PIX receba os dados da cobrança, valide campos obrigatórios, envie ao PSP parceiro e retorne txid, QR Code base64, payload copia e cola e status “Gerado”.

PRECONDITIONS

Ambiente TST

Endpoint de geração disponível

Requisição contendo: IdExterno, CodProduto, Valor ≥ 0,01, CPF/CNPJ, Nome do Pagador, Vencimento

PSP parceiro disponível para gerar o PIX

Token/OAuth disponível

Idempotência habilitada

TEST DETAILS (Cucumber)
Funcionalidade: Geração de PIX Dinâmico

  Contexto:
    Dado que o endpoint de geração de PIX esteja disponível
    E que a requisição contenha todos os campos obrigatórios
    E que o PSP esteja disponível para gerar a cobrança

  Cenário: Gerar PIX dinâmico com sucesso
    Quando envio uma requisição válida de geração de PIX
    Então devo receber status 201
    E o payload deve conter txid, qrCodeBase64, payloadCopiaECola e status Gerado

  Cenário: Validar campos obrigatórios ausentes
    Quando envio uma requisição sem um campo obrigatório
    Então devo receber erro indicando o campo faltante

  Cenário: Validar regras de multa, juros, abatimento e desconto
    Quando envio dados de multa, juros, abatimento ou desconto
    Então modalidade e percentual devem ser validados conforme regra

  Cenário: Validar expiração
    Quando envio uma expiração anterior ao horário atual
    Então devo receber erro indicando expiração inválida

  Cenário: Valor abaixo do mínimo
    Quando envio valor menor que 0,01
    Então devo receber erro de valor inválido

  Cenário: Idempotência
    Quando envio uma requisição idêntica com mesmo IdExterno e dados
    Então devo receber o mesmo txid e não gerar novo PIX

  Cenário: Indisponibilidade do PSP
    Quando o PSP estiver indisponível
    Então o serviço deve retornar mensagem clara de indisponibilidade

🟦 TC – MDPO-4012 – API de Baixa / Cancelamento de PIX
DESCRIPTION

Validar que o endpoint cancele um PIX existente, respeitando status atual, regras de erro e retorno atualizado da transação com status “Baixado”.

PRECONDITIONS

Ambiente TST

PIX existente com status GERADO ou PENDENTE

Identificação por txid ou CPF/CNPJ + IdExterno + vencimento

PSP disponível (se cancelamento envolver parceiro)

Regras de idempotência habilitadas

TEST DETAILS (Cucumber)
Funcionalidade: Cancelamento de PIX

  Contexto:
    Dado que exista um PIX registrado no Orquestrador
    E que a requisição contenha os identificadores obrigatórios

  Cenário: Cancelar PIX com sucesso
    Quando envio a requisição de cancelamento para um PIX Gerado
    Então devo receber status 201
    E o status interno deve ser atualizado para Baixado

  Cenário: Cancelar PIX Pendente
    Quando envio o cancelamento para um PIX Pendente
    Então devo receber status 201
    E o status deve ser atualizado para Baixado

  Cenário: Não permitir cancelamento de PIX Pago
    Quando o PIX possui status Pago
    Então devo receber erro informando que o PIX já foi pago

  Cenário: Não permitir cancelamento de PIX já cancelado
    Quando o PIX possui status Baixado
    Então devo receber erro indicando que o PIX já está cancelado

  Cenário: txid inexistente
    Quando o txid informado não existir
    Então deve retornar erro "txid não localizado"

  Cenário: PSP indisponível
    Quando o PSP estiver indisponível
    Então o serviço deve retornar erro de indisponibilidade

  Cenário: Campos obrigatórios faltando
    Quando algum campo obrigatório não for enviado
    Então o retorno deve indicar qual campo está ausente

  Cenário: Idempotência
    Quando cancelar novamente um PIX já baixado pelo mesmo requestId
    Então o retorno deve ser igual ao cancelamento anterior

🟦 TC – MDPO-4013 – API de Consulta de PIX
DESCRIPTION

Validar que o endpoint retorne informações completas do PIX consultado, incluindo status atualizado e detalhes de pagamento, sem acionar PSP.

PRECONDITIONS

Ambiente TST

PIX existente na base

Identificação por txid ou CPF/CNPJ + IdExterno + vencimento

Resposta deve respeitar vocabulário padronizado

Consulta nunca aciona PSP

TEST DETAILS (Cucumber)
Funcionalidade: Consulta de PIX

  Contexto:
    Dado que exista um PIX registrado na base
    E que o cliente envie um identificador válido

  Cenário: Consultar via txid
    Quando consulto informando o txid
    Então devo receber status 200
    E o payload deve conter dados completos do PIX

  Cenário: Consultar via CPF/CNPJ + IdExterno + vencimento
    Quando consulto usando dados alternativos
    Então devo receber status 200
    E os dados do PIX devem ser retornados corretamente

  Cenário: PIX Pago
    Quando o PIX possui status Pago
    Então o retorno deve conter dataLiquidacao, horarioLiquidacao e valorPago

  Cenário: PIX não pago
    Quando o PIX não está pago
    Então os campos de pagamento devem vir vazios

  Cenário: PIX inexistente
    Quando consulto um txid inexistente
    Então devo receber erro "PIX inexistente"

  Cenário: Formato inválido
    Quando envio um identificador inválido
    Então devo receber erro indicando o campo inválido

  Cenário: Retorno completo dos campos
    Quando consulto um PIX válido
    Então o payload deve conter qrCode, valor, vencimento, status e dados de pagamento

  Cenário: Desempenho SLO
    Quando faço a consulta
    Então o tempo de resposta deve ser inferior a 100ms

  Cenário: Rate limit
    Quando excedo o limite de consultas
    Então devo receber erro de rate limit

  Cenário: Não acionar PSP
    Quando realizo uma consulta de PIX
    Então somente a base interna deve ser consultada

🟦 TC – MDPO-4014 – Webhook para os Clients
DESCRIPTION

Validar que o Orquestrador envie Webhooks de liquidação com segurança, payload completo, assinatura digital, idempotência e política de retries.

PRECONDITIONS

Ambiente TST

URL do cliente configurada

Webhook habilitado

PIX liquidado na base

Assinatura digital ativa

Política de retries: 30 min × até 96 tentativas

TEST DETAILS (Cucumber)
Funcionalidade: Webhook de liquidação de PIX para os Clients

  Contexto:
    Dado que o Orquestrador esteja habilitado para enviar Webhooks
    E exista um PIX liquidado na base
    E a URL do cliente esteja ativa

  Cenário: Enviar Webhook com payload completo
    Quando ocorre a liquidação do PIX
    Então o Orquestrador deve enviar um Webhook contendo campos obrigatórios

  Cenário: Cliente responde com 200 OK
    Quando o Webhook é recebido pelo cliente
    Então o cliente deve responder 200 OK
    E o Orquestrador deve registrar entrega com sucesso

  Cenário: Idempotência
    Quando o mesmo evento for reenviado
    Então o cliente não deve processar duplicadamente

  Cenário: Reenvio automático
    Quando o cliente não responder 200 OK
    Então o Orquestrador deve reenviar a cada 30 minutos até 96 tentativas

  Cenário: Cliente indisponível
    Quando o cliente retornar erro 4xx ou 5xx
    Então o Orquestrador deve registrar falha e iniciar retries

  Cenário: Assinatura digital
    Quando o Webhook for enviado
    Então a mensagem deve estar assinada digitalmente

  Cenário: Registro de entrega
    Quando o cliente responder 200 OK
    Então o Orquestrador deve marcar Webhook como entregue

  Cenário: Bloquear envio com payload inválido
    Quando faltar um campo obrigatório no payload
    Então o envio deve ser bloqueado

  Cenário: Assinatura inválida
    Quando o Webhook tiver assinatura inválida
    Então o cliente deve rejeitar o evento

  Cenário: Webhook é método preferencial
    Quando o PIX for liquidado
    Então o cliente deve ser notificado via Webhook
