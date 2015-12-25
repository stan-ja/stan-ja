## 22.再現性Reproducibility

現代のコンピュータにおける浮動小数点演算は，IEEE754に準拠した基礎的な数値演算が完全には規定されていないため，追試が難しいことで有名です。根本的な問題点は演算の精度がハードウェアプラットフォームやソフトウェアの実装により異なっていることにあります。
Stanは完全な再現性を許容すべく設計されています。しかしながら，それはあくまで浮動小数点計算により課せられた外的制約により左右されます。

Floating point operations on modern computers are notoriously difficult to replicate because the fundamental arithmetic operations, right down to the IEEE 754 encoding level, are not fully specified. The primary problem is that the precision of operations varies across different hardware platforms and software implementations.
Stan is designed to allow full reproducibility. However, this is only possible up to the external constraints imposed by floating point arithmetic.

Stanの結果は以下のすべての要素が一致しているときにのみ厳密に再現可能となります：

- Stanのバージョン
- Stanのインターフェイス(Rstan, PyStan, CmdStan) およびそのバージョン，さらにインターフェイス言語(R, Python, shell)のバージョン
- インクルードされたライブラリのバージョン(BoostおよびEigen)
- OSのバージョン
- CPU，マザーボード，メモリを含むコンピュータのハードウェア
- C++コンパイラのバージョン，コンパイル時のフラグ，リンクされたライブラリ
- 乱数の種，チェーンのID，初期化およびデータを含むStan呼び出し時の設定

Stan results will only be exactly reproducible if all of the following components are identical :

- Stan version
- Stan interface (RStan, PyStan, CmdStan) and version, plus version of interface language (R, Python, shell)
- versions of included libraries (Boost and Eigen)
- operating system version
- computer hardware including CPU, motherboard and memory
- C++ compiler, including version, compiler flags, and linked libraries
- same configuration of call to Stan, including random seed, chain ID, initialization and data

これはStanの安定リリースを使っているか，特定の **`` Git hash tag  - Gitの特定のバージョンくらいに訳してしまってもよい？``** を使っているかには関係ありません。インターフェイスやコンパイラについても同様です。重要なのはもしこれらのどれか一つでも何らかの違いがあれば，浮動小数点計算の結果は変わる可能性があるということです。

It doesn’t matter if you use a stable release version of Stan or the version with a particular Git hash tag. The same goes for all of the interfaces, compilers, and so on. The point is that if any of these moving parts changes in some way, floating point results may change.

具体的には，もしあるStanプログラムをCmdStanでコンパイルするときに，最適化フラグを変更(-O3 とか -O2 または -O0)した場合，これらの一連の結果は必ずしも一致しません。このため，クラスターやIT部門に管理されたデスクトップ，自動更新がONになっているなど外部に管理されたハードウェア上で再現性を保証するのは極めて困難です。

Concretely, if you compile a single Stan program using the same CmdStan code base, but changed the optimization flag (-O3 vs. -O2 or -O0), the two programs may not return the identical stream of results. Thus it is very hard to guarantee reproducibility on externally managed hardware, like in a cluster or even a desktop managed by an IT department or with automatic updates turned on.

しかしながら，もしStanプログラムを一組のフラグを使ってコンパイルし，そのコンピュータをインターネットから取り外して一切アップデートしないようにし，10年後に戻ってきて同じように再コンパイルした場合，同じ結果が得られます。

If, however, you compiled a Stan program today using one set of flags, took the computer away from the internet and didn’t allow it to update anything, then came back in a decade and recompiled the Stan program in the same way, you should get the same results.

データについても **`bit level - ビットレベルとしてもよい？`** で同じである必要があります。例えば，もしRStanであればRcppがRの浮動小数点小数とC++の倍精度小数の変換を行います。もしRcppが変換のプロセスを変更したり異なる型を使うと，結果は **`bit level `** で同じであることは保証されません。

The data needs to be the same down to the bit level. For example, if you are running in RStan, Rcpp handles the conversion between R’s floating point numbers and C++ doubles. If Rcpp changes the conversion process or use different types, the results are not guaranteed to be the same down to the bit level.

コンパイラとコンパイラの設定も同じ問題を起こす可能性があります。インテル製コンパイラで再現性をいかにコントロールするかについての素敵な議論はCoden and Kreirzer(2014)を読んでください。 **`意訳しすぎ？参考文献へのリンクが文中に埋められているときはどう訳すべき？`**

**`PDFに埋められたBibliographyへのリンクはどう扱う？`**

The compiler and compiler settings can also be an issue. There is a nice discussion of the issues and how to control reproducibility in Intel’s proprietary compiler by Corden and Kreitzer (2014).

リンク先のBibliography  
Corden, M. J. and Kreitzer, D. (2014). Consistency of floating-point results using the Intel compiler or Why doesn’t my application always give the same answer? Technical report, Intel Corporation. 
