from fastapi.testclient import TestClient
from src.app.main import app

client = TestClient(app)

def test_create_profile():
    payload = {
        "user_id": 1,
        "role": "Test Role",
        "carbon_score": 75.0
    }
    response = client.post("/api/v1/profile/", json=payload)
    assert response.status_code == 200

    data = response.json()
    assert data["user_id"]     == payload["user_id"]
    assert data["role"]        == payload["role"]
    assert data["carbon_score"] == payload["carbon_score"]
