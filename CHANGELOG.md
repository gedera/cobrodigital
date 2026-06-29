# Changelog

## [1.9.0] — 2026-06-29

### Correcciones
- Reparar la rama HTTPS GET del cliente: variable `data` indefinida y colisión de la constante `CobroDigital::URI` con el módulo `::URI` de la stdlib (#9) — @gedera
- Agregar `require` explícitos de `net/http`, `uri`, `digest` y `json` (antes dependían de carga transitiva) (#10) — @gedera
- Enmascarar el `sid` y la PII del pagador en el log SOAP (`filters: [:parametros_de_entrada]`); `log_level` configurable vía `COBRODIGITAL_LOG_LEVEL` con default seguro `:error` (#12) — @gedera
- Validar `client_to_use` contra `CLIENTS` en `Client#initialize` → `ArgumentError` ante valor inválido (#13) — @gedera

### Mejoras internas
- Eliminar la dependencia de ActiveSupport: `present?` → `to_s.empty?` y `constantize` → `Net::HTTP::Post`/`Net::HTTP::Get` directos. La gema corre standalone sin Rails (#11) — @gedera

### Tests
- Reemplazar el spec placeholder (que fallaba a propósito) por tests reales de los constructores de operaciones y de `Operador#parse_response` (#14) — @gedera

### Otros
- CI/CD: GitHub Actions — `main.yml` (rspec sobre Ruby 2.7 en PRs y push a master) y `release.yml` (build + push a RubyGems tag-driven, vía `GEM_HOST_API_KEY`) — @gedera
- Eliminar `.travis.yml` legacy (Ruby 1.8.7) — @gedera
- gemspec: declarar `rspec ~> 3.13`, quitar el pin de `bundler`, `required_ruby_version = ['>= 2.7', '< 3.0']`, `documentation_uri` — @gedera
- Documentación: refrescar artefactos arch-* (`docs/`, `README.md`, `skill/SKILL.md`) al estado post-fix — @gedera
