from typing import Dict, Any, List, Optional
from pydantic import BaseModel, Field
import uuid

class WorkflowState(BaseModel):
    """
    Represents the state of a running orchestration workflow.
    This will be serialized to Redis.
    """
    workflow_id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    user_id: str
    original_query: str
    current_location: Optional[Dict[str, float]] = None
    
    # Execution trace
    status: str = "pending" # pending, running, completed, error
    completed_steps: List[str] = Field(default_factory=list)
    
    # Agent outputs
    intent: Optional[Dict[str, Any]] = None
    resolved_context: Optional[Dict[str, Any]] = None
    discovered_providers: List[Dict[str, Any]] = Field(default_factory=list)
    ranked_providers: List[Dict[str, Any]] = Field(default_factory=list)
    booking_result: Optional[Dict[str, Any]] = None
    followup_scheduled: bool = False

    def get_progress(self) -> float:
        total_steps = 6 # intent, context, discovery, ranking, booking, followup
        return len(self.completed_steps) / total_steps
