from flask import Flask, request, jsonify
from flask_cors import CORS
import yt_dlp
import moviepy.editor as mp
import whisper
import google.generativeai as genai
import os
from image_extraction_main import download_and_process_video
from concurrent.futures import ThreadPoolExecutor
import time

app = Flask(__name__)
CORS(app)

@app.route('/process_video', methods=['POST'])
def process_video():
    data = request.json
    youtube_link = data['url']

    video_file_path = r'C:\Users\Aditya Vinod\Desktop\vscode\CPI\youtube_backend\temp_video.mp4'
    audio_file_path = r'C:\Users\Aditya Vinod\Desktop\vscode\CPI\youtube_backend\temp_audio.wav'
    keyframes_dir = 'keyframes_dir'

    # Download YouTube video and process
    process_youtube_link(youtube_link, video_file_path, audio_file_path)

    with ThreadPoolExecutor() as executor:
        future_transcription = executor.submit(transcribe_audio, audio_file_path)
        future_keyframes = executor.submit(download_and_process_video, video_file_path, keyframes_dir)

        transcript = future_transcription.result()
        keyframes = future_keyframes.result()

    os.remove(video_file_path)

    summary = summarize_text(transcript)

    return jsonify({'summary': summary, 'keyframes': keyframes})

def process_youtube_link(youtube_link, video_file_path, audio_file_path):
    outtmpl = r'C:\Users\Aditya Vinod\Desktop\vscode\CPI\youtube_backend\temp_video'  #to avoid .mp4.mp4
    ydl_opts = {
        'format': 'best',
        'outtmpl': outtmpl,
        'postprocessors': [{
            'key': 'FFmpegVideoConvertor',   #to convert downloaded vid to mp4
            'preferedformat': 'mp4'
        }],
    }
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            ydl.download([youtube_link])
        print("Download complete.")
    except Exception as e:
        print(f"An error occurred: {e}")
    #waiting for video to be created to avoid file not available issue
    while not os.path.exists(video_file_path):
        print("Waiting for video file to be created...")
        time.sleep(1)  

    video = mp.VideoFileClip(video_file_path)
    video.audio.write_audiofile(audio_file_path)
    video.close()

def transcribe_audio(audio_file_path):
    model = whisper.load_model("base")
    result = model.transcribe(audio_file_path)
    os.remove(audio_file_path)
    return result["text"]

def summarize_text(transcript):
   with open('key.txt', 'r') as f:
        GOOGLE_API_KEY = f.read()
        f.close()
    genai.configure(api_key = <key_here>)
    model = genai.GenerativeModel('gemini-1.5-flash')
    prompt = f"Write notes on the following lecture:\\n{transcript}"
    response = model.generate_content(prompt)
    return response.text

if __name__ == "__main__":
    app.run(debug=True)
