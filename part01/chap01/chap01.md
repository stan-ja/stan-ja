# Overview
このドキュメントは統計モデリング言語であるStanのユーザーガイド，リファレンスマニュアルです．導入の章ではStanの全体像について紹介しますが，残りの章ではモデルの実際のプログラミングや，Stanのモデリング言語としての詳細な解説を，コードやデータの型も含めて，実践的な解説を行います．

## 1.1 Stan Home Page

最新のコード，例，マニュアル，バグレポート，機能追加の要望など，Stanに関する情報は下記のリンクにあるStanのホームページから参照できます．

[http://mc-stan.org](http://mc-stan.org)

## 1.2 Stanのインターフェース
Stan Projectでは３つのインターフェースをプロジェクトの一部としてサポートしています．モデリング部分やその使い方に関しては３つのインターフェースで共通していてるので，このマニュアルはその３つに共通するモデリング言語としてのマニュアルとなります．
すべてのインターフェースについて初期化やサンプリング，チューニング方法について共通していて，また事後分布を分析する機能についてもおおまかに共有されています．

提供されているすべてのインターフェースについて，getting-started guideやドキュメントが完全なソースコードと共に提供されています．

### CmdStan
CmdStanはコマンドラインからStanを利用することを可能にします．ある意味でCmdStanはStanのリファレンス実装ともいえます．もともとCmdStanのドキュメントはこのドキュメントの一部でしたが，今では独立したドキュメントとなっています．CmdStanのホームページは下記になります

[http://mc-stan.org/cmdstan.html](http://mc-stan.org/cmdstan.html)

### RStan
RStanはRにおけるStanのインターフェースです．RStanは，R2WinBUGSとR2jagsのモデルのように外側からStanを呼び出しているというよりは，むしろRのメモリに対するインターフェースです．RStanのホームページは下記のとおりです．

[http://mc-stan.org/cmdstan.html](http://mc-stan.org/cmdstan.html)

### PyStan
PyStanはPythonにおけるStanのインターフェースです．RStanと同様に外側のStanを呼び出すというよりは，pythonのメモリレベルのインターフェースです．PyStanのホームページは下記です．

[http://mc-stan.org/pystan.html](http://mc-stan.org/pystan.html)


### MatlabStan
MatlabStanはMatlabにおけるStanへのインターフェースです．RstanやPyStanとは異なり,現状MatlabStanはCmdStanのラッパーです．MatlabStanのホームページは下記のとおりです．

[http://mc-stan.org/matlab-stan.html](http://mc-stan.org/matlab-stan.html)

### Stan.jl
Stan.jlはJuliaにおけるStanのインターフェースです．これもMatlabStanと同様に，CmdStanのラッパーです．Stan.jlのホームページは以下のとおりです．

[http://mc-stan.org/julia-stan.html](http://mc-stan.org/julia-stan.html)

### StataStan
StataStanはStataにおけるStanのインターフェースです．MatlabStan，Stan.jl と同様にこれもCmdStanのラッパーです．StataStanのホームページは下記になります．

[http://mc-stan.org/stata-stan.html](http://mc-stan.org/stata-stan.html)


## 1.3 Stanのプログラム
Stanのプログラムは条件付き確率分布 $p(\theta|x, y)$により定義されます．ここで$\theta$はモデリングしたい未知の値の列(例： モデルの変数, 隠れ変数, 欠損データ, 将来の予測値)で，$y$はモデリングされる既知の変数列，$x$はモデリングされていない説明変数の列で定数です（例：サイズ，ハイパーパラメタ）．

Stanのプログラム，変数の型宣言とステートメントからなります．変数の型には制約が有る，もしくは無い，整数，実数，ベクトル，行列はもちろん，その他の型の（多次元な）配列もあります．

変数は，その使い方に応じて，data, transformed data, parameter, transformed parameter, generated quantityなるブロックの中で定義されます．また制約のないローカル変数はステートメントブロックで定義されます．

transformed data，transformed parameter，generated quantitiesのブロックはそのブロック自身で宣言された変数の定義文を含みます．

特別なmodelブロックはモデルの対数尤度を定義する文からなります．

modelブロックではBUGS風のサンプリング記法が逐次的な，変数の対数尤度や，対数尤度関数を定義する変数で用いられます．

対数尤度の変数もまた，直接アクセスすることができ，ユーザ定義関数や，変換のヤコビアンも利用できます．
**
 The log probability variable may also be accessed directly, allowing user-defined probability functions and Jacobians of transforms.
**






