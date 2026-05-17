from typing import Dict, Any, List, Optional
from pydantic import BaseModel, Field
import uuid

class WorkflowState(BaseModel):
    """
    Represents the state of a running orchestration workflow.
    """
    workflow_id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    user_id: str
    original_query: str
    current_location: Optional[Dict[str, float]] = None
    
    # Execution trace
    status: str = "pending" # pending, running, waiting_for_user, retrying, completed, error
    completed_steps: List[str] = Field(default_factory=list)
    pending_questions: List[str] = Field(default_factory=list)
    
    # Confidence and Retry Tracking
    overall_confidence: float = 1.0
    intent_confidence: float = 1.0
    provider_match_confidence: float = 1.0
    retry_count: int = 0
    max_retries: int = 3
    last_error: Optional[str] = None
    
    # Agent outputs
    intent: Optional[Dict[str, Any]] = None
    resolved_context: Optional[Dict[str, Any]] = None
    discovered_providers: List[Dict[str, Any]] = Field(default_factory=list)
    ranked_providers: List[Dict[str, Any]] = Field(default_factory=list)
    booking_result: Optional[Dict[str, Any]] = None
    followup_scheduled: bool = False

    def get_progress(self) -> float:
        total_steps = 6
        return min(1.0, len(self.completed_steps) / total_steps)
