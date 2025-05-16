from fastapi import FastAPI
from app.api.auth.auth import router as auth_router

# import your DB engine and Base
from database import engine, Base

app = FastAPI(title="Auth Service")

# include your auth router under /auth
app.include_router(auth_router, prefix="/auth", tags=["auth"])

# auto-create tables on startup
@app.on_event("startup")
def create_db_and_tables():
    Base.metadata.create_all(bind=engine)
