## 13. まばらなデータ構造と不ぞろいなデータ構造


### 13.1 まばらなデータ構造


```
data {
  int<lower=1> J;
  int<lower=1> K;
  int<lower=0,upper=1> y[J,K];
  ...
model {
  for (j in 1:J)
    for (k in 1:K)
      y[j,k] ~ bernoulli_logit(delta[k] * (alpha[j] - beta[k]));
...
```


```
data { ...
  int<lower=1> N;
  int<lower=1,upper=J> jj[N];
  int<lower=1,upper=K> kk[N];
  int<lower=0,upper=1> y[N];
  ...
model {
  for (n in 1:N)
    y[n] ~ bernoulli_logit(delta[kk[n]]
                           * (alpha[jj[n]] - beta[kk[n]]));
...
```


![$$y = \left[\begin{array}{cccc} 0 & 1 & \mathrm{NA} & 1 \\ 0 & \mathrm{NA} & \mathrm{NA} & 1 \\ \mathrm{NA} & 0 & \mathrm{NA} & \mathrm{NA} \end{array}\right] \quad \begin{array}{ll|l}jj & kk & y \\ \hline 1 & 1 & 0 \\ 1 & 2 & 1 \\ 1 & 4 & 1 \\ 2 & 1 & 0 \\ 2 & 4 & 1 \\ 3 & 2 & 0 \end{array}$$](fig/fig01.png)

図13.1: 

### 13.2. 不ぞろいなデータ構造


![$$\prod_{n=1}^{3}\log\mathsf{Normal}(y_{n}\mid\mu_{n},\sigma)$$](fig/fig02.png)


![$$\begin{minipage}[c]{0.35\textwidth} $y_1 =  \left[1.3 \ \ 2.4 \ \ 0.9\right]$ \\[3pt] $y_2 = \left[-1.8 \ \ -0.1\right]$ \\[3pt] $y_3 = \left[12.9 \ \ 18.7 \ \ 42.9 \ \ 4.7\right]$ \end{minipage} \ \ \ \begin{minipage}[c]{0.60\textwidth} $z = [1.3 \ \ 2.4 \ \ 0.9 \ \ -1.8 \ \ -0.1 \ \ 12.9 \ \ 18.7 \ \ 42.9 \ \ 4.7]$ \\[3pt] $s  =  \{ 3 \ \ 2 \ \ 4 \}$ \end{minipage}$$](fig/fig03.png)

図13.2:

```
data {
  int<lower=0> N;  // # observations
  int<lower=0> K;  // # of groups
  vector[N] y;     // observations
  int s[K];        // group sizes
  ...
model {
  int pos;
  pos <- 1;
  for (k in 1:K) {
    segment(y, pos, s[k]) ~ normal(mu[k], sigma);
    pos <- pos + s[k];
  }
```


