subdir('icons')

desktop_file = i18n.merge_file(
        input: 'co.tauos.Catalogue.desktop.in',
       output: 'co.tauos.Catalogue.desktop',
         type: 'desktop',
       po_dir: '../po',
      install: true,
  install_dir: catalogue_datadir / 'applications'
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate desktop file', desktop_utils, args: [desktop_file])
endif

appdata_conf = configuration_data()
appdata_conf.set('appid', application_id)
appstream_file = i18n.merge_file (
  input: configure_file(
    input: files('co.tauos.Catalogue.appdata.xml.in.in'),
    output: 'co.tauos.Catalogue.appdata.xml.in',
    configuration: appdata_conf
  ),
  output: '@0@.appdata.xml'.format(application_id),
  po_dir: '../po',
  install: true,
  install_dir: catalogue_datadir / 'metainfo'
)

appstream_util = find_program('appstream-util', required: false)
if appstream_util.found()
  test('Validate appstream file', appstream_util, args: ['validate', appstream_file])
endif

install_data('co.tauos.Catalogue.gschema.xml',
  install_dir: catalogue_datadir / 'glib-2.0' / 'schemas'
)

compile_schemas = find_program('glib-compile-schemas', required: false)
if compile_schemas.found()
  test('Validate schema file',
       compile_schemas,
       args: ['--strict', '--dry-run', meson.current_source_dir()])
endif

gnome.compile_resources(
  'resources',
  'resources.xml',
  gresource_bundle: true,
  source_dir: meson.current_build_dir(),
  install: true,
  install_dir: catalogue_pkgdatadir
)
