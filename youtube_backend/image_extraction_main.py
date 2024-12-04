import os
import cv2
from yt_dlp import YoutubeDL
from scenedetect import open_video, SceneManager
from scenedetect.detectors import ContentDetector
from keyframe_filtering import filter_keyframes


def download_and_process_video(video_file_path, output_dir):
    # Download YouTube video
    '''ydl_opts = {
        'format': 'best',
        'outtmpl': os.path.join(download_path, '%(title)s.%(ext)s'),
    }
    with YoutubeDL(ydl_opts) as ydl:
        info_dict = ydl.extract_info(youtube_url, download=True)
        video_file_path = ydl.prepare_filename(info_dict)
    '''
    # Open video and detect scenes
    video = open_video(video_file_path)
    scene_manager = SceneManager()
    scene_manager.add_detector(ContentDetector())
    scene_manager.detect_scenes(video)
    scene_list = scene_manager.get_scene_list()

    # Extract keyframes
    capture = cv2.VideoCapture(video_file_path)
    keyframe_dir = os.path.join(output_dir, 'keyframes')
    os.makedirs(keyframe_dir, exist_ok=True)
    
    for i, scene in enumerate(scene_list):
        start_frame, end_frame = scene[0].get_frames(), scene[1].get_frames()
        middle_frame = (start_frame + end_frame) // 2
        capture.set(cv2.CAP_PROP_POS_FRAMES, middle_frame)
        success, frame = capture.read()
        if success:
            keyframe_path = os.path.join(keyframe_dir, f'keyframe_{i}.jpg')
            cv2.imwrite(keyframe_path, frame)
    
    capture.release()

    filtered_keyframes = filter_keyframes(keyframe_dir)
    
    return filtered_keyframes #, video_file_path, info_dict['duration']

