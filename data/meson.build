desktop_file = i18n.merge_file(
  	input: application_id + '.desktop.in',
  	output: application_id + '.desktop',
  	type: 'desktop',
  	po_dir: '../po',
  	install: true,
  	install_dir: join_paths(get_option('datadir'), 'applications')
)

local_desktop_file = i18n.merge_file(
  	input: application_id + '.local.desktop.in',
  	output: application_id + '.local.desktop',
  	type: 'desktop',
  	po_dir: '../po',
  	install: true,
  	install_dir: join_paths(get_option('datadir'), 'applications')
)

# GNOME Shell Search Provider
configure_file(
    input: application_id + '.search-provider.ini.in',
    output: application_id + '.search-provider.ini',
    configuration: conf,
    install_dir: join_paths(get_option('datadir'), 'gnome-shell', 'search-providers')
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  	test('Validate desktop file', desktop_utils,
    		args: [desktop_file]
  	)
    test('Validate local desktop file', desktop_utils,
    		args: [local_desktop_file]
  	)
endif

appstream_file = i18n.merge_file(
  	input: application_id + '.appdata.xml.in',
  	output: application_id + '.appdata.xml',
  	po_dir: '../po',
  	install: true,
  	install_dir: join_paths(get_option('datadir'), 'appdata')
)

appstream_util = find_program('appstream-util', required: false)
if appstream_util.found()
  	test('Validate appstream file', appstream_util,
    		args: ['validate', appstream_file]
  	)
endif

install_data(
	application_id + '.gschema.xml',
  	install_dir: join_paths(get_option('datadir'), 'glib-2.0/schemas')
)

systemd = dependency('systemd', required: false)

if systemd.found()
    install_data(
        meson.project_name() + '.service',
        install_dir: join_paths(systemd.get_pkgconfig_variable('systemdsystemunitdir'), 'multi-user.target.wants')
    )
endif

compile_schemas = find_program('glib-compile-schemas', required: false)
if compile_schemas.found()
  	test('Validate schema file', compile_schemas,
    		args: ['--strict', '--dry-run', meson.current_source_dir()]
  	)
endif

subdir('icons')
