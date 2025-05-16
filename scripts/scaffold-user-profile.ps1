# scaffold-user-profile.ps1
# PowerShell Script to Scaffold User-Profile Microservice (Backend + Frontend)

# 0. Base paths
$backend  = "D:\CTMVP1\backend\user-profile"
$frontend = "D:\CTMVP1\frontend"

# Ensure Windows
if ($env:OS -notlike "*Windows*") {
    Write-Host "❌ This script is designed for Windows systems only." -ForegroundColor Red
    exit 1
}

# Check for Python and Node.js
if (!(Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Python is not installed. Exiting." -ForegroundColor Red
    exit 1
}
if (!(Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Node.js (npm) is not installed. Exiting." -ForegroundColor Red
    exit 1
}

# Start timing
$startTime = Get-Date

try {
    # -------------------
    # BACKEND SCAFFOLDING
    # -------------------

    # 1. Create backend directories
    @(
      "$backend\src\app\core",
      "$backend\src\app\api\v1\endpoints",
      "$backend\src\app\models",
      "$backend\tests\unit",
      "$backend\tests\integration"
    ) | ForEach-Object {
        if (!(Test-Path $_)) {
            New-Item -ItemType Directory -Path $_ -Force | Out-Null
            Write-Host "✅ Created directory: $_"
        } else {
            Write-Host "⚠️ Directory already exists: $_"
        }
    }

    # 2. requirements.txt
    @"
fastapi==0.95.1
uvicorn==0.23.2
pytest==8.3.5
pytest-asyncio==0.20.3
"@ | Set-Content -Path "$backend\requirements.txt" -Encoding utf8
    Write-Host "✅ Created file: requirements.txt"

    # 3. Dockerfile (multi-stage)
    @"
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY src/app ./src/app
CMD [\"uvicorn\", \"src.app.main:app\", \"--host\", \"0.0.0.0\", \"--port\", \"8000\"]
"@ | Set-Content -Path "$backend\Dockerfile" -Encoding utf8
    Write-Host "✅ Created file: Dockerfile"

    # 4. core/config.py
    @"
from pydantic import BaseSettings

class Settings(BaseSettings):
    app_name: str = 'UserProfileService'

settings = Settings()
"@ | Set-Content -Path "$backend\src\app\core\config.py" -Encoding utf8
    Write-Host "✅ Created file: src\app\core\config.py"

    # 5. models/user_profile.py
    @"
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
"@ | Set-Content -Path "$backend\src\app\models\user_profile.py" -Encoding utf8
    Write-Host "✅ Created file: src\app\models\user_profile.py"

    # 6. api/v1/endpoints/profile.py
    @"
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
"@ | Set-Content -Path "$backend\src\app\api\v1\endpoints\profile.py" -Encoding utf8
    Write-Host "✅ Created file: src\app\api\v1\endpoints\profile.py"

    # 7. main.py
    @"
from fastapi import FastAPI
from src.app.api.v1.endpoints.profile import router as profile_router

app = FastAPI(title='UserProfileService')
app.include_router(profile_router, prefix='/api/v1/profile', tags=['profile'])
"@ | Set-Content -Path "$backend\src\app\main.py" -Encoding utf8
    Write-Host "✅ Created file: src\app\main.py"

    # 8. Unit test
    @"
import pytest
from src.app.models.user_profile import list_profiles, create_or_update_profile, UserProfileInDB

def test_create_and_list():
    p = create_or_update_profile(1, 'freelancer', 10.0)
    assert isinstance(p, UserProfileInDB)
    assert p in list_profiles()
    assert p in list_profiles('freelancer')
"@ | Set-Content -Path "$backend\tests\unit\test_profile_model.py" -Encoding utf8
    Write-Host "✅ Created file: tests\unit\test_profile_model.py"

    # 9. Integration test
    @"
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_upsert_and_get():
    resp = client.post('/api/v1/profile/', json={'user_id': 1, 'role': 'supplier', 'carbon_score': 5.5})
    assert resp.status_code == 200
    data = resp.json()
    assert data['role'] == 'supplier'

    resp2 = client.get('/api/v1/profile/')
    assert resp2.status_code == 200
    assert any(p['user_id'] == 1 for p in resp2.json())
"@ | Set-Content -Path "$backend\tests\integration\test_profile_endpoints.py" -Encoding utf8
    Write-Host "✅ Created file: tests\integration\test_profile_endpoints.py"

    # 10. pytest.ini
    @"
[pytest]
testpaths = tests
python_files = test_*.py
"@ | Set-Content -Path "$backend\pytest.ini" -Encoding utf8
    Write-Host "✅ Created file: pytest.ini"

    # --------------------
    # FRONTEND SCAFFOLDING
    # --------------------

    # 11. Create frontend directories
    @(
      "$frontend\lib",
      "$frontend\pages\dashboard",
      "$frontend\components",
      "$frontend\cypress\e2e"
    ) | ForEach-Object {
        if (!(Test-Path $_)) {
            New-Item -ItemType Directory -Path $_ -Force | Out-Null
            Write-Host "✅ Created directory: $_"
        } else {
            Write-Host "⚠️ Directory already exists: $_"
        }
    }

    # 12. lib/profile.ts (preserve `${}`)
@'
import axios from "axios";

export interface Profile {
  id: number;
  user_id: number;
  role: string;
  carbon_score: number;
}

const API = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_BASE,
  withCredentials: true
});

export async function getProfiles(role?: string): Promise<Profile[]> {
  const resp = await API.get<Profile[]>(`/profile${role ? `?role=${role}` : ""}`);
  return resp.data;
}

export async function upsertProfile(p: Profile): Promise<Profile> {
  const resp = await API.post<Profile>("/profile/", p);
  return resp.data;
}
'@ | Set-Content -Path "$frontend\lib\profile.ts" -Encoding utf8
    Write-Host "✅ Created file: lib\profile.ts"

    # 13. pages/dashboard/user-profile.tsx
    @"
import { useEffect, useState } from 'react';
import { getProfiles } from '../../lib/profile';
import ProfileList from '../../components/ProfileList';

export default function UserProfilePage() {
  const [profiles, setProfiles] = useState<Profile[]>([]);

  useEffect(() => {
    getProfiles().then(setProfiles);
  }, []);

  return <ProfileList profiles={profiles} />;
}
"@ | Set-Content -Path "$frontend\pages\dashboard\user-profile.tsx" -Encoding utf8
    Write-Host "✅ Created file: pages\dashboard\user-profile.tsx"

    # 14. components/ProfileList.tsx
    @"
import { Profile } from '../lib/profile';

export default function ProfileList({ profiles }: { profiles: Profile[] }) {
  return (
    <table>
      <thead>
        <tr><th>User</th><th>Role</th><th>Score</th></tr>
      </thead>
      <tbody>
        {profiles.map(p => (
          <tr key={p.id}>
            <td>{p.user_id}</td>
            <td>{p.role}</td>
            <td>{p.carbon_score}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
"@ | Set-Content -Path "$frontend\components\ProfileList.tsx" -Encoding utf8
    Write-Host "✅ Created file: components\ProfileList.tsx"

    # 15. Cypress test
    @"
describe('UserProfile flow', () => {
  const user = { user_id: 3, role: 'admin', carbon_score: 12.5 };

  it('creates via API and displays in table', () => {
    cy.request('POST', '/api/v1/profile/', user);
    cy.visit('/dashboard/user-profile');
    cy.contains(user.role);
  });
});
"@ | Set-Content -Path "$frontend\cypress\e2e\profile.spec.js" -Encoding utf8
    Write-Host "✅ Created file: cypress\e2e\profile.spec.js"

    # 16. Install dependencies
    Write-Host "🚀 Installing backend dependencies..."
    pip install -r "$backend\requirements.txt"
    Write-Host "✅ Backend dependencies installed."

    Write-Host "🚀 Installing frontend dependencies..."
    npm install axios js-cookie next react react-dom typescript @types/react @types/node cypress --prefix $frontend
    Write-Host "✅ Frontend dependencies installed."
}
catch {
    Write-Host "❌ Error encountered: $_" -ForegroundColor Red
}
finally {
    $endTime = Get-Date
    Write-Host "⏱ Script start: $startTime"
    Write-Host "⏱ Script end:   $endTime"
    Write-Host "⏱ Duration:     $($endTime - $startTime)"
}

Write-Host "🎉 User-Profile microservice scaffold complete!"
