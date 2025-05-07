from fastapi import FastAPI
from pydantic import BaseModel
from sentence_transformers import SentenceTransformer
import numpy as np

app = FastAPI()

# Load the lightweight model (MiniLM)
model = SentenceTransformer('all-MiniLM-L6-v2')

class TextInput(BaseModel):
    text: str

@app.post("/embed")
async def get_embedding(input: TextInput):
    # Generate embedding
    embedding = model.encode(input.text, convert_to_numpy=True)
    return {"embedding": embedding.tolist()}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}