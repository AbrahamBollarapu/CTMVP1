from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from auth.src.app.core.security import (
    hash_password, verify_password, create_access_token
)
from auth.src.app.models.user import UserInDB as User, get_user_by_username, create_user

router = APIRouter()

class SignupRequest(BaseModel):
    username: str
    email: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"

@router.post("/signup", response_model=TokenResponse)
async def signup(req: SignupRequest):
    existing = get_user_by_username(req.username)
    if existing:
        raise HTTPException(status_code=400, detail="Username already exists")
    user = create_user(
        username=req.username,
        email=req.email,
        hashed_password=hash_password(req.password)
    )
    token = create_access_token({"sub": user.username})
    return {"access_token": token, "token_type": "bearer"}

class LoginRequest(BaseModel):
    username: str
    password: str

@router.post("/login", response_model=TokenResponse)
async def login(req: LoginRequest):
    user = get_user_by_username(req.username)
    if not user or not verify_password(req.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    token = create_access_token({"sub": user.username})
    return {"access_token": token, "token_type": "bearer"}
# Auth endpoints
