import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.routes import api_router
from app.api.websockets import ws_router

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.PROJECT_NAME,
        version=settings.VERSION,
        description="Agentic AI Service Orchestrator API for the informal economy",
    )

    # Set up CORS
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],  # In production, specify exact domains
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Include routers
    app.include_router(api_router, prefix=settings.API_V1_STR)
    app.include_router(ws_router, prefix="/ws")

    # Global Exception Handler
    from app.core.exceptions import global_exception_handler
    app.add_exception_handler(Exception, global_exception_handler)

    @app.get("/health", tags=["Health"])
    async def health_check():
        return {"status": "ok", "version": settings.VERSION}

    return app

app = create_app()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
