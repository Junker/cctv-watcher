project('cctv-watcher', 'vala', 'c',
	version : '0.3.2',
	license : 'GPL3')

gnome = import('gnome')

dependencies = [
	dependency('gtk+-3.0', version : '>=3.22'),
	dependency('gio-2.0'),
	dependency('gee-0.8'),
	dependency('gmodule-2.0'),
	dependency('gudev-1.0'),
	dependency('gstreamer-1.0'),
	dependency('gstreamer-rtsp-1.0'),
]

# StatusNotifierItem (AppIndicator) — работает в трее на Wayland / Plasma 6.
# Если библиотеки нет, собираемся без неё (старый GtkStatusIcon, только X11).
appindicator_dep = dependency('ayatana-appindicator3-0.1', required : false)
if not appindicator_dep.found()
	appindicator_dep = dependency('appindicator3-0.1', required : false)
endif
if appindicator_dep.found()
	dependencies += appindicator_dep
	add_project_arguments(['-D', 'HAVE_APPINDICATOR'], language: 'vala')
	message('AppIndicator found: tray icon will use StatusNotifierItem (Wayland/Plasma 6)')
else
	warning('AppIndicator not found: falling back to GtkStatusIcon (X11 only)')
endif

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
	'src/dbus-server.vala'
]

resources = gnome.compile_resources(
	'gresources',
	'gresources.xml',
	source_dir: 'ui',
)

install_data('cctv-watcher.desktop', install_dir: join_paths(datadir, 'applications'))
install_data('cctv-watcher.desktop', install_dir: project_datadir)

vala_flags = '--gresourcesdir=' + join_paths(meson.current_source_dir(), 'ui')
add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], language: 'vala')

executable('cctv-watcher', 'src/app.vala',
			sources,
			resources,
			dependencies : dependencies,
			install: true,
			vala_args: vala_flags
)
