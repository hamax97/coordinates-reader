#!/usr/bin/env bash

###############################################################################
# Install Tesseract

echo "deb https://notesalexp.org/tesseract-ocr5/bullseye/ bullseye main" >> /etc/apt/sources.list

wget -O - https://notesalexp.org/debian/alexp_key.asc | apt-key add -
apt-get update

apt-get install -y tesseract-ocr=5.3.0-1 libtesseract-dev=5.3.0-1

###############################################################################
# Install FFMPEG

apt-get install -y ffmpeg=7:4.3.5-0+deb11u1

###############################################################################
# Dependnecies for gems that do image processing

apt-get install -y libvips42

###############################################################################
# Install and start PostgreSQL

apt-get install -y postgresql-13 postgresql-client-13
service postgresql start
echo -e "$POSTGRES_PASSWORD\n$POSTGRES_PASSWORD" | runuser -l postgres -c "createuser -s $POSTGRES_USER -P"
