sources = [
    'window.vala',
    'preferences.vala',
    'application.vala',
    'layout/pages/explore.vala',
    'layout/pages/installed.vala',
    'layout/pages/updates.vala',
    'layout/pages/details.vala',
    'widgets/details/app-header.vala',
    'widgets/details/app-details.vala',
    'widgets/details/app-versionhistory.vala',
    'widgets/details/app-versionhistory-row.vala',
    'widgets/details/app-screenshots.vala',
    'widgets/details/app-links.vala',
    'widgets/details/app-context-bar.vala',
    'widgets/carousel.vala',
    'widgets/carousel-tile.vala',
    'widgets/app-tile.vala',
    'widgets/category-tile.vala',
    'widgets/featured-row.vala',
    'widgets/category-row.vala',
    'widgets/installed-row.vala',
    'objects/signals.vala'
]

config_file = configure_file(
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: conf
)

deps = [
    dependency('gtk4'),
    dependency('libadwaita-1'),
    dependency('gee-0.8'),
    dependency('flatpak'),
    dependency ('appstream', version: '>=0.12.10')
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
