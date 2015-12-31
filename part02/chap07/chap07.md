## 7. 時系列モデル

時系列データは、時間軸に沿って得られたデータです。この章では2種類の時系列モデルを紹介します。1つは、自己回帰および移動平均モデルといった回帰に似たモデル、もう1つは隠れマルコフモデルです。

15章ではガウス過程を紹介しますが、これを時系列（と空間）データに使ってもよいでしょう。

### 7.1 自己回帰モデル

正規ノイズの1次自己回帰モデル(AR(1))では、各点<var>y<sub>n</sub></var>は次式のように生成される数列<var>y</var>にまとめられます。

![$$ y_{n} \sim \mathsf{Normal}(\alpha + \beta y_{n-1}, \sigma) $$](fig01.png)

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

ARCH(1)モデルは典型的には以下の一連の式で示されます。ここで、<var>r<sub>t</sub></var>は時点<var>t</var>における観測された返り値、<var>μ</var>、<var>α<sub>0</sub></var>、<var>α<sub>1</sub></var>は未知の回帰係数パラメーターです。

![$$ r_{t} &= \mu + a_{t} \\ a_{t} &= \sigma_{t} \epsilon_{t} \\ \epsilon_{t} &\sim \mathsf{Normal}(0, 1) \\ \sigma_{t}^{2} &= \alpha_{0} + \alpha_{1}a_{t-1}^{2} $$](fig02.png)

ノイズ項<var>σ</var><sub><var>t</var></sub><sup>2</sup>が正であることを保証するため、<var>α<sub>0</sub></var>, <var>α<sub>1</sub></var> > 0と、スケール係数は正に制約されています。時系列の定常性を保証するため、<var>α<sub>1</sub></var> < 1と、傾きは1未満に制約されています。<sup>1</sup>ARCH(1)モデルはStanでは以下のようにそのままコーディングできます。

```
data {
  int<lower=0> T;
  real r[T];
}
parameters {
  real mu;
  real<lower=0> alpha0;          // noise intercept
  real<lower=0,upper=1> alpha1;  // noise slope
}
model {
  for (t in 2:T)
    r[t] ~ normal(mu, sqrt(alpha0 + alpha1 * pow(r[t-1] - mu,2)));
}
```

<sup>1</sup>実際には、この制約を外してみて、非定常な係数の組み合わせの方がデータによく当てはまるかどうかを試すのが有用なこともあります。あるいはまた、当てはまっていないトレンドがあるなら明らかに非定常でしょうから、モデルにトレンド項を加えることもあります。

### 7.2 時間的不等分散性のモデリング

一揃いの変数について、分散がすべて同じなら、等分散ということなります。一方、分散がすべては同じではないなら、不等分散ということになります。不等分散の時系列モデルでは、ノイズ項が時間的に変化してもよいとします。

#### GARCH(1,1)モデル

基本的なGARCH（Generalized AutoRegressive Conditional Heteroscedasticity, 一般化自己回帰条件付き不等分散）モデルであるGARCH(1,1)はARCH(1)モデルを拡張したもので、一期前の時点<var>t</var>-1での平均と返り値との差の2乗を、時点<var>t</var>のボラティリティの予測子に含みます。

![$$ \sigma_{t}^{2} = \alpha_{0} + \alpha_{1}a_{t-1}^{2} + \beta_{1}\sigma_{t-1}^{2} $$](fig03.png)

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

非負値配列の変換パラメータ(transformed parameter)`sigma`は各時点のスケールの値を格納するのに使われます。これらの値の定義はtransformed parametersブロックにあり、回帰もここで定義されるようにしました。切片`alpha0`、1期前の返り値と平均との差の2乗に対する傾き`alpha1`、1期前のノイズスケールの2乗に対する傾き`beta1`がここにあります。最後に、Stanでは正規分布には（分散パラメータではなく）スケール（偏差）パラメータが必要なので、回帰全体を`sqrt`関数の中に入れています。

transformed parametersブロックに回帰を置くことにより、モデルは、ベクトル化されたサンプリング文1行にまで減りました。`r`と`sigma`の長さは`T`ですので、すべてのデータが直接モデル化されています。

### 7.3 移動平均モデル

移動平均モデルは、過去の誤差を将来の結果の予測子に使います。次数<var>Q</var>の移動平均モデルMA(<var>Q</var>)には、全体的な平均パラメータ<var>μ</var>と、過去の誤差項についての回帰係数<var>θ<sub>q</sub></var>があります。時点<var>t</var>における誤差を<var>ε<sub>t</sub></var>として、結果<var>y<sub>t</sub></var>についてのモデルは次のように定義されます。

![$$ y_{t} = \mu + \theta_{1}\epsilon_{t-1} + \dots + \theta_{Q}\epsilon_{t-Q} + \epsilon_{t} $$](fig04.png)

結果<var>y<sub>t</sub></var>についての誤差項<var>ε<sub>t</sub></var>は正規分布としてモデル化されています。

![$$ \epsilon_{t} \sim \mathsf{Normal}(0, \sigma) $$](fig05.png)

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

![$$ y_{t} &= \epsilon_{t}\exp(h_{t}/2) \\ h_{t+1} &= \mu + \phi(h_{t}-\mu)+\delta_{t}\sigma \\ h_{1} &\sim \mathsf{Normal}\left(\mu, \frac{\sigma}{\sqrt{1-\phi^{2}}}\right) \\ \epsilon_{t} &\sim \mathsf{Normal}(0, 1), \delta_{t} &\sim \mathsf{Normal}(0, 1) $$](fig06.png)

![$$ y_{t} \sim \mathsf{Normal}(0, \exp(h_{t}/2)) $$](fig07.png)

![$$ h_{t} \sim \mathsf{Normal}(\mu + \phi(h_{t} - \mu), \sigma) $$](fig08.png)

### 7.6 隠れマルコフモデル

![$$ z_{t} \sim \mathsf{Categorical}(\theta_{z[t-1]}) $$](fig09.png)

![$$ y_{t} \sim \mathsf{Categorical}(\phi_{z[t]}) $$](fig10.png)



#### 教師付きパラメーター推定


#### 初期状態と終了状態の確率


#### 十分統計量の計算


#### 解析的事後分布



#### 準教師付き推定


#### 予測推定



