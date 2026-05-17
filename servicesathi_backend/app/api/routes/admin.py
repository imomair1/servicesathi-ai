from fastapi import APIRouter
from pydantic import BaseModel
from app.services.analytics import analytics_service
from app.core.config import settings

router = APIRouter()

class DemoConfigUpdate(BaseModel):
    demo_mode: bool
    presentation_mode: bool

@router.post("/config")
async def update_demo_config(config: DemoConfigUpdate):
    """Dynamically toggle Demo Mode without restarting the server."""
    settings.DEMO_MODE = config.demo_mode
    settings.PRESENTATION_MODE = config.presentation_mode
    return {"status": "success", "demo_mode": settings.DEMO_MODE, "presentation_mode": settings.PRESENTATION_MODE}

@router.get("/health")
async def get_system_health():
    """Returns system health metrics."""
    return {
        "status": "operational",
        "redis_connected": True, # Hardcoded for now
        "demo_mode_active": settings.DEMO_MODE,
        "presentation_mode": settings.PRESENTATION_MODE
    }

@router.get("/metrics")
async def get_metrics():
    """Returns live aggregated orchestration metrics."""
    return analytics_service.get_metrics()

@router.get("/history")
async def get_workflow_history():
    """Returns recently completed workflows for the replay engine."""
    return {"history": analytics_service.workflow_history}
