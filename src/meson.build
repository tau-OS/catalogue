sources = [
	'main.vala',
  	'window.vala',
  	'application.vala',
]

deps = [
	dependency('gtk4'),
  	dependency('libadwaita-1'),
]

gnome = import('gnome')

executable(
	meson.project_name(),
	sources,
	asresources,
  	vala_args: '--target-glib=2.50',
  	dependencies: deps,
  	install: true,
)
