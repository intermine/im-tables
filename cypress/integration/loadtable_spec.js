describe('Load Table', function() {
  it('find the Generate button', function() {
    cy.visit('http://localhost:9000/')
    cy.get('.language-selector')
  })

  it('find the Export button', function() {
    cy.visit('http://localhost:9000/')
    cy.get('.im-export-dialogue-button')
  })

  it('find the Manage Columns button', function() {
    cy.visit('http://localhost:9000/')
    cy.get('.im-column-manager-button')
  })

  it('find the Manage Filters button', function() {
    cy.visit('http://localhost:9000/')
    cy.get('.im-filter-dialogue-button')
  })

  it('find the Manage Relationships button', function() {
    cy.visit('http://localhost:9000/')
    cy.get('.im-join-manager-button')
  })

  it('checks if cells are present', function() {
    cy.visit('http://localhost:9000/')
    cy.get('.im-result-field')
  })

  it('checks if column heading is present', function() {
    cy.visit('http://localhost:9000/')
    cy.get('.im-th-buttons')
    cy.get('.im-title-part')
    cy.get('.im-parent')
    cy.get('.im-last')
  })
})
