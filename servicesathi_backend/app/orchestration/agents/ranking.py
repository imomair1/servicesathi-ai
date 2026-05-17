import time
import asyncio
from typing import List
from pydantic import BaseModel
from app.orchestration.agents.base import BaseAgent
from app.orchestration.state import WorkflowState
from app.models import AgentTrace, RankedProvider

class ReasoningOutput(BaseModel):
    reasoning: str

class RankingAgent(BaseAgent):
    def __init__(self):
        super().__init__(name="RankingAgent", icon="📊")
        self.system_instruction = """
        You are the Ranking Reasoning Agent for ServiceSathi AI.
        Look at the top ranked provider selected by the algorithm and the user's intent.
        Write a concise, 1-2 sentence explanation of WHY this provider is a great fit.
        Keep it professional and highlight their key strengths (e.g., rating, proximity, availability).
        """

    async def execute(self, state: WorkflowState) -> AgentTrace:
        start_time = time.time()
        
        try:
            if not state.discovered_providers:
                duration_ms = int((time.time() - start_time) * 1000)
                return self.create_trace(
                    action="Scoring & ranking providers",
                    status="completed",
                    confidence=1.0,
                    output_summary="No providers to rank",
                    details={},
                    duration_ms=duration_ms
                )

            ranked_providers = []
            
            # Algorithmic Scoring
            for p in state.discovered_providers:
                # Normalize values
                rating_score = p.get('rating', 0) / 5.0
                dist = p.get('distance', 10.0)
                distance_score = max(0, (10.0 - dist) / 10.0)
                availability_score = 1.0 if p.get('is_available', True) else 0.0
                trust_score = min(1.0, p.get('experience_years', 0) / 15.0)
                
                # Weighted formula
                composite_score = (
                    (0.35 * rating_score) +
                    (0.25 * distance_score) +
                    (0.30 * availability_score) +
                    (0.10 * trust_score)
                )
                
                ai_match_score = int(composite_score * 100)
                
                ranked_providers.append(RankedProvider(
                    **p,
                    ai_match_score=ai_match_score,
                    ai_reasoning="", # Will generate for top pick
                    rating_score=rating_score,
                    distance_score=distance_score,
                    availability_score=availability_score
                ))
            
            # Sort descending
            ranked_providers.sort(key=lambda x: x.ai_match_score, reverse=True)
            
            # Generate AI Reasoning for top pick
            top_provider = ranked_providers[0]
            prompt = f"User Intent: {state.intent}\nTop Selected Provider: {top_provider.model_dump()}\n\nGenerate the 'reasoning' explanation."
            
            reasoning_result: ReasoningOutput = await self._call_llm(
                prompt=prompt,
                schema=ReasoningOutput,
                system_instruction=self.system_instruction
            )
            
            top_provider.ai_reasoning = reasoning_result.reasoning
            
            # Mutate state
            state.ranked_providers = [p.model_dump() for p in ranked_providers]
            
            duration_ms = int((time.time() - start_time) * 1000)
            
            # Confidence based on score
            top_score = top_provider.ai_match_score
            confidence = top_score / 100.0
            
            return self.create_trace(
                action="Scoring & ranking providers",
                status="completed",
                confidence=confidence,
                output_summary=f"Ranked {len(state.ranked_providers)} providers. Top match: {top_score}/100",
                details={
                    "criteria": "Rating 35%, Distance 25%, Avail 30%, Exp 10%",
                    "top_score": f"{top_score}/100",
                    "reasoning": top_provider.ai_reasoning
                },
                duration_ms=duration_ms
            )
        except Exception as e:
            duration_ms = int((time.time() - start_time) * 1000)
            return self.create_trace(
                action="Scoring & ranking providers",
                status="error",
                confidence=0.0,
                output_summary=str(e),
                details={"error": str(e)},
                duration_ms=duration_ms
            )
