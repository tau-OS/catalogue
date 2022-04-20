project(
    'catalogue', ['c', 'vala'],
    version: '0.1.0',
    meson_version: '>= 0.59.0',
  	default_options: [ 'warning_level=2', ],
)

application_id = 'co.tauos.Catalogue'

if get_option('development')
  app_id = 'co.tauos.Catalogue.Devel'
  name_suffix = ' (Development)'
else
  app_id = 'co.tauos.Catalogue'
  name_suffix = ''
endif

conf = configuration_data()
conf.set_quoted('APP_ID', app_id)
conf.set_quoted('NAME_SUFFIX', name_suffix)
conf.set_quoted('VERSION', meson.project_version())

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

asresources = gnome.compile_resources(
	'as-resources', join_paths(meson.project_source_root(), 'data', application_id + '.gresource.xml'),
  	source_dir: join_paths(meson.project_source_root(), 'data'),
  	c_name: 'as'
)

subdir('data')
subdir('src')
subdir('po')

gnome.post_install(
  glib_compile_schemas: true,
  gtk_update_icon_cache: true,
  update_desktop_database: true,
)
