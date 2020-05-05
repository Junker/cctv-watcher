project('cctv-watcher', 'vala', 'c',
	version : '0.1.0',
	license : 'GPL3')

gnome = import('gnome')

dependencies = [
    dependency('gtk+-3.0', version : '>=3.22'),
    dependency('gee-0.8'),
    dependency('gmodule-2.0'),
    dependency('gudev-1.0'),
    dependency('gstreamer-1.0'),
    dependency('gstreamer-rtsp-1.0'),
]

prefix = get_option('prefix')
datadir = get_option('datadir')
project_datadir = join_paths(prefix, datadir, meson.project_name())

add_project_arguments('-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()), language: 'c')
add_project_arguments('-DDATA_DIR="@0@"'.format(project_datadir), language: 'c')

sources = [
	'src/main-window.vala',
	'src/edit-camera-dialog.vala',
	'src/camera-list-dialog.vala',
	'src/app.vala',
	'src/config-file.vala',
	'src/camera.vala',
	'src/utils.vala',
	'src/systray.vala',
	'src/settings-dialog.vala',
	'src/renderer-widget.vala',
	'src/rtsp-camera.vala',
	'src/mjpeg-camera.vala',
	'src/onvif-camera.vala',
	'src/v4l-camera.vala',
	'src/test-camera.vala',
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

install_data('cctv-watcher.desktop', install_dir: join_paths(datadir, 'applications'))
install_data('cctv-watcher.desktop', install_dir: project_datadir)

vala_flags = '--gresourcesdir=' + join_paths(meson.current_source_dir(), 'ui')

executable('cctv-watcher', 'src/app.vala',
		   sources,
		   resources,
		   dependencies : dependencies,
		   install: true,
		   vala_args: vala_flags
)
