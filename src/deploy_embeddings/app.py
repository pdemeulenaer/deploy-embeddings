from transformers import AutoTokenizer, AutoModel
import torch
from fastapi import FastAPI
from pydantic import BaseModel
# import os

app = FastAPI()

# MODEL_NAME = "sentence-transformers/paraphrase-MiniLM-L3-v2" # lighter, less general
MODEL_NAME = "sentence-transformers/all-MiniLM-L6-v2"

# Load model
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoModel.from_pretrained(MODEL_NAME)

# # MODEL_PATH = "/app/model/all-MiniLM-L6-v2/sentence-transformers--all-MiniLM-L6-v2"
# MODEL_ROOT = "/app/model/all-MiniLM-L6-v2"
# MODEL_SUBDIR = [f.path for f in os.scandir(MODEL_ROOT) if f.is_dir()][0]
# tokenizer = AutoTokenizer.from_pretrained(MODEL_SUBDIR, local_files_only=True)
# model = AutoModel.from_pretrained(MODEL_SUBDIR, local_files_only=True)

class TextInput(BaseModel):
    text: str

@app.post("/embed")
async def get_embedding(input: TextInput):
    inputs = tokenizer(input.text, return_tensors="pt", truncation=True, padding=True)
    with torch.no_grad():
        output = model(**inputs)
    # Use mean pooling
    embedding = output.last_hidden_state.mean(dim=1).squeeze().tolist()
    return {"embedding": embedding}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}




# from fastapi import FastAPI
# from pydantic import BaseModel
# from sentence_transformers import SentenceTransformer
# import numpy as np

# app = FastAPI()

# # Load the lightweight model (MiniLM)
# model = SentenceTransformer('all-MiniLM-L6-v2')

# class TextInput(BaseModel):
#     text: str

# @app.post("/embed")
# async def get_embedding(input: TextInput):
#     # Generate embedding
#     embedding = model.encode(input.text, convert_to_numpy=True)
#     return {"embedding": embedding.tolist()}

# @app.get("/health")
# async def health_check():
#     return {"status": "healthy"}