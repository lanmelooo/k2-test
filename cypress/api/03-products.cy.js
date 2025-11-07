describe('API - Products Management', () => {
  
  const apiUrl = Cypress.env('apiUrl')
  const duplicateProductName = 'Logitech MX Vertical' 
  let token
  let productId

  before(() => {
    const timestamp = Date.now()
    const adminUser = {
      nome: `Admin User ${timestamp}`,
      email: `admin${timestamp}@test.com`,
      password: 'admin123',
      administrador: 'true'
    }

    cy.request('POST', `${apiUrl}/usuarios`, adminUser).then(() => {
      cy.request({
        method: 'POST',
        url: `${apiUrl}/login`,
        body: {
          email: adminUser.email,
          password: adminUser.password
        }
      }).then((response) => {
        token = response.body.authorization
      })
    })
  })

  it('Should list all products', () => {
    cy.request('GET', `${apiUrl}/produtos`).then((response) => {
      expect(response.status).to.eq(200)
      expect(response.body.produtos).to.be.an('array')
      expect(response.body.quantidade).to.be.a('number')
      
      if (response.body.produtos.length > 0) {
        const product = response.body.produtos[0]
        expect(product.nome).to.exist
        expect(product.preco).to.exist
        expect(product._id).to.exist
      }
    })
  })

  it('Should create product successfully', () => {
    const timestamp = Date.now()
    const productData = {
      nome: `API Product ${timestamp}`,
      preco: 150,
      descricao: 'Product created via API tests',
      quantidade: 20
    }

    cy.request({
      method: 'POST',
      url: `${apiUrl}/produtos`,
      body: productData,
      headers: { 'Authorization': token }
    }).then((response) => {
      expect(response.status).to.eq(201)
      expect(response.body.message).to.eq('Cadastro realizado com sucesso') 
      expect(response.body._id).to.exist
      
      productId = response.body._id
    })
  })

  it('Should find product by ID', () => {
    const timestamp = Date.now()
    const newProduct = {
      nome: `Search Product ${timestamp}`,
      preco: 80,
      descricao: 'Product for search testing',
      quantidade: 15
    }

    cy.request({
      method: 'POST',
      url: `${apiUrl}/produtos`,
      body: newProduct,
      headers: { 'Authorization': token }
    }).then((res) => {
      const id = res.body._id
      
      cy.request('GET', `${apiUrl}/produtos/${id}`).then((response) => {
        expect(response.status).to.eq(200)
        expect(response.body.nome).to.eq(newProduct.nome)
        expect(response.body.preco).to.eq(newProduct.preco)
        expect(response.body._id).to.eq(id)
      })
    })
  })

  it('Should return error for non-existent product', () => {
    cy.request({
      method: 'GET',
      url: `${apiUrl}/produtos/invalidid123`,
      failOnStatusCode: false
    }).then((response) => {
      expect(response.status).to.eq(400)
    })
  })

  it('Should reject product creation without token', () => {
    cy.request({
      method: 'POST',
      url: `${apiUrl}/produtos`,
      body: {
        nome: 'Unauthorized Product',
        preco: 50,
        descricao: 'Without authorization',
        quantidade: 10
      },
      failOnStatusCode: false
    }).then((response) => {
      expect(response.status).to.eq(401)
      expect(response.body.message).to.include('Token')
    })
  })

  it('Should validate required fields', () => {
    cy.request({
      method: 'POST',
      url: `${apiUrl}/produtos`,
      body: { nome: 'Incomplete Product' },
      headers: { 'Authorization': token },
      failOnStatusCode: false
    }).then((response) => {
      expect(response.status).to.eq(400)
      expect(response.body.preco).to.exist
    })
  })

  it('Should prevent duplicate product name', () => {
    cy.request({
      method: 'POST',
      url: `${apiUrl}/produtos`,
      body: {
        nome: duplicateProductName,
        preco: 100,
        descricao: 'Duplicate product test',
        quantidade: 10
      },
      headers: { 'Authorization': token },
      failOnStatusCode: false
    }).then((response) => {
      expect(response.status).to.eq(400)
      expect(response.body.message).to.eq('Já existe produto com esse nome')
    })
  })
})