🟦 MDPO-4007 — Geração de Pix Cópia e Cola / QR Code no Itaú
DESCRIPTION

Garantir que o Orquestrador receba a solicitação de cobrança, consuma a API COBV do Itaú e retorne Txid, QR Code Base64 e Payload Copia e Cola, registrando a transação com status “GERADO”.

PRECONDITIONS

Ambiente TST

Orquestrador Pix ativo

API COBV do Itaú disponível

Autenticação OAuth 2.0 válida

Payload com dados obrigatórios: valor, vencimento, pagador, recebedor, juros/multas

Cobrança inexistente previamente na base

TEST DETAILS (Cucumber)
Funcionalidade: Geração de cobrança Pix no Itaú

  Contexto:
    Dado que exista uma requisição válida de criação de cobrança Pix
    E que o payload siga o modelo COBV exigido pelo Itaú
    E que o Orquestrador possua token OAuth 2.0 válido

  Cenário: Gerar Pix dinâmico com retorno de Txid, QR Code e Payload Copia e Cola
    Quando o Orquestrador enviar a cobrança para a API COBV do Itaú
    Então o Itaú deve retornar o Txid, o QR Code em Base64 e o Payload de Copia e Cola
    E o Orquestrador deve registrar a transação com status "GERADO"
    E deve armazenar a data e hora local da criação

  Cenário: Itaú indisponível na geração da cobrança
    Quando o Orquestrador tentar enviar a cobrança ao Itaú
    Então deve retornar ao cliente uma mensagem clara de indisponibilidade do PSP

  Cenário: Validar dados enviados pelo cliente no payload para o Itaú
    Quando o Orquestrador montar o payload COBV
    Então os dados de valor, vencimento, juros, pagador e recebedor devem ser mantidos exatamente como enviados

🟦 MDPO-4008 — Cancelamento / Baixa Operacional de Pix no Itaú
DESCRIPTION

Garantir que o Orquestrador receba a solicitação de cancelamento, envie para a API COBV do Itaú e atualize a transação para “BAIXADO” em caso de sucesso.

PRECONDITIONS

Ambiente TST

Orquestrador Pix ativo

API COBV do Itaú disponível

Token OAuth 2.0 válido

Cobrança existente com status GERADO ou PENDENTE

Txid registrado internamente

TEST DETAILS (Cucumber)
Funcionalidade: Cancelamento de cobrança Pix no Itaú

  Contexto:
    Dado que exista uma cobrança Pix registrada com Txid
    E que o payload de cancelamento siga o modelo COBV
    E que o Orquestrador esteja autenticado no Itaú

  Cenário: Cancelar cobrança com sucesso
    Quando o Orquestrador enviar o cancelamento ao Itaú
    Então o Itaú deve retornar sucesso
    E o Orquestrador deve atualizar o status interno para "BAIXADO"
    E deve registrar a data e hora local do cancelamento

  Cenário: Cancelamento recusado pelo Itaú (Pix já pago ou já cancelado)
    Quando o Itaú retornar erro informando que o Pix já foi pago ou cancelado
    Então o Orquestrador deve retornar exatamente a mesma mensagem ao cliente

  Cenário: Itaú indisponível durante o cancelamento
    Quando o Orquestrador tentar cancelar a cobrança
    Então o Orquestrador deve realizar até três tentativas
    E caso todas falhem, deve retornar mensagem clara de indisponibilidade

🟦 MDPO-4009 — Liquidação de Pix via Webhook Itaú
DESCRIPTION

Garantir que o Orquestrador receba notificações de liquidação do Itaú, valide a origem, processe o payload e atualize a cobrança para status “PAGO”.

PRECONDITIONS

Ambiente TST

Endpoint exclusivo para Webhook registrado no Itaú

Mecanismo de autenticação/validação de origem ativo

Transação existente com status GERADO ou ATIVA

Mensageria configurada para notificação ao cliente

Logs habilitados

TEST DETAILS (Cucumber)
Funcionalidade: Processamento de Webhook de liquidação Pix

  Contexto:
    Dado que o endpoint de Webhook esteja ativo e registrado no Itaú
    E que exista uma transação interna com Txid correspondente
    E que o payload enviado pelo Itaú seja validável

  Cenário: Processar Webhook de Pix liquidado com sucesso
    Quando o Itaú enviar o status "CONCLUIDA"
    Então o Orquestrador deve atualizar o status para "PAGO"
    E deve registrar a data e hora local da liquidação
    E deve publicar evento na fila de mensagens

  Cenário: Webhook inválido ou falha de autenticação
    Quando o Orquestrador validar o payload recebido
    Então, se houver falha, deve registrar o erro e responder com HTTP 400

  Cenário: Responder 200 OK imediatamente ao receber Webhook válido
    Quando o Itaú enviar o Webhook
    Então o Orquestrador deve responder 200 OK mesmo que o processamento interno leve mais tempo

🟦 MDPO-4010 — Scheduler / Polling de Status Pix no Itaú
DESCRIPTION

Garantir que o Scheduler consulte o status do Pix no Itaú nos horários definidos, aplique a lógica de mapeamento de status e atualize a transação interna para “PAGO” ou “BAIXADO”.

PRECONDITIONS

Ambiente TST

Scheduler configurado para rodar 07h00 e 20h30

Orquestrador com certificados e credenciais válidas

Circuit Breaker ativo

Transações internas com status PENDENTE ou GERADO

Txid armazenado nos metadados

TEST DETAILS (Cucumber)
Funcionalidade: Consulta de Status Pix via Polling Itaú

  Contexto:
    Dado que o Scheduler execute automaticamente nos horários configurados
    E que o Orquestrador tenha acesso à API de consulta do Itaú
    E que existam transações com Txid e status Pendente ou Gerado

  Cenário: Atualizar status para PAGO quando o Itaú retornar CONCLUIDA
    Quando o Orquestrador consultar o Itaú
    Então, se o retorno for "CONCLUIDA", o status deve ser atualizado para "PAGO"
    E a data e hora local do pagamento devem ser registradas

  Cenário: Atualizar status para BAIXADO quando o Itaú retornar REMOVIDO_PELO_USUARIO_RECEBEDOR ou REMOVIDO_PELO_PSP
    Quando o Orquestrador receber um desses status
    Então deve atualizar a transação para "BAIXADO"
    E registrar a data e hora local da atualização

  Cenário: Status ATIVA não altera o registro interno
    Quando o Itaú retornar "ATIVA"
    Então o status interno não deve ser modificado

  Cenário: Falha na comunicação com o Itaú
    Quando o Orquestrador tentar consultar o PSP e ocorrer indisponibilidade
    Então o Circuit Breaker deve impedir múltiplas chamadas
    E o erro deve ser registrado em log
