describe('Auth flow', () => {
  const user = {
    username: 'testuser',
    email: 'test@example.com',
    password: 'password123'
  };

  beforeEach(() => {
    cy.clearAllCookies();
  });

  it('rejects invalid login', () => {
    cy.visit('/login');
    cy.get('button').contains('Log In').click();
    cy.contains('Missing fields').should('exist');
  });

  it('registers, logs in, and shows dashboard', () => {
    cy.visit('/register');
    cy.get('input[placeholder=\"Username\"]').type(user.username);
    cy.get('input[placeholder=\"Email\"]').type(user.email);
    cy.get('input[placeholder=\"Password\"]').type(user.password);
    cy.get('button').contains('Sign Up').click();

    cy.url().should('include','/dashboard');
    cy.contains(\Welcome, \\);
  });
});
