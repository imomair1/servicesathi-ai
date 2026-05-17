import time
from typing import Any
from pydantic import BaseModel
from app.orchestration.agents.base import BaseAgent
from app.orchestration.state import WorkflowState
from app.models import AgentTrace, IntentExtraction

class IntentAgent(BaseAgent):
    def __init__(self):
        super().__init__(name="Intent Agent", icon="🧠")
        self.system_instruction = """
        You are an Intent Extraction Agent for ServiceSathi AI.
        Your job is to analyze user requests for home services in Pakistan.
        The user might speak English, Urdu, or Roman Urdu (e.g., 'mujhe AC theek karwana hai').
        Extract the required service, location, urgency, language used, and any budget mentioned.
        Normalize the service type to one of: ['ac_repair', 'plumbing', 'electrical', 'beauty', 'tutoring', 'mechanic', 'other'].
        """

    async def execute(self, state: WorkflowState) -> AgentTrace:
        start_time = time.time()
        
        prompt = f"Analyze the following request:\nQuery: {state.original_query}\nUser Location context: {state.current_location}"
        
        try:
            # Call Gemini
            extracted: IntentExtraction = await self._call_llm(
                prompt=prompt,
                schema=IntentExtraction,
                system_instruction=self.system_instruction
            )
            
            # Mutate state
            state.intent = extracted.model_dump()
            state.completed_steps.append("intent")
            
            duration_ms = int((time.time() - start_time) * 1000)
            
            # Return trace
            return AgentTrace(
                agent_name=self.name,
                action="Analyzing natural language input",
                status="completed",
                duration_ms=duration_ms,
                confidence=extracted.confidence,
                output_summary=f"Detected: {extracted.service_type} in {extracted.location}, {extracted.urgency} urgency",
                details=state.intent
            )
        except Exception as e:
            duration_ms = int((time.time() - start_time) * 1000)
            return AgentTrace(
                agent_name=self.name,
                action="Analyzing natural language input",
                status="error",
                duration_ms=duration_ms,
                confidence=0.0,
                output_summary=str(e),
                details={"error": str(e)}
            )
