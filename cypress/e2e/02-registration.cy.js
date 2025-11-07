describe('User Registration Tests', () => {
  
  beforeEach(() => {
    cy.visit('/')
    cy.get('[data-testid="cadastrar"]').click()
  })

  it('Should register new user successfully', () => {
    const timestamp = Date.now()
    const newUser = {
      nome: `Test User ${timestamp}`,
      email: `test${timestamp}@email.com`,
      password: 'test123'
    }

    cy.intercept('POST', '**/usuarios').as('registerRequest')
    
    cy.get('[data-testid="nome"]').type(newUser.nome)
    cy.get('[data-testid="email"]').type(newUser.email)
    cy.get('[data-testid="password"]').type(newUser.password)
    cy.get('[data-testid="cadastrar"]').click()

    cy.wait('@registerRequest').then((interception) => {
      expect(interception.response.statusCode).to.eq(201)
    })

    cy.get('.alert').should('be.visible')
    cy.get('.alert').should('contain', 'Cadastro realizado com sucesso')
  })

  it('Should prevent registration with existing email', () => {
    const timestamp = Date.now()
    const existingUser = {
      nome: `Existing User ${timestamp}`,
      email: `existing${timestamp}@test.com`,
      password: 'existing123',
      administrador: 'false'
    }

    cy.request('POST', `${Cypress.env('apiUrl')}/usuarios`, existingUser).then(() => {
      cy.get('[data-testid="nome"]').type('Duplicate User')
      cy.get('[data-testid="email"]').type(existingUser.email)
      cy.get('[data-testid="password"]').type('test123')
      cy.get('[data-testid="cadastrar"]').click()

      cy.get('.alert').should('be.visible')
      cy.get('.alert').should('contain', 'Este email já está sendo usado')
    })
  })

  it('Should validate required fields', () => {
    cy.get('[data-testid="cadastrar"]').click()
    
    cy.url().should('include', '/cadastrarusuarios')
    
    cy.get('[data-testid="nome"]').should('be.visible').and('have.value', '')
    cy.get('[data-testid="email"]').should('be.visible').and('have.value', '')
    cy.get('[data-testid="password"]').should('be.visible').and('have.value', '')
  })
})