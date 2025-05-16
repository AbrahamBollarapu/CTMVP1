from fastapi import APIRouter, Response, Request, HTTPException, status, Body
from jose import jwt, JWTError
from datetime import datetime, timedelta
from passlib.context import CryptContext
from pydantic import BaseModel
from models.user import User
from database import SessionLocal

router = APIRouter()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

SECRET_KEY = "your-secret-key"
ALGORITHM = "HS256"

class LoginRequest(BaseModel):
    email: str
    password: str

@router.post("/login")
async def login(response: Response, creds: LoginRequest):
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.email == creds.email).first()
        print("🔍 Found user:", user.email if user else "None")
        if not user or not pwd_context.verify(creds.password, user.hashed_password):
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

        expire = datetime.utcnow() + timedelta(hours=1)
        access_token = jwt.encode({"sub": user.email, "exp": expire}, SECRET_KEY, algorithm=ALGORITHM)

        response.set_cookie(
            key="access_token",
            value=f"Bearer {access_token}",
            httponly=True,
            secure=False,
            samesite="lax",
            max_age=3600
        )
        return {"message": "Login successful"}
    finally:
        db.close()

def get_current_user(token: str):
    try:
        print("🔐 Decoding token:", token)
        payload = jwt.decode(token.replace("Bearer ", ""), SECRET_KEY, algorithms=[ALGORITHM])
        email = payload.get("sub")
        print("✅ Decoded email:", email)
        if not email:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    except JWTError as e:
        print("❌ JWT error:", str(e))
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

    db = SessionLocal()
    try:
        user = db.query(User).filter(User.email == email).first()
        if not user:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
        return user
    finally:
        db.close()

@router.get("/me")
async def me(request: Request):
    token = request.cookies.get("access_token")
    print("🍪 Token from cookie:", token)
    if not token:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Unauthorized")
    user = get_current_user(token)
    return {"email": user.email, "role": user.role}

@router.post("/logout")
async def logout(response: Response):
    response.delete_cookie("access_token")
    return {"message": "Successfully logged out"}

@router.post("/create-user")
def create_user(
    username: str = Body(...),
    email: str = Body(...),
    password: str = Body(...)
):
    db = SessionLocal()
    try:
        existing = db.query(User).filter(User.email == email).first()
        if existing:
            raise HTTPException(status_code=400, detail="User already exists")

        hashed_password = pwd_context.hash(password)
        user = User(username=username, email=email, hashed_password=hashed_password)
        db.add(user)
        db.commit()
        db.refresh(user)
        return {"message": "User created", "user_id": user.id}
    finally:
        db.close()
