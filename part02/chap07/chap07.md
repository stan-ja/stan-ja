## 7. 時系列モデル

時系列データは、時間軸に沿って得られたデータです。この章では2種類の時系列モデルを紹介します。1つは、自己回帰および移動平均モデルといった回帰に似たモデル、もう1つは隠れマルコフモデルです。

15章ではガウス過程を紹介しますが、これを時系列（と空間）データに使ってもよいでしょう。

### 7.1 自己回帰モデル

正規ノイズの1次自己回帰モデル(AR(1))では、各点<var>y<sub>n</sub></var>は次式のように生成される数列<var>y</var>にまとめられます。

![$$ y_{n} \sim \mathsf{Normal}(\alpha + \beta y_{n-1}, \sigma) $$](fig/fig01.png)

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

計量経済学（***econometrics*）と財政学の時系列モデルでは不等分散を仮定するのが普通です（すなわち、系列を定義するノイズ項のスケールが時間的に変化してもよいとします）。そのようなモデルで最も単純なのが自己回帰条件付き不等分散(augoregressive conditional heteroscedasticity: ARCH)モデルです(Engle, 1982)。自己回帰モデルAR(1)では、系列の平均が時間的に変化しますが、ノイズ項は固定されたままです。ARCH(1)モデルでは、これとは異なり、ノイズ項のスケールが時間的に変化する一方で平均項は固定されたままです。もちろん、平均もスケールも時間的に変化するとモデルを定義することもできるでしょう。計量経済学の文献では幅広い範囲の時系列モデリングの選択肢があります。

ARCH(1)モデルは典型的には以下の一連の式で示されます。ここで、<var>r<sub>t</sub></var>は時点<var>t</var>における観測された返り値、<var>μ</var>、<var>α<sub>0</sub></var>、<var>α<sub>1</sub></var>は未知の回帰係数パラメーターです。

![$$ r_{t} &= \mu + a_{t} \\ a_{t} &= \sigma_{t} \epsilon_{t} \\ \epsilon_{t} &\sim \mathsf{Normal}(0, 1) \\ \sigma_{t}^{2} &= \alpha_{0} + \alpha_{1}a_{t-1}^{2} $$](fig/fig02.png)

ノイズ項<var>σ</var><sub><var>t</var><sub><sup>2</sup>が正であることを保証するため、<var>α<sub>0</sub></var>, <var>α<sub>1</sub></var> > 0と、スケール係数は正に制約されています。時系列の定常性を保証するため、<var>α<sub>1</sub></var> < 1と、傾きは1未満に制約されています。<sup>1</sup>ARCH(1)モデルはStanでは以下のようにそのままコーディングできます。

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

基本的なGARCH(Generalized AutoRegressive Conditional Heteroscedasticity: 一般化自己回帰条件付き不等分散)モデルであるGARCH(1,1)モデルはARCH(1)モデルを拡張したもので、一期前の時点<var>t</var>-1での平均と返り値のと差の2乗を、時点<var>t</var>のボラティリティの予測子に含みます。

![$$ \sigma_{t}^{2} = \alpha_{0} + \alpha_{1}a_{t-1}^{2} + \beta_{1}\sigma_{t-1}^{2} $$](fig/fig03.png)

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

非負値配列の変換パラメータ`sigma`は各時点のスケールの値を格納するのに使われます。

### 7.3 移動平均モデル

![$$ y_{t} = \mu + \theta_{1}\epsilon_{t-1} + \dots + \theta_{Q}\epsilon_{t-Q} + \epsilon_{t} $$](fig/fig04.png)

![$$ \epsilon_{t} \sim \mathsf{Normal}(0, \sigma) $$](fig/fig05.png)

#### MA(2)の例



#### ベクトル化したMA(<var>Q</var>)モデル



### 7.4 自己回帰移動平均モデル



#### 同定可能性と安定性



### 7.5 確率的ボラティリティモデル

![$$ y_{t} &= \epsilon_{t}\exp(h_{t}/2) \\ h_{t+1} &= \mu + \phi(h_{t}-\mu)+\delta_{t}\sigma \\ h_{1} &\sim \mathsf{Normal}\left(\mu, \frac{\sigma}{\sqrt{1-\phi^{2}}}\right) \\ \epsilon_{t} &\sim \mathsf{Normal}(0, 1), \delta_{t} &\sim \mathsf{Normal}(0, 1) $$](fig/fig06.png)

![$$ y_{t} \sim \mathsf{Normal}(0, \exp(h_{t}/2)) $$](fig/fig07.png)

![$$ h_{t} \sim \mathsf{Normal}(\mu + \phi(h_{t} - \mu), \sigma) $$](fig/fig08.png)

### 7.6 隠れマルコフモデル

![$$ z_{t} \sim \mathsf{Categorical}(\theta_{z[t-1]}) $$](fig/fig09.png)

![$$ y_{t} \sim \mathsf{Categorical}(\phi_{z[t]}) $$](fig/fig10.png)



#### 教師付きパラメーター推定


#### 初期状態と終了状態の確率


#### 十分統計量の計算


#### 解析的事後分布



#### 準教師付き推定


#### 予測推定



