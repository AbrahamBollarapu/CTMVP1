# D:/CTMVP1/backend/tests/integration/test_auth_endpoints.py

from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_signup_endpoint():
    response = client.post(
        "/api/v1/auth/signup",
        json={
            "username": "testuser",
            "email": "test@example.com",
            "password": "password123"
        }
    )
    assert response.status_code == 200
    body = response.json()
    assert "access_token" in body
    assert body["token_type"] == "bearer"

def test_login_endpoint():
    # ensure user exists
    client.post(
        "/api/v1/auth/signup",
        json={
            "username": "testuser",
            "email": "test@example.com",
            "password": "password123"
        }
    )
    response = client.post(
        "/api/v1/auth/login",
        data={
            "username": "testuser",
            "password": "password123"
        }
    )
    assert response.status_code == 200
    body = response.json()
    assert "access_token" in body
    assert body["token_type"] == "bearer"
