from fastapi import APIRouter
from app.api.routes.orchestration import router as orchestration_router
from app.api.routes.admin import router as admin_router

api_router = APIRouter()

api_router.include_router(orchestration_router, tags=["Orchestration"])
api_router.include_router(admin_router, prefix="/admin", tags=["Admin Analytics"])

# Example route
@api_router.get("/status")
async def status():
    return {"status": "operational"}
