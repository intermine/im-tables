describe('Pagination', function() {
  it('check for current page button', function() {
    cy.visit('http://localhost:9000/')
    cy.get('.im-current-page')
  })

  it('check for forward by 1 button', function() {
    if ((cy.get('.disabled')==false) && cy.get('Go to next page')==false) { //When we are in the last page the next page button is disabled
      cy.visit('http://localhost:9000/')
      cy.get('.im-go-fwd-1')
    }
  })

  it('check for forward by 5 button', function() {
    if ((cy.get('.disabled')==false) && cy.get('Go forward five pages')==false) {
      cy.visit('http://localhost:9000/')
      cy.get('.im-go-fwd-5')
    }
  })

  it('check for go to last page button', function() {
    if ((cy.get('.disabled')==false) && cy.get('Go to last page')==false) {
      cy.visit('http://localhost:9000/')
      cy.get('.im-goto-end')
    }
  })

  it('check for back by 1 button', function() {
    if ((cy.get('.disabled')==false) && cy.get('Go to previous page')==false) {
      cy.visit('http://localhost:9000/')
      cy.get('.im-go-back-1')
    }
  })

  it('check for back by 5 button', function() {
    if ((cy.get('.disabled')==false) && cy.get('Go back five pages')==false) {
      cy.visit('http://localhost:9000/')
      cy.get('.im-go-back-5')
    }
  })

  it('check for go to first page button', function() {
    if ((cy.get('.disabled')==false) && cy.get('Go to start')==false) {
      cy.visit('http://localhost:9000/')
      cy.get('.im-goto-start')
    }
  })
})
