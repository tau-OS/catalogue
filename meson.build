project('catalogue', 'rust',
            version: '0.1.0',
      meson_version: '>= 0.59.0',
            license: '0.5.1',
    default_options: [ 'warning_level=2', 'werror=false', ],

)

i18n = import('i18n')
gnome = import('gnome')

if get_option('profile') == 'development'
  profile = '.Devel'
  vcs_tag = run_command('git', 'rev-parse', '--short', 'HEAD').stdout().strip()
  if vcs_tag == ''
    version_suffix = '-devel'
  else
    version_suffix = '-@0@'.format (vcs_tag)
  endif
else
  profile = ''
  version_suffix = ''
endif

application_id = 'co.tauos.Catalogue' + profile

catalogue_prefix = get_option('prefix')
catalogue_datadir = get_option('datadir')
catalogue_bindir = catalogue_prefix / get_option('bindir')
catalogue_localedir = catalogue_prefix / get_option('localedir')
catalogue_pkgdatadir = catalogue_prefix / catalogue_datadir / meson.project_name()

cargo_sources = files(
  'Cargo.toml',
  'Cargo.lock',
)

subdir('data')
subdir('src')
subdir('po')

gnome.post_install(
  glib_compile_schemas: true,
  gtk_update_icon_cache: true,
  update_desktop_database: true,
)
