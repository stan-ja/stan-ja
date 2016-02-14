## 9. 切断あるいは打ちきりデータ


### 9.1. 切断分布


### 9.2. 切断データ

```
data {
  int<lower=0> N;
  real U;
  real<upper=U> y[N];
}
parameters {
  real mu;
  real<lower=0> sigma;
}
model {
  for (n in 1:N)
    y[n] ~ normal(mu,sigma) T[,U];
}
```

#### 制約と範囲外の値


#### 未知の切断点

```
data {
  int<lower=1> N;
  real y[N];
}
parameters {
  real<upper = min(y)> L;
  real<lower = max(y)> U;
  real mu;
  real<lower=0> sigma;
}
model {
  L ~ ...;
  U ~ ...;
  for (n in 1:N)
    y[n] ~ normal(mu,sigma) T[L,U];
}
```

### 9.3 打ちきりデータ


#### 打ちきられた値の推定

```
data {
  int<lower=0> N_obs;
  int<lower=0> N_cens;
  real y_obs[N_obs];
  real<lower=max(y_obs)> U;
}
parameters {
  real<lower=U> y_cens[N_cens];
  real mu;
  real<lower=0> sigma;
}
model {
  y_obs ~ normal(mu,sigma);
  y_cens ~ normal(mu,sigma);
}
```

#### 打ちきられた値の積分消去


```
data {
  int<lower=0> N_obs;
  int<lower=0> N_cens;
  real y_obs[N_obs];
  real<lower=max(y_obs)> U;
}
parameters {
  real mu;
  real<lower=0> sigma;
}
model {
  y_obs ~ normal(mu,sigma);
  increment_log_prob(N_cens * normal_ccdf_log(U,mu,sigma));
}
```


```
data {
  int<lower=0> N_obs;
  int<lower=0> N_cens;
  real y_obs[N_obs];
}
parameters {
  real<upper=min(y_obs)> L;
  real mu;
  real<lower=0> sigma;
}
model {
  L ~ normal(mu,sigma);
  y_obs ~ normal(mu,sigma);
  increment_log_prob(N_cens * normal_cdf_log(L,mu,sigma));
}
````