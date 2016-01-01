## 7. 時系列モデル

時系列データは、時間軸に沿って得られたデータです。この章では2種類の時系列モデルを紹介します。1つは、自己回帰および移動平均モデルといった回帰に似たモデル、もう1つは隠れマルコフモデルです。

15章ではガウス過程を紹介しますが、これを時系列（と空間）データに使ってもよいでしょう。

### 7.1 自己回帰モデル

正規ノイズの1次自己回帰モデル(AR(1))では、各点<var>y<sub>n</sub></var>は次式のように生成される数列<var>y</var>にまとめられます。

![$$y_{n} \sim \mathsf{Normal}(\alpha + \beta y_{n-1}, \sigma)$$](fig/fig01.png)

すなわち、<var>y<sub>n</sub></var>の期待値は<var>α</var> + <var>βy</var><sub><var>n</var>-1</sub>で、ノイズのスケールは<var>σ</var>です。

#### AR(1)モデル

傾き（<var>β</var>）、切片（<var>α</var>）、ノイズスケール（<var>σ</var>）の回帰係数に非正則平坦一様分布を設定するなら、AR(1)モデルのStanプログラムは以下のようになります。

```
data {
  int<lower=0> N;
  vector[N] y;
}
parameters {
  real alpha;
  real beta;
  real<lower=0> sigma;
}
model {
  for (n in 2:N)
    y[n] ~ normal(alpha + beta * y[n-1], sigma);
}
```

最初の観測データ点`y[1]`はここではモデル化されていません。これは条件となるものが何もないからです。そのかわり、`y[2]`の条件となっています。このモデルではまた`sigma`に非正則事前分布を使っていますが、もし`y`の時間的変化のスケールに情報があるのなら、問題なく情報事前分布を加えることができます。あるいは、`y`のスケールに大ざっぱな知識があるのであれば弱度の情報事前分布で推定を良くすることもできます。

##### スライシングで効率よく

おそらく少し読みにくくはなりますが、上のモデルをとても効率良く記述する方法がベクトルのスライシングです。上のモデルは1行で書けます。

```
model {
  tail(y, N - 1) ~ normal(alpha + beta * head(y, N - 1), sigma);
}
```

tail演算は、`y`の末尾から`N - 1`個の要素を取り出すもので、head演算は最初の`N - 1`個を取り出すものです。head要素に`beta`を掛けるのにはベクトル計算を使っています。

#### AR(1)モデルの拡張

回帰係数とノイズパラメーターには、ある範囲の違った分布族の生息事前分布を加えてもよいでしょう。正規ノイズモデルは、スチューデントのt分布などの制限のないことがわかっている分布に変えることができます。複数の観測系列があるようなら、このモデルは階層的にもできるでしょう。

定常AR(1)プロセスの推定に限定させるなら、傾きの係数`beta`には以下のように上下限に制約をつけてもよいかもしれません。

```
real<lower=-1,upper=1> beta;
```

実際には、こうした制約はおすすめしません。データが定常でないなら、モデルのあてはめのときにそれがわかるというのが最善です。定常パラメーターの推定は、`beta`の事前分布の値が零近辺に集まるようにすることで可能です。

#### AR(2)モデル

このモデルの次数を拡張するのも簡単にできます。例えば、2次の係数`gamma`を入れることで、以下のモデル文のようにAR(2)モデルをコーディングできます。

```
for (n in 3:N)
  y[n] ~ normal(alpha + beta*y[n-1] + gamma*y[n-2], sigma);
```

#### AR(<var>K</var>)モデル

次数自体もデータとして与えるような一般モデルは、係数を配列に入れ、線形予測子をループ内で計算させるようにしてコーディングできます。

```
data {
  int<lower=0> K;
  int<lower=0> N;
real y[N];
}
parameters {
  real alpha;
  real beta[K];
  real sigma;
}
model {
  for (n in (K+1):N) {
    real mu;
    mu <- alpha;
    for (k in 1:K)
      mu <- mu + beta[k] * y[n-k];
   y[n] ~ normal(mu, sigma);
  }
}
```

#### ARCH(1)モデル

計量経済学と財政学の時系列モデルでは不等分散を仮定するのが普通です（すなわち、系列を定義するノイズ項のスケールが時間的に変化してもよいとします）。そのようなモデルで最も単純なのがARCH（AugoRegressive Conditional Heteroscedasticity, 自己回帰条件付き不等分散）モデルです(Engle, 1982)。自己回帰モデルAR(1)では、系列の平均が時間的に変化しますが、ノイズ項は固定されたままです。ARCH(1)モデルでは、これとは異なり、ノイズ項のスケールが時間的に変化する一方で平均項は固定されたままです。もちろん、平均もスケールも時間的に変化するとモデルを定義することもできるでしょう。計量経済学の文献では幅広い範囲の時系列モデリングの選択肢があります。

ARCH(1)モデルは典型的には以下の一連の式で示されます。ここで、<var>r<sub>t</sub></var>は時点<var>t</var>における収益の観測値、<var>μ</var>、<var>α<sub>0</sub></var>、<var>α<sub>1</sub></var>は未知の回帰係数パラメーターです。

![$$\begin{array}{rl}r_{t} &= \mu + a_{t} \\ a_{t} &= \sigma_{t} \epsilon_{t} \\ \epsilon_{t} &\sim \mathsf{Normal}(0, 1) \\ \sigma_{t}^{2} &= \alpha_{0} + \alpha_{1}a_{t-1}^{2}\end{array}$$](fig/fig02.png)

ノイズ項<var>σ</var><sub><var>t</var></sub><sup>2</sup>が正であることを保証するため、<var>α<sub>0</sub></var>, <var>α<sub>1</sub></var> > 0と、スケール係数は正に制約されています。時系列の定常性を保証するため、<var>α<sub>1</sub></var> < 1と、傾きは1未満に制約されています。<sup>1</sup>ARCH(1)モデルはStanでは以下のようにそのままコーディングできます。

```
data {
  int<lower=0> T;   // 時点の数
  real r[T];        // 時点tにおける収益
}
parameters {
  real mu;                       // 平均収益
  real<lower=0> alpha0;          // 誤差の切片
  real<lower=0,upper=1> alpha1;  // 誤差の傾き
}
model {
  for (t in 2:T)
    r[t] ~ normal(mu, sqrt(alpha0 + alpha1 * pow(r[t-1] - mu,2)));
}
```

このモデルのループは、時点<var>t</var> = 1における収益をモデル化しないように定義されています。次節のモデルで<var>t</var> = 1における収益のモデルかの仕方をお見せします。このモデルは、ベクトル化してより効率的にすることができません。次節のモデルでベクトル化の例を紹介します。

<sup>1</sup>実際には、この制約を外してみて、非定常な係数の組み合わせの方がデータによく当てはまるかどうかを試すのが有用なこともあります。あるいはまた、当てはまっていないトレンドがあるなら明らかに非定常でしょうから、モデルにトレンド項を加えることもあります。

### 7.2 時間的不等分散性のモデリング

一揃いの変数について、分散がすべて同じなら、等分散ということなります。一方、分散がすべては同じではないなら、不等分散ということになります。不等分散の時系列モデルでは、ノイズ項が時間的に変化してもよいとします。

#### GARCH(1,1)モデル

基本的なGARCH（Generalized AutoRegressive Conditional Heteroscedasticity, 一般化自己回帰条件付き不等分散）モデルであるGARCH(1,1)はARCH(1)モデルを拡張したもので、一期前の時点<var>t</var>-1での収益の平均との差の2乗を、時点<var>t</var>のボラティリティの予測子に含みます。

![$$\sigma_{t}^{2} = \alpha_{0} + \alpha_{1}a_{t-1}^{2} + \beta_{1}\sigma_{t-1}^{2}$$](fig/fig03.png)

スケール項が正であることと時系列が定常であることを保証するため、係数については、<var>α
</var><sub>0</sub>, <var>α</var><sub>1</sub>, <var>β</var><sub>1</sub> > 0、かつ傾きについて<var>α</var><sub>1</sub> + <var>β</var><sub>1</sub> < 1をすべて満たさなくてなりません。

```
data {
  int<lower=0> T;
  real r[T];
  real<lower=0> sigma1;
}
parameters {
  real mu;
  real<lower=0> alpha0;
  real<lower=0,upper=1> alpha1;
  real<lower=0,upper=(1-alpha1)> beta1;
}
transformed parameters {
  real<lower=0> sigma[T];
  sigma[1] <- sigma1;
  for (t in 2:T)
    sigma[t] <- sqrt(alpha0
                     + alpha1 * pow(r[t-1] - mu, 2)
                     + beta1 * pow(sigma[t-1], 2));
}
model {
  r ~ normal(mu,sigma);
}
```

ボラティリティ回帰の再帰的定義の最初を決めるために、<var>t</var> = 1におけるノイズのスケールを決める非負値の`sigma1`をデータ宣言に含めます。

制約はそのままパラメータ宣言でコーディングされています。この宣言は、`alpha1`の値が`beta1`に依存するという制約があるので、この順序どおりにする必要があります。

非負値配列の変換パラメータ(transformed parameter)`sigma`は各時点のスケールの値を格納するのに使われます。これらの値の定義はtransformed parametersブロックにあり、回帰もここで定義されるようにしました。切片`alpha0`、1期前の収益と平均との差の2乗に対する傾き`alpha1`、1期前のノイズスケールの2乗に対する傾き`beta1`がここにあります。最後に、Stanでは正規分布には（分散パラメータではなく）スケール（偏差）パラメータが必要なので、回帰全体を`sqrt`関数の中に入れています。

transformed parametersブロックに回帰を置くことにより、モデルは、ベクトル化されたサンプリング文1行にまで減りました。`r`と`sigma`の長さは`T`ですので、すべてのデータが直接モデル化されています。

### 7.3 移動平均モデル

移動平均モデルは、過去の誤差を将来の結果の予測子に使います。次数<var>Q</var>の移動平均モデルMA(<var>Q</var>)には、全体的な平均パラメータ<var>μ</var>と、過去の誤差項についての回帰係数<var>θ<sub>q</sub></var>があります。時点<var>t</var>における誤差を<var>ε<sub>t</sub></var>として、結果<var>y<sub>t</sub></var>についてのモデルは次のように定義されます。

![$$y_{t} = \mu + \theta_{1}\epsilon_{t-1} + \dots + \theta_{Q}\epsilon_{t-Q} + \epsilon_{t}$$](fig/fig04.png)

結果<var>y<sub>t</sub></var>についての誤差項<var>ε<sub>t</sub></var>は正規分布としてモデル化されています。

![$$\epsilon_{t} \sim \mathsf{Normal}(0, \sigma)$$](fig/fig05.png)

正則ベイズモデルでは、<var>μ</var>, <var>θ</var>, <var>σ</var>にはすべて事前分布を与える必要があります。

#### MA(2)の例

MA(2)モデルはStanでは以下のようにコーディングできます。

```
data {
  int<lower=3> T;  // 観測値の数
  vector[T] y;     // 時点Tにおける観測値
}
parameters {
  real mu;              // 平均
  real<lower=0> sigma;  // 誤差のスケール
  vector[2] theta;      // ラグの係数
}
transformed parameters {
  vector[T] epsilon;    // 誤差項
  epsilon[1] <- y[1] - mu;
  epsilon[2] <- y[2] - mu - theta[1] * epsilon[1];
  for (t in 3:T)
   epsilon[t] <- ( y[t] - mu
                   - theta[1] * epsilon[t - 1]
                   - theta[2] * epsilon[t - 2] );
}
model {
  mu ~ cauchy(0,2.5);
  theta ~ cauchy(0,2.5);
  sigma ~ cauchy(0,2.5);
  for (t in 3:T)
    y[t] ~ normal(mu
                  + theta[1] * epsilon[t - 1]
                  + theta[2] * epsilon[t - 2],
                  sigma);
}
```

誤差項<var>ε<sub>t</sub></var>は、観測値とパラメータを使って変換パラメータ(transformed parameter)として定義されています。（尤度を定義する）サンプリング文の定義もこれと同じ定義を使っていますが、<var>n</var> > <var>Q</var>の<var>y<sub>n</sub></var>にのみ適用可能です。この例では、パラメータにはコーシー事前分布（<var>σ</var>には半コーシー分布）を与えています。とはいえ、ほかの事前分布でも大丈夫ですが。

modelブロック中のサンプリング文をベクトル化すると、このモデルはもっと速くできるでしょう。ループの代わりにドット乗算を使って<var>ε<sub>t</sub></var>の計算をベクトル化しても高速化できるでしょう。

#### ベクトル化したMA(<var>Q</var>)モデル

確率サンプリングをベクトル化した一般的なMA(<var>Q</var>)モデルは以下のように定義できるでしょう。

```
data {
  int<lower=0> Q;  // 過去のノイズ項の数
  int<lower=3> T;  // 観測値の数
  vector[T] y;     // 時点tにおける観測値
}
parameters {
  real mu;              // 平均
  real<lower=0> sigma;  // 誤差のスケール
  vector[Q] theta;      // 誤差の係数, lag -t
}
transformed parameters {
  vector[T] epsilon;    // 時点tにおける誤差
  for (t in 1:T) {
    epsilon[t] <- y[t] - mu;
    for (q in 1:min(t - 1, Q))
      epsilon[t] <- epsilon[t] - theta[q] * epsilon[t - q];
  }
}
model {
  vector[T] eta;
  mu ~ cauchy(0, 2.5);
  theta ~ cauchy(0, 2.5);
  sigma ~ cauchy(0, 2.5);
  for (t in 1:T) {
    eta[t] <- mu;
    for (q in 1:min(t - 1, Q))
      eta[t] <- eta[t] + theta[q] * epsilon[t - q];
  }
  y ~ normal(eta, sigma);
}
```

ここではすべてのデータがモデル化されています。不足する項は単に、誤差項の計算の際に回帰から除かれます。両方のモデルともとても速く収束し、収束した連鎖はよく混ざっています。ベクトル化したモデルの方がちょっとだけ速いのですが、これは繰り返しあたりについてのことで、収束についてではありません。というのも両者は同じモデルだからです。

### 7.4 自己回帰移動平均モデル

ARMA（AutoRegressive Moving-Average, 自己回帰移動平均）モデルは、自己回帰モデルと移動平均モデルの予測子を結合させたものです。履歴が1状態のARMA(1,1)モデルは、Stanでは以下のようにコーディングできます。

```
data {
  int<lower=1> T;           // 観測値の数
  real y[T];                // 観測結果
}
parameters {
  real mu;                  // 平均の係数
  real phi;                 // 自己回帰の係数
  real theta;               // 移動平均の係数
  real<lower=0> sigma;      // 誤差のスケール
}
model {
  vector[T] nu;             // 時点tでの予測値
  vector[T] err;            // 時点tでの誤差
  nu[1] <- mu + phi * mu;   // err[0] == 0と仮定
  err[1] <- y[1] - nu[1];
  for (t in 2:T) {
    nu[t] <- mu + phi * y[t-1] + theta * err[t-1];
    err[t] <- y[t] - nu[t];
  }
  mu ~ normal(0,10);        // 事前分布
  phi ~ normal(0,2);
  theta ~ normal(0,2);
  sigma ~ cauchy(0,5);
  err ~ normal(0,sigma);    // 尤度
}
```

データは他の時系列回帰と同様に宣言されており、パラメータはコード中に説明があります。

modelブロックでは、局所ベクトル`nu`が予測値を、`err`が誤差を格納しています。これらの計算は、前節で記述した移動平均モデルの誤差と同様です。

定常過程にするため、弱度の情報事前分布を設定しています。尤度は誤差項だけを含み、この例では効率的にベクトル化されています。

このようなモデルでは、計算した誤差項を調べるのが必要なことがよくあります。Stanでは、変換パラメータ(transformed parameter)として`err`を宣言することで簡単に対応できるでしょう。その場合も、上のモデルでの定義と同様です。`nu`は局所変数のままでも良いのですが、ここではtransformed parametersブロックに移しましょう。

Wayne Foltaは、局所ベクトルを使わないモデルのコーディングを提案してくれました。以下がそれです。

```
model {
  real err;
  mu ~ normal(0,10);
  phi ~ normal(0,2);
  theta ~ normal(0,2);
  sigma ~ cauchy(0,5);
  err <- y[1] - mu + phi * mu;
  err ~ normal(0,sigma);
  for (t in 2:T) {
    err <- y[t] - (mu + phi * y[t-1] + theta * err);
    err ~ normal(0,sigma);
  }
}
```

このARMAモデルのアプローチは、Stanではどのように局所変数（この場合は`err`）を再利用できるか示す良い例となっています。Foltaのアプローチは、2つ以上の誤差項を局所変数に格納し、ループ内で再割り当てすることで、高次の移動平均モデルにも拡張できるでしょう。

両方のコーディングとも大変高速です。元のコーディングは正規分布をベクトル化できるという利点がありますが、使用メモリがやや多くなります。中間点は、`err`だけをベクトル化することでしょう。

#### 同定可能性と定常性

MA部分の多項の特徴量（**訳注:'characteristic polynomial'の訳ですが自信なし**）の平方根が単位円の中にあるなら、MAおよびARMAモデルは同定可能ではありません。その場合、以下の制約をつける必要があります。<sup>2</sup>

```
real<lower = -1, upper = 1> theta;
```

このモデルから生成される合成データを用いて、上の制約をつけずにモデルを走らせると、[-1,1]の範囲外に(`theta`, `phi`)の最頻値ができることがあります。これは事後分布の多峰性問題となり、またNUTSのtree depthが非常に大きく（10を超えることもままあります）なります。制約をつけることにより、事後分布がより正確になり、tree depthが劇的に減少します。そのため、シミュレーションがかなり速くなります（典型的には10倍をはるかに超えます）。

さらに、プロセスが本当に非定常なものであるとは考えられないのであれば、定常性を確保するため以下の制約をつける価値があります。

```
read<lower = -1, upper = 1> phi;
```

<sup>2</sup>この小節は、Jonathan GilliganのGitHubのコメントを少し編集したものです。https://github.com/stan-dev/stan/issues/1617#issuecomment-160249142 を参照してください。

### 7.5 確率的ボラティリティモデル

確率的ボラティリティモデルは、離散時間の潜在確率論モデルに従って、証券購入のオプションのような資産収益のボラティリティ（すなわち分散）を扱います(Kim et al., 1998)。データは、<var>T</var>個の等間隔時点における原資産に対する平均修正（すなわち中央化）収益<var>y<sub>t</sub></var>からなります。Kim et al.は、以下の回帰に似た式を使って典型的な確率ボラティリティモデルを定式化しています。ここで、潜在パラメータ<var>h<sub>t</sub></var>は対数ボラティリティを、パラメータ<var>μ</var>は平均対数ボラティリティを、<var>φ</var>はボラティリティ項の継続性をしめします。変数<var>ε<sub>t</sub></var>は時点<var>t</var>における資産収益に対するホワイトノイズショック（すなわち乗法的誤差）で、<var>δ<sub>t</sub></var>は時点<var>t</var>におけるボラティリティに対するショックを表します。（**訳注:このあたりよく知らないので自信ありません**）

![$$\begin{array}{rl}y_{t} &= \epsilon_{t}\exp(h_{t}/2) \\ h_{t+1} &= \mu + \phi(h_{t}-\mu)+\delta_{t}\sigma \\ h_{1} &\sim \mathsf{Normal}\left(\mu, \frac{\sigma}{\sqrt{1-\phi^{2}}}\right) \\ \epsilon_{t} &\sim \mathsf{Normal}(0, 1), \delta_{t} \sim \mathsf{Normal}(0, 1)\end{array}$$](fig/fig06.png)

最初の行を変形すると、<var>ε<sub>t</sub></var> = <var>y<sub>t</sub></var>exp(-<var>h<sub>t</sub></var>/2)となり、<var>y<sub>t</sub></var>のサンプリング分布は以下のように書けます。

![$$y_{t} \sim \mathsf{Normal}(0, \exp(h_{t}/2))$$](fig/fig07.png)

<var>h</var><sub><var>t</var>+1</sub>についての再帰式には、<var>δ<sub>t</sub></var>のスケーリングとサンプリングを組み合わせることができて、次のサンプリング分布が得られます。

![$$h_{t} \sim \mathsf{Normal}(\mu + \phi(h_{t} - \mu), \sigma)$$](fig/fig08.png)

（**訳注:左辺は'<var>h</var><sub><var>t</var>+1</sub>'が正しい?**）

この定式化はそのままコーディングできて、以下のStanモデルになります。

```
data {
  int<lower=0> T;  // # 時点 (等間隔)
  vector[T] y;     // 時点tにおける平均修正収益
}
parameters {
  real mu;                     // 平均対数ボラティリティ
  real<lower=-1,upper=1> phi;  // ボラティリティの継続性
  real<lower=0> sigma;         // ホワイトノイズショックのスケール
  vector[T] h;                 // 時点tにおける対数ボラティリティ
}
model {
  phi ~ uniform(-1,1);
  sigma ~ cauchy(0,5);
  mu ~ cauchy(0,10);
  h[1] ~ normal(mu, sigma / sqrt(1 - phi * phi));
  for (t in 2:T)
    h[t] ~ normal(mu + phi * (h[t - 1] -  mu), sigma);
  for (t in 1:T)
    y[t] ~ normal(0, exp(h[t] / 2));
}
```

Kim et al.の定式化と比較すると、Stanのモデルではパラメータ<var>φ</var>, <var>σ</var>, <var>μ</var>に事前分布を与えています。ショック項<var>ε<sub>t</sub></var>と<var>δ<sub>t</sub></var>はモデル中には明示的には現れないことに注意してください。とはいえ、generated quantitiesブロックで効率的に計算することは可能でしょう。

このような確率的ボラティリティモデルの事後分布で事後分散が大きくなるのは普通のことです。例えば、 <var>μ</var> = -1.02, <var>φ</var> = 0.95, <var>σ</var> = 0.25として上のモデルで500データ点のシミュレーションを行なうと、95%事後区間は<var>μ</var>が(-1.23,-0.54)、<var>φ</var>が(0.82,0.98)、<var>σ</var>が(0.16,0.38)となります。

このモデルで生成される、秒あたりの有効サンプルを1桁以上高速化するのは比較的単純です。まず、収益<var>y</var>についてのサンプリング文は簡単にベクトル化できます。

```
y ~ normal(0, exp(h / 2));
```

これにより繰り返しは高速化されますが、有効サンブルサイズは変化しません。根本的なパラメータ化と対数確率関数は変わっていないからです。標準化ボラティリティの再パラメータ化と、それからリスケーリングにより、連鎖の混ざり具合は改善されます。これには、`h`の代わりに、標準化パラメータ`h_std`を宣言する必要があります。

```
parameters {
  ...
  vector[T] h_std; // 時点tにおける標準化対数ボラティリティ
```

この時、元の`h`の値はtransformed parametersブロックで定義します。

```
transformed parameters {
  vector[T] h;            // 時点tにおける対数ボラティリティ
  h <- h_std * sigma;     // h ~ normal(0,sigma)とした
  h[1] <- h[1] / sqrt(1 - phi * phi);  // h[1]をリスケール
  h <- h + mu;
  for (t in 2:T)
    h[t] <- h[t] + phi * (h[t-1] - mu);
}
```

最初の代入では、`h_std`をNormal(0,σ)という分布になるようにリスケールして、これを一時的に`h`に代入しています。2番目の代入では、`h[1]`の事前分布が`h[2]`から`h[T]`までの事前分布とは異なるように`h[1]`をリスケールしています。その次の代入では`mu`にオフセットをつけており、これにより`h[2]`から`h[T]`までがNormal(μ,σ)という分布になります。この移動は`h[1]`のリスケーリングの後に行なう必要があることに注意してください。最後のループは、`h[2]`から`h[T]`までが`phi`と`mu`と比較して適切にモデル化されるように移動平均に加算します。（**訳注:このあたりもあまり自信ありません**）

最後の改良として、`h[1]`のサンプリング文と、`h[2]`から`h[T]`のサンプリングのループを、1行のベクトル化した標準正規分布のサンプリング文に置き換えます。

```
model { ...
  h_std ~ normal(0,1);
```

元のモデルでは、数百から時には数千回の繰り返しが収束に必要となることがありますが、再パラメータ化したモデルでは数十回の繰り返しで信頼できる収束に至ります。連鎖の混ざり具合も劇的に改善され、繰り返しあたりの有効サンプルサイズも多くなります。最後に、各繰り返しの時間は元のモデルのおおよそ4分の1になります。

### 7.6 隠れマルコフモデル

隠れマルコフモデル（HMM: Hidden Markov Model）は、<var>T</var>個の出力量<var>y<sub>t</sub></var>からなる数列を、潜在カテゴリー状態変数<var>z<sub>t</sub> ∈ {1,...,<var>K</var>}からなる並行する数列を条件として生成します。<var>z<sub>t</sub></var>は、<var>z</var><sub><var>z</var>-1</sub>が与えられたときに他の変数とは条件付き独立であるように、この「隠れ」状態変数はマルコフ連鎖を形成すると仮定します。このマルコフ連鎖は、<var>θ<sub>k</sub></var>がK次元単体（<var>k</var> ∈ {1,...,<var>K</var>）として、推移行列<var>θ</var>によりパラメータ化されます。状態<var>z</var><sub><var>t</var>-1</sub>から状態<var>z</var><sub><var>t</var></sub>への推移確率は次式のようになります。

![$$z_{t} \sim \mathsf{Categorical}(\theta_{z[t-1]})$$](fig/fig09.png)

時点<var>t</var>における出力<var>y<sub>t</sub></var>は潜在状態<var>z<sub>t</sub></var>に基づいて条件付き独立に生成されます。

この節では、出力<var>y<sub>t</sub></var> ∈ {1,...,<var>V</var>について、単純なカテゴリカルモデルでHMMを記述します。潜在状態<var>k</var>についてのカテゴリー分布はV次元単体<var>φ<sub>k</sub></var>によりパラメータ化されます。時点<var>t</var>における出力の観測値<var>y<sub>t</sub></var>は、時点<var>t</var>における隠れ状態のインジケータ<var>z<sub>t</sub></var>に基づいて生成されます。

![$$y_{t} \sim \mathsf{Categorical}(\phi_{z[t]})$$](fig/fig10.png)

つまり、混合成分のインジケータが潜在マルコフ連鎖を形成するような離散混合分布モデルをHMMは形成しています。

#### 教師付きパラメーター推定

隠れ状態が既知の状況では、パラメータ<var>θ</var>および<var>φ</var>のあてはめのため、以下の単純なモデルを使うことができます。<sup>3</sup>

```
data {  int<lower=1> K;  // num categories  int<lower=1> V;  // num words  int<lower=0> T;  // num instances  int<lower=1,upper=V> w[T]; // words  int<lower=1,upper=K> z[T]; // categories  vector<lower=0>[K] alpha;  // transit prior  vector<lower=0>[V] beta;   // emit prior}parameters {  simplex[K] theta[K];  // transit probs  simplex[V] phi[K];    // emit probs}model {  for (k in 1:K)    theta[k] ~ dirichlet(alpha);  for (k in 1:K)    phi[k] ~ dirichlet(beta);  for (t in 1:T)    w[t] ~ categorical(phi[z[t]]);  for (t in 2:T)    z[t] ~ categorical(theta[z[t - 1]]);    }
```

<var>θ<sub>k</sub></var>と<var>φ<sub>k</sub></var>には明示的なディリクレ事前分布を与えています。この2文を除くと、有効な単体全体についての一様事前分布が暗黙のうちに使われることでしょう。

<sup>3</sup>このプログラムは、Stan例題モデルのリポジトリで入手できます。https://github.com/stan-dev/example-models/tree/master/misc/gaussian-process を参照してください。

#### 開始状態と終了状態の確率

動くことは動きますが、上のようにHMMをしても完全ではありません。開始状態<var>z</var><sub>1</sub>がモデル化されていないからです（添字は2から<var>T</var>までです）。データを長い過程の部分数列と考えるなら、<var>z</var><sub>1</sub>1の確率は、マルコフ連鎖の定常状態確率に合わせるべきでしょう。この場合、データには明確な終了がなく、数列が<var>z<sub>T</sub></var>で終了する確率をモデル化する必要はありません。

HMMはまた別の概念として、有限長の数列のモデルとして考えることもできます。例えば、自然言語の文には明確な開始の分布（通常は大文字）と、終了の分布（通常は何らかの句読点）とがあります。文の境界をモデル化する最も簡単な方法は、新しい潜在状態<var>K</var>+1を加え、パラメータベクトル<var>θ</var><sub><var>K</var>+1</sub>によりカテゴリー分布から最初の状態を生成し、状態<var>K</var>+1への推移が文の終了時にのみ起こり、それ以外では起こらないように推移を制限することです。

#### 十分統計量の計算


#### 解析的事後分布



#### 準教師付き推定


#### 予測推定



