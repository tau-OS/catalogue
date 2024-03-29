main_sources = [
    'window.vala',
    'preferences.vala',
    'application.vala',
    'utils.vala',
    'widgets/dialogs/add-repository.vala',
    'widgets/dialogs/version-history.vala',
    'widgets/dialogs/uninstall-warning.vala',
    'widgets/dialogs/failure.vala',
    'widgets/pages/explore.vala',
    'widgets/pages/installed.vala',
    'widgets/pages/updates.vala',
    'widgets/pages/details.vala',
    'widgets/pages/search.vala',
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
    'widgets/search-row.vala',
    'widgets/skeleton-tile.vala',
    'objects/signals.vala',
    'objects/categories.vala',
    'helpers/content_rating.vala',
    'helpers/flatpak_ref.vala',
    'helpers/catalogue_client.vala'
]

daemon_sources = [
    'daemon.vala',
    'services/search_provider.vala'
]

core_sources = [
    'core/flatpak_backend.vala',
    'core/package.vala',
    'core/utils.vala', 
    'core/client.vala',
    'core/job.vala',
    'core/screenshot_cache.vala',
    'core/change_information.vala',
    'core/update_manager.vala',
    'async_mutex.vala',
    'services/thread_service.vala'
]

config_file = configure_file(
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: conf
)

libbismuth_dep = meson.get_compiler('c').find_library('libbismuth', required: false)
deps = [
    dependency('gtk4'),
    dependency('libhelium-1'),
    dependency('libbismuth-1', fallback: [ 'libbismuth', 'libbismuth_dep' ], version: '>=1.0.0'),
    dependency('gee-0.8'),
    dependency('flatpak'),
    dependency('appstream', version: '>=0.12.10'),
    dependency('libxml-2.0'),
    meson.get_compiler('c').find_library('m'),
    dependency('json-glib-1.0')
]

gnome = import('gnome')

executable(
	meson.project_name(),
	main_sources,
    core_sources,
    config_file,
	asresources,
	vala_args: '--target-glib=2.50',
	dependencies: deps,
	install: true,
)

executable(
	meson.project_name() + '-daemon',
	daemon_sources,
    core_sources,
    config_file,
	vala_args: '--target-glib=2.50',
	dependencies: deps,
	install: true,
)
