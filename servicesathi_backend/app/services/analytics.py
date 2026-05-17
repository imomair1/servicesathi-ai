import time
from typing import Dict, Any, List

class AnalyticsService:
    """
    In-memory singleton for capturing and aggregating orchestration metrics.
    In a real production environment, this would write to Datadog/LangSmith.
    """
    
    def __init__(self):
        self.total_workflows: int = 0
        self.active_workflows: int = 0
        self.completed_workflows: int = 0
        self.failed_workflows: int = 0
        
        # Agent specific metrics (latency, error count)
        self.agent_metrics: Dict[str, Dict[str, Any]] = {
            "IntentAgent": {"calls": 0, "errors": 0, "total_ms": 0},
            "ContextAgent": {"calls": 0, "errors": 0, "total_ms": 0},
            "DiscoveryAgent": {"calls": 0, "errors": 0, "total_ms": 0},
            "RankingAgent": {"calls": 0, "errors": 0, "total_ms": 0},
            "BookingAgent": {"calls": 0, "errors": 0, "total_ms": 0},
            "FollowUpAgent": {"calls": 0, "errors": 0, "total_ms": 0},
        }
        
        self.workflow_history: List[Dict[str, Any]] = []

    def log_workflow_start(self, workflow_id: str):
        self.total_workflows += 1
        self.active_workflows += 1

    def log_workflow_end(self, workflow_id: str, status: str, state_dump: dict):
        self.active_workflows = max(0, self.active_workflows - 1)
        if status == "completed":
            self.completed_workflows += 1
        elif status == "error":
            self.failed_workflows += 1
            
        # Store for replay engine (keep last 50)
        self.workflow_history.insert(0, {
            "workflow_id": workflow_id,
            "status": status,
            "timestamp": time.time(),
            "state": state_dump
        })
        if len(self.workflow_history) > 50:
            self.workflow_history.pop()

    def log_agent_trace(self, agent_name: str, duration_ms: int, status: str):
        if agent_name in self.agent_metrics:
            self.agent_metrics[agent_name]["calls"] += 1
            self.agent_metrics[agent_name]["total_ms"] += duration_ms
            if status == "error":
                self.agent_metrics[agent_name]["errors"] += 1

    def get_metrics(self) -> Dict[str, Any]:
        """Calculates derived metrics like avg latency and error rates."""
        stats = {}
        for agent, data in self.agent_metrics.items():
            calls = data["calls"]
            avg_ms = int(data["total_ms"] / calls) if calls > 0 else 0
            error_rate = (data["errors"] / calls) if calls > 0 else 0.0
            
            stats[agent] = {
                "calls": calls,
                "avg_latency_ms": avg_ms,
                "error_rate": error_rate
            }
            
        return {
            "workflows": {
                "total": self.total_workflows,
                "active": self.active_workflows,
                "completed": self.completed_workflows,
                "failed": self.failed_workflows
            },
            "agents": stats
        }

# Global singleton
analytics_service = AnalyticsService()
