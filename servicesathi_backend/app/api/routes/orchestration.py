from fastapi import APIRouter, BackgroundTasks, HTTPException
from app.models import ServiceRequest
from app.orchestration.state import WorkflowState
from app.orchestration.engine import WorkflowEngine
from app.services.redis_cache import redis_state
import uuid

router = APIRouter()

async def run_orchestration_background(state: WorkflowState):
    """Background task that runs the orchestration engine."""
    engine = WorkflowEngine(state)
    await engine.run()

@router.post("/orchestrate", status_code=202)
async def start_orchestration(request: ServiceRequest, background_tasks: BackgroundTasks):
    """
    Start an agentic workflow for a given user request.
    Returns a workflow_id immediately, while agents run in the background.
    Clients should connect to the websocket with the workflow_id to get real-time traces.
    """
    workflow_id = f"wf_{uuid.uuid4().hex[:8]}"
    
    # Initialize state
    state = WorkflowState(
        workflow_id=workflow_id,
        user_id=request.user_id,
        original_query=request.query,
        current_location=request.current_location
    )
    
    # Save initial state
    await redis_state.set_state(f"workflow:{workflow_id}", state.model_dump())
    
    # Run the engine in background
    background_tasks.add_task(run_orchestration_background, state)
    
    return {
        "status": "accepted",
        "workflow_id": workflow_id,
        "message": "Orchestration pipeline started. Connect to websocket for live trace updates."
    }
