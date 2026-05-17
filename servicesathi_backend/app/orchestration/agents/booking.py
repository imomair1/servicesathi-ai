import time
import uuid
import asyncio
from typing import Dict, Any
from app.orchestration.agents.base import BaseAgent
from app.orchestration.state import WorkflowState
from app.models import AgentTrace

class BookingAgent(BaseAgent):
    def __init__(self):
        super().__init__(name="Booking Agent", icon="📋")

    async def execute(self, state: WorkflowState) -> AgentTrace:
        start_time = time.time()
        
        try:
            if not state.ranked_providers:
                raise ValueError("No ranked providers available to book.")

            # For simulation, pick the top ranked provider
            top_provider = state.ranked_providers[0]
            
            # Simulate API call to the provider's external system
            await asyncio.sleep(0.8)
            
            booking_id = f"BK-{uuid.uuid4().hex[:8].upper()}"
            
            state.booking_result = {
                "booking_id": booking_id,
                "provider_id": top_provider["id"],
                "provider_name": top_provider["name"],
                "status": "confirmed",
                "estimated_cost": f"{top_provider['price_min']} PKR",
                "time_slot": "Today, 3:00 PM" # Mock timeslot
            }
            state.completed_steps.append("booking")
            
            duration_ms = int((time.time() - start_time) * 1000)
            
            return AgentTrace(
                agent_name=self.name,
                action="Simulating booking",
                status="completed",
                duration_ms=duration_ms,
                confidence=1.0,
                output_summary=f"Booking simulated: {booking_id}",
                details={
                    "booking_id": booking_id,
                    "provider": top_provider["name"],
                    "est_cost": f"{top_provider['price_min']} PKR",
                    "time_slot": "Today, 3:00 PM"
                }
            )
        except Exception as e:
            duration_ms = int((time.time() - start_time) * 1000)
            return AgentTrace(
                agent_name=self.name,
                action="Simulating booking",
                status="error",
                duration_ms=duration_ms,
                confidence=0.0,
                output_summary=str(e),
                details={"error": str(e)}
            )
