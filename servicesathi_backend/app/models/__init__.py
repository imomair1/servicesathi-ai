from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any

class ServiceRequest(BaseModel):
    query: str = Field(..., description="Natural language request in English, Urdu, or Roman Urdu")
    user_id: str = Field(..., description="ID of the user making the request")
    current_location: Optional[Dict[str, float]] = Field(None, description="Lat/long if available")

class IntentExtraction(BaseModel):
    service_type: str
    location: str
    urgency: str
    language: str
    budget_range: Optional[str] = None
    confidence: float

class Provider(BaseModel):
    id: str
    name: str
    service_type: str
    city: str
    area: str
    rating: float
    distance: float
    price_min: int
    price_max: int
    experience_years: int

class RankedProvider(Provider):
    ai_match_score: int
    ai_reasoning: str

class AgentTrace(BaseModel):
    agent_name: str
    action: str
    status: str
    duration_ms: int
    confidence: float
    output_summary: str
    details: Dict[str, Any] = {}
