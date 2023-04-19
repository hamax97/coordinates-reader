# Coordinates Reader

Ruby on Rails webapp that reads a video that contains coordinates as text, updated per second, and produces
a set of images, one per each coordinate change, with their corresponding coordinates by reading the text in
the video.

![coordinates-reader.png](./docs/coordinates-reader.png)

<!-- TOC -->

- [Coordinates Reader](#coordinates-reader)
    - [Run with Docker](#run-with-docker)
    - [Build Docker image](#build-docker-image)
    - [Setup development environment](#setup-development-environment)
        - [Start application](#start-application)
    - [Run Tesseract manually](#run-tesseract-manually)
    - [Run FFMPEG manually](#run-ffmpeg-manually)

<!-- /TOC -->

## Run with Docker

Pull image:

```bash
docker pull hamax97/coordinates-reader
```

Run in terminal:

```bash
docker run -d -e SECRET_KEY_BASE=$(bin/rails secret) -p 3000:3000 -h coordinates-reader --name coordinates-reader coordinates-reader:latest
```

TODO: Run in Docker Desktop.

## Build Docker image

Build image:

```bash
docker build -t coordinates-reader .
```

Tag and push:

```bash
docker tag <image_id> hamax97/coordinates-reader:<version>
docker push hamax97/coordinates-reader:<version>
```

## Setup development environment

Developed with:

- Ubuntu 20.04
- Ruby 3.2.0
- Rails 7.0.4
- PostgreSQL 12
- Text extraction: Tesseract version 5.3.0
- Video processing: FFMPEG version 7:4.2.7-0ubuntu0.1

Install Tessearct:

```bash
echo "deb https://notesalexp.org/tesseract-ocr5/focal/ focal main" >> /etc/apt/sources.list

wget -O - https://notesalexp.org/debian/alexp_key.asc | sudo apt-key add -
sudo apt-get update

sudo apt-get install -y tesseract-ocr=5.3.0-1 libtesseract-dev=5.3.0-1
```

Install FFMPEG:

```bash
sudo apt-get -y install ffmpeg=7:4.2.7-0ubuntu0.1

```

Install libraries used by rails for image processing:

```bash
# required for gem image_processing, which required for displaying images.
sudo apt-get -y install libvips42
```

Install PostgreSQL and set the password for user `coordinates_reader` to `CoordinatesReader123*`:

```bash
sudo apt-get install postgresql-12 postgresql-client-12

# set password to: CoordinatesReader123*
sudo -u postgres createuser -s coordinates_reader -P
```

### Start application

Please note that `bin/rails db:create db:migrate` and `bin/rails active_storage:install` are run only
once to initliaze the DB. After that, starting the PostgreSQL service and the rails server will work.

```bash
sudo service postgresql start
bin/rails db:create db:migrate

bin/rails server
```

## Run Tesseract manually

```bash
tesseract -c load_system_dawg=0 -c load_freq_dawg=0 <path_to_image> out
tesseract -c load_system_dawg=0 -c load_freq_dawg=0 -c tessedit_char_whitelist="0123456789. -+" <path_to_image> out
tesseract <path_to_image> out --loglevel ALL tesseract.config
```

Useful links:

- [Tesseract improving quality](https://tesseract-ocr.github.io/tessdoc/ImproveQuality.htmlhttps://tesseract-ocr.github.io/tessdoc/ImproveQuality.html#dictionaries-word-lists-and-patterns).

- [Tesseract config files](https://github.com/tesseract-ocr/tesseract/blob/main/doc/tesseract.1.asc#config-files-and-augmenting-with-user-data)

- [Tesseract patterns docs (look for the function read_pattern_list)](https://github.com/tesseract-ocr/tesseract/blob/main/src/dict/trie.h)


## Run FFMPEG manually

- First frame:

```bash
ffmpeg -i example.mp4 -vframes 1 000000.png
```

- Rest of the frames:

```bash
ffmpeg -i example.mp4 -vf fps=1 %06d.png
```
