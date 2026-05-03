#!/usr/bin/env bash
set -euo pipefail

MAIN="main"
BUILD_DIR="build"
PASSES="${PASSES:-2}"

usage() {
    cat <<EOF
Usage: $(basename "$0") [build|clean|rebuild]
  build    Compile $MAIN.tex with xelatex into $BUILD_DIR/ (default)
  clean    Remove $BUILD_DIR/ and stray auxiliary files
  rebuild  clean + build

Env:
  PASSES   Number of xelatex passes (default: $PASSES)
EOF
}

clean() {
    rm -rf "$BUILD_DIR"
    find . -maxdepth 2 -type f \( \
        -name '*.aux' -o -name '*.log' -o -name '*.out' -o -name '*.toc' \
        -o -name '*.nav' -o -name '*.snm' -o -name '*.vrb' -o -name '*.fls' \
        -o -name '*.fdb_latexmk' -o -name '*.synctex.gz' -o -name '*.bbl' \
        -o -name '*.blg' -o -name '*.run.xml' -o -name '*-blx.bib' \
        -o -name '*.bcf' \
    \) -delete
}

build() {
    mkdir -p "$BUILD_DIR"
    for i in $(seq 1 "$PASSES"); do
        echo ">>> xelatex pass $i/$PASSES"
        xelatex -interaction=nonstopmode -halt-on-error \
            -output-directory="$BUILD_DIR" "$MAIN.tex"
    done
    cp "$BUILD_DIR/$MAIN.pdf" "./$MAIN.pdf"
    echo "PDF: $MAIN.pdf"
}

case "${1:-build}" in
    build)   build ;;
    clean)   clean ;;
    rebuild) clean && build ;;
    -h|--help) usage ;;
    *) usage; exit 1 ;;
esac
