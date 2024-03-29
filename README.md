<img align="left" style="vertical-align: middle" width="120" height="120" src="data/icons/com.fyralabs.Catalogue.svg">

# Catalogue

An open app store for developers.

###

[![Please do not theme this app](https://stopthemingmy.app/badge.svg)](https://stopthemingmy.app)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)

## 🛠️ Dependencies

You'll need the following dependencies:

> *Note*: This dependency list is the names searched for by `pkg-config`. Depending on your distribution, you may need to install other packages (for example, `gtk4-devel` on Fedora)

- `meson`
- `valac`
- `gtk4`
- `libbismuth-1`
- `libhelium-1`
- `gee-0.8`
- `flatpak`
- `appstream`
- `libxml-2.0`
- `json-glib-1.0`

## 🏗️ Building

Simply clone this repo, then run `meson build` to configure the build environment. Change to the build directory and run `ninja test` to build and run automated tests.

```bash
$ meson build --prefix=/usr
$ cd build
$ ninja test
```

For debug messages on the GUI application, set the `G_MESSAGES_DEBUG` environment variable, e.g. to `all`:

```bash
G_MESSAGES_DEBUG=all ./src/catalogue
```

## 📦 Installing

To install, use `ninja install`, then execute with `catalogue`.

```bash
$ sudo ninja install
$ catalogue
```


