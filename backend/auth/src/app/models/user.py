# auth/src/app/models/user.py

from pydantic import BaseModel
from typing import Optional, Dict

# In-memory user storage for MVP
_fake_users: Dict[str, "UserInDB"] = {}
_next_id = 1

class UserInDB(BaseModel):
    id: int
    username: str
    email: str
    hashed_password: str

def get_user_by_username(username: str) -> Optional[UserInDB]:
    """Retrieve a user by username from the in-memory store."""
    return _fake_users.get(username)

def create_user(username: str, email: str, hashed_password: str) -> UserInDB:
    """Create a new user in the in-memory store and return it."""
    global _next_id
    user = UserInDB(
        id=_next_id,
        username=username,
        email=email,
        hashed_password=hashed_password
    )
    _fake_users[username] = user
    _next_id += 1
    return user
# User model
