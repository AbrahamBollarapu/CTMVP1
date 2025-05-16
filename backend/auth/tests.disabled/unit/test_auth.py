# D:/CTMVP1/backend/tests/unit/test_auth.py

from auth.src.app.core.security import hash_password, verify_password, create_access_token

def test_hash_and_verify_password():
    pw = "secret"
    h = hash_password(pw)
    assert verify_password(pw, h)
    assert not verify_password("wrong", h)

def test_create_access_token():
    token = create_access_token({"sub": "testuser"})
    assert isinstance(token, str) and len(token) > 0
