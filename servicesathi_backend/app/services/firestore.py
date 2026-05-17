import firebase_admin
from firebase_admin import credentials, firestore
import os

# Initialize Firebase app (assumes serviceAccountKey.json is in root for dev)
# In production, use env vars.
try:
    if not firebase_admin._apps:
        # Check if local credentials exist
        if os.path.exists("serviceAccountKey.json"):
            cred = credentials.Certificate("serviceAccountKey.json")
            firebase_admin.initialize_app(cred)
        else:
            # Fallback to default application credentials
            firebase_admin.initialize_app()
    db = firestore.client()
except Exception as e:
    # If firebase fails to init (e.g. CI/CD or missing key), mock it out or print error
    print(f"Warning: Firebase initialization failed. Firestore operations will error. {e}")
    db = None

class FirestoreRepo:
    """Repository pattern for Firestore collections."""
    
    @staticmethod
    def get_providers(service_type: str = None):
        """Fetch providers, optionally filtered by service_type."""
        if not db:
            return []
        query = db.collection("providers")
        if service_type:
            query = query.where("service_type", "==", service_type)
        docs = query.stream()
        return [{"id": doc.id, **doc.to_dict()} for doc in docs]

    @staticmethod
    def create_booking(booking_data: dict):
        if not db:
            return
        doc_ref = db.collection("bookings").document(booking_data.get("booking_id"))
        doc_ref.set(booking_data)

    @staticmethod
    def log_workflow(workflow_id: str, state_data: dict):
        if not db:
            return
        doc_ref = db.collection("workflow_logs").document(workflow_id)
        doc_ref.set(state_data)
