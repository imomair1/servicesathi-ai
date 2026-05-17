import time
from typing import Any
from pydantic import BaseModel
from app.orchestration.agents.base import BaseAgent
from app.orchestration.state import WorkflowState
from app.models import AgentTrace, IntentExtraction

class IntentAgent(BaseAgent):
    def __init__(self):
        super().__init__(name="IntentAgent", icon="🧠")
        self.system_instruction = """
        You are an Intent Extraction Agent for ServiceSathi AI.
        Analyze user requests for home services in Pakistan. Language: English, Urdu, or Roman Urdu.
        Extract service, location, urgency, language, and budget.
        Normalize the service type to: ['ac_repair', 'plumbing', 'electrical', 'beauty', 'tutoring', 'mechanic', 'other'].
        CRITICAL: If essential context like 'location' is missing, set `confidence` below 0.7 and add 'location' to the `missing_context` list.
        If the service is completely ambiguous, add 'service_type' to `missing_context`.
        """

    async def execute(self, state: WorkflowState) -> AgentTrace:
        start_time = time.time()
        
        prompt = f"Analyze the following request:\nQuery: {state.original_query}\nUser Location context: {state.current_location}\nPrevious Answers: {state.resolved_context}"
        
        try:
            # Call Gemini
            extracted: IntentExtraction = await self._call_llm(
                prompt=prompt,
                schema=IntentExtraction,
                system_instruction=self.system_instruction
            )
            
            # Mutate state
            state.intent = extracted.model_dump()
            
            duration_ms = int((time.time() - start_time) * 1000)
            
            # If missing context, output summary reflects it
            summary = f"Detected: {extracted.service_type} in {extracted.location}"
            if extracted.missing_context:
                summary = f"Missing context: {', '.join(extracted.missing_context)}"
                
            return self.create_trace(
                action="Analyzing natural language input",
                status="completed",
                confidence=extracted.confidence,
                output_summary=summary,
                details=state.intent,
                duration_ms=duration_ms
            )
        except Exception as e:
            duration_ms = int((time.time() - start_time) * 1000)
            return self.create_trace(
                action="Analyzing natural language input",
                status="error",
                confidence=0.0,
                output_summary=str(e),
                details={"error": str(e)},
                duration_ms=duration_ms
            )
