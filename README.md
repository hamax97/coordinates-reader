# Coordinates Reader
Reads coordinates given in a video and produces a set of geo-referenced images, one image per second.

# Dependencies

```bash
sudo apt install tesseract-ocr libtesseract-dev
sudo apt install ffmpeg
```

Tested with:

- Tesseract 4.1.1
- FFMPEG 4.2.7-0ubuntu0.1

# How to Use

- First frame:

```bash
ffmpeg -i example.mp4 -vframes 1 000000.png
```

- Rest of the frames:

```bash
ffmpeg -i example.mp4 -vf fps=1 %06d.png
```

# TODOs

- Use the gem for ffmpeg and try to execute the commands above.
- Setup the core logic:
  - Receive a video filename.
  - Create a new folder with a screenshot of each second of the video.
    - Consider using .jpg format because .png takes too much space.
  - Iterate over each image in the folder and extract the coordinates using tesseract.
- How to add the metadata to each image? What does google street view require? Image format?