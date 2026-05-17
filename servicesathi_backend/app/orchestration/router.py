from typing import Optional
from app.orchestration.state import WorkflowState

class WorkflowRouter:
    """
    Evaluates the WorkflowState and dynamically determines the next agent to execute.
    Handles fallback, retry loops, and clarification pauses.
    """
    @staticmethod
    def determine_next_agent(state: WorkflowState) -> Optional[str]:
        # If workflow is not active, stop routing
        if state.status not in ["running", "retrying"]:
            return None
            
        # 1. Intent Extraction
        if "IntentAgent" not in state.completed_steps:
            return "IntentAgent"
            
        # 2. Context Resolution / Clarification Loop
        if state.pending_questions or state.intent_confidence < 0.7 or (state.intent and getattr(state.intent, 'missing_context', None)):
            # If we already asked a question and are waiting, stop routing and pause
            if state.status == "waiting_for_user":
                return None
            if "ContextAgent" not in state.completed_steps:
                 return "ContextAgent"
                 
        # 3. Discovery
        if "DiscoveryAgent" not in state.completed_steps:
            return "DiscoveryAgent"
            
        # 4. Ranking
        if "RankingAgent" not in state.completed_steps:
            return "RankingAgent"
            
        # 5. Booking
        if "BookingAgent" not in state.completed_steps:
            return "BookingAgent"
            
        # 6. Follow-Up
        if "FollowUpAgent" not in state.completed_steps:
            return "FollowUpAgent"
            
        return None

    @staticmethod
    def evaluate_trace(state: WorkflowState, trace):
        """
        Updates state status/confidence based on an agent's trace.
        """
        if trace.status == "error":
            state.last_error = trace.output_summary
            state.status = "retrying" if state.retry_count < state.max_retries else "error"
            return
            
        # Mark successful step
        if trace.agent_name not in state.completed_steps:
            state.completed_steps.append(trace.agent_name)
            
        # Specific Agent Rules
        if trace.agent_name == "ContextAgent":
            state.status = "waiting_for_user"
            state.completed_steps.remove("ContextAgent") # Will re-evaluate once context is provided
            
        elif trace.agent_name == "IntentAgent":
            state.intent_confidence = trace.confidence
            
        elif trace.agent_name == "RankingAgent":
            state.provider_match_confidence = trace.confidence
            
        if "FollowUpAgent" in state.completed_steps:
            state.status = "completed"

    @staticmethod
    def handle_failure(state: WorkflowState, error: Exception):
        """
        Manages workflow failure states and backoff logic.
        """
        state.retry_count += 1
        state.last_error = str(error)
        
        if state.retry_count >= state.max_retries:
            state.status = "error"
            state.overall_confidence = 0.0
        else:
            state.status = "retrying"
