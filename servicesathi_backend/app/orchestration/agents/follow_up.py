import time
import asyncio
from app.orchestration.agents.base import BaseAgent
from app.orchestration.state import WorkflowState
from app.models import AgentTrace

class FollowUpAgent(BaseAgent):
    def __init__(self):
        super().__init__(name="Follow-Up Agent", icon="🔔")

    async def execute(self, state: WorkflowState) -> AgentTrace:
        start_time = time.time()
        
        try:
            if not state.booking_result:
                raise ValueError("No booking result found. Cannot schedule follow-ups.")

            # Simulate scheduling delayed jobs / cron tasks
            await asyncio.sleep(0.3)
            
            state.followup_scheduled = True
            state.completed_steps.append("followup")
            
            duration_ms = int((time.time() - start_time) * 1000)
            
            return AgentTrace(
                agent_name=self.name,
                action="Scheduling reminders",
                status="completed",
                duration_ms=duration_ms,
                confidence=1.0,
                output_summary="2 reminders + satisfaction survey scheduled",
                details={
                    "reminder_1": "1 hour before service",
                    "reminder_2": "15 min before arrival",
                    "survey": "After service completion"
                }
            )
        except Exception as e:
            duration_ms = int((time.time() - start_time) * 1000)
            return AgentTrace(
                agent_name=self.name,
                action="Scheduling reminders",
                status="error",
                duration_ms=duration_ms,
                confidence=0.0,
                output_summary=str(e),
                details={"error": str(e)}
            )
