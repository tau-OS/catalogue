sources = [
	'main.vala',
  	'window.vala',
    'preferences.vala',
  	'application.vala',
    'layout/pages/explore.vala',
    'layout/pages/installed.vala',
    'layout/pages/updates.vala',
    'widgets/carousel.vala',
    'widgets/carousel-tile.vala',
    'widgets/app-tile.vala',
    'widgets/category-tile.vala',
    'widgets/featured-row.vala',
    'widgets/category-row.vala',
    'widgets/installed-row.vala'
]

config_file = configure_file(
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: conf
)

deps = [
	dependency('gtk4'),
  	dependency('libadwaita-1'),
    dependency('gee-0.8')
]

gnome = import('gnome')

executable(
	meson.project_name(),
	sources,
    config_file,
	asresources,
  	vala_args: '--target-glib=2.50',
  	dependencies: deps,
  	install: true,
)
