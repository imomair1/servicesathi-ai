import asyncio
import time
from app.orchestration.agents.base import BaseAgent
from app.models import AgentTrace
from app.orchestration.state import WorkflowState

class ContextAgent(BaseAgent):
    """
    Evaluates missing context and formulates a clarification question.
    """
    def __init__(self):
        super().__init__("ContextAgent")

    async def execute(self, state: WorkflowState) -> AgentTrace:
        start_time = time.time()
        
        try:
            missing = state.intent.get("missing_context", []) if state.intent else []
            
            question = "Can you provide more details?"
            if "location" in missing:
                question = "Which area or city do you need this service in?"
            elif "service_type" in missing:
                question = "Could you clarify exactly what service you need?"
                
            state.pending_questions.append(question)
            
            duration = int((time.time() - start_time) * 1000)
            return self.create_trace(
                action="Clarification Required",
                status="completed",
                confidence=1.0,
                output_summary=f"Asked user: {question}",
                details={"question": question},
                duration_ms=duration
            )
            
        except Exception as e:
            duration = int((time.time() - start_time) * 1000)
            return self.create_trace(
                action="Context Error",
                status="error",
                confidence=0.0,
                output_summary=str(e),
                duration_ms=duration
            )
