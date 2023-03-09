# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

### [1.1.14](https://github.com/allex/cmp-ui-base/compare/1.1.13...1.1.14) (2023-03-09)


### Features

* add log format for upstream ([d6e312d](https://github.com/allex/cmp-ui-base/commit/d6e312d824140b266910c1756670c21e2ae1c740))


### Bug Fixes

* change default TZ=Asia/Shanghai ([dd7a52c](https://github.com/allex/cmp-ui-base/commit/dd7a52cc9f0c0022127afade0c788808acc7fb92))

### [1.1.13](https://github.com/allex/cmp-ui-base/compare/1.1.12...1.1.13) (2023-02-01)


### Bug Fixes

* allow bind privileged port when non root ([4ec3dc0](https://github.com/allex/cmp-ui-base/commit/f403a4f6becac3c0565508924c0d4c4169467514))

### [1.1.12](https://github.com/allex/cmp-ui-base/compare/1.1.11...1.1.12) (2022-11-10)


### Features

* add cookie samesite flags ([9d9800c](https://github.com/allex/cmp-ui-base/commit/9d9800c6272a84c2e81c99134d978c572e8f879f))
* add ngx header vars: ${FSS_HEADERS_CSP}, ${FSS_HEADERS_XSS_PROTECTION} ([9bf394f](https://github.com/allex/cmp-ui-base/commit/9bf394f2ea4aeec806493e9e2e28e305110626c2))
* add ssl support (${FSS_SSL_PORT}) ([616ebf0](https://github.com/allex/cmp-ui-base/commit/616ebf0af23b8d56340a3d0dc9432a5697bb3939))
* optimize entry and add builtin helpers ([d35528b](https://github.com/allex/cmp-ui-base/commit/d35528bd0d4f04dd6a6ef986457a805885b2aef3))


### Bug Fixes

* physical uri with auto index ([03c6ab5](https://github.com/allex/cmp-ui-base/commit/03c6ab5a7d654b966383586475579be4c96228e0))

### [1.1.11](https://github.com/allex/cmp-ui-base/compare/1.1.10...1.1.11) (2022-08-02)


### Features

* add static assets with video files ([72f7d88](https://github.com/allex/cmp-ui-base/commit/72f7d88e8c98301a7c9f72ed4febe978b1979b4d))


### Bug Fixes

* add localize files reserve ([716ddd6](https://github.com/allex/cmp-ui-base/commit/716ddd6b37640ca663b038d3e39a3cfac7b8a3b5))

### [1.1.10](https://github.com/allex/cmp-ui-base/compare/1.1.9...1.1.10) (2022-07-12)


### Features

* add api rewrite env ${FSS_REWRITE_API} ([4a4ba2f](https://github.com/allex/cmp-ui-base/commit/4a4ba2fea339f52343faace0d0acbb22dc28601f))


### Bug Fixes

* allow html resources ([f64e47b](https://github.com/allex/cmp-ui-base/commit/f64e47b153b3d6aeaf650ab1b0a9b7c0a54be951))

### [1.1.9](https://github.com/allex/fss-proxy/compare/1.1.8...1.1.9) (2022-05-13)


### Features

* add custom api prefix support **FSS_API_BASE** ([d848880](https://github.com/allex/fss-proxy/commit/fd2f87780a81e26c341b35c4c8e42113ca737f53))

### [1.1.8](https://github.com/allex/fss-proxy/compare/1.1.7...1.1.8) (2022-03-24)


### Bug Fixes

* add `charset_types` enable chartset "text/css" etc,. ([6e5637e](https://github.com/allex/fss-proxy/commit/6e5637e8138e1cf25b4c65f6ee9169cab103e843))

### [1.1.7](https://github.com/allex/fss-proxy/compare/1.1.6...1.1.7) (2021-12-01)


### Bug Fixes

* add CSP with cdn script-src ([bfa1d61](https://github.com/allex/fss-proxy/commit/bfa1d61e3a197ad4f30451b3820fc309462bba5a))
* set current ts as BUILD_GIT_HEAD default value ([2455607](https://github.com/allex/fss-proxy/commit/245560730ea2e2d1e8ec159fed0ef6567e8c3ea7))
