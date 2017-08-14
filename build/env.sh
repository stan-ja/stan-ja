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
  --mathjax=https://gist.githubusercontent.com/MatsuuraKentaro/6796418c5454bb1e3b6ac0427008d7fe/raw/ff13e4c7571c154077dfecb9fb2cea401dec57c6/dynoload.js
  --css=build/github-pandoc.css
  --template=build/template.html"

