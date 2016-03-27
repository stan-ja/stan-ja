## 2. ソフトウェア開発としてのモデル構築
Stanで統計モデルの開発を行うということはStanプログラムを書くということを意味し、それは一種のソフトウェア開発です。ソフトを開発することは大変です。とても大変です。変わりつつある箇所とその組み合わせが非常にたくさんあるため、多くのことが間違った方に行くことがあります。

コンピュータプログラムを書くことにもともと備わっている複雑さによって引き起こされる諸問題を軽減するために、ソフトウェア開発の営みはデザインされています。不幸なことに、多くの方法論は独断的な考えかセコいテクニックに話題がそれます。開発者への堅実で実践的なアドバイスで私達がオススメできるものは、(Hunt and Thomas, 1999)と(McConnell, 2004)です。この節では彼らのアドバイスのいくつかをまとめようとしています。

### 2.1. バージョン管理を使う
バージョン管理のソフト（SubversionやGitなど）はコーディングしはじめる前に使えるように用意しておくべきです(注1)。バージョン管理を学ぶことは労力の大きな投資に見えるかもしれません。しかし、その価値はあります。一つのコマンドで前に作業していたバージョンに戻ることができたり、今のバージョンと古いバージョンの差を得ることができます。あなたが他の人と作業を共有する必要がある時にはもっとよいものになります。**`{on a paper}`**。作業は独立に行われ、自動的にマージされるでしょう。Stan自体がどのように開発されているかについては62章を見てください。

(注1) StanはSubversion (SVN)を使ってはじまりましたが、もっと色々なことができるGitに移行しました。GitはSVNができることは全部できるし、もっと色々なことができます。対価としてはSVNより学習曲線が急なことが挙げられます。個人用、もしくはとても小さいチームでの開発ならSVNでいいです。

### 2.2 再現可能にする
モデルを動かす時にコマンドライン上で（もしくはRやPythonのような言語をインタラクティブなモードで起動して）コマンドを入力するよりは、スクリプトを書いてモデルにデータを入れて、必要な事後の解析を試して欲しいです。スクリプトはCmdStanを使ったシェルスクリプトでも、RStanを使ったRスクリプトでも、PyStanを使ったPythonスクリプトでも書けます。そのスクリプトはどんな言語でもいいですが、必要なものはすべて含んで自己完結しているべきです。設定されているグローバル変数や読み込まれている他のデータに依存するべきではありません。

Stanにおける再現性とそのインターフェースについての完全な情報については22章を見てください。

#### スクリプトとよい文書
もし1行のコードのプロジェクトならやりすぎに見えるかもしれませんが、スクリプトはコードの実行の仕方だけではなく、何が実行されるかについて具体的なドキュメントでもあるべきです。

#### ランダム化と乱数の種の保存
ランダムネスは再現性をダメにします。MCMCは概念上は乱数を使ってランダム化されています。Stanのサンプラーは乱数を使ったランダムな初期化を行うだけでなく、MCMCのiterationごとにも乱数を使ってランダム化しています（ハミルトニアン・モンテカルロは各々のiterationでランダムなモーメントを生成します）。

コンピュータは決定論的です。真のランダムネスは存在せず、擬似乱数の生成があるだけです。「種」をもとに乱数の列が生成されます。Stan では（Rのような他の言語でも）時刻や日付に基づいた種を生成する方法を使うことができます。また、種をStanに（もしくはRに）整数として与えることもできます。Stanはあとで結果が再現するように、Stan自体のバージョン番号だけでなく、乱数を生成するのに使った乱数の種を出力することができます(注2)。

(注2) 再現性を保つにはコンパイラを同じにして、ハードウェアを同じにする必要もあります。なぜなら浮動小数点演算はOSやハードウェアの設定やコンパイラをまたいで振る舞いが完全に同じではないからです。


### 2.3. 可読性を高める
他の形式のライティングのように聴衆ありきでプログラムやスクリプトを扱うことで、コードの使われ方について重要な広がりがあります。他人がプログラムやモデルを読みたくなるかもしれないだけでなく、開発者もあとからそれを読みたくなるでしょう。Stanのデザインのモチベーションの一つは次の諸観点からモデルがドキュメントそのものになることでした。変数の使い方（すなわちデータとパラメータの対比）や型（すなわち分散共分散行列と制限のない行列の対比）やサイズの観点です。

可読性の大きな部分は一貫性です。特に名前とレイアウトにおける一貫性です。プログラムだけではなく、そのプログラムが置かれるディレクトリやファイルの名前やレイアウトの一貫性です。

コードの可読性はコメントについてだけではありません（Stanのコメントの推奨や文法については2.8節を見てください）。

誰か他の人に助けを得るためにデバッグやデザインの問題について十分に説明しようとする時に、その問題の解決策が出てくることは驚くべきほどたくさんあります。これはメーリングリスト上でも起こりえます。人to人の時に最もそうなります。あなた自身の問題を誰かに説明する時に解決策を見つけることはソフトウェア開発において非常に多いので、聞いている人は「ゴムのアヒル」と呼ばれています。なぜなら聞いている人は話に合わせてうんうんと相づちを打つだけだからです(注3)。

(注3) 実際のゴムのアヒルではうまくいかないことが研究によって示されています。何らかの理由でゴムのアヒルは実際に説明を理解できなければならないのです。


### 2.4. データを探検する

言うまでもないことですが、やみくもにデータをフィットだけさせようとしないでください。実際に手元にあるデータの性質を理解するために、よく見てください。もしロジスティック回帰をしているなら、それは分離可能ですか？もしマルチレベルモデリングをしているなら、そもそもの結果はレベルごとに変化していますか？もし線形回帰をしているなら、xとyの散布図を書いてそんなモデルが意味があるかどうか見てみましょう。


### 2.5. トップダウンでデザインし、ボトムアップでコーディングする

ソフトウェアのプロジェクトはだいたいいつも一つかそれ以上の意図的なユースケースからトップダウンでデザインされます。一方、良いソフトウェアのコーディングは典型的にはボトムアップで行われます。
トップダウンデザインの動機は明白です。ボトムアップ開発の動機は、すでにすっかりテスト済みのコンポーネントを使って開発するほうがはるかに容易だということです。Stanはモジュール対応もテストへの対応も組み込まれていませんが、同じ原理の多くがあてはまります。
Stanの開発者自身がモデルを構築するやり方は、できるだけ単純にスタートし、そこから組み立てていきます。これは最終的に複雑なモデルを想定しているときであっても、また最終的にフィットさせたいモデルの良いアイディアを持っている場合であっても同様です。複数の交互作用、事前共分散、またはその他の複雑な構造の階層的モデルを構築するよりも、単純にスタートしましょう。固定の（そしてややタイトな）事前分布の単純な回帰モデルを構築しましょう。それから交互作用やレベルの追加をおこないます。1度にひとつずつ。正しくなっていることを確認しましょう。それから拡張です。


### 2.6. シミュレートされたデータでフィットさせる

あなたのモデルが計算上正しいことを確認するための最善の方法のひとつは、シミュレートされた（つまり偽りの）データを既知のパラメータで作成し、それからモデルがこのパラメータをデータから再生することができるかどうかを確認することです。もしだめであれば、生のデータで正しい結果を得る希望はほとんど持てないでしょう。
*There are fancier ways to do this, where you can do things like run χ2 tests on marginal statistics or follow the paradigm introduced in (Cook et al., 2006), which involves interval tests.*
周辺統計でのカイ2乗検定、またはインターバルテストを含んでいるクックら(2006)の枠組みに従うといったときにこれをおこなうもっと洒落た方法がある。 →ここの意味がわからない

### 2.7. 印字することでデバッグする

Stanにはステップごとのデバッガも単体テストのフレームワークもついていませんが、昔ながらのprintfでのデバッグはサポートしています(注4)。
Stanは1つまたはそれ以上の文字列もしくは式を引数として持つprint文をサポートしています。Stanは命令型の言語なので、変数はプログラムの実行中の異なる場所で異なる値を持つことができます。Print文はStanのようなステップごとのデバッガを持たない言語には非常に価値があります。
例えば、変数yとzの値を表示するときは以下のような文を使います。 `print("y=",y,"z=",z);`
このPrint文は文字列`"y="`に続いて変数yの値、文字列`"z="`に続いて変数zの値を印字します。
それぞれのPrint文の最後には改行がつきます。改行のための具体的なアスキー文字はプラットフォーム依存です。
任意の式表現を使うことができます。例えば、
```
    print("1+1=",1+1);
```
という文は`"1+1=2"`に続けて改行を印字します。
Print文は他の命令を使うことができる場所ならどこでも使うことができますが、頻度についての挙動は記述されているブロックがどのくらいの回数評価されるかに依存します。Print文の文法と評価について詳しくはセクション26.8を参照してください。

(注4) 「f」がついているのは誤字ではありません。これはC言語で書式付き印字をするときに使われるprintf関数の名前にちなんだ歴史的な産物です。

 
### 2.8. コメント

*コードは嘘をつかない*

機械はドキュメントに書かれたことではなくコードに書かれたことを実行します。ドキュメントは一方、必ずしもコードと一致しません。ドキュメントがきちんとメンテナンスされていない場合、コードの進化にともなってコードのドキュメントは容易に腐ってしまいます。
したがって、読めないコードのドキュメントを書くのに対して、読めるコードを書くほうが常に好ましいです。ドキュメントを書くときにはいつも、コードをそんな風にかく方法がないか自問して、ドキュメントが不必要になるようにしましょう。

*Comment Styles in Stan*
Stan supports C++-style comments; see Section 28.1 for full details. The recommended style is to use line-based comments for short comments on the code or to comment out one or more lines of code. Bracketed comments are then reserved for long documentation comments. The reason for this convention is that bracketed comments cannot be wrapped inside of bracketed comments.


*What Not to Comment*
When commenting code, it is usually safe to assume that you are writing the comments for other programmers who understand the basics of the programming lan- guage in use. In other words, don’t comment the obvious. For instance, there is no need to have comments such as the following, which add nothing to the code.
```
    y ~ normal(0,1);  // y has a unit normal distribution
```
A Jacobian adjustment for a hand-coded transform might be worth commenting, as in the following example.
```
    exp(y) ~ normal(0,1);
    // adjust for change of vars: y = log | d/dy exp(y) |
    increment_log_prob(y);
```
It’s an art form to empathize with a future code reader and decide what they will or won’t know (or remember) about statistics and Stan.

*What to Comment*
It can help to document variable declarations if variables are given generic names like N, mu, and sigma. For example, some data variable declarations in an item-response model might be usefully commented as follows.
```
    int<lower=1> N;  // number of observations
    int<lower=1> I;  // number of students
    int<lower=1> J;  // number of test questions
```
The alternative is to use longer names that do not require comments.
```
    int<lower=1> n_obs;
    int<lower=1> n_students;
    int<lower=1> n_questions;
```
Both styles are reasonable and which one to adopt is mostly a matter of taste (mostly because sometimes models come with their own naming conventions which should be followed so as not to confuse readers of the code familiar with the statistical conventions).
Some code authors like big blocks of comments at the top explaining the purpose of the model, who wrote it, copyright and licensing information, and so on. The following bracketed comment is an example of a conventional style for large comment blocks.

```
    /*
    * Item-Response Theory PL3 Model
     * -----------------------------------------------------
     * Copyright: Joe Schmoe  <joe@schmoe.com>
     * Date:  19 September 2012
     * License: GPLv3
     */
    data { // ...
```

The use of leading asterisks helps readers understand the scope of the comment. The problem with including dates or other volatile information in comments is that they can easily get out of synch with the reality of the code. A misleading comment or one that is wrong is worse than no comment at all!
