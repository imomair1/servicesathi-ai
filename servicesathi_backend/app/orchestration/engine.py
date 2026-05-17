import asyncio
from app.orchestration.state import WorkflowState
from app.orchestration.agents.intent import IntentAgent
from app.orchestration.agents.discovery import DiscoveryAgent
from app.orchestration.agents.ranking import RankingAgent
from app.orchestration.agents.booking import BookingAgent
from app.orchestration.agents.follow_up import FollowUpAgent

class WorkflowEngine:
    def __init__(self, state: WorkflowState):
        self.state = state
        self.intent_agent = IntentAgent()
        self.discovery_agent = DiscoveryAgent()
        self.ranking_agent = RankingAgent()
        self.booking_agent = BookingAgent()
        self.follow_up_agent = FollowUpAgent()

    async def run(self):
        """
        Executes the agentic DAG pipeline.
        In a full Antigravity setup, this would be a managed workflow graph.
        """
        self.state.status = "running"
        await self._publish_state()

        agents_to_run = [
            self.intent_agent,
            self.discovery_agent,
            self.ranking_agent,
            self.booking_agent,
            self.follow_up_agent
        ]

        for agent in agents_to_run:
            trace = await agent.execute(self.state)
            await self._publish_trace(trace)
            
            if trace.status == "error":
                self.state.status = "error"
                await self._publish_state()
                return
        
        self.state.status = "completed"
        await self._publish_state()

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

