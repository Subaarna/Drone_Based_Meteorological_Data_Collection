import os
from fastapi import FastAPI, UploadFile, File
from fastai.vision import load_learner, open_image
import io
import torch

app = FastAPI()

# Define classes for weather classification
classes = ['cloudy', 'foggy', 'rainy', 'snowy', 'sunny']

# Load the weather classification model
model_path = "./model"
learn = load_learner(model_path)
model = learn.model
model = model.cuda() if torch.cuda.is_available() else model

# Define endpoint for making predictions
@app.post("/predict/")
async def predict(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        
        # Open the image
        img = open_image(io.BytesIO(contents))
        img = img.cuda() if torch.cuda.is_available() else img
        
        # Make prediction
        prediction = learn.predict(img)
        
        # Extract predicted class and prediction probabilities
        predicted_class_idx = prediction[1].item()  # Get the index of the predicted class
        prediction_probs = prediction[2].tolist()   # Convert prediction probabilities to list
        
        predicted_class = classes[predicted_class_idx]
        
        return {"prediction": prediction_probs, "class_idx": predicted_class_idx, "class": predicted_class}
    except Exception as e:
        return {"error": str(e)}
