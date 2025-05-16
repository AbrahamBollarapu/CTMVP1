# ==============================================
# 🚀 FastAPI JWT HttpOnly Cookie Setup Script
# ==============================================

# Activate Python Virtual Environment (if exists)
if (Test-Path ".\venv\Scripts\Activate.ps1") {
    Write-Output "🔄 Activating virtual environment..."
    .\venv\Scripts\Activate.ps1
}

# Step 1: Install Dependencies
Write-Output "`n🔧 [Step 1] Installing Dependencies..."
pip install fastapi uvicorn python-jose bcrypt sqlalchemy python-multipart passlib
Write-Output "✅ Dependencies installed.`n"

# Step 2: Update auth.py with JWT HttpOnly Cookie Logic
Write-Output "🔧 [Step 2] Updating auth.py endpoint..."

$auth_endpoint_file = ".\api\v1\endpoints\auth.py"

$auth_py_content = @'
from fastapi import APIRouter, Response, Request, HTTPException, status
from jose import jwt
from datetime import datetime, timedelta
from passlib.context import CryptContext
from models import User
from database import SessionLocal

router = APIRouter()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

SECRET_KEY = "your-secret-key"
ALGORITHM = "HS256"

@router.post("/login")
async def login(response: Response, email: str, password: str):
    db = SessionLocal()
    user = db.query(User).filter(User.email == email).first()

    if not user or not pwd_context.verify(password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    expire = datetime.utcnow() + timedelta(hours=1)
    access_token = jwt.encode({"sub": user.email, "exp": expire}, SECRET_KEY, algorithm=ALGORITHM)

    response.set_cookie(
        key="access_token",
        value=f"Bearer {access_token}",
        httponly=True,
        secure=False,  # set True in production (HTTPS)
        samesite="lax",
        max_age=3600
    )

    return {"message": "Login successful"}

def get_current_user(token: str):
    try:
        payload = jwt.decode(token.replace("Bearer ", ""), SECRET_KEY, algorithms=[ALGORITHM])
        email = payload.get("sub")
        if not email:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    except jwt.JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

    db = SessionLocal()
    user = db.query(User).filter(User.email == email).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")

    return user

@router.get("/me")
async def me(request: Request):
    token = request.cookies.get("access_token")
    if not token:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Unauthorized")

    user = get_current_user(token)
    return {"email": user.email, "role": user.role}

@router.post("/logout")
async def logout(response: Response):
    response.delete_cookie("access_token")
    return {"message": "Successfully logged out"}
'@

Set-Content -Path $auth_endpoint_file -Value $auth_py_content -Encoding UTF8
Write-Output "✅ auth.py updated successfully.`n"

# Step 3: Update main.py to allow credentials in CORS
Write-Output "🔧 [Step 3] Updating main.py CORS settings..."

$main_app_file = ".\main.py"

$main_py_content = @'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api.v1.endpoints.auth import router as auth_router

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router, prefix="/auth", tags=["auth"])
'@

Set-Content -Path $main_app_file -Value $main_py_content -Encoding UTF8
Write-Output "✅ main.py updated successfully.`n"

# Step 4: Final Checklist
Write-Output "🎯 [Step 4] Verification Checklist:"
Write-Output "------------------------------------"
Write-Output "[ ] Dependencies installed correctly."
Write-Output "[ ] auth.py endpoints functioning."
Write-Output "[ ] main.py CORS middleware updated."
Write-Output "[ ] Run backend with: uvicorn main:app --reload"
Write-Output "[ ] Manually test login, /me, logout endpoints."
Write-Output "------------------------------------`n"

Write-Output "JWT HttpOnly Cookie integration completed successfully!"
