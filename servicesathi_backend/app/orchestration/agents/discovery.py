import time
from typing import List
from pydantic import BaseModel, Field
from app.orchestration.agents.base import BaseAgent
from app.orchestration.state import WorkflowState
from app.models import AgentTrace

# Using mock providers for the prototype
MOCK_PROVIDERS = [
    {"id": "p_001", "name": "Ali AC Services", "service_type": "ac_repair", "city": "Lahore", "area": "Gulberg", "rating": 4.8, "price_min": 800, "price_max": 2500, "experience_years": 8, "distance": 2.3},
    {"id": "p_002", "name": "Hassan Cool Tech", "service_type": "ac_repair", "city": "Lahore", "area": "Model Town", "rating": 4.6, "price_min": 600, "price_max": 2000, "experience_years": 5, "distance": 3.8},
    {"id": "p_003", "name": "Ustad Rafiq Electric", "service_type": "ac_repair", "city": "Lahore", "area": "DHA Phase 5", "rating": 4.9, "price_min": 1000, "price_max": 3500, "experience_years": 12, "distance": 5.1},
    {"id": "p_004", "name": "Bashir Plumbing", "service_type": "plumbing", "city": "Lahore", "area": "Gulberg", "rating": 4.5, "price_min": 500, "price_max": 1500, "experience_years": 6, "distance": 1.2},
]

class DiscoveryAgent(BaseAgent):
    def __init__(self):
        super().__init__(name="Discovery Agent", icon="🔍")

    async def execute(self, state: WorkflowState) -> AgentTrace:
        start_time = time.time()
        
        try:
            if not state.intent:
                raise ValueError("No intent found in state. Cannot discover providers.")

            service_type = state.intent.get("service_type")
            location = state.intent.get("location", "")

            # Simulate DB query delay
            await asyncio.sleep(0.5)

            # Basic filtering logic
            discovered = [
                p for p in MOCK_PROVIDERS 
                if p["service_type"] == service_type 
            ]

            # In a real app, we'd use geospatial querying against Firestore here
            
            state.discovered_providers = discovered
            state.completed_steps.append("discovery")
            
            duration_ms = int((time.time() - start_time) * 1000)
            
            return AgentTrace(
                agent_name=self.name,
                action="Searching provider database",
                status="completed",
                duration_ms=duration_ms,
                confidence=1.0,
                output_summary=f"Found {len(discovered)} providers matching criteria",
                details={
                    "total_found": len(discovered),
                    "search_criteria": {"service": service_type, "location": location}
                }
            )
        except Exception as e:
            duration_ms = int((time.time() - start_time) * 1000)
            return AgentTrace(
                agent_name=self.name,
                action="Searching provider database",
                status="error",
                duration_ms=duration_ms,
                confidence=0.0,
                output_summary=str(e),
                details={"error": str(e)}
            )
