from fastapi import APIRouter
from app.api.routes.orchestration import router as orchestration_router

api_router = APIRouter()

api_router.include_router(orchestration_router, tags=["Orchestration"])

# Example route
@api_router.get("/status")
async def status():
    return {"status": "operational"}
