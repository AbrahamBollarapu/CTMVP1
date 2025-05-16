from auth.src.app.core.security import hash_password, verify_password, create_access_token

def test_password_hashing():
    password = "testpassword"
    hashed = hash_password(password)
    assert verify_password(password, hashed) 