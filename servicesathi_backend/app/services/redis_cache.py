import redis.asyncio as redis
import json
from typing import Any, Optional
from app.core.config import settings

class RedisState:
    def __init__(self):
        self.redis = redis.from_url(settings.REDIS_URL, decode_responses=True)

    async def get_state(self, key: str) -> Optional[dict]:
        data = await self.redis.get(key)
        if data:
            return json.loads(data)
        return None

    async def set_state(self, key: str, value: dict, expire_seconds: int = 3600):
        await self.redis.set(key, json.dumps(value), ex=expire_seconds)

    async def publish_trace(self, channel: str, message: dict):
        """Publish a trace event to a specific websocket channel."""
        await self.redis.publish(channel, json.dumps(message))

# Global instance
redis_state = RedisState()
