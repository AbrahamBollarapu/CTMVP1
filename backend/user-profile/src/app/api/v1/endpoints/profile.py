from fastapi import APIRouter, Query, HTTPException
from pydantic import BaseModel
from src.app.models.user_profile import UserProfileInDB, list_profiles, create_or_update_profile

router = APIRouter()

class ProfileRequest(BaseModel):
    user_id: int
    role: str
    carbon_score: float = 0.0

@router.get('/', response_model=list[UserProfileInDB])
async def get_profiles(role: str = Query(None)):
    return list_profiles(role)

@router.post('/', response_model=UserProfileInDB)
async def upsert_profile(req: ProfileRequest):
    try:
        return create_or_update_profile(req.user_id, req.role, req.carbon_score)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
