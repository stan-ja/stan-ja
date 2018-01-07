## 18. ガウス過程

ガウス過程(Gaussian Process, GP)は連続的な確率過程であり、関数についての確率分布を得るものと解釈することもできます。
連続関数についての確率分布とは、大ざっぱに言うと、有効な入力のそれぞれに対応するような確率変数を無限に集めたものと見ることもできます。
サポートされる関数の一般性により、一般的な多変量（非線形）回帰の問題では、ガウス分布が事前分布によく用いられます。

ガウス過程の決定的な特徴といえば、有限個の入力点での関数の値の同時分布が多変量正規分布であることです。
これにより、有限の量の観測データからモデルを当てはめることと、有限の数の新しいデータ点についての予測をおこなうことの両方が扱いやすくなります。

単純な多変量正規分布は平均ベクトルと共分散行列によりパラメーター化されますが、ガウス過程はこれとは違って、平均関数と共分散関数によりパラメーター化されます。
平均関数と共分散関数が入力ベクトルに適用され、平均ベクトルと共分散行列が返されます。そして、この過程から抽出された関数での、入力点に対応する出力の平均と分散が得られます。

Stanでガウス過程をエンコードするには、平均関数と共分散関数を実装し、結果をそのサンプリング分布のガウス形式につなげるか（**訳: ここはよくわかりませんでした。**）、あるいは、以下で説明するような特別な共分散関数を使うかします。
この形式のモデルは単純で、シミュレーションやモデル当てはめ、事後予測推測に使うこともできるでしょう。正規分布する結果をもつGPをStanにもっと効率的に実装するには、潜在ガウス過程を周辺化し、尤度と事後予測分布を解析的に計算するためガウス分布のコレスキー因子による再パラメーター化を適用します。

ガウス過程を定義した後、この章で扱うのは、単変量の回帰、多変量の回帰、多変量のロジスティック回帰についての、シミュレーション、ハイパーパラメーターの推定、事後予測推測の基本的な実装です。
ガウス過程はとても一般的なものですから、この章では必然的に基本的なモデルをいくつか触れるのみとなっています。
さらに知るには、Rasmussen and Williams (2006)を参照してください。

### 18.1. ガウス過程回帰

多変量のガウス過程回帰のデータは、要素数$N$の入力の列$x_1,\dots,x_N \in \mathbb{R}^D$と、それと対になる出力$y_1,\dots,y_N \in \mathbb{R}$からなります。
ガウス過程の決定的な特徴は、入力$x$で条件付けされた、有限個の出力$y$の確率がガウス分布となることです。

$$ y \sim \mathsf{MultiNormal}(m(x), K(x \mid \theta)) $$

ここで、$m(x)$は$N$次元ベクトル、$K(x \mid \theta)$は$N \times N$次元の共分散行列です。
平均関数$m: \mathbb{R}^{N \times D} \rightarrow \mathbb{R}^N$に制約はありませんが、共分散関数$K: \mathbb{R}^{N \times D} \rightarrow \mathbb{R}^{N \times N}$は、すべての入力$x$について正定値行列を生成しなくてはなりません。^[ガウス過程は、共分散関数が半正定値行列を生成してもよいように拡張できます。しかし、Stanではその結果のモデルの推定ができません。これは、その結果の分布が制約のない台を持たないからです。]

一般的な共分散関数は、この章の後の実装でも使われますが、指数化二次関数（exponentiated quadratic function; **この訳でよい?**）です。

$$ K(x \mid \alpha, \rho, \sigma)_{i,j} = \alpha^2 \exp\left(-\frac{1}{2\rho^2}\sum_{d=1}^{D}(x_{i,d}-x_{j,d})^2\right)+\delta_{i,j}\sigma^2 $$

ここで、$\alpha$、$\rho$、$\sigma$は共分散関数を定義するハイパーパラメーターで、$\delta_{i,j}$は、$i=j$のとき1、それ以外のとき0の値を持つクロネッカーのデルタ関数です。この比較は、$i$と$j$との間のものであって、$x_i$と$x_j$との間のものではないことに注意してください。
ほかに注意する点として、このカーネルは、2個の独立のガウス過程$f_1$と$f_2$を畳み込んで得られたものとなっています。それぞれのカーネルは以下のとおりです。

$$ K_1(x \mid \alpha, \rho)_{i,j} = \alpha^2 \exp\left(-\frac{1}{2\rho^2}\sum_{d=1}^{D}(x_{i,d}-x_{j,d})^2\right) $$

$$ K_2(x \mid \sigma)_{i,j} = \delta_{i,j}\sigma^2 $$

対角成分に$\sigma^2$を加えるのは重要で、これにより、入力値が同じ場合$x_i=x_j$に結果の行列が正定値であることが保証されます。統計的には$\sigma$は、回帰のときのノイズ項のスケールです。

ハイパーパラメーター$\rho$は「長さのスケール」で、領域に関するガウス過程の事前分布によってあらわされる関数の頻度に対応します（**訳: ここはよくわかりません。**）。$\rho$の値がゼロに近いと、GPは高周波の関数であらわされるようになり、$\rho$の値が大きくなると低周波の関数になります。
ハイパーパラメーター$\alpha$は「周辺標準偏差」です。
GPであらわされる関数の範囲の大きさを制御します。
$\alpha$のひとつの値を条件とする1個の入力$x$に対してGPの$f_1$事前分布からの多数の抽出の標準偏差を得ることができるのであれば、$\alpha$が回復できるのですが（**訳:ここはよくわかりません**）

入力$x_i$と$x_j$を内包する二乗指数共分散関数の中の唯一の項は、入力ベクトルの差$x_i-x_j$です。こうすると、定常共分散をもつ過程が生成されます。これは、入力ベクトル$x$がベクトル$\epsilon$により$x+\epsilon$へ移動した場合にも、$K(x\mid\theta)=K(x+\epsilon\mid\theta)$なので、出力の組すべてについて共分散が不変であるという意味においてです。

内包される総和はちょうど、$x_i$と$x_j$とのユークリッド距離の二乗になっています（すなわち、距離$x_i-x_j$の$L_2$ノルムです）。
これは結果として、過程の平滑化関数の役に立っています。
関数中の変動の総量は自由ハイパーパラメーター$\alpha$、$\rho$、$\sigma$により制御されます。

距離の記法をユークリッド距離からタクシーキャブ距離（すなわち$L_1$ノルム）にかえると、連続的だが平滑ではない関数が支持されるようになります。

### 18.2. ガウス過程からのシミュレーション

もっともシンプルに、ガウス過程からの関数$f$の抽出をシミュレートするだけのStanモデルから始めます。
実際のところは、このモデルは多数の入力点$x_n$について値$y_n=f(x_n)$を抽出します。

このStanモデルは、平均関数と共分散関数を`transformed data`ブロックで定義し、多変量正規分布を使ったモデルで出力$y$をサンプリングしています。
モデルを具体化するため、前の節で書いた二乗指数共分散関数のハイパーパラメーターを$\alpha^2=1$、$\rho^2=1$、$\sigma^2=0.1$とします。そして、平均関数$m$は常にゼロベクトルを返す、すなわち$m(x) = \mathbf{0}$と定義します。^[このモデルは例題モデルリポジトリにあります。http://mc-stan.org/documentation を参照してください。]


```
data {
  int<lower=1> N;
  real x[N];
}
transformed data {
  matrix[N, N] K;
  vector[N] mu = rep_vector(0, N);
  for (i in 1:(N - 1)) {
    K[i, i] = 1 + 0.1;
    for (j in (i + 1):N) {
      K[i, j] = exp(-0.5 * square(x[i] - x[j]));
      K[j, i] = K[i, j];
    }
  }
  K[N, N] = 1 + 0.1;
}
parameters {
  vector[N] y;
}
model {
  y ~ multi_normal(mu, K);
}
```

上のモデルは、指数化二次カーネルを実装した特別な共分散関数を使ってより簡潔に書くこともできます。

```
data {
  int<lower=1> N;
  real x[N];
}
transformed data {
  matrix[N, N] K = cov_exp_quad(x, 1.0, 1.0);
  vector[N] mu = rep_vector(0, N);
  for (n in 1:N)
    K[n, n] = K[n, n] + 0.1;
}
parameters {
  vector[N] y;
}
model {
  y ~ multi_normal(mu, K);
}
```

入力するデータは、入力値のベクトル`x`とそのサイズ`N`だけです。
このようなモデルは、一定間隔の`x`の値を与えると、ガウス過程から関数のサンプル抽出をプロットするために使うことができます。


#### 多変量の入力

単変量モデルを多変量モデルにするのに必要なのは、入力データを変更することだけです。^[このモデルは例題モデルリポジトリにあります。http://mc-stan.org/documentation を参照してください。]
上の単変量モデルでは以下の行を変えるだけです。

```
data {
  int<lower=1> N;
  int<lower=1> D;
  vector[D] x[N];
}
transformed data {
...
...
```

データは、スカラーの配列ではなくベクトルの配列と宣言されるようになりました。次元数`D`も宣言されます。

この章の後でも簡単のため単変量モデルが使われますが、どのモデルも、上のシンプルなサンプリングのモデルと同様に多変量モデルに変更できるでしょう。
多変量モデルで計算上のオーバーヘッドが増えるのは距離計算のところだけです。

#### コレスキー因子と変換による実装

このシミュレーションモデルはStanでは、等方単位正規変量（** isotropic unit normal variteの訳語?? **）の平行移動、拡大縮小、回転を使うと、より効率的に実装できます。
$\eta$を等方単位正規変量（** isotropic unit normal variteの訳語?? **）とします。

$$ \eta \sim \mathsf{Normal}(\mathbf{0}, \mathbf{1}) $$

ここで、$\mathbf{0}$は$N$次の0値のベクトル、$\mathbf{1}$は、$N \times N$の単位行列です。
$L$を$K(x\mid\theta)$のコレスキー分解、すなわち、$LL^{\top}=K(x\mid\theta)$となるような下三角行列$L$とします。
すると、変換された変数$\mu + L\eta$が、意図した目的分布となります。

$$ \mu + L\eta \sim \mathsf{MultiNormal}(\mu(x), K(x \mid \theta)) $$

この変換はガウス過程のシミュレーションに直接適用できます。^[このコードは例題モデルリポジトリにあります。http://mc-stan.org/documentation を参照してください。]
このモデルのデータ宣言は`N`と`x`で、前のモデルから変わりません。変換データ(`transformed data`)の定義も`mu`と`K`については同じですが、コレスキー分解のための変数が加わります。
パラメーター(`parameters`)は、等方単位正規分布からサンプリングされたそのままのパラメーターとなり、実際のサンプルは生成量(`generated quantities`)として定義されます。

```
...
transformed data {
  matrix[N, N] L;
...
  L = cholesky_decompose(K);
}
parameters {
  vector[N] eta;
}
model {
  eta ~ normal(0, 1);
}
generated quantities {
  vector[N] y;
  y = mu + L * eta;
}
```

コレスキー分解は、データが読み込まれ、共分散行列`K`が計算された後に1度だけ計算されます。
`eta`の等方正規分布は効率化のため、ベクトル化された単変量分布として指定されます。すなわち、`eta[n]`のそれぞれが独立な単位正規分布であるとしています。
そして、サンプリングされたベクトル`y`は、上に書いた変換をそのままエンコーディングして、生成量として定義されています。

### 18.3. ガウス過程への当てはめ

#### 正規分布の出力のGP

有限の$N$について、入力$x \in R^N$と正規分布の出力$y \in R^N$を持つGPを完全に生成するモデルは以下のようになります。

$$ \begin{array}{l} \rho \sim \mathsf{InvGamma}(5, 5)\\ \alpha \sim \mathsf{Normal}(0, 1) \\ \sigma \sim \mathsf{Normal}(0, 1)\\ f \sim \mathsf{MultiNormal}(0, K(x \mid \alpha,\rho))\\ y_i \sim \mathsf{Normal}(f_i, \sigma)\,\forall i \in \{1,\dots,N\} \end{array} $$

出力が正規分布なら、ガウス過程$f$を積分消去できます。より節約的なモデルは以下になります。

$$ \begin{array}{l} \rho \sim \mathsf{InvGamma}(5, 5)\\ \alpha \sim \mathsf{Normal}(0, 1) \\ \sigma \sim \mathsf{Normal}(0, 1)\\ y \sim \mathsf{MultiNormal}\left(0,K(x \mid \alpha,\rho)+\mathbf{I}_N\sigma^2\right) \end{array} $$

正規分布の出力を扱うときはガウス過程を積分消去すると計算的により効率的になります。これは、推定を行なうのがより低次元のパラメーター空間となるからです。
両方のモデルをStanで当てはめてみましょう。
はじめのモデルは潜在変数GPといわれます。一方、あとのモデルは周辺尤度GPと呼ばれます。

ガウス過程の共分散関数を制御するハイパーパラメーターは、上の生成モデルで行なったのと同様に事前分布を設定し、観測データに対してハイパーパラメーターの事後分布を計算することで、当てはめができます。
パラメーターの事前分布は、出力値($\alpha$)のスケールと、出力ノイズ($\sigma$)のスケール、入力間の距離を測るスケール($\rho$)についての事前の知識をもとに定義すべきです。
ハイパーパラメーターについて適切な事前分布を指定する方法については、18.3.4節を参照してください。

周辺尤度GPを実装したStanプログラムを以下に示します。
このプログラムは、上のシミュレーションGPの実装と似ていますが、ハイパーパラメーターについて推定を行ないますから、`transformed data`ブロックではなく、`model`ブロックで共分散行列`K`を計算する必要があります。^[このプログラムは例題モデルリポジトリにあります。http://mc-stan.org/documentation を参照してください。]

```
data {
  int<lower=1> N;
  real x[N];
  vector[N] y;
}
transformed data {
  vector[N] mu = rep_vector(0, N);
}
parameters {
  real<lower=0> rho;
  real<lower=0> alpha;
  real<lower=0> sigma;
}
model {
  matrix[N, N] L_K;
  matrix[N, N] K = cov_exp_quad(x, alpha, rho);
  real sq_sigma = square(sigma);

  // diagonal elements
  for (n in 1:N)
    K[n, n] = K[n, n] + sq_sigma;

  L_K = cholesky_decompose(K);
  rho ~ inv_gamma(5, 5);
  alpha ~ normal(0, 1);
  sigma ~ normal(0, 1);

  y ~ multi_normal_cholesky(mu, L_K);
}
```

`data`ブロックでは、入力`x[n]`に対する観測値`y[n]`のベクトル`y`を宣言するようになりました。
`transformed data`ブロックは平均ベクトルをゼロに定義するだけになっています。
3個のハイパーパラメーターは、非負に制約されるパラメーターとして定義されています。
共分散行列`K`は、未知パラメーターを含んでいるので、`transformed data`として前もって計算しておくことができなくなり、`model`ブロックで計算されるようになりました。
モデルの残りは、ハイパーパラメーターの事前分布と、コレスキー分解でパラメーター化された多変量正規分布の尤度とからなっています。値`y`が既知量となったので、共分散行列`K`はハイパーパラメーターにのみ依存する既知量です。したがって、ハイパーパラメーターを推定します。

標準の`MultiNormal`ではなく、コレスキー分解でパラメーター化された`MultiNormal`を使用しました。これは、小さな行列にも大きな行列にも最適化されている`cholesky_decompose`関数を利用できるからです。
小さな行列を扱うときには、どちらの方法でも計算速度に目立った違いはありませんが、大きな行列($N \gtrsim 100$)のときは、コレスキー分解を使った方が高速になります。

ハミルトニアンモンテカルロのサンプリング、このモデルのハイパーパラメーターの推定にはきわめて高速化つ効率的です(Neal, 1997)。
ハイパーパラメーターの事後分布がよく集中しているなら、このStan実装は数百のデータ点があっても数秒でこのモデルのハイパーパラメーターに当てはめを行ないます。

##### 潜在変数のGP

GPの潜在変数による定式化もStanで明示的にコーディングできます。
これは、出力が正規分布でないときに便利でしょう。
共分散行列が正定値であることを保証するため、小さな正値の項$\delta$を共分散行列の対角成分に加える必要があります。

```
data {
  int<lower=1> N;
  real x[N];
  vector[N] y;
}
transformed data {
  real delta = 1e-9;
}
parameters {
  real<lower=0> rho;
  real<lower=0> alpha;
  real<lower=0> sigma;
  vector[N] eta;
}
model {
  vector[N] f;
  {
    matrix[N, N] L_K;
    matrix[N, N] K = cov_exp_quad(x, alpha, rho);

    // diagonal elements
    for (n in 1:N)
      K[n, n] = K[n, n] + delta;
    L_K = cholesky_decompose(K);
    f = L_K * eta;
  }
  rho ~ inv_gamma(5, 5);
  alpha ~ normal(0, 1);
  sigma ~ normal(0, 1);
  eta ~ normal(0, 1);

  y ~ normal(f, sigma);
}
```

潜在変数GPと周辺尤度GPとの間には2点ばかり違いがありますが、ささいなものです。
ひとつめは、`eta`という長さ$N$のパラメーターベクトルを加えて`parameters`ブロックを拡張したことです。
これは、潜在GPに対応する$f$という多変量正規ベクトルを生成するために`model`ブロックで使われます。
シミュレーションの節の、コレスキー分解でパラメーター化したGPと同様、$\mathsf{Normal}(0, 1)$事前分布を`eta`に設定しています。
ふたつめの違いは、尤度が単変量になったことです。とはいえ、$N$個の尤度の項を、単位共分散行列に$\sigma^2$をかけた1個の$N$次元多変量正規分布としてコーディングすることもできるでしょう。
しかし、上に示した、ベクトル化した文を使う方がより効率的です。

#### ガウス過程による離散出力

標準の線形モデルにリンク関数を導入するのと同じ方法で、ガウス過程を一般化することができます。
これにより、離散データのモデルとしてGPを使うことができるようになります。

##### ポアソンGP

カウントデータをモデリングしたいときには、$\sigma$パラメーターを取り除き、`poisson_log`を使うことができます。`poisson_log`は、対数リンクを実装し、`normal`のかわりに尤度となります。
また、全体の平均のパラメーター$a$を加えることができます。これは、$y$の周辺期待値を説明します。
正規分布するデータとはちがって、カウントデータを中央化することができないのでこのようにします。

```
data {
...
  int<lower=0> y[N];
...
}
...
parameters {
  real<lower=0> rho;
  real<lower=0> alpha;
  real a;
  vector[N] eta;
}
model {
...
  rho ~ inv_gamma(5, 5);
  alpha ~ normal(0, 1);
  a ~ normal(0, 1);
  eta ~ normal(0, 1);

  y ~ poisson_log(a + f);
}
```

##### ロジスティックガウス過程回帰

2値分類問題では、観測された出力$z_n \in \{0,1\}$は2値です。
このような出力は、ロジスティックリンクを通した、（未観測の）出力$y_n$のガウス過程を使ってモデリングします。

$$ z_n \sim \mathsf{Bernoulli}(\mathrm{logit}^{-1}(y_n)) $$

以下は別の記法です。

$$ \Pr[z_n = 1] = \mathrm{logit}^{-1}(y_n) $$

分類問題を扱うため、潜在変数GPのStanプログラムを拡張することができます。
下の$a$はバイアス項です。これは、訓練データ中のバイアスのない階級を説明するのに役立ちます。

```
data {
...
  int<lower=0, upper=1> z[N];
...
}
...
model {
...
  y ~ bernoulli_logit(a + f);
}
```

#### 関連度自動決定

多変量の入力$x \in \mathbb{R}^D$があるとき、スケールパラメーター$\rho_d$を各次元$d$について当てはめることで、二乗指数共分散関数はさらに一般化できます。

$$ k(x \mid \alpha,\vec{\rho},\sigma)_{i,j} = \alpha^2\exp\left(-\frac{1}{2}\sum_{d=1}^D\frac{1}{\rho_d^2}(x_{i,d}-x_{j,d})^2\right)+\delta_{i,j}\sigma^2 $$

`rho`の推定は、Neal (1996a)で「関連度自動決定」と名付けられていますが、これは誤解を招くものです。というのも、各$\rho_d$の事後分布のスケールの大きさは、次元$d$の入力データのスケーリングに依存するからです。
さらに、パラメーター$\rho_d$のスケールは、「関連度」ではなく$d$番目の次元の非線形性の測度(**measuresの訳??**)です(Piironen and Vehtari, 2016)。

先験的には、$\rho_d$がゼロに近づくと、次元$d$の条件付き平均は非線形になります。
経験的には、$x$と$y$との間の実際の依存性が役目を果たしています。
ある共変量$x_1$が線形の効果を持ち、別の共変量$x_2$が非線形の効果を持つとき、$x_1$の予測関連度が高い場合であっても、$\rho_1 > \rho_2$となることはありえます(Rasmussen and Williams, 2006, 80ページ)。
$\rho_d$（あるいは$1/\rho_d$）パラメーターのセット（**collectionの訳??**）は階層的にもモデリングできます。

関連度自動決定の実装はStanではそのままです。ただし、現在のところ、ユーザーが共分散行列を直接コーディングする必要があります。
`L_cov_exp_quad_ARD`という、共分散行列のコレスキー分解を生成する関数を書きます。

```
functions {
  matrix L_cov_exp_quad_ARD(vector[] x,
                            real alpha,
                            vector rho,
                            real delta) {
    int N = size(x);
    matrix[N, N] K;
    real sq_alpha = square(alpha);
    for (i in 1:(N-1)) {
      K[i, i] = sq_alpha + delta;
      for (j in (i + 1):N) {
        K[i, j] = sq_alpha
                      * exp(-0.5 * dot_self((x[i] - x[j]) ./ rho));
        K[j, i] = K[i, j];
      }
    }
    K[N, N] = sq_alpha + delta;
    return cholesky_decompose(K);
  }
}
data {
  int<lower=1> N;
  int<lower=1> D;
  vector[D] x[N];
  vector[N] y;
}
transformed data {
  real delta = 1e-9;
}
parameters {
  vector<lower=0>[D] rho;
  real<lower=0> alpha;
  real<lower=0> sigma;
  vector[N] eta;
}
model {
  vector[N] f;
  {
    matrix[N, N] L_K = L_cov_exp_quad_ARD(x, alpha, rho, delta);
    f = L_K * eta;
  }

  rho ~ inv_gamma(5, 5);
  alpha ~ normal(0, 1);
  sigma ~ normal(0, 1);
  eta ~ normal(0, 1);

  y ~ normal(f, sigma);
}
```

#### ガウス過程のパラメーターへの事前分布

GPのハイパーパラメーターの事前分布を定式化するには、GPの内在的な統計的特性、モデルにおけるGPの目的、GPを推定するときにStanで発生するおそれのある数値的問題を分析する必要があります。

おそらくもっとも重要なのは、パラメーター$\rho$と$\alpha$の識別性が弱いことです(Zhang, 2004)。
このふたつのパラメーターの比はうまく識別されますが、実用的には、このふたつのハイパーパラメーターには独立な事前分布を設定します。このふたつの量は、それらの比よりも解釈しやすいからです。

##### 長さスケールへの事前分布

GPの事前分布は柔軟に設定可能であり（** GPs are a flexible class of priors の訳?? **）、それ自体は幅広い関数を表すことができます。
長さのスケールが共分散の最小間隔未満では、GPの尤度は頭打ちになります。
事前分布で規格化しないと、この平坦な尤度のため、長さスケールが小さいところのかなりの事後分布の質量で、観測値の分散がゼロになり、GPでサポートされる関数が入力データの間を正確に補完するようになります。
その結果、事後分布が入力値に過剰適合するだけではなく、ユークリッドHMCをつかって正確にサンプリングするのが困難になります。
（** この段落はよく分かりませんでした **）

長さスケールにもっと柔軟な制約をつけたいかもしれませんが、これは、統計モデルでのGPの使われ方に依存します。

もし、モデルがGPだけからなる、すなわち以下のような場合なら、

$$ \begin{array}{l} f \sim \mathsf{MultiNormal}(0,K(x \mid \alpha,\rho))\\ y_i \sim \mathsf{Normal}(f_i,\sigma)\,\forall i \in \{1,\dots,N\}\\ x \in \mathbb{R}^{N\times D}, f \in \mathbb{R}^N \end{array} $$

小さな長さスケールへの罰則を超えるような制約は必要ないでしょう。
GPの事前分布が高周波の関数も低周波の関数も表すことができるので、両方の関数セットについて無視できない質量を事前分布が設定できます。
この場合、逆ガンマ分布、Stan言語では`inv_gamma_lpdf`を使うとうまくいくでしょう。鋭い左裾では、無限小の長さスケールに対し無視できる質量を設定する一方、重い右裾では、大きな長さスケールを可能にします。
逆ガンマ事前分布は、ゼロでの密度がゼロなので、無限小の長さスケールを回避できます。そのため、長さスケールの事後分布はゼロから離れることになります。
逆ガンマ分布は、ゼロを回避する、あるいは境界を回避する分布のひとつです。
境界を回避する事前分布についてさらに知るには9.10.1節を参照してください。

もし、GPの対象として使うのと同じ変数についての全体平均と固定効果を含めるような、より大きなモデルの部品としてGPを使うなら、すなわち以下のような場合なら、

$$ \begin{array}{l} f \sim \mathsf{MultiNormal}(0,K(x \mid \alpha,\rho))\\ y_i \sim \mathsf{Normal}(\beta_0+x_i\beta_{[1:D]}+f_i, \sigma)\,\forall i \in \{1,\dots,N\}\\ x_i^T,\beta_{[1:D]} \in \mathbb{R}^{D}, x \in \mathbb{R}^{N\times D},f \in \mathbb{R}^N \end{array} $$

大きな長さスケールにも制約をつけたいでしょう。
事実上線形（特定の共変量について）で、長さスケールを増加させるようなGP事後分布を生成するようなデータのスケールよりも大きな長さスケールは、尤度にほとんど影響しません。
こうなるとモデルは、固定効果とGPとで同じ変動を説明するようになり、識別不可能になるでしょう。
GPと線形回帰との間のオーバーラップの量を制限するため、右裾がより鋭い事前分布を使ってGPの高周波関数を制限します。
そのためには、一般化逆ガウス分布を使うことができます。


$$ f(x \mid \alpha,\beta,p) = \frac{(a/b)^{p/2}}{2K_p(\sqrt{ab})}x^{p-1}\exp(-(ax+b/x)/2) $$
$$ x,a,b \in \mathbb{R}^{+}, p \in \mathbb{Z} $$

$p \le 0$のときは左裾は逆ガンマ分布であり、右裾は逆ガウス分布です。
これはStanの数学ライブラリーにはまだ実装されていませんが、ユーザー定義関数として実装することができます。

```
functions {
  real generalized_inverse_gaussian_lpdf(real x, int p,
                                         real a, real b) {
    return p * 0.5 * log(a / b)
      - log(2 * modified_bessel_second_kind(p, sqrt(a * b)))
      + (p - 1) * log(x)
      - (a * x + b / x) * 0.5;
  }
}
data {
...
```

固定効果に高周波共変量を持たせたいときは、GPが高周波関数を使わないようにさらに規格化したいということがあるかもしれません。これは、小さな長さスケールに罰則を付けるということになります。
さいわい、GPをサポートする関数の周波数に長さスケールがどのくらい影響しているかを考えるための便利な方法があります。
固定領域$[0,T]$で長さスケール$\rho$であるゼロ平均のGPから繰り返し抽出するとしたら、GPの各抽出がゼロの軸と交わった回数の分布を得ることができるでしょう。
この確率変数、すなわちゼロと交差した回数の期待値は$T/\pi\rho$です。
$\rho$が小さくなると、交差の回数の期待値が大きくなり、GPがより高周波の関数を表すようになります。
そのためこの値は、高周波の共変量があるときには、長さスケールの事前分布の下限を設定する際に注意すべきよい統計量となります。
ただし、この統計量は入力が1次元のときにのみ有効です。

（** この項目はよく分かりませんでした。 **）

##### 周辺標準偏差への事前分布

パラメーター$\alpha$は、変動のどれくらいが回帰関数で説明されるのかに対応し、線形モデルの重みづけへの事前分散と似た役割を持っています。
これは、$\alpha$に対する半$t$事前分布のように、事前分布が線形モデルと同様に使えるということを意味します。

$\alpha$に対する半$t$あるいは半ガウス事前分布には、ゼロの周辺の事前分布の質量を小さくしないという利点があります。
これにより、GPはゼロ関数をサポートでき、出力全体の条件付き平均にGPが寄与しないということが可能になります。

#### ガウス過程による予測推論

与えられた入力$x$の列について、対応する出力$y$が観測されているとします。
新しい入力列$\tilde{x}$が与えられたとき、それらのラベルの事後予測分布は、サンプリング出力$\tilde{y}$により以下のように計算されます。

$$ p(\tilde{y} \mid \tilde{x},x,y) = \frac{p(\tilde{y},y\mid\tilde{x},x)}{p(y \mid x)} \propto p(\tilde{y},y \mid \tilde{x},x) $$

Stanでそのまま実装するには、観測された$y$と観測されていない$\tilde{y}$の同時分布の点からモデルを定義します。

```
data {
  int<lower=1> N1;
  real x1[N1];
  vector[N1] y1;
  int<lower=1> N2;
  real x2[N2];
}
transformed data {
  real delta = 1e-9;
  int<lower=1> N = N1 + N2;
  real x[N];
  for (n1 in 1:N1) x[n1] = x1[n1];
  for (n2 in 1:N2) x[N1 + n2] = x2[n2];
}
parameters {
  real<lower=0> rho;
  real<lower=0> alpha;
  real<lower=0> sigma;
  vector[N] eta;
}
transformed parameters {
  vector[N] f;
  {
    matrix[N, N] L_K;
    matrix[N, N] K = cov_exp_quad(x, alpha, rho);

    // diagonal elements
    for (n in 1:N)
      K[n, n] = K[n, n] + delta;
    L_K = cholesky_decompose(K);
    f = L_K * eta;
  }
}
model {
  rho ~ inv_gamma(5, 5);
  alpha ~ normal(0, 1);
  sigma ~ normal(0, 1);
  eta ~ normal(0, 1);
  y1 ~ normal(f[1:N1], sigma);
}
generated quantities {
  vector[N2] y2;
  for (n2 in 1:N2)
    y2[n2] = normal_rng(f[N1 + n2], sigma);
}
```

入力ベクトル`x1`と`x2`は、観測された出力ベクトル`y1`と同様に、データとして宣言します。
未知の出力ベクトル`y2`は、入力ベクトル`x2`に対応し、`generated quantities`ブロックで宣言され、モデルが実行されるときにサンプリングされます。

`transformed data`ブロックは、入力ベクトル`x1`と`x2`とを単一のベクトル`x`に結合するのに使われています。

`model`ブロックは、結合された出力ベクトル`f`についての局所変数を宣言・定義するのに使われています。`f`は、既知の出力`y1`と未知の出力`y2`の条件付き平均を連結したもので構成されます。
したがって、結合された出力ベクトル`f`は、結合された入力ベクトル`x`とそろったものとなっています。
あとは、`y`についての単変量正規分布のサンプリング文を定義することだけです。

`generated quantities`ブロックでは量`y2`を定義しています。
`y2`は、`f`の適切な要素にそれぞれ対応する平均を持つ、`N2`個の単変量正規分布をサンプリングすることにより生成します。^[このプログラムは例題モデルリポジトリにあります。http://mc-stan.org/documentation を参照してください。]

##### 非ガウス分布のGPでの予測推論

非ガウス分布のGPでも、ガウス分布GPとほとんど同様に予測推論を行なうことができます。

ロジスティックガウス過程回帰を使った予測のための以下のフルモデルを考えます。^[このモデルは例題モデルリポジトリにあります。http://mc-stan.org/documentation を参照してください。]

```
data {
  int<lower=1> N1;
  real x1[N1];
  int<lower=0, upper=1> z1[N1];
  int<lower=1> N2;
  real x2[N2];
}
transformed data {
  real delta = 1e-9;
  int<lower=1> N = N1 + N2;
  real x[N];
  for (n1 in 1:N1) x[n1] = x1[n1];
  for (n2 in 1:N2) x[N1 + n2] = x2[n2];
}
parameters {
  real<lower=0> rho;
  real<lower=0> alpha;
  real a;
  vector[N] eta;
}
transformed parameters {
  vector[N] f;
  {
    matrix[N, N] L_K;
    matrix[N, N] K = cov_exp_quad(x, alpha, rho);

    // diagonal elements
    for (n in 1:N)
      K[n, n] = K[n, n] + delta;
    L_K = cholesky_decompose(K);
    f = L_K * eta;
  }
}
model {
  rho ~ inv_gamma(5, 5);
  alpha ~ normal(0, 1);
  a ~ normal(0, 1);
  eta ~ normal(0, 1);
  z1 ~ bernoulli_logit(a + f[1:N1]);
}
generated quantities {
  int z2[N2];
  for (n2 in 1:N2)
    z2[n2] = bernoulli_logit_rng(a + f[N1 + n2]);
}
```

##### 同時予測推論の解析形

ガウス分布の観測値についてのガウス過程のベイズ予測推論は、事後分布を解析的に導出し、そこから直接サンプリングすることにより高速化できます。

いきなり結果を示すと、以下のようになります。

$$ p(\tilde{y}\mid\tilde{x},y,x) = \mathsf{Normal}(K^\top\Sigma^{-1}y,\Omega-K^\top\Sigma^{-1}K) $$

ここで、$\Sigma = K(x\mid\alpha,\rho,\sigma)$は、共分散関数を入力$x$と観測された出力$y$に適用した結果です。$\Omega = K(\tilde{x}\mid\alpha,\rho)$は、予測値の推測のために共分散関数を入力$\tilde{x}$に適用した結果です。また、$K$は、入力$x$と$\tilde{x}$の共分散の行列です。指数化二次共分散関数の場合は以下のようになります。

$$ K(x\mid\alpha,\rho)_{i,j} = \eta^2\exp\left(-\frac{1}{2\rho^2}\sum_{d=1}^D(x_{i,d}-\tilde{x}_{j,d})^2\right) $$

$x$と$\tilde{x}$の要素のインデックスは決して同じにはなりませんから、$\sigma^2$を含むノイズ項はありません。

下のStanコード^[このプログラムは例題モデルリポジトリにあります。http://mc-stan.org/documentation を参照してください。]は事後分布の解析型を使っており、コレスキー分解を使って、結果となる多変量正規分布をサンプリングしています。
データ宣言は潜在変数の例と同じですが、`gp_pred_rng`という関数を定義しています。この関数は、観測されたデータ`y1`で条件づけられた事後予測平均からの抽出を生成します。
$p(\tilde{y})$の条件つき平均と条件つき共分散を計算する際、行列-行列の乗算の数を減らすために、このコードは三角行列解（**triangular solvesの訳??**）にコレスキー分解を使っています。

```
functions {
  vector gp_pred_rng(real[] x2,
                     vector y1,
                     real[] x1,
                     real alpha,
                     real rho,
                     real sigma,
                     real delta) {
    int N1 = rows(y1);
    int N2 = size(x2);
    vector[N2] f2;
    {
      matrix[N1, N1] L_K;
      vector[N1] K_div_y1;
      matrix[N1, N2] k_x1_x2;
      matrix[N1, N2] v_pred;
      vector[N2] f2_mu;
      matrix[N2, N2] cov_f2;
      matrix[N2, N2] diag_delta;
      matrix[N1, N1] K;
      K = cov_exp_quad(x1, alpha, rho);
      for (n in 1:N1)
        K[n, n] = K[n,n] + square(sigma);
      L_K = cholesky_decompose(K);
      K_div_y1 = mdivide_left_tri_low(L_K, y1);
      K_div_y1 = mdivide_right_tri_low(K_div_y1',L_K)';
      k_x1_x2 = cov_exp_quad(x1, x2, alpha, rho);
      f2_mu = (k_x1_x2' * K_div_y1);
      v_pred = mdivide_left_tri_low(L_K, k_x1_x2);
      cov_f2 = cov_exp_quad(x2, alpha, rho) - v_pred' * v_pred;
      diag_delta = diag_matrix(rep_vector(delta,N2));
      f2 = multi_normal_rng(f2_mu, cov_f2 + diag_delta);
    }
    return f2;
  }
}
data {
  int<lower=1> N1;
  real x1[N1];
  vector[N1] y1;
  int<lower=1> N2;
  real x2[N2];
}
transformed data {
  vector[N1] mu = rep_vector(0, N1);
  real delta = 1e-9;
}
parameters {
  real<lower=0> rho;
  real<lower=0> alpha;
  real<lower=0> sigma;
}
model {
  matrix[N1, N1] L_K;
  {
    matrix[N1, N1] K = cov_exp_quad(x1, alpha, rho);
    real sq_sigma = square(sigma);

    // diagonal elements
    for (n1 in 1:N1)
      K[n1, n1] = K[n1, n1] + sq_sigma;
    L_K = cholesky_decompose(K);
  }

  rho ~ inv_gamma(5, 5);
  alpha ~ normal(0, 1);
  sigma ~ normal(0, 1);

  y1 ~ multi_normal_cholesky(mu, L_K);
}
generated quantities {
  vector[N2] f2;
  vector[N2] y2;
  f2 = gp_pred_rng(x2, y1, x1, alpha, rho, sigma, delta);
  for (n2 in 1:N2)
    y2[n2] = normal_rng(f2[n2], sigma);
}
```

#### 多出力のガウス過程

$x_i \in \mathbb{R}^K$で観測された観測値$y_i \in \mathbb{R}^M$があるとします。
このデータは以下のようにモデリングできます。

$$ \begin{array}{l} y_i \sim \mathsf{MultiNormal}(f(x_i),\mathbf{I}_M\sigma^2)\\ f(x) \sim \mathsf{GP}(m(x), K(x\mid\theta,\phi))\\ K(x\mid\theta) \in \mathbb{R}^{M \times M}, f(x), m(x) \in \mathbb{R}^M \end{array} $$

ここで、$K(x,x^\prime\mid\theta,\phi)_{[m,m^\prime]}$の要素は、$f_m(x)$とf_{m^\prime}(x^\prime)(x)との共分散を定義しています。
このようにガウス過程を構築すると、$f(x)$の出力次元の間の共分散を推定できます。
もし、カーネル$K$を以下のようにパラメーター化するなら、

$$ K(x,x^\prime\mid\theta,\phi)_{[m,m^\prime]} = k(x,x^\prime\mid\theta)k(m,m^\prime\mid\phi) $$

これに対する有限次元の生成モデルは以下のようになります。

$$ \begin{array}{l} f \sim \mathsf{MatrixNormal}(m(x),K(x\mid\alpha,\rho),C(\phi))\\ y_{i,m} \sim \mathsf{Normal}(f_{i,m},\sigma)\\ f \in \mathbb{R}^{N \times M}\end{array} $$

ここで、$K(x\mid\alpha,\rho)$は、この章でずっと使ってきた指数化二乗カーネルです。また、$C(\phi)$は正定値行列で、同じベクトル$\phi$でパラメーター化されています。

$\mathsf{MatrixNormal}$分布は、ふたつの共分散行列を引数に持ちます。$K(x\mid\alpha,\rho)$は列の共分散をエンコードし、$C(\phi)$は行の共分散を定義します。
この$\mathsf{MatrixNormal}$の目立った特徴は、行列$f$の行が以下のように分布することです。

$$ f_{[n,]} \sim \mathsf{MultiNormal}(m(x)_{[n,]},K(x\mid\alpha,\rho)_{[n,n]}C(\phi)) $$

また、行列$f$の列は以下のように分布します。

$$ f_{[,m]} \sim \mathsf{MultiNormal}(m(x)_{[,m]},K(x\mid\alpha,\rho)C(\phi)_{[m,m]}) $$

これはまた、$\mathbb{E}[f^{\top}f$が$\mathrm{trace}(K(x\mid\alpha,\rho))\times C$に等しいことを意味します。一方、$\mathbb{E}[ff^{\top}]$は$\mathrm{trace(C) \times K(x\mid\alpha,\rho)$です。
期待値の特性と、$\mathsf{MatrixNormal}$の密度を使って、これを導出することができます。

$\mathrm{trace}(C)=1$と制約をつけない限り、パラメーターは識別できませんから、$\alpha$は1.0とすべきです。
さもないと、$\alpha$にスカラー値$d$を掛け、$C$に$1/d$を掛けるとすることができ、そうしても尤度は変化しません。

$\mathbb{R}^{N \times M}$における$\mathsf{MatrixNormal}$の密度から、確率変数$f$を以下のアルゴリズムを使って生成できます

$$ \begin{array}{l} \eta_{i,j} \sim \mathsf{Normal}(0, 1)\,\forall i,j\\ f = L_{K(x\mid 1.0,\rho)} \eta L_C(\phi)^{\top}\\ f \sim \mathsf{MatrixNormal}(0, K(x\mid 1.0,\rho), C(\phi))\\ \eta \in \mathbb{R}^{N \times M}\\ L_C(\phi) = \mathrm{cholesky\_decompose}(C(\phi))\\ L_{K(x\mid 1.0, \rho)} = \mathrm{cholesky\_decompose}(K(x \mid 1.0, \rho)) \end{array} $$

これはStanでは潜在変数GPの定式化を使って実装できます。
$C(\phi)$に$\mathsf{LkjCorr}$を使っていますが、どんな正定値行列でもかまいません。

```
data {
  int<lower=1> N;
  int<lower=1> D;
  real x[N];
  matrix[N, D] y;
}
transformed data {
  real delta = 1e-9;
}
parameters {
  real<lower=0> rho;
  vector<lower=0>[D] alpha;
  real<lower=0> sigma;
  cholesky_factor_corr[D] L_Omega;
  matrix[N, D] eta;
}
model {
  matrix[N, D] f;
  {
    matrix[N, N] K = cov_exp_quad(x, 1.0, rho);
    matrix[N, N] L_K;

    // diagonal elements
    for (n in 1:N)
      K[n, n] = K[n, n] + delta;
    L_K = cholesky_decompose(K);
    f = L_K * eta
        * diag_pre_multiply(alpha, L_Omega)';
  }

  rho ~ inv_gamma(5, 5);
  alpha ~ normal(0, 1);
  sigma ~ normal(0, 1);
  L_Omega ~ lkj_corr_cholesky(3);
  to_vector(eta) ~ normal(0, 1);

  to_vector(y) ~ normal(to_vector(f), sigma);
}
generated quantities {
  matrix[D, D] Omega;
  Omega = L_Omega * L_Omega';
}
```
