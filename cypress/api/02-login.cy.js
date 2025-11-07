describe('API - Authentication', () => {
  
  const apiUrl = Cypress.env('apiUrl')

  it('Should login with valid credentials', () => {
    const timestamp = Date.now()
    const userData = {
      nome: `Login Test User ${timestamp}`,
      email: `logintest${timestamp}@test.com`,
      password: 'test123',
      administrador: 'false'
    }

    cy.request('POST', `${apiUrl}/usuarios`, userData).then(() => {
      cy.request({
        method: 'POST',
        url: `${apiUrl}/login`,
        body: {
          email: userData.email,
          password: userData.password
        }
      }).then((response) => {
        expect(response.status).to.eq(200)
        expect(response.body.message).to.eq('Login realizado com sucesso') 
        expect(response.body.authorization).to.exist
        expect(response.body.authorization).to.include('Bearer')
      })
    })
  })

  it('Should reject invalid credentials', () => {
    cy.request({
      method: 'POST',
      url: `${apiUrl}/login`,
      body: {
        email: 'nonexistent@user.com',
        password: 'wrongpassword'
      },
      failOnStatusCode: false
    }).then((response) => {
      expect(response.status).to.eq(401)
      expect(response.body.message).to.eq('Email e/ou senha inválidos')
    })
  })

  it('Should validate required fields', () => {
    cy.request({
      method: 'POST',
      url: `${apiUrl}/login`,
      body: { password: 'test123' },
      failOnStatusCode: false
    }).then((response) => {
      expect(response.status).to.eq(400)
      expect(response.body.email).to.exist
    })

    cy.request({
      method: 'POST',
      url: `${apiUrl}/login`,
      body: { email: 'test@email.com' },
      failOnStatusCode: false
    }).then((response) => {
      expect(response.status).to.eq(400)
      expect(response.body.password).to.exist
    })
  })

  it('Should create user and login workflow', () => {
    const timestamp = Date.now()
    const userData = {
      nome: `Login User ${timestamp}`,
      email: `login${timestamp}@test.com`,
      password: 'password123',
      administrador: 'false'
    }

    cy.request('POST', `${apiUrl}/usuarios`, userData).then(() => {
      cy.request({
        method: 'POST',
        url: `${apiUrl}/login`,
        body: {
          email: userData.email,
          password: userData.password
        }
      }).then((response) => {
        expect(response.status).to.eq(200)
        expect(response.body.message).to.eq('Login realizado com sucesso')
        expect(response.body.authorization).to.exist
      })
    })
  })

  it('Should validate email format', () => {
    cy.request({
      method: 'POST',
      url: `${apiUrl}/login`,
      body: {
        email: 'invalidemail',
        password: 'test123'
      },
      failOnStatusCode: false
    }).then((response) => {
      expect(response.status).to.eq(400)
      expect(response.body.email).to.exist
    })
  })
})