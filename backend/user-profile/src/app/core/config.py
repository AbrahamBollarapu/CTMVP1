from pydantic import BaseSettings

class Settings(BaseSettings):
    app_name: str = 'UserProfileService'

settings = Settings()
