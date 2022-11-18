Name:           catalogue
Version:        1.0.0
Release:        2%{?dist}
Summary:        An open app store for developers.

License:        GPLv3
URL:            https://github.com/tau-OS/catalogue
Source0:        https://github.com/tau-OS/catalogue/archive/refs/heads/main.zip
Source1:        99-co.tauos.Catalogue.preset

BuildRequires:  meson
BuildRequires:  gcc
BuildRequires:  vala
BuildRequires:  cmake
BuildRequires:  desktop-file-utils
BuildRequires:  pkgconfig(gtk4)
BuildRequires:  pkgconfig(libhelium-1)
BuildRequires:  pkgconfig(libbismuth-1)
BuildRequires:  pkgconfig(gee-0.8)
BuildRequires:  pkgconfig(flatpak)
BuildRequires:  pkgconfig(appstream)
BuildRequires:  pkgconfig(libxml-2.0)
BuildRequires:  pkgconfig(json-glib-1.0)

%description
An open app store for developers.

%prep
%autosetup -n catalogue-main

%build
%meson
%meson_build

%install
%meson_install

install -Dp -m 0644 %{SOURCE1} %{buildroot}%{_presetdir}/99-co.tauos.Catalogue.preset

%check
%meson_test

%files
%{_bindir}/co.tauos.Catalogue
%{_bindir}/co.tauos.Catalogue-daemon
%{_datadir}/applications/co.tauos.Catalogue.desktop
%{_datadir}/applications/co.tauos.Catalogue.local.desktop
%{_datadir}/glib-2.0/schemas/co.tauos.Catalogue.gschema.xml
%{_datadir}/icons/hicolor/scalable/apps/co.tauos.Catalogue.svg
%{_datadir}/icons/hicolor/symbolic/apps/co.tauos.Catalogue-symbolic.svg
%{_datadir}/gnome-shell/search-providers/co.tauos.Catalogue.search-provider.ini
%{_datadir}/appdata/co.tauos.Catalogue.appdata.xml
%{_unitdir}/multi-user.target.wants/co.tauos.Catalogue.service
%{_presetdir}/99-co.tauos.Catalogue.preset

%post
%systemd_post co.tauos.Catalogue.service

%preun
%systemd_preun co.tauos.Catalogue.service

%postun
%systemd_postun_with_restart co.tauos.Catalogue.service

%changelog
* Fri Nov 18 2022 Lains <lains@airmail.cc> - 1.0.0-2
- RDNN and some fixes
* Thu Nov 17 2022 Lleyton Gray <lleyton@fyralabs.com> - 1.0.0-1
- Initial Release
