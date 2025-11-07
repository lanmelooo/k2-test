describe('Login Tests', () => {
  
  beforeEach(() => {
    cy.visit('/')
  })

  it('Should login successfully with valid credentials', () => {
    const timestamp = Date.now()
    const adminUser = {
      nome: `E2E Admin ${timestamp}`,
      email: `e2eadmin${timestamp}@test.com`,
      password: 'admin123',
      administrador: 'true'
    }

    cy.request('POST', `${Cypress.env('apiUrl')}/usuarios`, adminUser).then(() => {
      cy.intercept('POST', '**/login').as('loginRequest')
      
      cy.get('[data-testid="email"]').type(adminUser.email)
      cy.get('[data-testid="senha"]').type(adminUser.password)
      cy.get('[data-testid="entrar"]').click()

      cy.wait('@loginRequest').then((interception) => {
        expect(interception.response.statusCode).to.eq(200)
      })

      cy.url().should('include', '/admin/home')
      cy.get('h1').should('contain', 'Bem Vindo')
    })
  })

  it('Should show error with invalid credentials', () => {
    cy.intercept('POST', '**/login').as('loginRequest')
    
    cy.get('[data-testid="email"]').type('invalid@user.com')
    cy.get('[data-testid="senha"]').type('wrongpassword')
    cy.get('[data-testid="entrar"]').click()

    cy.get('.alert').should('be.visible')
    cy.get('.alert').should('contain', 'Email e/ou senha inválidos')
    cy.url().should('not.include', '/admin/home')
  })

  it('Should validate required fields', () => {
    cy.get('[data-testid="entrar"]').click()
    
    cy.url().should('not.include', '/admin/home')
    
    cy.get('[data-testid="email"]').should('be.visible').and('have.value', '')
    cy.get('[data-testid="senha"]').should('be.visible').and('have.value', '')
  })
})