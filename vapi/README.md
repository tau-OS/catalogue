# Generating Flatpak VAPI

Requirements:

- `flatpak-devel`


```sh
$ vapigen \       
--library flatpak \
--metadatadir . \
--pkg gio-2.0 \
/usr/share/gir-1.0/Flatpak-1.0.gir
```
