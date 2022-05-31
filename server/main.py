import re
import os
from typing import List, Optional

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Create app server
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get('/', summary="Health check")
def get() -> None:
    return {"ok": True}

@app.get('/image/{image_name}', summary="Get at least one image")
def get_images(image_name: str) -> Optional[str]:
    print('Got image name', image_name)
    
    # Get the list of all the images
    root_directory = os.getcwd()
    image_path =f'{root_directory}/images/'
    images: List[str] = os.listdir(image_path)
    print('Got images', images)

    matched_images = search_and_get_images_by_name(images, image_name)
    print('Got matched_images', matched_images)

    response = {'image_name': None}

    if matched_images:
        # Return the first one
        response['image_name'] = matched_images[0]

    return response

def search_and_get_images_by_name(images: List[str], image_name: str) -> List:
    matching_images: List = []

    for image in images:
        match = re.search(image_name, image)
        if match:
           matching_images.append(image)
    
    return matching_images

