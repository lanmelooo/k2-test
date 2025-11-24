✅ TEST CASE — MDPO-4015 — Rota de cadastro bancário
DESCRIPTION

Validar o recebimento, armazenamento e consulta do mapeamento entre Código de Produto e dados bancários na rota de cadastro, garantindo que o Orquestrador utilize essas informações no roteamento de Pix.

PRECONDITIONS

Ambiente: TST

API de Gestão de Mapeamento disponível

Base de dados do Orquestrador com estrutura para persistência dos campos:

codProduto

clientId (banco)

banco

agência

conta

chave

sequencial

flag ativo/inativo

Autenticação interna habilitada (token interno)

Payloads de exemplo fornecidos pela história

TEST DETAILS (Gherkin)
Funcionalidade: Cadastro de mapeamento bancário por Código de Produto
Contexto:
Dado que existe uma API de Gestão de Mapeamento ativa
E que o serviço aceita autenticação interna por token
E que a base de dados está acessível para criação e consulta de mapeamentos

Cenário: Cadastrar um novo mapeamento válido
Dado que envio uma requisição POST para a rota de cadastro
E informo um codProduto válido e todos os campos obrigatórios
Quando o cadastro for processado
Então o serviço deve retornar HTTP 201 Created
E o mapeamento deve ser salvo na base de dados
E deve estar marcado como ativo

Cenário: Consultar mapeamento cadastrado
Dado que existe um mapeamento cadastrado para um codProduto
Quando envio uma requisição GET consultando esse codProduto
Então o serviço deve retornar HTTP 200 OK
E retornar todos os campos cadastrados corretamente

Cenário: Rejeitar cadastro com campos obrigatórios faltando
Dado que envio uma requisição POST sem informar um dos campos obrigatórios
Quando o serviço validar o payload
Então deve retornar HTTP 400 Bad Request
E deve informar exatamente qual campo está incorreto ou ausente

Cenário: Rejeitar cadastro com dados em formato inválido
Dado que envio um cadastro com agência fora do padrão numérico
Quando o serviço validar o payload
Então deve retornar HTTP 400 Bad Request
E retornar a mensagem clara informada na história, por exemplo "Campo XPTO inválido"

Cenário: Atualizar um mapeamento existente
Dado que já existe um mapeamento ativo para um codProduto
Quando envio nova requisição POST ou PUT atualizando seus dados
Então o serviço deve sobrescrever os dados anteriores
E retornar HTTP 200 OK
E o novo valor deve estar persistido no banco

Cenário: Consultar mapeamento inexistente
Dado que não existe mapeamento cadastrado para um codProduto informado
Quando envio requisição de consulta
Então o serviço deve retornar HTTP 404 Not Found
E uma mensagem clara de que o mapeamento não foi encontrado ou está inativo

Cenário: Impedir acesso sem autenticação interna
Dado que envio uma requisição sem token interno válido
Quando a API processar a autenticação
Então deve retornar HTTP 401 Unauthorized

Cenário: Utilização do mapeamento pelo módulo de Geração de Pix
Dado que existe mapeamento válido cadastrado
E o módulo de geração de Pix envia uma requisição contendo o codProduto
Quando o Orquestrador realizar o lookup na rota de mapeamento
Então deve localizar o mapeamento correto
E retornar os dados bancários completos para roteamento
