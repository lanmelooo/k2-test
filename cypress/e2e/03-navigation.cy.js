describe('Navigation and Products Tests', () => {
  
  let adminUser
  
  before(() => {
    const timestamp = Date.now()
    adminUser = {
      nome: `Nav Admin ${timestamp}`,
      email: `navadmin${timestamp}@test.com`,
      password: 'admin123',
      administrador: 'true'
    }

    cy.request('POST', `${Cypress.env('apiUrl')}/usuarios`, adminUser)
  })
  
  beforeEach(() => {
    cy.visit('/')
    cy.get('[data-testid="email"]').type(adminUser.email)
    cy.get('[data-testid="senha"]').type(adminUser.password)
    cy.get('[data-testid="entrar"]').click()
    
    cy.url().should('include', '/admin/home')
  })

  it('Should navigate and view products', () => {
    cy.get('h1').should('contain', 'Bem Vindo')
    
    cy.get('[data-testid="listarProdutos"]').click()
    cy.url().should('include', '/admin/listarprodutos')
    
    cy.get('h1').should('contain', 'Lista dos Produtos')
    cy.get('body').then(($body) => {
      if ($body.find('.card').length > 0) {
        cy.get('.card').should('have.length.greaterThan', 0)
      } else {
        cy.get('h1').should('contain', 'Lista dos Produtos')
      }
    })
  })

  it('Should access product registration', () => {
    cy.get('[data-testid="cadastrarProdutos"]').click()
    cy.url().should('include', '/admin/cadastrarprodutos')
    
    cy.get('h1').should('contain', 'Cadastro de Produtos')
    cy.get('[data-testid="nome"]').should('be.visible')
    cy.get('[data-testid="preco"]').should('be.visible')
    cy.get('[data-testid="descricao"]').should('be.visible')
    cy.get('[data-testid="quantity"]').should('be.visible')
    cy.get('[data-testid="cadastarProdutos"]').should('be.visible')
  })

  it('Should logout successfully', () => {
    cy.get('h1').should('contain', 'Bem Vindo')
    
    cy.get('[data-testid="logout"]').click()
    
    cy.url().should('not.include', '/admin')
    cy.get('h1').should('contain', 'Login')
    cy.get('[data-testid="email"]').should('be.visible')
    cy.get('[data-testid="senha"]').should('be.visible')
  })
})