# Modeling Language User’s Guide and Reference Manual, v2.9.0 (日本語訳)

## 目的
[Modeling Language User’s Guide and Reference Manual, v2.9.0](https://github.com/stan-dev/stan/releases/download/v2.9.0/stan-reference-2.9.0.pdf) の日本語訳の作成です.

## 文章のルール
* Markdown形式で書く
  * [参考リンク1 (pdf)](http://packetlife.net/media/library/16/Markdown.pdf)
  * [参考リンク2](http://qiita.com/Qiita/items/c686397e4a0f4f11683d) QiitaのMarkdownとは数式の部分だけは異なるので注意.
  * [参考リンク3](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)
  * プレビューに使えるサイトはいくつかあります. [wri.pe](https://wri.pe/)などです.
* Part XX は #
* Chapter は ##
* sub chapter は ###
* 文体は丁寧語にしてください.
* 句読点は好きなように. 最終的なpdfにする時には`。`を`. `に, `、`を`, `に置換します.
* 複雑な数式はスクリーンショットが望ましいです. cf. [chap33](https://github.com/stan-ja/stan-ja/blob/master/part04/chap33/chap33.md)
  * TeX記法はweb上ではレンダリングされないけど, pdf化する時には反映されます.
  * 単純な数式はお任せします.
* 複数行に渡るStanコードは\`\`\`textと\`\`\`で囲む
* インラインのStanコードは\`と\`で囲む
* 自信のない箇所は英文のままにしておく. できれば, \*\*\`と\`\*\*で囲んで強調しておく.
* 最終的にpandocを使ってmdファイルから1つのpdfファイルにします.

## 運用のルールとgitの初歩

* 作業はbranchを切ってからおねがいします．
	* ブランチ名は新しく記事を作成する場合は接頭語に `create/` をつける
	* 修正する場合は `fix/` をつける
	* それ以外の例外的な部分も作業内容がわかるようにbranch名を決めて頂けると幸いです．

* レビュワーは r-wakalang/rstan あたりで探して下さい．
* レビュワーのlgtmがでたら作業者は確認のうえでmaster branchにmerge!


### チームで翻訳する，大まかな流れ
* 最新のremoteにあるmaster branchを取得します．

```
% git pull origin master
```

* 作業用のbranchを切ります

```
git checkout -b 'create/partxx/chapyy'
```

* 修正したファイルをgitのインデックスに登録します

```
git add hoge/huga.md
```

* インデックスに追加した更新をローカルブランチにcommitします

何を修正したのかがわかるようにコミットメッセージを追加しましょう．
```
git commit -m '１章を翻訳しました＜＜コミットメッセージ'
```

* コミット内容をリモートブランチにpushします

```
git push origin create/partxx/chapyy
```

* github上からmaster branchに対するpull requestを送ります．

* レビュワーの意見を元に再度修正を行い `add` > `commit` > `push` を行います

* lgtmがでたらmasterブランチにmergeしましょう．
