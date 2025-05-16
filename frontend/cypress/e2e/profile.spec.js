describe('UserProfile flow', () => {
  const user = { user_id: 3, role: 'admin', carbon_score: 12.5 };

  it('creates via API and displays in table', () => {
    cy.request('POST', '/api/v1/profile/', user);
    cy.visit('/dashboard/user-profile');
    cy.contains(user.role);
  });
});
