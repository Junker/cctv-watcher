<div align="center">
  <img width="600" height="516" src=".readme/shot.png">
</div>

# CCTV Watcher
Application for CCTV cameras monitoring. RTSP, MJPEG, V4L2 cameras supported.

### Requirements
* Gstreamer (gstreamer-libav, gstreamer-rtsp, gstreamer-gtk)
* Gtk
* libgudev

### Build & Install

	meson build --prefix=/usr
	cd build
	ninja
	sudo ninja install

### Install from Arch Linux & Manjaro 
	yaourt -S cctv-watcher
