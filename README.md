# ServeRest Automation Testing Project

![Tests](https://img.shields.io/badge/tests-26%20passing-brightgreen)
![Cypress](https://img.shields.io/badge/cypress-13.17.0-17202C)
![Node](https://img.shields.io/badge/node-18.12.1-green)

Comprehensive test automation project using Cypress for the ServeRest application.

## About

This project implements automated tests for:
- **Frontend E2E**: https://front.serverest.dev/
- **REST API**: https://serverest.dev/

## Project Structure

```
cypress/
├── e2e/                     # End-to-End Tests
│   ├── 01-login.cy.js       # Login functionality
│   ├── 02-registration.cy.js # User registration
│   └── 03-navigation.cy.js  # Navigation & products
├── api/                     # API Tests
│   ├── 01-users.cy.js       # User management
│   ├── 02-login.cy.js       # Authentication
│   └── 03-products.cy.js    # Product management
├── fixtures/                # Test data
└── support/                 # Custom commands & config
```

## Getting Started

### Installation
```bash
npm install
```

### Running Tests
```bash
# All tests
npm test

# E2E tests only
npm run test:e2e

# API tests only  
npm run test:api

# Interactive mode
npm run cypress:open
```

## Test Scenarios

### Frontend (E2E Tests)
1. **Login Tests**: Valid/invalid credentials, field validation
2. **Registration Tests**: New user creation, duplicate email handling
3. **Navigation Tests**: Product listing, admin access, logout

### API Tests
1. **User Management**: CRUD operations, ID search, validations
2. **Authentication**: Login flows, field validation, token handling
3. **Product Management**: Listing, creation (admin), authorization checks

## Custom Commands

- `cy.loginAPI(email, password)`: API authentication
- `cy.createUserAPI(userData)`: User creation
- `cy.createProductAPI(productData, token)`: Product creation (admin)

## Configuration

- **Timeout**: 10 seconds default
- **Retries**: 1 retry in run mode for stability
- **Videos**: Enabled for test execution
- **Screenshots**: Captured on failures

## Notes

- Uses dynamic timestamps to avoid data conflicts
- Creates users dynamically for each test execution
- Tests target public ServeRest environment
- 100% test coverage with 26 passing tests
- Constants defined for reusable test data