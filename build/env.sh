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
  --self-contained
  --mathjax=https://gist.githubusercontent.com/yohm/0c8ed72b6f18948a2fd3/raw/624defc8ffebb0934ab459854b7b3efc563f6efb/dynoload.js
  --css=https://gist.githubusercontent.com/griffin-stewie/9755783/raw/13cf5c04803102d90d2457a39c3a849a2d2cc04b/github.css"

