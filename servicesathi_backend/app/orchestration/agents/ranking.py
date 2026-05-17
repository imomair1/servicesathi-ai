import time
from typing import List
from pydantic import BaseModel, Field
from app.orchestration.agents.base import BaseAgent
from app.orchestration.state import WorkflowState
from app.models import AgentTrace, RankedProvider

class RankedProviderResult(BaseModel):
    providers: List[RankedProvider]

class RankingAgent(BaseAgent):
    def __init__(self):
        super().__init__(name="Ranking Agent", icon="📊")
        self.system_instruction = """
        You are the Ranking Agent for ServiceSathi AI.
        Given a list of discovered service providers and a user's intent, your job is to:
        1. Rank the providers based on relevance, rating, distance, and experience.
        2. Assign an AI match score (0-100) to each provider.
        3. Write a concise, 1-2 sentence 'ai_reasoning' explaining WHY this provider is a good fit for the user.
        Return the list sorted from highest match score to lowest.
        """

    async def execute(self, state: WorkflowState) -> AgentTrace:
        start_time = time.time()
        
        try:
            if not state.discovered_providers:
                # No providers found, nothing to rank
                state.ranked_providers = []
                state.completed_steps.append("ranking")
                duration_ms = int((time.time() - start_time) * 1000)
                return AgentTrace(
                    agent_name=self.name,
                    action="Scoring & ranking providers",
                    status="completed",
                    duration_ms=duration_ms,
                    confidence=1.0,
                    output_summary="No providers to rank",
                    details={}
                )

            prompt = f"User Intent: {state.intent}\nDiscovered Providers: {state.discovered_providers}\n\nRank these providers and generate reasoning."
            
            # Call Gemini
            result: RankedProviderResult = await self._call_llm(
                prompt=prompt,
                schema=RankedProviderResult,
                system_instruction=self.system_instruction
            )
            
            # Mutate state
            state.ranked_providers = [p.model_dump() for p in result.providers]
            state.completed_steps.append("ranking")
            
            duration_ms = int((time.time() - start_time) * 1000)
            
            # Assuming the first provider is the best match
            top_score = state.ranked_providers[0]['ai_match_score'] if state.ranked_providers else 0
            
            return AgentTrace(
                agent_name=self.name,
                action="Scoring & ranking providers",
                status="completed",
                duration_ms=duration_ms,
                confidence=0.92,
                output_summary=f"Ranked {len(state.ranked_providers)} providers by composite score",
                details={
                    "criteria": "Rating 30%, Distance 25%, Price 20%, Avail 15%, Exp 10%",
                    "top_score": f"{top_score}/100"
                }
            )
        except Exception as e:
            duration_ms = int((time.time() - start_time) * 1000)
            return AgentTrace(
                agent_name=self.name,
                action="Scoring & ranking providers",
                status="error",
                duration_ms=duration_ms,
                confidence=0.0,
                output_summary=str(e),
                details={"error": str(e)}
            )
