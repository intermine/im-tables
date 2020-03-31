describe('Code Generation', function() {
  it('find the Generate button', function() {
    cy.visit('http://localhost:9000/')
    cy.get('.language-selector')
  })

  it('checks for change language', function() {
    cy.visit('http://localhost:9000/')
    cy.get('.im-show-code-gen-dialogue')
  })

  it('checks if Download option is present', function() {
    cy.visit('http://localhost:9000/')
    cy.get('.fa-file-archive')
  })

  it('checks if choice of languages are available', function() {
    cy.visit('http://localhost:9000/')
    cy.get('.dropdown-menu')
    cy.get('.im-code-gen-langs')
  })
})
