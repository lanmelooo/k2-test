describe('API - Users Management', () => {
  
  const apiUrl = Cypress.env('apiUrl')
  const duplicateEmail = 'beltrano@qa.com.br'
  let userId

  it('Should create user successfully', () => {
    const timestamp = Date.now()
    const userData = {
      nome: `API User ${timestamp}`,
      email: `user${timestamp}@test.com`,
      password: 'test123',
      administrador: 'false'
    }

    cy.request({
      method: 'POST',
      url: `${apiUrl}/usuarios`,
      body: userData
    }).then((response) => {
      expect(response.status).to.eq(201)
      expect(response.body.message).to.eq('Cadastro realizado com sucesso') 
      expect(response.body._id).to.exist
      
      userId = response.body._id
    })
  })

  it('Should list all users', () => {
    cy.request('GET', `${apiUrl}/usuarios`).then((response) => {
      expect(response.status).to.eq(200)
      expect(response.body.usuarios).to.be.an('array')
      expect(response.body.quantidade).to.be.a('number')
      
      if (response.body.usuarios.length > 0) {
        const user = response.body.usuarios[0]
        expect(user).to.have.property('nome')
        expect(user).to.have.property('email')
        expect(user).to.have.property('_id')
      }
    })
  })

  it('Should find user by ID', () => {
    const timestamp = Date.now()
    const newUser = {
      nome: `Search User ${timestamp}`,
      email: `search${timestamp}@test.com`,
      password: 'test123',
      administrador: 'true'
    }

    cy.request('POST', `${apiUrl}/usuarios`, newUser).then((res) => {
      const id = res.body._id
      
      cy.request('GET', `${apiUrl}/usuarios/${id}`).then((response) => {
        expect(response.status).to.eq(200)
        expect(response.body.nome).to.eq(newUser.nome)
        expect(response.body.email).to.eq(newUser.email)
        expect(response.body._id).to.eq(id)
      })
    })
  })

  it('Should return error for non-existent user', () => {
    cy.request({
      method: 'GET',
      url: `${apiUrl}/usuarios/invalidid123`,
      failOnStatusCode: false
    }).then((response) => {
      expect(response.status).to.eq(400)
    })
  })

  it('Should prevent duplicate email registration', () => {
    cy.request({
      method: 'POST',
      url: `${apiUrl}/usuarios`,
      body: {
        nome: 'Duplicate User',
        email: duplicateEmail,
        password: 'test123',
        administrador: 'false'
      },
      failOnStatusCode: false
    }).then((response) => {
      expect(response.status).to.eq(400)
      expect(response.body.message).to.eq('Este email já está sendo usado')
    })
  })
})