project('cctv-watcher', 'vala', 'c',
	version : '0.0.1',
	license : 'GPL3')

gnome = import('gnome')

dependencies = [
    dependency('gtk+-3.0', version : '>=3.22'),
    dependency('gee-0.8'),
    dependency('gmodule-2.0'),
    dependency('gstreamer-1.0'),
    dependency('gstreamer-rtsp-1.0'),
]



add_project_arguments('-DGETTEXT_PACKAGE="cctv-watcher"', language: 'c')

sources = [
	'src/main-window.vala',
	'src/edit-camera-dialog.vala',
	'src/app.vala',
	'src/config-file.vala',
	'src/camera.vala',
	'src/rtsp-camera.vala',
	'src/mjpeg-camera.vala',
	'src/onvif-camera.vala',
	'src/v4l-camera.vala',
	'src/test-camera.vala',
	'src/utils.vala',
	'src/renderer.vala',
	'src/rtsp-renderer.vala',
	'src/test-renderer.vala',
	'src/v4l-renderer.vala',
	'src/mjpeg-renderer.vala',

]

resources = gnome.compile_resources(
    'gresources',
    'gresources.xml',
    source_dir: 'ui',
)

vala_flags = '--gresourcesdir=' + join_paths(meson.current_source_dir(), 'ui')

install_desktoppath = join_paths(get_option('datadir'), 'applications')

# install_data('cctv-watcher.desktop', install_dir: install_desktoppath)

executable('cctv-watcher', 'src/app.vala',
		   sources,
		   resources,
		   dependencies : dependencies,
		   install: true,
		   vala_args: vala_flags
)
