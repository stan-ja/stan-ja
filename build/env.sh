#!/bin/bash

CJK_MAIN_FONT=IPAPMincho
MONOSPACE_FONT=IPAGothic

function get_markdown() {
   find . -name "*.md" | grep -v "README.md" | sort
}

export PANDOC_PDF="pandoc
  -t latex
  --latex-engine=xelatex
  --template=build/template.latex
  -V CJKmainfont=$CJK_MAIN_FONT
  -V monofont=$MONOSPACE_FONT"
export PANDOC_HTML="pandoc
  -t html5
  --standalone
  --template=build/template.html"

