## 30. 罰則付き最尤点推定

この章では、ベイズ推定ではありませんが、最尤推定と罰則付き最尤推定というよく使われる方法を定義し、事後分布の平均値・中央値・最頻値を使って、それらをベイズ点推定に関連づけます。最尤推定値は、事後分布ではなく、モデルのパラメーター$\theta$についての単一の値から求められるので、「点推定値」と呼ばれます。

どのような尤度関数も罰則関数もStanのモデリング言語でコーディングすることができるので、Stanのオプティマイザ（optimizer）を使って（罰則付き）最尤推定を実装することができます。Stanのオプティマイザはまた、事後最頻値に基づくベイズの枠組みでの点推定にも使うことができます。Stanのマルコフ連鎖モンテカルロサンプラーは、事後分布の平均値や中央値に基づくベイズモデルでの点推定を実装するのにも使えます。

### 30.1. 最尤推定

尤度関数$p(y\mid\theta)$と、固定されたデータのベクトル$y$とが与えられたとき、尤度を最大にするようなパラメータのベクトル$\hat{\theta}$のことを最尤推定値(maximum likelihood estimate, MLE)といいます。

$$ \hat{\theta}=\mathrm{argmax}_{\theta}\ p(y\mid\theta) $$

通常は対数スケールにするほうが便利です。次式も、MLEの定式化として等価です。^[この等価性は、密度が正値であり、対数関数が厳密に単調であるという事実から導かれます。すなわち、$p(y\mid\theta) \ge 0$、かつ、すべての$a,b>0$について、$a>b$のときのみ$\log a > \log b$です。]

$$ \hat{\theta}=\mathrm{argmax}_{\theta}\ \log p(y\mid\theta) $$

#### 最尤推定値の存在

すべての関数がただひとつの最大値を持っているとは限りませんので、最尤推定値が存在することは保証されるものではありません。24章で議論したように、この状況は以下のようなときに起こります。

- 2つ以上の点で尤度関数が最大になるとき
- 尤度関数が発散するとき
- 尤度関数が有限のパラメータの値では達しない漸近線を持ち、有界となるとき

こうした問題は、次の節で議論する罰則付き最尤推定でも、その後の節で議論するベイズ事後最頻値でもついて回ります。

#### 例: 線形回帰

通常の線形回帰の問題を考えます。観測値$y$が$N$次元のベクトル、予測変数が$(N \times K)$次元のデータ行列$x$、回帰係数が$K$次元のパラメータのベクトル$\beta$、実数値のノイズのスケールが$\sigma > 0$のとき、尤度関数は次式のようになります。

$$ \log p(y\mid\beta,x)=\sum_{n=1}^{N}\log\mathsf{Normal}(y_n \mid x_n \beta, \sigma) $$

$\theta = (\beta, \sigma)$の最尤推定値は次式のようになります。

$$ (\hat{\beta},\hat{\sigma})=\mathrm{argmax}_{\beta,\sigma}\log p(y\mid\beta,\sigma,x) = \mathrm{argmax}_{\beta,\sigma}\sum_{n=1}^{N} \log \mathsf{Normal}(y_n \mid x_n \beta,\sigma) $$

（**訳注**: 原文では最右辺でargmaxが抜けている）

##### 二乗誤差

対数尤度関数について少し代数計算をすると、周辺最尤推定値$\hat{\theta}=(\hat{\beta},\hat{\sigma})$が、最小二乗法で求めた$\hat{\beta}$と等価に定式化できることが分かります。すなわち、$\hat{\beta}$は、二乗予測誤差の和を最小化するような係数ベクトルの値です。

$$ \hat{\beta}=\mathrm{argmin}_{\beta}\sum_{n=1}^{N}(y_{n}-x_{n}\beta)^2=\mathrm{argmin}_{\beta}(y-x\beta)^{\top}(y-x\beta) $$

$n$番目のデータの残差誤差は、実際の値と予測値との差$y_n - x_n \hat{\beta}$です。ノイズのスケールの最尤推定値$\hat{\sigma}$は、平均二乗残差の平方根とちょうど同じです。

$$ \hat{\sigma}^2=\frac{1}{N}\sum_{n=1}^{N}\left(y_{n}-x_{n}\hat{\beta}\right)^2=\frac{1}{N}(y-x\hat{\beta})^{\top}(y-x\hat{\beta}) $$

##### Stanでの二乗誤差の最小化

線形回帰において二乗誤差を最小にするアプローチはStanでは以下のモデルで直接コーディングできます。

```
data {
  int<lower=0> N;
  int<lower=1> K;
  vector[N] y;
  matrix[N,K] x;
}
parameters {
  vector[K] beta;
}
transformed parameters {
  real<lower=0> squared_error;
  squared_error = dot_self(y - x * beta);
}
model {
  target += -squared_error;
}
generated quantities {
  real<lower=0> sigma_squared;
  sigma_squared = squared_error / N;
}
```

このモデルをStanのオプティマイザで走らせると、二乗誤差の和を直接最小化するとともに、その値を使って生成量としてノイズのスケールを定義することで、線形回帰のMLEが生成されます。

`sigma_squared`の定義にある分母の`N`を`N-1`に変えると、より一般的に用いられる$\sigma^2$の不偏推定量が計算できます。推定の偏りの定義と、分散の推定についての議論については30.6節を参照してください。

### 30.2. 罰則付き最尤推定

最適化を行なう能力に関する限り、尤度関数については特別なことはありません。非ベイズ統計では普通に行なわれますが、対数尤度に「罰則」関数と呼ばれる関数を加えて、その新しく定義した関数を最適化する方法があります。対数尤度関数$\log p(y\mid\theta)$と罰則関数$r(\theta)$からなる罰則付き最尤推定量は次式のように定義されます。

$$ \hat{\theta}=\mathrm{argmax}_{\theta}\log p(y\mid\theta)-r(\theta) $$

罰則関数$r(\theta)$を対数尤度の最大化から差し引いて、推定値$\hat{\theta}$が、対数尤度の最大化と罰則の最小化のつりあいをとるようにします。
罰則をつけることは「正則化」とも呼ばれます。

#### 例
##### リッジ回帰

リッジ回帰(Hoerl and Kennard, 1970)の基礎は、係数ベクトル$\beta$のユークリッド長さ（**訳注**: 二乗のこと）に罰則をつけるところにあります。次式がリッジ罰則関数です。

$$　r(\beta)=\lambda\sum_{k=1}^{K}\beta_{k}^2=\lambda\beta^{\top}\beta　$$

ここで$\lambda$は、罰則の大きさを決める固定したチューニングパラメータです。

したがって、リッジ回帰の罰則付き最尤推定値は次式のとおりです。

$$　(\hat{\beta},\hat{\sigma})=\mathrm{argmax}_{\beta,\sigma}\sum_{n=1}^{N}\log\mathsf{Normal}(y_{n}\mid x_{n}\beta,\sigma)-\lambda\sum_{k=1}^{K}\beta_{k}^2　$$

リッジ罰則は、L2ノルムとの関連から、L2正則化あるいは縮小と呼ばれることもあります。

基本的なMLEと同様、係数$\beta$についてのリッジ回帰の推定値は最小二乗法として定式化することもできます。

$$　\hat{\beta}=\mathrm{argmin}_{\beta}\sum_{n=1}^{N}(y_{n}-x_{n}\beta)^2+\sum_{k=1}^{K}\beta_{k}^2=\mathrm{argmin}_{\beta}(y-x\beta)^{\top}(y-x\beta)+\lambda\beta^{\top}\beta　$$

リッジ罰則関数を加えると、$\beta$についてのリッジ回帰の推定値がより短いベクトルとなる効果があります。すなわち$\hat{\beta}$が縮小されます。リッジ推定値は必ずしもすべての$k$について$\beta_k$の絶対値が小さくなるとは限りませんし、係数ベクトルが、最尤推定値と同じ方向を指すとも限りません。

Stanでリッジ罰則を加えるには、罰則の大きさをデータ変数として加え、罰則自身を`model`ブロックに加えます。

```
data {
  // ...
  real<lower=0> lambda;
}
// ...
model {
  // ...
  target += - lambda * dot_self(beta);
}
```

ノイズ項の計算はそのままです。

##### Lasso

Lasso (Tibshirani, 1966)はリッジ回帰の代替法で、係数の二乗和ではなく、係数の絶対値和に基づいて罰則を適用します。

$$ r(\beta)=\lambda\sum_{k=1}^{K}|\beta_{k}| $$

Lassoは、L1ノルムとの関連から、L1縮小とも呼ばれます。L1ノルムは、タクシー距離あるいはマンハッタン距離としても知られています。

罰則の導関数は$\beta_k$の値に依存しません。

$$ \frac{d}{d\beta_{k}}\lambda\sum_{k=1}^{K}|\beta_{k}|=\mathrm{signum}(\beta_{k}) $$

そのため、縮小するパラメータは、最尤推定値では完全に0になるという効果があります。したがって、単に縮小だけではなく変数選択として使うこともできます。^[実際には、勾配に基づくStanのオプティマイザでは完全に0の値となることが保証されません。勾配降下法で完全に0の値を得るための議論は、Langfordら(2009)を参照してください。] Lassoも、罰則の大きさをデータとして宣言し、罰則を`model`ブロックに加えることにより、リッジ回帰と同じくらい簡単にStanで実装できます。

```
data {
  // ...
  real<lower=0> lambda;
}
// ...
model {
  // ...
  for (k in 1:K)
    target += - lambda * fabs(beta[k]);
}
```

##### Elastic Net

ナイーブElastic Net (Zou and Hastie, 2005)は、リッジとLassoの罰則の重みづけ平均を取り入れています。罰則関数は次式です。

$$ r(\beta)=\lambda_{1}\sum_{k=1}^{K}|\beta_{k}|+\lambda_{2}\sum_{k=1}^{K}\beta_{k}^2 $$

ナイーブElastic Netは、リッジ回帰とLassoの両方の特性を組み合わせたもので、識別と変数選択の両方ができます。

ナイーブElastic Netは、Stanでは、リッジ回帰とLassoの実装を組み合わせることにより直接実装できます。

```
data {
  real<lower=0> lambda1;
  real<lower=0> lambda2;
  // ...
}
// ...
model {
  // ...
  for (k in 1:K)
    target += -lambda1 * fabs(beta[k]);
  target += -lambda2 * dot_self(beta);
}
```

$r(\beta)$は罰則関数ですので、プログラム中では符号は負であることに注意してください。

Elastic Net (Zou and Hastie, 2005)は、ナイーブElastic Netで生成された当てはめ値$\hat{\beta}$から、最終的な$\beta$の推定値を調整するようにしています。Elastic Netの推定値は次式です。

$$ \hat{\beta}=(1+\lambda_{2})\beta^{\ast} $$

ここで、$\beta^{\ast}$は、ナイーブElastic Netの推定値です。

StanでElastic Netを実装するときも、`data`、`parameters`、`model`の各ブロックはナイーブElastic Netと同じままです。それに加えて、Elastic Netの推定値を`generated quantities`ブロックで計算します。

```
generated quantities {
  vector[K] beta_elastic_net;
  // ...
  beta_elastic_net = (1 + lambda2) * beta;
}
```

誤差のスケールも、Elastic Netの係数`beta_elastic_net`から`generated quantities`ブロックで計算する必要があります。

##### 他の罰則付き回帰

James and Stein (1961)のように、係数の推定値を0ではない値に偏らせるような罰則関数も普通に使われます。推定値を集団の平均に偏らせる罰則関数も使うことができます(Efron and Morris, 1975; Efron, 2012)。後者の手法は、ベイズ統計で普通に採用される階層モデルに似ています。

### 30.3 推定値の誤差、バイアス（偏り）、分散

推定値$\hat{\theta}$は、特定のデータ$y$のほか、対数尤度関数$\log p(y \mid \theta)$、罰則付き尤度関数$\log p(y \mid \theta) - r(\theta)$、対数確率関数$\log p(y,\theta) = \log p(y \mid \theta) + log p(\theta)$（**訳注**: 原文は$\log p(y, \theta) = \log p(y, \theta) + log p(\theta)$だがこれは誤り）のうちのいずれかに依存します。この節では、$\hat{\theta}$という記法は推定量を示すものとしても定義します。このときの推定量とは、データと（罰則付き）尤度あるいは確率関数の非明示的な関数です。

#### 推定値の誤差

真のパラメータ$\theta$にしたがって生成された特定の観測値のデータセット$y$について、パラメータの推定値と真の値との差が推定誤差です。

$$ \mathrm{err}(\hat{\theta}) = \hat{\theta} - \theta $$

#### 推定値のバイアス（偏り）

特定の真のパラメータの値を$\theta$、尤度関数を$p(y \mid \theta)$とすると、推定量のバイアスとは推定誤差の期待値です。

$$ \mathbb{E}_{p(y\mid\theta)}[\hat{\theta}-\theta] = \mathbb{E}_{p(y\mid\theta)}[\hat{\theta}] - \theta $$

ここで$\mathbb{E}_{p(y\mid\theta)}[\hat{\theta}]$は以下のように、推定値$\hat{\theta}$を尤度関数$p(y \mid \theta)$で重みづけてデータセット$y$の取りうる範囲全体について積分したものです。

$$ \mathbb{E}_{p(y\mid\theta)}[\hat{\theta}] = \int \left(\mathrm{argmax}_{\theta'}p(y\mid\theta')\right)p(y\mid\theta)dy $$

バイアスは$\theta$と同じ次元の多変量です。この期待推定誤差が0であれば推定量は不偏ですが、そうでなければバイアスがあります。

##### 例: 正規分布の推定

正規分布から抽出された、$n \in 1:N$についての観測値$y_n$からなるデータセットがあるとします。これは、$y_n \sim \mathsf{Normal}(\mu, \sigma)$というモデルを仮定しています。ここで、$\mu$と$\sigma>0$はともにパラメータです。尤度は次式のとおりです。

$$ \log p(y\mid\mu,\sigma) = \sum_{n=1}^{N}\log\mathsf{Normal}(y_{n}\mid\mu,\sigma) $$

$\mu$の最尤推定量はちょうど標本平均、すなわち標本の平均値となります。

$$ \hat{\mu} = \frac{1}{N}\sum_{n=1}^{N}y_{n} $$

この平均についての最尤推定量は不偏です。

分散$\sigma^2$の最尤推定量は、平均との差の二乗の平均です。

$$ \hat{\sigma}^2 = \frac{1}{N}\sum_{n=1}{N}(y_{n} - \hat{\mu})^2 $$

分散の最尤値は小さい方に偏っています。

$$ \mathbb{E}_{p(y\mid\mu,\sigma)}[\hat{\sigma}^2] < \sigma $$

最尤推定値が、平均値の推定値$\hat{\mu}$との差に基づいていることがこの偏りの理由です。実際の平均値をいれてみると、差の二乗和が大きくなります。すなわち、$\mu \neq \hat{\mu}$ならば、次式のようになります。

$$ \frac{1}{N}\sum_{n=1}^{N}(y_{n}-\mu)^2 > \frac{1}{N}\sum_{n=1}^{N}(y_{n}-\hat{\mu})^2 $$

分散の推定値はもうひとつあり、それが不偏分散（**訳注**: 原文はsample varianceですが、これは誤り）です。次式のように定義されます。

$$ \hat{\sigma}^2 = \frac{1}{N-1}\sum_{n=1}^{N}(y_{n}-\hat{\mu})^2 $$

(**訳注**: 原文は$\hat{\mu}$ですが、これは誤り)

この値は、最尤推定値よりも$N/(N-1)$倍だけ大きくなります。

#### 推定値の分散

推定量$\hat{\theta}$の成分$k$の分散も他の分散と同じように計算されます。期待値との差の二乗の期待値です。

$$ \mathrm{var}_{p(y\mid\theta)}[\hat{\theta}_{k}] = \mathbb{E}_{p(y\mid\theta)}[(\hat{\theta}_{k} - \mathbb{E}_{p(y\mid\theta)}[\hat{\theta}_{k}])^{2}] $$

推定量の$K \times K$共分散行列全体も、いつもどおり以下のように定義されます。

$$ \mathrm{covar}_{p(y\mid\theta)}[\hat{\theta}] = \mathbb{E}_{p(y\mid\theta)}[(\hat{\theta} - \mathbb{E}[\hat{\theta}])(\hat{\theta}-\mathbb{E}[\hat{\theta}])^{\top}] $$

標本データから正規分布の平均と分散を推定する例での計算では、最尤推定量（すなわち標本平均）は、分散を最小とするような平均$\mu$の不偏推定量です。そのことは、正規ノイズの仮定のもとで最小二乗推定について、また等価ですが、最尤推定について、ガウス-マルコフの定理によって一定の一般性をもって証明されました。Hastieら(2009)の3.2.2節を参照してください。
