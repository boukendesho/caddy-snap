# Caddy snap

[![caddy](https://snapcraft.io/caddy/badge.svg)](https://snapcraft.io/caddy)

[Caddy Project Link](https://caddyserver.com/) 

Caddy is a Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS.
  
### Authors

This snap is maintained by me, and is not affiliated with the upstream project in any way. If you encounter any issues, please kindly report it here.

[![Get it from the Snap Store](https://snapcraft.io/static/images/badges/en/snap-store-black.svg)](https://snapcraft.io/caddy)

## Requirements

[Snap installed](https://snapcraft.io/docs/installing-snapd)

## Install

```bash
$ sudo snap install caddy
```

## Doc

see: [Official Docs](https://caddyserver.com/docs/)


This repository contains the source files for the caddy snap, an
unofficial snap package for caddy.

What distinguishes this snap from other caddy snaps is that it is intended
primarily for use on Ubuntu and Ubuntu Core.

This particular snap has a few key features:
1) Intended for use on Ubuntu and Ubuntu Core

  caddy is setup as a daemon so that Ubuntu Core machines can use it! This means
  that the configuration is intended to be passed in a fashion useful for Ubuntu
  Core devices, snap config values. Instead of creating a Caddyfile, set the
  JSON corresponding to your desired configuration as a config value via:

	```
  	snap set caddy config='{...}'
	```
  caddy-wrapper will consume this configuration value and pass that to caddy.

2) Useful with other snaps

  Instead of serving the content from the caddy snap itself (also supported),
  instead other snaps can provide the content caddy serves. As long as the
  implement the caddy-content slot which properly exposes the file hierarchy,
  caddy can access that file tree and serve the content! To do so, run:

	```
	  snap connect caddy:caddy-content <snap>:caddy-content
	```

  Provider snaps should expose the content as READ to `"<foo>"`, and that content
  should be available to caddy at `"$SNAP/var/www/<foo>"`

3) Extensible

  A check is involved just in-case end-users run `caddy add-package`. As this
  behaviour modifies the caddy binary itself and snaps are read-only, the caddy
  binary is instead copied to the writable area and that modified caddy binary
  is the one being used to add and remove modules. Whether the modified caddy
  binary is the one being used or not can be checked (or set) with:

	```
	  snap get caddy modified
	```

  Modules can be specified by the gadget snap which caddy will fetch on first
  installation via the `default-configure` hook:

	```
		defaults:
			<snap ID>:
				modules: 2
				module:
					cloudflare: github.com/caddy-dns/cloudflare
					porkbun: github.com/caddy-dns/porkbun
	```

Only officially registered modules are supported.

Importantly, configuration is handled via snap config values. Because Caddy's
API uses JSON for configuration, this is a natural choice.

Of course, for users opting to use the CLI directly any method for supplying a
configuration can be used.


## Usage

To test the server, run:

```
  echo "Hello, world!" | sudo tee -a /var/snap/caddy/common/www/index.html
  snap set caddy config='{
  "apps": {
    "http": {
      "servers": {
        "myserver": {
          "listen": [
              ":2020"
          ],
          "routes": [
            {
              "handle": [
                {
                  "handler": "file_server",
                  "root": "/var/snap/caddy/common/www"
                }
              ]
            }
          ]
        }
      }
    }
  }'
```

The configuration file `caddy.json` is handled programmatically by caddy's
`configure` hook. As such, directly editing `${SNAP_COMMON}/caddy.json` is
ill-advised and may result in an inconsistent `caddy.json`.


## Tips

Caddy's JSON configuration is quite a bit more featureful than the standard
Caddyfile syntax allows, so it can be hard to "know" how to convert from a
Caddyfile to JSON. Never fear! Caddy includes a way of converting a Caddyfile
to JSON:

```
  caddy adapt Caddyfile | jq
```

This will produce a JSON output which can be used to configure caddy.
