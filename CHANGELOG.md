# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

### [1.1.20](https://github.com/allex/fss-proxy/compare/1.1.19...1.1.20) (2024-12-05)


### Features

* add auto ssl certs issuer ([ec30509](https://github.com/allex/fss-proxy/commit/ec3050993388c7248fb36ff9a6f5441422363cf6))
* add custom resolvers ([85fab9a](https://github.com/allex/fss-proxy/commit/85fab9a1e198dbef26c7a474f3c9b8f000158f02))
* disable proxy buffering ([574b458](https://github.com/allex/fss-proxy/commit/574b4585fc67f9b51cfbef338455300aefedfc0a))
* enhances FSS_PROXY entry with properties (rewrite, cors) ([4e6bac1](https://github.com/allex/fss-proxy/commit/4e6bac1eebec00993b57321f177473045db832f4))
* refactor patch load mechanism ([072df8f](https://github.com/allex/fss-proxy/commit/072df8f1f9939f94bd4d10d7b60af5443a8e1539))


### Bug Fixes

* add custom server_name supports ([a44b4bc](https://github.com/allex/fss-proxy/commit/a44b4bcb52f140d6a38f620d509cc5fd37553efd))
* remove api cors headers ([8a455be](https://github.com/allex/fss-proxy/commit/8a455bebbfc38a19697de1e3356b30c5884ee1a2))

### [1.1.18](https://github.com/allex/fss-proxy/compare/1.1.17...1.1.18) (2024-01-23)


### Bug Fixes

* add proxy websocket support ([d996902](https://github.com/allex/fss-proxy/commit/d99690223daab6fc431e7b06afa27b4a6734f601))
* **Makefile:** drop version stamp file ([38c5821](https://github.com/allex/fss-proxy/commit/38c58215f8f7063e7b5750596f64c757005208f2))

### [1.1.17](https://github.com/allex/fss-proxy/compare/1.1.16...1.1.17) (2023-09-14)


### Features

* add support force ssl redirect ($FSS_FORCE_SSL) ([fa20e12](https://github.com/allex/fss-proxy/commit/fa20e12bc638cfa18f996fda67c2405859538691))
* upgrade nginx 1.25.2 ([24b7fba](https://github.com/allex/fss-proxy/commit/24b7fba3f1e7387ab478af2d40b56ec6868de2ee))


### Bug Fixes

* add support of manaully version ([ba3255e](https://github.com/allex/fss-proxy/commit/ba3255e289336c91a69c9b544d62ece4ea62baf0))
* ensure NGINX_VERSION ([266d1f3](https://github.com/allex/fss-proxy/commit/266d1f33695e7cc63316097da261aea375394d03))
* improve proxy_pass generator ([bf3ff06](https://github.com/allex/fss-proxy/commit/bf3ff06333caa203c5a026f8d74c8636f57119fc))
* redirecting when HTTP request sent to HTTPS port ([57c97c3](https://github.com/allex/fss-proxy/commit/57c97c3650549fe00085ed3a383b7a805e0a2dc3))

### [1.1.16](https://github.com/allex/fss-proxy/compare/1.1.15...1.1.16) (2023-05-27)


### Features

* add customzie proxy support ([720fe63](https://github.com/allex/fss-proxy/commit/720fe630e93d880841ce6203e65c665b2a8adaae))

### [1.1.15](https://github.com/allex/fss-proxy/compare/1.1.14...1.1.15) (2023-04-27)


### Features

* add custom forward prefix, valid_referers ([fd718d1](https://github.com/allex/fss-proxy/commit/fd718d1e3df7aa0f61267b70c60fbcd3d99ae107))


### Bug Fixes

* api content-type missing ([5dd430f](https://github.com/allex/fss-proxy/commit/5dd430f7917038440c432fceb7b1d363915eaab7))

### [1.1.14](https://github.com/allex/fss-proxy/compare/1.1.13...1.1.14) (2023-03-09)


### Features

* add log format for upstream ([d6e312d](https://github.com/allex/fss-proxy/commit/d6e312d824140b266910c1756670c21e2ae1c740))


### Bug Fixes

* change default TZ=Asia/Shanghai ([dd7a52c](https://github.com/allex/fss-proxy/commit/dd7a52cc9f0c0022127afade0c788808acc7fb92))

### [1.1.13](https://github.com/allex/fss-proxy/compare/1.1.12...1.1.13) (2023-02-02)


### Bug Fixes

* allow bind privileged port when non root ([8f8e4cd](https://github.com/allex/fss-proxy/commit/8f8e4cdd3e10f25fb4b592c6a05c46f5fe2dc1e2))

### [1.1.12](https://github.com/allex/fss-proxy/compare/1.1.11...1.1.12) (2022-11-10)


### Features

* add cookie samesite flags ([9d9800c](https://github.com/allex/fss-proxy/commit/9d9800c6272a84c2e81c99134d978c572e8f879f))
* add ngx header vars: ${FSS_HEADERS_CSP}, ${FSS_HEADERS_XSS_PROTECTION} ([9bf394f](https://github.com/allex/fss-proxy/commit/9bf394f2ea4aeec806493e9e2e28e305110626c2))
* add ssl support (${FSS_SSL_PORT}) ([616ebf0](https://github.com/allex/fss-proxy/commit/616ebf0af23b8d56340a3d0dc9432a5697bb3939))
* optimize entry and add builtin helpers ([d35528b](https://github.com/allex/fss-proxy/commit/d35528bd0d4f04dd6a6ef986457a805885b2aef3))


### Bug Fixes

* physical uri with auto index ([03c6ab5](https://github.com/allex/fss-proxy/commit/03c6ab5a7d654b966383586475579be4c96228e0))

### [1.1.11](https://github.com/allex/fss-proxy/compare/1.1.10...1.1.11) (2022-08-02)


### Features

* add static assets with video files ([72f7d88](https://github.com/allex/fss-proxy/commit/72f7d88e8c98301a7c9f72ed4febe978b1979b4d))


### Bug Fixes

* add localize files reserve ([716ddd6](https://github.com/allex/fss-proxy/commit/716ddd6b37640ca663b038d3e39a3cfac7b8a3b5))

### [1.1.10](https://github.com/allex/fss-proxy/compare/1.1.9...1.1.10) (2022-07-12)


### Features

* add api rewrite env ${FSS_REWRITE_API} ([4a4ba2f](https://github.com/allex/fss-proxy/commit/4a4ba2fea339f52343faace0d0acbb22dc28601f))


### Bug Fixes

* allow html resources ([f64e47b](https://github.com/allex/fss-proxy/commit/f64e47b153b3d6aeaf650ab1b0a9b7c0a54be951))

### [1.1.9](https://github.com/allex/fss-proxy/compare/1.1.8...1.1.9) (2022-05-13)


### Features

* add custom api prefix support **FSS_API_BASE** ([fd2f877](https://github.com/allex/fss-proxy/commit/fd2f87780a81e26c341b35c4c8e42113ca737f53))

### [1.1.8](https://github.com/allex/fss-proxy/compare/1.1.7...1.1.8) (2022-03-24)


### Bug Fixes

* add `charset_types` enable chartset "text/css" etc,. ([6e5637e](https://github.com/allex/fss-proxy/commit/6e5637e8138e1cf25b4c65f6ee9169cab103e843))

### [1.1.7](https://github.com/allex/fss-proxy/compare/1.1.6...1.1.7) (2021-12-23)


### Bug Fixes

* add CSP with cdn script-src ([ee8681c](https://github.com/allex/fss-proxy/commit/ee8681c704dbcad10ce46750557a648dd479ef99))
* use date timestamp instead when BUILD_GIT_HEAD empty ([ae568ea](https://github.com/allex/fss-proxy/commit/ae568eac68a20175a2436dfab328713cdd03bd7f))

### [1.1.6](https://github.com/allex/fss-proxy/compare/1.1.5...1.1.6) (2021-11-11)


### Features

* improve entrypoint sh, add env.FSS_VERSION ([cd5bf7e](https://github.com/allex/fss-proxy/commit/cd5bf7e0c2ea23887f73b1615631ee5ce5f1741b))


### Bug Fixes

* improve static site config ([ea6c1eb](https://github.com/allex/fss-proxy/commit/ea6c1ebff26fc003daf59da4eb16b993a0c542ea))

### [1.1.5](https://github.com/allex/fss-proxy/compare/1.1.4...1.1.5) (2021-11-05)


### Features

* upgrade ngx 1.21 and patch hook feature ([ff961b2](https://github.com/allex/fss-proxy/commit/ff961b2dec4008dcfcfa7c101bb342944591a06c))

### [1.1.4](https://github.com/allex/fss-proxy/compare/1.1.3...1.1.4) (2021-09-06)


### Bug Fixes

* onbuild arg BUILD_GIT_HEAD value assign failed ([eb28511](https://github.com/allex/fss-proxy/commit/eb28511b1edca60cf508e0fad934b422253d3580))

### [1.1.3](https://github.com/allex/fss-proxy/compare/1.1.2...1.1.3) (2021-07-02)


### Features

* add base image support with on-build instruction ([147009c](https://github.com/allex/fss-proxy/commit/147009c7b5a9cee7d08bc5e06fa3c35cfccad08f))
* add traversal route /svc/* ([bda152d](https://github.com/allex/fss-proxy/commit/bda152d4fc94c83be667caae20937507e796598c))
* merge docker build instructions, add SPA compatible [FSS_SPA] ([66748ab](https://github.com/allex/fss-proxy/commit/66748ab45113043d5b218687c7d655ca274150b5))

### [1.1.2](https://github.com/allex/fss-proxy/compare/1.0.0...1.1.2) (2021-05-18)


### Features

* add api/oauth2/* excludes ([8eb156c](https://github.com/allex/fss-proxy/commit/8eb156c1036969703812496370f347665fe2958a))
* add endpoint websocket support ([f518ba3](https://github.com/allex/fss-proxy/commit/f518ba3949b643a3779a022c218259e4fc14969c))
* add envgod, support multi upstreams ([417f2fe](https://github.com/allex/fss-proxy/commit/417f2feceb196c75e8647c716cd543bf0c6b298a))
* add Makefile for multi bundles ([045f838](https://github.com/allex/fss-proxy/commit/045f838d4c7617436f64ccf2743fc9d3cc9049be))
* add static fallback ([c75a813](https://github.com/allex/fss-proxy/commit/c75a813e34ab9d7eb700691a79cb59d8358e9a4e))

## 1.0.0 (2020-05-09)
