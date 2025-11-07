Cypress.Commands.add('loginAPI', (email, password) => {
  return cy.request({
    method: 'POST',
    url: `${Cypress.env('apiUrl')}/login`,
    body: {
      email: email,
      password: password
    }
  }).then((response) => {
    expect(response.status).to.eq(200)
    window.localStorage.setItem('serverest/userEmail', email)
    window.localStorage.setItem('serverest/userToken', response.body.authorization)
    return response.body
  })
})

Cypress.Commands.add('createUserAPI', (userData) => {
  return cy.request({
    method: 'POST',
    url: `${Cypress.env('apiUrl')}/usuarios`,
    body: userData,
    failOnStatusCode: false
  }).then((response) => {
    return response.body
  })
})

Cypress.Commands.add('deleteUserAPI', (userId, token) => {
  return cy.request({
    method: 'DELETE',
    url: `${Cypress.env('apiUrl')}/usuarios/${userId}`,
    headers: {
      'Authorization': token
    },
    failOnStatusCode: false
  }).then((response) => {
    return response.body
  })
})

Cypress.Commands.add('createProductAPI', (productData, token) => {
  return cy.request({
    method: 'POST',
    url: `${Cypress.env('apiUrl')}/produtos`,
    body: productData,
    headers: {
      'Authorization': token
    },
    failOnStatusCode: false
  }).then((response) => {
    return response.body
  })
})