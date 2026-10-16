# FAIR Data Train specifications

The specifications of the FAIR Data Train (FDT), published at
**<https://specs.fairdatatrain.org>**.

| Document | Source | Published at |
|---|---|---|
| **FAIR Data Train — General Architecture** (v0.2, editors' draft) | [`index.bs`](index.bs) | <https://specs.fairdatatrain.org/> |
| **FAIR Data Train — Visit Protocol** (v1, editors' draft): the protocol between a Data Station and a Train Handler | [`visit-protocol/index.bs`](visit-protocol/index.bs) | <https://specs.fairdatatrain.org/visit-protocol/> |
| General Architecture **v0.1** (10 July 2025), the previous version, unchanged in content | [`v0.1/index.bs`](v0.1/index.bs) | <https://specs.fairdatatrain.org/v0.1/> |

The specifications describe the behaviour of the
[FAIR Data Train reference implementation](https://github.com/FAIRDataTeam/FAIRDataTrain). Its
shared contracts — vocabularies, SHACL shapes, JSON Schemas, OpenAPI documents and the fixtures
every component is tested against — live in
[`fdt-commons`](https://github.com/FAIRDataTeam/fdt-commons) and are the normative artefacts the
Visit Protocol text refers to. The examples under `visit-protocol/examples/` are copied from there
verbatim; `FDT-COMMONS-COMMIT` records which commit.

## Building

The sources are [Bikeshed](https://speced.github.io/bikeshed/) documents (`*.bs`). The built
`*.html` beside each source is committed, because GitHub Pages serves this repository's root
directly; a CI workflow fails if a committed page differs from what its source builds to.

```sh
make            # builds every specification into its .html (creates .venv on first run)
make check      # fails if any committed page is stale
make watch      # rebuilds the protocol spec on every save
```

Bikeshed is pinned to 7.2.0 on Python 3.12: its output is deterministic for one version and not
across versions, and 7.x does not run on Python 3.14. `uv` is used to create the environment.

## Layout

```
index.bs, index.html                 the General Architecture, latest version
visit-protocol/index.bs, index.html  the Visit Protocol
visit-protocol/examples/             fixtures copied from fdt-commons (see FDT-COMMONS-COMMIT)
visit-protocol/diagrams/             sequence and state diagrams (hand-authored SVG)
v0.1/                                the previous version of the General Architecture
boilerplate/                         the header, status and licence text shared by every document
images/                              figures
```

Each document directory holds symlinks to `boilerplate/*.include`, which is how Bikeshed finds a
document's local boilerplate.

## Versions

The root serves the latest General Architecture. When a new version is published, the previous
one is frozen under `vN.N/` with its own source, and the new document's *Previous Version* points
at it.

## Citing

See [`CITATION.cff`](CITATION.cff).
