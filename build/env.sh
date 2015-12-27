#!/bin/bash

CJK_MAIN_FONT=IPAPMincho
MONOSPACE_FONT=IPAGothic

function get_markdown() {
   find . -name "*.md" | grep -v "README.md" | sort
}

export PANDOC="pandoc
  --latex-engine=xelatex
  --template=build/template.latex
  -V CJKmainfont=$CJK_MAIN_FONT
  -V monofont=$MONOSPACE_FONT"

