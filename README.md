# EmComm Tools Debian Edition

This is an unofficial spin on [EmComm Tools OS Community](https://community.emcommtools.com/)
created by [The Tech Prepper](https://www.thetechprepper.com/).

EmComm Tools does not provide ready to use ISO images.
This is what this project is set up to solve.

In an ideal world, this project will become obsolete by having this solved
upstream.

## Obtaining EmComm Tools Debian Edition

> [!IMPORTANT]
> This project is not endorsed by The Tech Prepper.
> If you experience issues, please do not direct requests at him.

You will find the latest build on [this projects' releases section](https://github.com/corvus-ch/emcomm-tools-os-community/releases).

## Key differences

This project builds on top of Debian instead of Ubuntu. While they both use the
Gnome desktop, Debian does not come with Canonicals' changes to Gnome. As a
result, Debian Edition will have a different look and feel.

In an attempt better blend in to Gnomes look and feel, Debian Edition uses
Epiphany as the default web browser.

## Build on your own

Having a ready to use ISO image is convenient. Being able to build your own,
allows you to tailor it to your own needs.

### Reasons to build your own

* Select maps relevant to your area.
* Add a ready to use VARA using a backup from a previous instance.
* Add additional software

### Build prerequisites

* Working instance of Debian Stable
* The packages `make` and `live-build` installed
* A copy of this repository

### Building

From within the top folder, run:

```sh
make
```
