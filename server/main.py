import os
from typing import List, Optional

from fastapi import FastAPI
from settings import IMAGE_PATH

# Create app server
app = FastAPI()

@app.get('/{image_name}', summary="Get at least one image")
def get_images(image_name: str) -> Optional[str]:
    print('Got image name', image_name)
    
    # Get the list of all the images
    images: List[str] = os.listdir(IMAGE_PATH)
    print('Got images', images)
    
    matched_images = search_and_get_images_by_name(images, image_name)
    print('Got matched_images', matched_images)

    if matched_images:
        # Return the first one
        return matched_images[0]

    return None

def search_and_get_images_by_name(images: List[str], image_name: str) -> List:
    matching_images: List = []

    for image in images:
       splitted_image_name: List[str] = image.split('_')

       if image_name in splitted_image_name:
           matching_images.append(image)
    
    return matching_images

