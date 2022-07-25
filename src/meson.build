conf = configuration_data()
conf.set_quoted('APP_ID', application_id)
conf.set_quoted('VERSION', meson.project_version() + version_suffix)
conf.set_quoted('LOCALEDIR', catalogue_localedir)
conf.set_quoted('PKGDATADIR', catalogue_pkgdatadir)
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('RESOURCES_FILE', catalogue_pkgdatadir / 'resources.gresource')
config_rs = configure_file(
    input: 'config.rs.in',
    output: 'config.rs',
    configuration: conf
)

run_command(
  'cp',
  config_rs,
  meson.current_source_dir(),
  check: true
)

sources = files(
  'application.rs',
  'config.rs',
  'main.rs',
  'window.rs',
  'macros.rs'
)

cargo_script = find_program(meson.project_source_root() / 'build-aux' / 'cargo.sh')
cargo_release = custom_target('cargo-build',
  		           build_by_default: true,
                                      input: [
                                      	      cargo_sources,
                                      	      sources
                                      	     ],
  			             output: meson.project_name(),
  			            install: true,
                                install_dir: catalogue_bindir,
                                   console: true,
                                   command: [
                                             cargo_script,
                                             meson.project_build_root(),
                                             meson.project_source_root(),
                                             '@OUTPUT@',
                                             profile,
  				            ]
)
