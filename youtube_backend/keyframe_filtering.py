import cv2
from skimage.metrics import structural_similarity as ssim
import numpy as np
import os

# Function to filter out similar keyframes using SSIM
def filter_keyframes(keyframes_dir, threshold=0.8):
    keyframes = sorted([os.path.join(keyframes_dir, f) for f in os.listdir(keyframes_dir) if f.endswith('.jpg')])
    unique_keyframes = []

    if len(keyframes) == 0:
        print("No keyframes to filter.")
        return unique_keyframes

    # Load the first keyframe
    prev_frame = cv2.imread(keyframes[0], cv2.IMREAD_GRAYSCALE)
    unique_keyframes.append(keyframes[0])

    # Compare each keyframe with the previous one
    for i in range(1, len(keyframes)):
        curr_frame = cv2.imread(keyframes[i], cv2.IMREAD_GRAYSCALE)
        similarity = ssim(prev_frame, curr_frame)

        # If frames are different enough, add to the unique list
        if similarity < threshold:
            unique_keyframes.append(keyframes[i])
            prev_frame = curr_frame

    return unique_keyframes
