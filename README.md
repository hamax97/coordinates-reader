# Coordinates Reader
Reads coordinates given in a video and produces a set of geo-referenced images, one image per second.

# Dependencies

```bash
# Tesseract
sudo apt-get install apt-transport-https

# Add this to the /etc/apt/sources.list
deb https://notesalexp.org/tesseract-ocr5/focal/ focal main

wget -O - https://notesalexp.org/debian/alexp_key.asc | sudo apt-key add -
sudo apt-get update

sudo apt install tesseract-ocr libtesseract-dev
```

```bash
sudo apt install tesseract-ocr libtesseract-dev
sudo apt install ffmpeg
```

Tested with:

- Tesseract version 4.1.1
- FFMPEG version 4.2.7-0ubuntu0.1
- Ruby version 3.2.0
- SQLite 3 - 3.31.1
- Rails

# How to Use

Run:

```bash
lib/cli.rb -v ./assets/example.mp4
```

Tesseract

```
tesseract -c load_system_dawg=0 -c load_freq_dawg=0 example/000040.png out
tesseract -c load_system_dawg=0 -c load_freq_dawg=0 -c tessedit_char_whitelist="0123456789. -+" example/000050.jpg out
tesseract example/000038.jpg out --loglevel ALL tesseract.config
```

Tesseract improving quality: https://tesseract-ocr.github.io/tessdoc/ImproveQuality.htmlhttps://tesseract-ocr.github.io/tessdoc/ImproveQuality.html#dictionaries-word-lists-and-patterns
Tesseract config files: https://github.com/tesseract-ocr/tesseract/blob/main/doc/tesseract.1.asc#config-files-and-augmenting-with-user-data
Tesseract patterns docs (look for the function read_pattern_list): https://github.com/tesseract-ocr/tesseract/blob/main/src/dict/trie.h


# FFMPEG Reference
- First frame:

```bash
ffmpeg -i example.mp4 -vframes 1 000000.png
```

- Rest of the frames:

```bash
ffmpeg -i example.mp4 -vf fps=1 %06d.png
```

# TODOs

- Support receiving a folder with multiple videos in CLI.
- Add a simple web service to do the processing in a set of videos (or video per video maybe.)
- Install FFMPEG and Tesseract in a docker container together with Ruby.
  - Lock the versions for each of the tools. Also the Gemfile.
  - Make the docker container expose the web service.
  - Upload the docker image to Dockerhub.
