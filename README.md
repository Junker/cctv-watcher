[![Build Status](https://travis-ci.com/Junker/cctv-watcher.svg?branch=master)](https://travis-ci.com/Junker/cctv-watcher)

# CCTV Watcher
Application for CCTV cameras monitoring. RTSP, MJPEG, V4L2 cameras supported.

### Requirements
* Gstreamer (gstreamer-libav, gstreamer-rtsp)
* Gtk

### Control
* Left-Button click - mute/unmute
* Middle-Button click - mixer
* Srcoll - Volume up/down

### Build & Install

	meson build --prefix=/usr
	cd build
	ninja
	sudo ninja install

