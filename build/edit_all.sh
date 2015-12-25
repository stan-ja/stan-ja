#!/bin/bash

# 画像の処理
# 1. pandoc 処理のためにパスを相対パスから絶対パスに変換する
# 2. 数式画像 (キャプションが TeX になっているもの) を画像から数式に差し替える
#
# 【制限】
# * ![]() が一行で入力されてないと動かない
# * ファイル名に []() あたりの文字が入っていると死ぬ
# TODO: Markdown パーサーを使って処理するように修正
for md in `find . -name "chap*.md"`
do
  if [ -s "$md" ]
  then
    tmpfile=$(mktemp)
    dir=`dirname "$md" | sed -e 's/\//\\\\\//g'`
    replace_math="s/\!\[\$\$\(.*\)\$\$\](.*)/\$\$\1\$\$/g"
    replace_paths="s/\!\[\(.*\)\](\(.*\))/\!\[\1\](${dir}\/\2)/g"
    cat "$md" \
      | sed -e $replace_math \
      | sed -e $replace_paths \
      >"$tmpfile"
    mv -f "$tmpfile" "$md"
  fi
done

