# Overview
このドキュメントは統計モデリング言語であるStanのユーザーガイド，リファレンスマニュアルです．序盤の章ではStanの全体像について紹介するが，後半の章ではモデルの実際のプログラミングや，Stanのモデリング言語としての解説を，言語のモデルやデータの型との関係も含めて，実践的な解説を行います．

## 1.1 Stan Home Page

最新のコード，例，マニュアル，バグレポート，機能追加の要望など，Stanに関する情報は下記のリンクにあるStanのホームページから参照できます．

[http://mc-stan.org](http://mc-stan.org)

## 1.2 Stanのインターフェース
Stan Projectでは３つのインターフェースをプロジェクトの一部としてサポートしています．モデリング部分やその使い方に関しては３つのインターフェースで共通していてるので，このマニュアルはその３つに共通するモデリング言語としてのマニュアルとなります．
すべてのインターフェースについて初期化やサンプリング，シミュレーション変数のチューニングについて共通していて，また事後分布を分析する機能についてもおおまかに共有されています．

提供されているすべてのインターフェースについて，getting-started guideやドキュメントが完全なソースコードと共に提供されています．

### CmdStan
CmdStanはコマンドラインからStanを利用することを可能にします．ある意味でCmdStanはStanのリファレンス実装ともいえます．もともとCmdStanのドキュメントはこのドキュメントの一部でしたが，今では独立したドキュメントとなっています．CmdStanのホームページは下記になります

[http://mc-stan.org/cmdstan.html](http://mc-stan.org/cmdstan.html)

### RStan
RStanはRにおけるStanのインターフェースです．RStanのインターフェースは，のメモリを経由するというよりは，R2WinBUGSとR2jagsのモデルと同様に，外側からStanを呼び出しているといえます．RStanのホームページは下記のとおりです．

[http://mc-stan.org/cmdstan.html](http://mc-stan.org/cmdstan.html)

### PyStan
PyStanはPythonにおけるStanのインターフェースです．RStanと同様にPythonのメモリ上ではなくむしろ，外側のStanを呼び出して利用します．PyStanのホームページは下記です．

[http://mc-stan.org/pystan.html](http://mc-stan.org/pystan.html)


### MatlabStan
MatlabStanはMatlabにおけるStanへのインターフェースです．RstanやPyStanとは異なり,現状MatlabStanはCmdStanのプロセスを内包しています．MatlabStanのホームページは下記のとおりです．

[http://mc-stan.org/matlab-stan.html](http://mc-stan.org/matlab-stan.html)

### Stan.jl
Stan.jlはJuliaにおけるStanのインターフェースです．これもMatlabStanと同様に，CmdStanのプロセスを内包しています．Stan.jlのホームページは以下のとおりです．

[http://mc-stan.org/julia-stan.html](http://mc-stan.org/julia-stan.html)

### StataStan
StataStanはStataにおけるStanのインターフェースです．MatlabStan，Stan.jl と同様にこれもCmdStanのプロセスを内包しています．StataStanのホームページは下記になります．

[http://mc-stan.org/stata-stan.html](http://mc-stan.org/stata-stan.html)
