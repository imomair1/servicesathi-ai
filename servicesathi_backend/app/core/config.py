from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    PROJECT_NAME: str = "ServiceSathi AI"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # Demo & Presentation
    DEMO_MODE: bool = True
    PRESENTATION_MODE: bool = False
    
    # LLM Settings
    GEMINI_API_KEY: str = ""
    
    # Redis Settings
    REDIS_URL: str = "redis://localhost:6379/0"
    
    # Security
    SECRET_KEY: str = "your-super-secret-key-change-in-production"
    
    model_config = SettingsConfigDict(env_file=".env", case_sensitive=True, extra="ignore")

settings = Settings()
