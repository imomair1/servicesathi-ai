import abc
from app.orchestration.state import WorkflowState
from app.models import AgentTrace
from google import genai
from google.genai import types
from app.core.config import settings

class BaseAgent(abc.ABC):
    def __init__(self, name: str, icon: str):
        self.name = name
        self.icon = icon
        # Initialize Gemini client
        self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
        self.model = "gemini-2.0-flash" # Default fast model

    @abc.abstractmethod
    async def execute(self, state: WorkflowState) -> AgentTrace:
        """Execute the agent logic, mutate the state, and return a trace."""
        pass

    async def _call_llm(self, prompt: str, schema: type[BaseModel] = None, system_instruction: str = None) -> Any:
        """Helper to call Gemini with structured output."""
        config = types.GenerateContentConfig(
            temperature=0.2,
        )
        if system_instruction:
            config.system_instruction = system_instruction
        if schema:
            config.response_mime_type = "application/json"
            config.response_schema = schema

        # This uses synchronous SDK under the hood wrapped in a way or we use the async client if available.
        # For this prototype, we'll assume the standard client logic.
        response = self.client.models.generate_content(
            model=self.model,
            contents=prompt,
            config=config,
        )
        if schema:
            # Pydantic schema validation happens here
            return schema.model_validate_json(response.text)
        return response.text
