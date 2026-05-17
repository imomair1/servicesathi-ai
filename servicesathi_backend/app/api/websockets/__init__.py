from fastapi import APIRouter, WebSocket, WebSocketDisconnect
import asyncio
from app.services.redis_cache import redis_state

ws_router = APIRouter()

@ws_router.websocket("/workflow/{workflow_id}")
async def workflow_websocket(websocket: WebSocket, workflow_id: str):
    await websocket.accept()
    
    # Subscribe to Redis channel for this specific workflow
    pubsub = redis_state.redis.pubsub()
    channel = f"trace:{workflow_id}"
    await pubsub.subscribe(channel)
    
    try:
        while True:
            message = await pubsub.get_message(ignore_subscribe_messages=True, timeout=1.0)
            if message:
                await websocket.send_text(message["data"])
            await asyncio.sleep(0.01)
    except WebSocketDisconnect:
        print(f"Client disconnected from workflow {workflow_id}")
    finally:
        await pubsub.unsubscribe(channel)
        await pubsub.close()

@ws_router.websocket("/admin_monitor")
async def admin_monitor_websocket(websocket: WebSocket):
    await websocket.accept()
    
    pubsub = redis_state.redis.pubsub()
    # Pattern subscribe to all traces
    await pubsub.psubscribe("trace:*")
    
    try:
        while True:
            message = await pubsub.get_message(ignore_subscribe_messages=True, timeout=1.0)
            if message:
                await websocket.send_text(message["data"])
            await asyncio.sleep(0.01)
    except WebSocketDisconnect:
        print("Admin dashboard disconnected")
    finally:
        await pubsub.punsubscribe("trace:*")
        await pubsub.close()
