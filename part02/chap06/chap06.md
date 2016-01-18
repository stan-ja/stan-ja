## 6. 回帰モデル

Stanでは、単純な線形回帰からマルチレベルの一般化線形モデルまでの回帰モデルが使えます。

### 6.1. 線形回帰

以下は最も単純な線形回帰モデルで、1つの予測変数と、傾きと切片の係数があり、ノイズは正規分布です。

![$$ y_{n} = \alpha + \beta x_{n} + \epsilon_{n} \quad\text{ここで}\quad \epsilon_{n} \sim \mathsf{Normal}(0, \sigma) $$](fig/fig01.png)

これは、以下のように残差を含めてサンプリングするのと等価です。

![$$ y_{n} - (\alpha + \beta X_{n}) \sim \mathsf{Normal}(0, \sigma) $$](fig/fig02.png)

さらに短くなります。

![$$ y_{n} \sim \mathsf{Normal}(\alpha + \beta X_{n}, \sigma) $$](fig/fig03.png)

このモデルの最後の形はStanでは以下のようにコーディングします。

```
data {
  int<lower=0> N;
  vector[N] x;
  vector[N] y;
}
parameters {
  real alpha;
  real beta;
  real<lower=0> sigma;
}
model {
  y ~ normal(alpha + beta * x, sigma);
}
```

`N`回の観測があり、それぞれに予測値`x[n]`と結果`y[n]`があります。切片と傾きのパラメータは`alpha`と`beta`です。このモデルでは、スケール`sigma`の、正規分布するノイズ項を仮定しています。また、2つの回帰係数には非正則事前分布が設定されています。

#### 行列記法とベクトル化

前のモデルのサンプリング文はベクトル化されています。

```
y ~ normal(alpha + beta * x, sigma);
```

同じモデルの、ベクトル化されていないバージョンは以下のとおりです。

```
for (n in 1:N)
  y[n] ~ normal(alpha + beta * x[n], sigma);
```

より簡潔なことに加えて、ベクトル化された形の方がはるかに高速です。<sup>1</sup>

一般にStanでは、`normal`のような分布に渡す引数はベクトルにすることができます。他の引数のいずれかがベクトルまたは配列なら、同じサイズでなくてはなりません。多の引数のいずれかがスカラーなら、ベクトルの各要素に再利用されます。確率関数のベクトル化についてのより詳しい情報は37.5節を参照してください。

この書き方がうまくいく他の理由は、行列には行列演算を行なうように、Stanの算術演算子がオーバーロードされるからです。この場合では、`x`が`vector`型で`beta`が`real`型なので、式`beta * x`は`vector`型です。Stanはベクトル化をサポートしているので、2つ以上の予測変数がある回帰モデルもそのまま行列の記法を用いて書くことができます。

```
data {
  int<lower=0> N;  // number of data items
  int<lower=0> K;  // number of predictors
  matrix[N,K] x;   // predictor matrix
  vector[N] y;     // outcome vector
}
parameters {
  real alpha;           // intercept
  vector[K] beta;       // coefficients for predictors
  real<lower=0> sigma;  // error scale
}
model {
  y ~ normal(x * beta + alpha, sigma);  // likelihood
}
```

`sigma`の宣言には`lower=0`という制約をつけて、値が0以上になるように制限しています。`model`ブロックには事前分布がないので、非負の実数の非正則事前分布ということになります。より情報のある事前分布を加えることもできますが、正則事後分布が導ける限り、非正則事前分布も使えます。

上のモデルでは、`x`は$N \times K$行列の予測変数、`beta`は$K$次元ベクトルの係数なので、`x * beta`は$N$次元ベクトルの予測値です。$N$個のデータ項目のそれぞれに対応します。これら予測値は、$N$次元ベクトル`y`にある結果に対応して揃っていますので、上のようにモデル全体を行列演算を使って書くことができます。値が1の列を`x`に含めることにより、`alpha`パラメータをなくすこともできるでしょう。

上のモデルのサンプリング文は、統計的に等価な以下のモデルのような、ループを使ったモデルを、より効率的に、ベクトルによる方法でコーディングしただけです。
```
model {
  for (n in 1:N)
    y[n] ~ normal(x[n] * beta, sigma);
}
```

Stanの行列のインデキシング方式では、`x[n]`は行列`x`の行`n`を取り出します。`beta`は列ベクトルなので、積`x[n] * beta`は`real`型のスカラーです。

##### 入力に含めた切片



```
y ~ normal(x * beta, sigma);
```

<sup>1</sup> PythonやRはインタプリタとして動作しますが、それとは異なりStanはC++に変換されてコンパイルされます。そのため、ループと代入文は高速です。ベクトル化されたコードがStanで高速なのは以下の理由によります。(a) 導関数を計算するのに使われる式木が単純にできます。これにより、仮想関数の呼び出しが少なくなります。(b) 上のモデルでは`log(sigma)`がそうですが、ループするバージョンでは繰り返される計算が、1度計算された後は再利用されるようになります。

### 6.2. 係数とスケールの事前分布


#### 背景となる文献


#### 非正則一様事前分布


#### 正則一様事前分布: 範囲の制限

```
real<lower=0.1, upper=2.7> sigma;
```

```
parameters {
  real<lower=0> sigma;
  ...
model {
  // *** bad *** : support narrower than constraint
  sigma ~ uniform(0.1, 2.7);
```

#### 「無情報」正則事前分布

![$$ \sigma^2 \sim \mathsf{InvGamma}(0.001, 0.001) $$](fig/fig04.png)


#### 切断事前分布

```
real<lower=0> sigma;
```

```
sigma ~ normal(0,1000);
```

![$$ p(\sigma) = \frac{\mathsf{Normal}(\sigma \mid 0,1000)}{1 - \mathsf{NormalCDF}(0 \mid 0, 1000)} \propto \mathsf{Normal}(\sigma \mid 0, 1000) $$](fig/fig05.png)


#### 弱情報事前分布


#### 上下限のある事前分布


#### 裾の重い事前分布と「デフォルト」の事前分布


#### 情報事前分布


#### 共役性


### 6.3. ロバストノイズモデル

```
data {
  ...
  real<lower=0> nu;
}
...
model {
  for (n in 1:N)
    y[n] ~ student_t(nu, alpha + beta * x[n], sigma);
}
```

### 6.4. ロジスティック回帰とプロビット回帰

```
data {
  int<lower=0> N;
  vector[N] x;
  int<lower=0,upper=1> y[N];
}
parameters {
  real alpha;
  real beta;
}
model {
  y ~ bernoulli_logit(alpha + beta * x);
}
```

![$$ \mathrm{logit}(\nu) = \log\left(\frac{\nu}{1 - \nu}\right) $$](fig/fig06.png)

![$$ \mathrm{logit}^{-1}(u) = \frac{1}{1 + \exp(-u)} $$](fig/fig07.png)

![$$ \mathsf{BernoulliLogit}(y \mid \alpha) = \mathsf{Bernoulli}(y \mid \mathrm{logit}^{-1}(\alpha)) $$](fig/fig08.png)

```
for (n in 1:N)
  y[n] ~ bernoulli_logit(alpha + beta * x[n]);
```

```
for (n in 1:N)
  y[n] ~ bernoulli(inv_logit(alpha + beta * x[n]));
```

![$$ \Phi(x) = \int_{-\infty}^{\infty}\mathsf{Normal}(\gamma \mid 0, 1)dy $$](fig/fig09.png)

```
y[n] ~ bernoulli(Phi(alpha + beta * x[n]));
```

```
y[n] ~ bernoulli(Phi_approx(alpha + beta * x[n]));
```

### 6.5. 多ロジット回帰

```
data { int K;
  int N;
  int D;
  int y[N];
  vector[D] x[N];
}
parameters {
  matrix[K,D] beta;
}
model {
  for (k in 1:K)
    beta[k] ~ normal(0,5);
  for (n in 1:N)
    y[n] ~ categorical(softmax(beta * x[n]));
}
```

```
y[n] ~ categorical_logit(beta * x[n]);
```

```
to_vector(beta) ~ normal(0,5);
```

##### データ宣言時の制約

```
int<lower=2> K;
  int<lower=0> N;
  int<lower=1> D;
  int<lower=1,upper=K> y[N];
```

#### 識別可能性

```
parameters {
  matrix[K - 1, D] beta_raw;
}
```

```
transformed data {
  vector[D] zeros;
  zeros <- rep_vector(0, D);
}
```

```
transformed parameters {
  matrix[K, D] beta;
  beta <- append_col(beta_raw, zeros);
}
```

### 6.6. 中央化ベクトルへのパラメータ化

![$$ \sum_{k=1}^{K}\beta_{k} = 0 $$](fig/fig10.png)

#### K-1自由度

```
parameters {
  vector[K-1] beta_raw;
  ...
transformed parameters {
  vector[K] beta;  // centered
  for (k in 1:(K-1)) {
    beta[k] <- beta_raw[k];
  }
  beta[K] <- -sum(beta_raw);
  ...
```

#### 単体への移動およびスケール変換

```
parameters {
  simplex[K] beta_raw;
  real beta_scale;
  ...
transformed parameters {
  vector[K] beta;
  beta <- beta_scale * (beta_raw - 1.0 / K);
  ...
```

#### 弱い中央化


### 6.7. 順序ロジスティック回帰と順序プロビット回帰


#### 順序ロジスティック回帰

```
data {
  int<lower=2> K;
  int<lower=0> N;
  int<lower=1> D;
  int<lower=1,upper=K> y[N];
  row_vector[D] x[N];
}
parameters {
  vector[D] beta;
  ordered[K-1] c;
}
model {
  for (n in 1:N)
    y[n] ~ ordered_logistic(x[n] * beta, c);
}
```

##### 順序プロビット

```
data {
  int<lower=2> K;
  int<lower=0> N;
  int<lower=1> D;
  int<lower=1,upper=K> y[N];
  row_vector[D] x[N];
}
parameters {
  vector[D] beta;
  ordered[K-1] c;
}
model {
  vector[K] theta;
  for (n in 1:N) {
    real eta;
    eta <- x[n] * beta;
    theta[1] <- 1 - Phi(eta - c[1]);
    for (k in 2:(K-1))
      theta[k] <- Phi(eta - c[k-1]) - Phi(eta - c[k]);
    theta[K] <- Phi(eta - c[K-1]);
    y[n] ~ categorical(theta);
  }
}
```

### 6.8. 階層ロジスティック回帰

```
data {
  int<lower=1> D;
  int<lower=0> N;
  int<lower=1> L;
  int<lower=0,upper=1> y[N];
  int<lower=1,upper=L> ll[N];
  row_vector[D] x[N];
}
parameters {
  real mu[D];
  real<lower=0> sigma[D];
  vector[D] beta[L];
} model {
  for (d in 1:D) {
    mu[d] ~ normal(0,100);
    for (l in 1:L)
      beta[l,d] ~ normal(mu[d],sigma[d]);
  }
  for (n in 1:N)
    y[n] ~ bernoulli(inv_logit(x[n] * beta[ll[n]]));
}
```

##### モデルの最適化

```
mu ~ normal(0,100);
  for (l in 1:L)
    beta[l] ~ normal(mu,sigma);
```

```
for (n in 1:N)
  y[n] ~ bernoulli_logit(x[n] * beta[ll[n]]);
```

```
{
  vector[N] x_beta_ll;
  for (n in 1:N)
    x_beta_ll[n] <- x[n] * beta[ll[n]];
  y ~ bernoulli_logit(x_beta_ll);
}
```

### 6.9. 階層事前分布


#### 階層モデルのMLEで、限度がなくなる事前分布

![$$ \begin{array}{rl}y_{n} &\sim \mathsf{Normal}(x_{n}\beta, \sigma)\\ \beta_{k} &\sim \mathsf{Normal}(0, \tau)\\ \tau &\sim \mathsf{Cauchy}(0, 2.5) \end{array} $$](fig/fig11.png)

![$$ p(\beta, \tau, \sigma \mid y, x) \propto p(y \mid x, \beta, \tau, \sigma) $$](fig/fig12.png)

![$$ \sigma \sim \mathsf{Gamma}(2, 1/A) $$](fig/fig13.png)

### 6.10. 項目応答理論モデル


#### 欠測のあるデータ宣言

```
data {
  int<lower=1> J;              // number of students
  int<lower=1> K;              // number of questions
  int<lower=1> N;              // number of observations
  int<lower=1,upper=J> jj[N];  // student for observation n
  int<lower=1,upper=K> kk[N];  // question for observation n
  int<lower=0,upper=1> y[N];   // correctness for observation n
}
```

#### 1PL (Rasch) モデル

```
parameters {
  real delta;          // mean student ability
  real alpha[J];       // ability of student j - mean ability
  real beta[K];        // difficulty of question k
}
```

```
model {
  alpha ~ normal(0,1);      // informative true prior
  beta ~ normal(0,1);       // informative true prior
  delta ~ normal(.75,1);    // informative true prior
  for (n in 1:N)
    y[n] ~ bernoulli_logit(alpha[jj[n]] - beta[kk[n]] + delta);
}
```

![$$ \mathsf{bernoulli\_logit}(y \mid \alpha) = \mathsf{bernoulli}(y \mid \mathsf{logit}^{-1}(\alpha)) $$](fig/fig14.png)

![$$ \Pr[y_{n} = 1] = \mathrm{logit}^{-1}(\alpha_{jj[n]} - \beta_{kk[n]} + \delta) $$](fig/fig15.png)


#### マルチレベル2PLモデル


```
parameters {
  real mu_beta;                // mean student ability
  real alpha[J];               // ability for j - mean
  real beta[K];                // difficulty for k
  real<lower=0> gamma[K];      // discriminations of k
  real<lower=0> sigma_beta;    // scale of difficulties
  real<lower=0> sigma_gamma;   // scale of log discrimination
}
```

```
model {
  alpha ~ normal(0,1);
  beta ~ normal(0,sigma_beta);
  gamma ~ lognormal(0,sigma_gamma);
  mu_beta ~ cauchy(0,5);
  sigma_alpha ~ cauchy(0,5);
  sigma_beta ~ cauchy(0,5);
  sigma_gamma ~ cauchy(0,5);
  for (n in 1:N)
    y[n] ~ bernoulli_logit(gamma[kk[n]]
                           * (alpha[jj[n]] - (beta[kk[n]] + mu_beta)));
}
```

```
beta ~ normal(0,5);
gamma ~ lognormal(0,2);
```

```
beta ~ normal(mu_beta, sigma_beta);
```

```
y[n] ~ bernoulli_logit(gamma[kk[n]] * (alpha[jj[n]] - beta[kk[n]]));
```

### 6.11. 識別可能性のための事前分布


#### 位置とスケールの固定


#### 多重共線性


#### 分離可能性


### 6.12. 階層モデルの多変量事前分布


#### 多変量回帰の例


##### 尤度

![$$ y_{n} \sim \mathsf{Normal}(x_{n}\beta_{jj[n]}, \sigma) \quad\text{ただし}\quad n \in 1:N $$](fig/fig16.png)

##### 係数の事前分布

![$$ \beta_{j} \sim \mathsf{MultiNormal}(\mu, \Sigma) \quad\text{ただし}\quad j \in 1:J $$](fig/fig17.png)

##### ハイパーパラメータ

![$$ \mu_{j} \sim \mathsf{Normal}(0, 5) $$](fig/fig18.png)

![$$ \Sigma = \mathrm{diag_matrix}(\tau)\Omega\mathrm{diag_matrix}(\tau) $$](fig/fig19.png)

![$$ \tau_{k} \sim \mathsf{Cauchy}(0, 2.5) \quad\text{ただし}\quad k \in 1:J \quad\text{かつ}\quad \tau_{k} > 0 $$](fig/fig20.png)

![$$ \Omega \sim \mathsf{LKJcorr}(\nu) $$](fig/fig21.png)

##### 事前平均についてのグループレベルの予測変数

![$$ \beta_{j} \sim \mathsf{MultiNormal}(u_{j}\gamma, \Sigma) $$](fig/fig22.png)

![$$ \gamma_{l} \sim \mathsf{Normal}(0, 5) $$](fig/fig23.png)


##### Stanでのモデルのコーディング

```
data {
  int<lower=0> N;              // num individuals
  int<lower=1> K;              // num ind predictors
  int<lower=1> J;              // num groups
  int<lower=1> L;              // num group predictors
  int<lower=1,upper=J> jj[N];  // group for individual
  matrix[N,K] x;               // individual predictors
  row_vector[L] u[J];          // group predictors
  vector[N] y;                 // outcomes
}
parameters {
  corr_matrix[K] Omega;        // prior correlation
  vector<lower=0>[K] tau;      // prior scale
  matrix[L,K] gamma;           // group coeffs
  vector[K] beta[J];           // indiv coeffs by group
  real<lower=0> sigma;         // prediction error scale
}
model {
  tau ~ cauchy(0,2.5);
  Omega ~ lkj_corr(2);
  to_vector(gamma) ~ normal(0, 5);
  {
    row_vector[K] u_gamma[J];
    for (j in 1:J)
      u_gamma[j] <- u[j] * gamma;
    beta ~ multi_normal(u_gamma, quad_form_diag(Omega, tau));
  }
  {
    vector[N] x_beta_jj;
    for (n in 1:N)
      x_beta_jj[n] <- x[n] * beta[jj[n]];
    y ~ normal(x_beta_jj, sigma);
  }
}
```

##### ベクトル化による最適化

```
for (n in 1:N)
  y[n] ~ normal(x[n] * beta[jj[n]], sigma);
```

```
{
  matrix[K,K] Sigma_beta;
  Sigma_beta <- quad_form_diag(Omega, tau);
  for (j in 1:J)
    beta[j] ~ multi_normal((u[j] * gamma)', Sigma_beta);
}
```

##### Cholesky分解による最適化


```
parameters {
  matrix[K,J] z;
  cholesky_factor_corr[K] L_Omega;
  ...
transformed parameters {
  matrix[J,K] beta;
  beta <- u * gamma + (diag_pre_multiply(tau,L_Omega) * z)';
}
model {
  to_vector(z) ~ normal(0,1);
  L_Omega ~ lkj_corr_cholesky(2);
  ...
```

```
Omega = L_Omega * L_Omega'
```

```
Sigma_beta
= quad_form_diag(Omega,tau)
= diag_pre_multiply(tau,L_Omega) * diag_pre_multiply(tau,L_Omega)'
```

```
diag_pre_multiply(a,b) = diag_matrix(a) * b
```

```
parameters {
  matrix[K,J] z;
  cholesky_factor_corr[K] L_Omega;
  vector<lower=0>[K] tau;      // prior scale
  matrix[L,K] gamma;           // group coeffs
  real<lower=0> sigma;         // prediction error scale
}
transformed parameters {
  matrix[J,K] beta;
  beta <- u * gamma + (diag_pre_multiply(tau,L_Omega) * z)';
}
model {
  vector[N] x_beta_jj;
  for (n in 1:N)
    x_beta_jj[n] <- x[n] * beta[jj[n]]';
  y ~ normal(x_beta_jj, sigma);
  tau ~ cauchy(0,2.5);
  to_vector(z) ~ normal(0,1);
  L_Omega ~ lkj_corr_cholesky(2);
  to_vector(gamma) ~ normal(0,5);
}
```

### 6.13. 予測、フォーキャストとバックキャスト


#### 予測のプログラミング


```
data {
  int<lower=1> K;
  int<lower=0> N;
  matrix[N,K] x;
  vector[N] y;
  int<lower=0> N_new;
  matrix[N_new, K] x_new;
}
parameters {
  vector[K] beta;
  real<lower=0> sigma;
  vector[N_new] y_new;                  // predictions
}
model {
  y ~ normal(x * beta, sigma);          // observed model

  y_new ~ normal(x_new * beta, sigma);  // prediction model
}
```

#### 生成量としての予測

```
...data as above...

parameters {
  vector[K] beta;
  real<lower=0> sigma;
}
model {
  y ~ normal(x * beta, sigma);
}
generated quantities {
  vector[N_new] y_new;
  for (n in 1:N_new)
    y_new[n] <- normal_rng(x_new[n] * beta, sigma);
}
```

### 6.14. 多変量の結果


#### 見かけ上無関係な回帰


![$$ \begin{array}{rl} y_{n} &= x_{n}\beta + \epsilon_{n}\\ \epsilon_{n} &\sim \mathsf{MultiNormal}(0, \Sigma) \end{array} $$](fig/fig24.png)

![$$ y_{n,k} = \mathrm{I}(z_{n,k} > 0) $$](fig/fig25.png)


```
data {
  int<lower=1> K;
  int<lower=1> J;
  int<lower=0> N;
  vector[J] x[N];
  vector[K] y[N];
}
parameters {
  matrix[K,J] beta;
  cov_matrix[K] Sigma;
}
model {
  vector[K] mu[N];
  for (n in 1:N)
    mu[n] <- beta * x[n];
  y ~ multi_normal(mu, Sigma);
}
```

```
...
parameters {
  matrix[K,J] beta;
  cholesky_factor_corr[K] L_Omega;
  vector<lower=0>[K] L_sigma;
}
model {
  vector[K] mu[N];
  matrix[K,K] L_Sigma;

  for (n in 1:N)
    mu[n] <- beta * x[n];

  L_Sigma <- diag_pre_multiply(L_sigma, L_Omega);

  to_vector(beta) ~ normal(0, 5);
  L_Omega ~ lkj_corr_cholesky(4);
  L_sigma ~ cauchy(0, 2.5);
  y ~ multi_normal_cholesky(mu, L_Sigma);
}
```

#### 多変量プロビット回帰


![$$ \begin{array}{rl} z_{n} &= x_{n}\beta + \epsilon_{n}\\ \epsilon_{n} &\sim \mathsf{MultiNormal}(0, \Sigma) \end{array} $$](fig/fig24.png)

```
functions {
  int sum(int[,] a) {
    int s;
    s <- 0;
    for (i in 1:size(a))
      s <- s + sum(a[i]);
    return s;
  }
}
```

```
data {
  int<lower=1> K;
  int<lower=1> D;
  int<lower=0> N;
  int<lower=0,upper=1> y[N,D];
  vector[K] x[N];
}
```

```
transformed data {
  int<lower=0> N_pos;
  int<lower=1,upper=N> n_pos[sum(y)];
  int<lower=1,upper=D> d_pos[size(n_pos)];
  int<lower=0> N_neg;
  int<lower=1,upper=N> n_neg[(N * D) - size(n_pos)];
  int<lower=1,upper=D> d_neg[size(n_neg)];

  N_pos <- size(n_pos);
  N_neg <- size(n_neg);
  {
    int i;
    int j;
    i <- 1;
    j <- 1;
    for (n in 1:N) {
      for (d in 1:D) {
        if (y[n,d] == 1) {
          n_pos[i] <- n;
          d_pos[i] <- d;
          i <- i + 1;
        } else {
          n_neg[j] <- n;
          d_neg[j] <- d;
          j <- j + 1;
        }
      }
    }
  }
}
```

```
parameters {
  matrix[D,K] beta;
  cholesky_factor_corr[D] L_Omega;
  vector<lower=0>[N_pos] z_pos;
  vector<upper=0>[N_neg] z_neg;
}
```

```
transformed parameters {
  vector[D] z[N];
  for (n in 1:N_pos)
    z[n_pos[n], d_pos[n]] <- z_pos[n];
  for (n in 1:N_neg)
    z[n_neg[n], d_neg[n]] <- z_neg[n];
}
```

```
model {
  L_Omega ~ lkj_corr_cholesky(4);
  to_vector(beta) ~ normal(0, 5);
  {
    vector[D] beta_x[N];
    for (n in 1:N)
      beta_x[n] <- beta * x[n];
    z ~ multi_normal_cholesky(beta_x, L_Omega);
  }
}
```

```
generated quantities {
  corr_matrix[D] Omega;
  Omega <- multiply_lower_tri_self_transpose(L_Omega);
}
```
