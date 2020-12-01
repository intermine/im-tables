describe('Column Manager', function() {
  it('find the Manage Columns button', function() {
    cy.visit('http://localhost:9000/')
    cy.get('.im-column-manager-button')
  })

  it('check for sort option', function() {
    cy.visit('http://localhost:9000/')
    cy.get('.fa-unsorted')
  })

  it('check for remove column option', function() {
    cy.visit('http://localhost:9000/')
    cy.get('.im-col-remover')
  })

  it('check for toggle column option', function() {
    cy.visit('http://localhost:9000/')
    cy.get('.im-col-minumaximiser')
  })

  it('check for filter column option', function() {
    cy.visit('http://localhost:9000/')
    cy.get('.im-filter-summary')
  })

  it('check for column summary option', function() {
    cy.visit('http://localhost:9000/')
    cy.get('.im-summary')
  })
})
