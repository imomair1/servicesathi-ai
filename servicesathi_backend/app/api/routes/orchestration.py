from fastapi import APIRouter, BackgroundTasks, HTTPException
from app.models import ServiceRequest, ClarificationReply
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

@router.post("/workflows/{workflow_id}/clarify", status_code=202)
async def clarify_workflow(workflow_id: str, reply: ClarificationReply, background_tasks: BackgroundTasks):
    """
    Submit an answer to a clarification question, resuming a WAITING_FOR_USER workflow.
    """
    raw_state = await redis_state.get_state(f"workflow:{workflow_id}")
    if not raw_state:
        raise HTTPException(status_code=404, detail="Workflow not found")
        
    state = WorkflowState(**raw_state)
    
    if state.status != "waiting_for_user":
        raise HTTPException(status_code=400, detail=f"Workflow is not waiting for user. Current status: {state.status}")
        
    # Append to resolved context
    if state.resolved_context is None:
        state.resolved_context = {}
        
    if state.pending_questions:
        last_q = state.pending_questions.pop()
        state.resolved_context[last_q] = reply.reply
        
    if reply.current_location:
        state.current_location = reply.current_location
        
    # Remove IntentAgent from completed steps to force a re-evaluation
    if "IntentAgent" in state.completed_steps:
        state.completed_steps.remove("IntentAgent")
        
    # Resume workflow
    state.status = "running"
    await redis_state.set_state(f"workflow:{workflow_id}", state.model_dump())
    
    background_tasks.add_task(run_orchestration_background, state)
    
    return {
        "status": "resumed",
        "workflow_id": workflow_id,
        "message": "Clarification accepted. Workflow resumed."
    }
