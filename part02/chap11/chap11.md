## 11. 測定誤差とメタアナリシス



### 11.1 ベイズ測定誤差モデル



#### 測定誤差のある回帰



```
data {
  int<lower=0> N;       // 場合の数
  real x[N];            // 予測変数（共変量）
  real y[N];            // 結果（変量）
}
parameters {
  real alpha;           // 切片
  real beta;            // 傾き
  real<lower=0> sigma;  // 結果のノイズ
} model {
  y ~ normal(alpha + beta * x, sigma);
  alpha ~ normal(0,10);
  beta ~ normal(0,10);
  sigma ~ cauchy(0,5);
}
```



```
data {
  ...
  real x_meas[N];     // xの測定値
  real<lower=0> tau;  // 測定ノイズ
}
parameters {
  real x[N];          // 未知の真値
  real mu_x;          // 事前分布の位置
  real sigma_x;       // 事前分布のスケール
  ...
}
model {
x ~ normal(mu_x, sigma_x);   // 事前分布
  x_meas ~ normal(x, tau);   // 測定モデル
  y ~ normal(alpha + beta * x, sigma);
  ...
}
```


![$$x_{n} \sim \mathsf{Normal}(\gamma^{\top}c,\upsilon)$$](fig/fig01.png)


#### 丸め



![$$z_{n} \sim \mathsf{Normal}(\mu,\sigma)$$](fig/fig02.png)



![$$p(y_{n}\mid\mu,\sigma)=\int_{y_{n}-0.5}^{y_{n}+0.5}\mathsf{Normal}(z_{n}\mid\mu,\sigma)\mathrm{d}z_{n}=\Phi\left(\frac{y_{n}+0.5-\mu}{\sigma}\right)-\Phi\left(\frac{y_{n}-0.5-\mu}{\sigma}\right)$$](fig/fig03.png)


![$$p(\mu,\sigma^2) \propto \frac{1}{\sigma^2}$$](fig/fig04.png)


![$$\begin{array}{ll}p(\mu,\sigma^2\mid y) &\propto p(\mu,\sigma^2)p(y\mid\mu,\sigma^2)\\ &\propto \frac{1}{\sigma^2}\prod_{n=1}^{5}\left(\Phi\left(\frac{y_{n}+0.5-\mu}{\sigma}\right)-\Phi\left(\frac{y_{n}-0.5-\mu}{\sigma}\right)\right) end{array}$$](fig/fig05.png)

```
data {
  int<lower=0> N;
  vector[N] y;
}
parameters {
  real mu;
  real<lower=0> sigma_sq;
}
transformed parameters {
  real<lower=0> sigma;
  sigma <- sqrt(sigma_sq);
}
model {
  increment_log_prob(-2 * log(sigma));
  for (n in 1:N)
    increment_log_prob(log(Phi((y[n] + 0.5 - mu) / sigma)
                           - Phi((y[n] - 0.5 - mu) / sigma)));
}
```



```
data {
  int<lower=0> N;
  vector[N] y;
}
parameters {
  real mu;
  real<lower=0> sigma_sq;
  vector<lower=-0.5, upper=0.5>[5] y_err;
}
transformed parameters {
  real<lower=0> sigma;
  vector[N] z;
  sigma <- sqrt(sigma_sq);
  z <- y + y_err;
}
model {
  increment_log_prob(-2 * log(sigma));
  z ~ normal(mu, sigma);
}
```



### 11.2. メタアナリシス



#### 統制研究における処置の効果



##### データ



```
data {
  int<lower=0> J;
  int<lower=0> n_t[J];  // num cases, treatment
  int<lower=0> r_t[J];  // num successes, treatment
  int<lower=0> n_c[J];  // num cases, control
  int<lower=0> r_c[J];  // num successes, control
}
```

##### 対数オッズへの変換と標準誤差



![$$y_{j}=\log\left(\frac{r^{t}_{j}/(n^{t}_{j}-r^{t}_{j})}{r^{c}_{j}/(n^{c}_{j}-r^{c}_{j})}\right)=\log\left(\frac{r^{t}_{j}}{n^{t}_{j}-r^{t}_{j}}\right)-\log\left(\frac{r^{c}_{j}}{n^{c}_{j}-r^{c}_{j}}\right)$$](fig/fig06.png)


![$$\sigma_{j}=\sqrt{\frac{1}{r^T_i}+\frac{1}{n^T_i-r^T_i}+\frac{1}{r^C_i}+\frac{1}{n^C_i-r^C_i}}$$](fig/fig07.png)

```
transformed data {
  real y[J];
  real<lower=0> sigma[J];
  for (j in 1:J)
    y[j] <- log(r_t[j]) - log(n_t[j] - r_t[j])
            - (log(r_c[j]) - log(n_c[j] - r_c[j]);
  for (j in 1:J)
    sigma[j] <- sqrt(1.0/r_t[i] + 1.0/(n_t[i] - r_t[i])
                     + 1.0/r_c[i] + 1.0/(n_c[i] - r_c[i]));
}
```



##### 非階層モデル



```
parameters {
  real theta;  // global treatment effect, log odds
}
model {
  y ~ normal(theta,sigma);
}
```



```
for (j in 1:J)
  y[j] ~ normal(theta,sigma[j]);
```



##### 階層モデル



##### 拡張と代替法



