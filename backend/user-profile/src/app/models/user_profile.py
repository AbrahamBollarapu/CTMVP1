from pydantic import BaseModel
from typing import Optional, List

_profiles: List['UserProfileInDB'] = []
_next_id = 1

class UserProfileInDB(BaseModel):
    id: int
    user_id: int
    role: str
    carbon_score: float = 0.0

def list_profiles(role: Optional[str] = None) -> List[UserProfileInDB]:
    return [p for p in _profiles if role is None or p.role == role]

def create_or_update_profile(user_id: int, role: str, carbon_score: float = 0.0) -> UserProfileInDB:
    global _next_id
    existing = next((p for p in _profiles if p.user_id == user_id), None)
    if existing:
        existing.role = role
        existing.carbon_score = carbon_score
        return existing
    profile = UserProfileInDB(id=_next_id, user_id=user_id, role=role, carbon_score=carbon_score)
    _next_id += 1
    _profiles.append(profile)
    return profile
