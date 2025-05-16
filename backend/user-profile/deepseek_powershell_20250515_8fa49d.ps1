<#
.SYNOPSIS
Sets up the testing environment for FastAPI backend
#>

param(
    [string]$ProjectPath = "D:\CTMVP1\backend\user-profile"
)

# 1. Create directory structure
$directories = @(
    "tests\integration",
    "src\app\api\v1\endpoints",
    "src\app\models",
    "src\app\db"
)

foreach ($dir in $directories) {
    $fullPath = Join-Path -Path $ProjectPath -ChildPath $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "Created directory: $fullPath"
    }
}

# 2. Create test files
$testFiles = @{
    "tests\integration\test_profile_endpoints.py" = @'
from fastapi.testclient import TestClient
from src.app.main import app

client = TestClient(app)

def test_create_profile():
    profile_data = {
        "email": "test@example.com",
        "name": "Test User",
        "esg_score": 75
    }
    response = client.post("/profiles/", json=profile_data)
    assert response.status_code == 200
    assert response.json()["email"] == "test@example.com"
'@
    
    "tests\conftest.py" = @'
import pytest
from src.app.db.session import engine, Base

@pytest.fixture(scope="session", autouse=True)
def setup_db():
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)
'@
}

foreach ($file in $testFiles.GetEnumerator()) {
    $fullPath = Join-Path -Path $ProjectPath -ChildPath $file.Key
    $file.Value | Out-File -FilePath $fullPath -Encoding utf8
    Write-Host "Created test file: $fullPath"
}

# 3. Update requirements
$requirements = @'
fastapi>=0.68.0
pytest>=7.0.0
httpx>=0.23.0
pytest-cov>=3.0.0
sqlalchemy>=1.4.0
uvicorn>=0.15.0
python-dotenv>=0.19.0
'@

$requirementsPath = Join-Path -Path $ProjectPath -ChildPath "requirements.txt"
$requirements | Out-File -FilePath $requirementsPath -Encoding utf8
Write-Host "Updated requirements.txt"

# 4. Install packages
Write-Host "Installing/updating packages..."
Start-Process -FilePath "pip" -ArgumentList "install -r requirements.txt --upgrade" -Wait -NoNewWindow

# 5. Run tests
Write-Host "Running tests with coverage..."
Set-Location -Path $ProjectPath
pytest tests/ --cov=src --cov-report=term-missing -v

Write-Host "Test environment setup complete!"