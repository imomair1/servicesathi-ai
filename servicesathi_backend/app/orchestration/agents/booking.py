import time
import uuid
import asyncio
from typing import Dict, Any
from app.orchestration.agents.base import BaseAgent
from app.orchestration.state import WorkflowState
from app.models import AgentTrace

import time
import uuid
import asyncio
from typing import Dict, Any
from app.orchestration.agents.base import BaseAgent
from app.orchestration.state import WorkflowState
from app.models import AgentTrace

class BookingAgent(BaseAgent):
    def __init__(self):
        super().__init__(name="BookingAgent", icon="📋")

    async def execute(self, state: WorkflowState) -> AgentTrace:
        start_time = time.time()
        
        try:
            if not state.ranked_providers:
                raise ValueError("No ranked providers available to book.")

            # Selection logic: If retrying, try the next provider
            # e.g., retry_count 0 -> index 0; retry_count 1 -> index 1
            provider_index = min(state.retry_count, len(state.ranked_providers) - 1)
            selected_provider = state.ranked_providers[provider_index]
            
            # Simulate API call to the provider's external system
            await asyncio.sleep(0.8)
            
            # Simulate a 30% failure rate on the first try to demonstrate compensation
            import random
            if state.retry_count == 0 and random.random() < 0.3:
                raise ConnectionError(f"Provider {selected_provider['name']} system rejected the booking request. Timeout.")
            
            booking_id = f"BK-{uuid.uuid4().hex[:8].upper()}"
            
            state.booking_result = {
                "booking_id": booking_id,
                "provider_id": selected_provider["id"],
                "provider_name": selected_provider["name"],
                "status": "confirmed",
                "estimated_cost": f"{selected_provider['price_min']} PKR",
                "time_slot": "Today, 3:00 PM" # Mock timeslot
            }
            
            duration_ms = int((time.time() - start_time) * 1000)
            
            return self.create_trace(
                action="Executing booking transaction",
                status="completed",
                confidence=1.0,
                output_summary=f"Booking confirmed: {booking_id} with {selected_provider['name']}",
                details={
                    "booking_id": booking_id,
                    "provider": selected_provider["name"],
                    "est_cost": f"{selected_provider['price_min']} PKR",
                    "time_slot": "Today, 3:00 PM",
                    "retry_attempt": state.retry_count
                },
                duration_ms=duration_ms
            )
        except Exception as e:
            duration_ms = int((time.time() - start_time) * 1000)
            return self.create_trace(
                action="Executing booking transaction",
                status="error",
                confidence=0.0,
                output_summary=str(e),
                details={"error": str(e)},
                duration_ms=duration_ms
            )
