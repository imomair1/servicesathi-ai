import asyncio
from app.orchestration.state import WorkflowState
from app.orchestration.router import WorkflowRouter
from app.orchestration.agents.intent import IntentAgent
from app.orchestration.agents.context import ContextAgent
from app.orchestration.agents.discovery import DiscoveryAgent
from app.orchestration.agents.ranking import RankingAgent
from app.orchestration.agents.booking import BookingAgent
from app.orchestration.agents.follow_up import FollowUpAgent
from app.services.analytics import analytics_service
from app.core.config import settings

class WorkflowEngine:
    def __init__(self, state: WorkflowState):
        self.state = state
        self.router = WorkflowRouter()
        
        self.agents = {
            "IntentAgent": IntentAgent(),
            "ContextAgent": ContextAgent(),
            "DiscoveryAgent": DiscoveryAgent(),
            "RankingAgent": RankingAgent(),
            "BookingAgent": BookingAgent(),
            "FollowUpAgent": FollowUpAgent()
        }

    async def run(self):
        """
        Executes the dynamic agentic pipeline using a state machine controller.
        """
        if self.state.status == "pending":
            self.state.status = "running"
            analytics_service.log_workflow_start(self.state.workflow_id)
            
        await self._publish_state()

        while self.state.status in ["running", "retrying"]:
            next_agent_name = self.router.determine_next_agent(self.state)
            
            if not next_agent_name:
                break # Wait for user or completed
                
            agent = self.agents.get(next_agent_name)
            
            if self.state.status == "retrying":
                # Implement exponential backoff
                backoff_time = 2 ** self.state.retry_count
                await asyncio.sleep(min(backoff_time, 5))
                self.state.status = "running"

            try:
                trace = await agent.execute(self.state)
                
                # Log to analytics
                analytics_service.log_agent_trace(trace.agent_name, trace.duration_ms, trace.status)
                
                self.router.evaluate_trace(self.state, trace)
                await self._publish_trace(trace)
                
            except Exception as e:
                self.router.handle_failure(self.state, e)
                analytics_service.log_agent_trace(next_agent_name, 0, "error")
                await self._publish_state()
                
            # Yield to event loop to allow UI updates
            sleep_time = 2.0 if settings.PRESENTATION_MODE else 0.5
            await asyncio.sleep(sleep_time)

        # Final state publish
        await self._publish_state()
        
        if self.state.status in ["completed", "error", "waiting_for_user"]:
            analytics_service.log_workflow_end(self.state.workflow_id, self.state.status, self.state.model_dump())

    async def _publish_trace(self, trace):
        from app.services.redis_cache import redis_state
        print(f"[TRACE] {trace.agent_name} -> {trace.status} ({trace.duration_ms}ms)")
        print(f"        {trace.output_summary}")
        await redis_state.publish_trace(
            channel=f"trace:{self.state.workflow_id}",
            message={
                "type": "agent_trace",
                "data": trace.model_dump()
            }
        )

    async def _publish_state(self):
        from app.services.redis_cache import redis_state
        from app.services.firestore import FirestoreRepo
        
        state_dump = self.state.model_dump()
        
        # 1. Update Redis cache
        await redis_state.set_state(f"workflow:{self.state.workflow_id}", state_dump)
        
        # 2. Publish state update to websocket clients
        await redis_state.publish_trace(
            channel=f"trace:{self.state.workflow_id}",
            message={
                "type": "workflow_state",
                "data": state_dump
            }
        )
        
        # 3. Log completed workflows to Firestore
        if self.state.status in ["completed", "error"]:
            FirestoreRepo.log_workflow(self.state.workflow_id, state_dump)
            if self.state.booking_result:
                FirestoreRepo.create_booking(self.state.booking_result)
