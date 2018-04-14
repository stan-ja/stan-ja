<!-- 2.17の35章を訳しました。 -->
## 34. 制約のある変数の変換


### 34.1. 変数変換

$$ \mathrm{supp}(X) = \{x \mid p_X(x) > 0\} $$

#### 単変量の変数変換

$$ p_Y(y) = p_X(f^{-1}(y)) \left| \frac{d}{dy}f^{-1}(y)\right| $$

#### 多変量の変数変換

$$ J_{f^{-1}}(y) = \left[ \begin{array}{ccc}\frac{\partial x_1}{\partial y_1} & \dots & \frac{\partial x1}{\partial y_K} \\ \vdots & \vdots & \vdots \\ \frac{\partial x_K}{\partial y_1} & \dots & \frac{\partial x_K}{\partial y_K} \end{array}\right] $$

$$ \mathrm{det}J_{f^{-1}}(y) = \prod_{k=1}^{K}\frac{\partial x_k}{\partial y_k} $$

### 34.2. 下限のあるスカラー


#### 下限の変換

$$ Y = \log(X - a) $$

#### 下限の逆変換

$$ X = \exp(Y) + a $$

#### 下限逆変換の導関数の絶対値

$$ \left| \frac{d}{dy}(\exp(y) + a) \right| = \exp(y) $$

$$ p_Y(y) = p_X(\exp(y) + a)\cdot\exp(y) $$

### 34.3. 上限のあるスカラー


#### 上限の変換

$$ Y = \log(b - X) $$

#### 上限の逆変換

$$ X = b - \exp(Y) $$

#### 上限逆変換の導関数の絶対値

$$ \left| \frac{d}{dy}(b - \exp(y)) \right| = exp(y) $$

$$ p_Y(y) = p_X(b - \exp(y))\cdot\exp(y) $$

### 34.4. 上下限のあるスカラー


#### 対数オッズとロジスティックシグモイド

$$ \mathrm{logit}(u) = \log\frac{u}{1 - u} $$

$$ \mathrm{logit}^{-1}(v) = \frac{1}{1 + \exp(-v)} $$

$$ \frac{d}{dy}\mathrm{logit}^{-1}(y) = \mathrm{logit}^{-1}(y)\cdot\left(1 - \mathrm{logit}^{-1}(y)\right) $$

#### 上下限の変換

$$ Y = \mathrm{logit}\left(\frac{X - a}{b - a}\right) $$

#### 上下限の逆変換

$$ X = a + (b - a)\cdot\mathrm{logit}^{-1}(Y) $$

#### 上下限逆変換の導関数の絶対値

$$ \left| \frac{d}{dy}\left(a + (b - a)\cdot\mathrm{logit}^{-1}(y)\right) \right| = (b - a)\cdot\mathrm{logit}^{-1}(y)\cdot\left(1 - \mathrm{logit}^{-1}(y)\right) $$

$$ p_Y(y) = p_X\left(a + (b - a)\cdot\mathrm{logit}^{-1}(y)\right) \cdot (b - a) \cdot \mathrm{logit}^{-1}(y) \cdot \left( 1 - \mathrm{logit}^{-1}(y) \right) $$

### 34.5. 順序のあるベクトル

$$ x_k < x_{k + 1} $$

#### 順序の変換

$$ y_k = \left\{ \begin{array}{ll} x_1 & k = 1\text{のとき} \\[4pt] \log(x_k - x_{k - 1}) & 1 < k \le K\text{のとき} \end{array} \right. $$


#### 順序の逆変換

$$ x_k = \left\{ \begin{array}{ll} y_1 & k = 1\text{のとき} \\[4pt] x_{k - 1} + \exp(y_k) & 1 < k \le K\text{のとき} \end{array}\right. $$

$$ x_k = y_1 + \sum_{k'=2}^{k}\exp(y_{k'}) $$

#### 順序逆変換のヤコビ行列式の絶対値

$$ J_{k,k} = \left\{\begin{array}{ll} 1 & k = 1\text{のとき} \\[4pt] \exp(y_k) & 1 < k \le K\text{のとき} \end{array} \right. $$

$$ \left| \mathrm{det}J \right| = \left| \prod_{k = 1}^{K}J_{k,k} \right| = \prod_{k=1}^{K}\exp(y_k) $$

$$ p_Y(y) = p_X(f^{-1}(y))\prod_{k=1}^{K}\exp(y_k) $$

### 34.6. 単体

$$ x_k > 0 $$

$$ \sum_{k=1}^{K}x_k = 1 $$

$$ x_K = 1 - \sum_{k=1}^{K-1}x_k $$

#### 単体の逆変換

$$ z_k = \mathrm{logit}^{-1}\left( y_k + \log\left(\frac{1}{K - k}\right) \right) $$

$$ x_k = \left( 1 - \sum_{k' = 1}^{k - 1} x_{k'} \right) z_k $$

#### 単体の逆変換のヤコビ行列式の絶対値

$$ J_{k,k} = \frac{\partial x_k}{\partial y_k} = \frac{\partial x_k}{\partial z_k}\frac{\partial z_k}{\partial y_k} $$

$$ \frac{\partial z_k}{\partial y_k} = \frac{\partial}{\partial y_k}\mathrm{logit}^{-1}\left( y_k + \log\left(\frac{1}{K - k}\right) \right) = z_k(1 - z_k) $$

$$ \frac{\partial x_k}{\partial z_k} = \left( 1 - \sum_{k' = 1}^{k - 1}x_{k'} \right) $$

$$ | \mathrm{det}J | = \prod_{k=1}^{K-1}J_{k,k} = \prod_{k=1}^{K-1}z_k(1 - z_k)\left( 1 - \sum_{k'=1}^{k-1}x_{k'}\right) $$

$$ p_Y(y) = p_X(f^{-1}(y))\prod_{k=1}^{K-1}z_k(1-z_k)\left( 1 - \sum_{k'=1}^{k-1}x_{k'}\right) $$

#### 単体の変換

$$ y_k = \mathrm{logit}(z_k) - \log\left(\frac{1}{K - k}\right) $$

$$ z_k = \frac{x_k}{1 - \sum_{k'=1}^{k-1}x_{k'}} $$

### 34.7. 単位ベクトル

$$ ||x|| = \sqrt{x^{\top}x} = \sqrt{x_1^2 + x_2^2 + \cdots + x_n^2} = 1 $$

#### 単位ベクトルの逆変換

$$ x = \frac{y}{||y||} $$

##### 警告: ゼロでは未定義

#### 単位ベクトル逆変換のヤコビ行列式の絶対値

### 34.8. 相関行列

$$ x_{k,k'} = x_{k',k} $$

$$ x_{k,k} = 1 $$

$$ a^{\top}xa > 0 $$

#### 相関行列の逆変換

$$ \tanh x = \frac{\exp(2x) - 1}{\exp(2x) + 1} $$

$$ z = \left[\begin{array}{cccc} 0 & \tanh y_1 & \tanh y_2 & \tanh y_4 \\ 0 & 0 & \tanh y_3 & \tanh y_5 \\ 0 & 0 & 0 & \tanh y_6 \\ 0 & 0 & 0 & 0 \end{array}\right] $$

$$ w_{i,j} = \left\{\begin{array}{cl} 0 & i > j\text{のとき} \\[4pt] 1 & 1 = i = j\text{のとき} \\[4pt] \prod_{i'=1}^{i-1}\left(1 - z_{i',j}^{2}\right)^{1/2} & 1 < i = j\text{のとき} \\[4pt] z_{i,j} & 1 = i < j\text{のとき} \\[4pt] z_{i,j}\prod_{i'=1}^{i-1}\left(1 - z_{i',j}^2\right)^{1/2} & 1 < i < j\text{のとき} \end{array}\right. $$

$$ w_{i,j} = \left\{\begin{array}{cl} 0 & i > j\text{のとき} \\[4pt] 1 & 1 = i = j\text{のとき} \\[4pt] z_{i,j} & 1 = i < j\text{のとき} \\[4pt] z_{i,j}\prod_{i'=1}^{i-1}\left(1 - z_{i',j}^2\right)^{1/2} & 1 < i \le j\text{のとき} \end{array}\right. $$

$$ x = w^{\top}w $$

$$ \mathrm{det} x = \prod_{i=1}^{K-1}\prod_{j=i+1}^{K}(1 - z_{i,j}^2) = \prod_{1 \le i < j \le K}(1 - z_{i,j}^2) $$

#### 相関行列逆変換のヤコビ行列式の絶対値

$$ \sqrt{\prod_{i=1}^{K-1}\prod_{j=i+1}^{K}\left(1 - z_{i,j}^2\right)^{K-i-1}} \times \prod_{i=1}^{K-1}\prod_{j=i+1}^{K}\frac{\partial \tanh z_{i,j}}{\partial y_{i,j}} $$

#### 相関行列の変換

$$ w = \mathrm{chol}(x) $$

$$ z_{i,j} = \left\{\begin{array}{cl} 0 & i \le j\text{のとき} \\[4pt] w_{i,j} & 1 = i < j\text{のとき} \\[4pt] w_{i,j}\prod_{i'=1}^{i-1}\left(1 - z_{i',j}^2\right)^{-2} & 1 < i < j\text{のとき}\end{array}\right. $$

$$ \tanh^{-1}v = \frac{1}{2}\log\left(\frac{1+v}{1-v}\right) $$

### 34.9. 共分散行列

#### 共分散行列の変換

$$ x = z z^{\top} $$

$$ y_{m,n} = \left\{\begin{array}{cl} 0 & m < n \text{のとき} \\[4pt] \log z_{m,m} & m = n \text{のとき} \\[4pt] z_{m,n} & m > n \text{のとき}\end{array}\right. $$



#### 共分散行列の逆変換

$$ z_{m,n} = \left\{\begin{array}{cl} 0 & m < n \text{のとき} \\[4pt] \exp(y_{m,m}) & m = n \text{のとき} \\[4pt] y_{m,n} & m > n \text{のとき} \end{array}\right. $$

$$ x = z z^{\top} $$

#### 共分散行列逆変換のヤコビ行列式の絶対値

$$ \prod_{k=1}^{K}\frac{\partial}{\partial_{y_{k,k}}}\exp(y_{k,k}) = \prod_{k=1}^{K}\exp(y_{k,k}) = \prod_{k=1}^{K}z_{k,k} $$

$$ \frac{\partial}{\partial z_{m,n}}\left(z z^\top\right)_{m,n} = \frac{\partial}{\partial z_{m,n}}\left(\sum_{k=1}^{K}z_{m,k}z_{n,k}\right) = \left\{\begin{array}{cl} 2 z_{n,n} & m = n \text{のとき} \\[4pt] z_{n,n} & m > n \text{のとき}\end{array}\right. $$

$$ 2^K \prod_{m=1}^{K}\prod_{n=1}^{m}z_{n,n} = \prod_{n=1}^{K}\prod_{m=n}^{K}z_{n,n} = 2^K \prod_{k=1}^{K}z_{k,k}^{K-k+1} $$

$$ \left(\prod_{k=1}^{K}z_{k,k}\right)\left(2^K \prod_{k=1}^{K}z_{k,k}^{K-k+1}\right) = 2^K \prod_{k=1}^{K} z_{k,k}^{K-k+2} $$

$$ p_Y(y) = p_X(f^{-1}(y)) 2^K \prod_{k=1}^{K}z_{k,k}^{K-k+2} $$

### 34.10. 共分散行列のコレスキー因子

#### 共分散行列のコレスキー因子の変換

$$ y_{m,n} = \left\{\begin{array}{cl} 0 & m < n \text{のとき} \\[4pt] \log x_{m,m} & m = n \text{のとき} \\[4pt] x_{m,n} & m > n \text{のとき}\end{array}\right. $$

#### 共分散行列のコレスキー因子の逆変換

$$ x_{m,n} = \left\{\begin{array}{cl} 0 & m < n \text{のとき} \\[4pt] \exp(y_{m,m}) & m = n \text{のとき} \\[4pt] y_{m,n} & m > n \text{のとき}\end{array}\right. $$

#### 共分散行列コレスキー因子逆変換のヤコビ行列式の絶対値

$$ \prod_{n=1}^{N}\frac{\partial}{\partial_{y_{n,n}}}\exp(y_{n,n}) = \prod_{n=1}^{N}\exp(y_{n,n}) = \prod_{n=1}^{N}x_{n,n} $$

$$ p_Y(y) = p_X(f^{-1}(y))\prod_{n=1}^{N}x_{n,n} $$

### 34.11. 相関行列のコレスキー因子

$$ \Omega_{k,k} = L_k L_k^\top = 1 $$

#### 相関行列のコレスキー因子の逆変換

$$ z = \left[\begin{array}{ccc} 0 & 0 & 0 \\ \tanh y_1 & 0 & 0 \\ \tanh y_2 & \tanh y_3 & 0 \end{array}\right] $$

$$ x_{i,j} = \left\{\begin{array}{ll} 0 & i < j \text{のとき（対角より上）} \\[12pt] \sqrt{1 - \sum_{j'<j}x_{i,j'}^2} & i = j \text{のとき（対角）} \\[12pt] z_{i,j}\sqrt{1 - \sum_{j'<j}x_{i,j'}^2} & i > j \text{のとき（対角より下）}\end{array}\right] $$

$$ x = \left[\begin{array}{ccc} 1 & 0 & 0 \\[6pt] z_{2,1} & \sqrt{1 - x_{2,1}^2} & 0 \\[6pt] z_{3,1} & z_{3,2}\sqrt{1 - x_{3,1}^2} & \sqrt{1 - (x_{3,1}^2 + x_{3,2}^2)}\end{array}\right] $$

#### 相関行列のコレスキー因子の変換

$$ z_{i,j} = \frac{x_{i,j}}{\sqrt{1 - \sum_{j'<j}x_{i,j'}^2}} $$

$$ y = \tanh^{-1}z = \frac{1}{2}(\log(1 + z) - \log(1 - z)) $$

#### 逆変換のヤコビ行列式の絶対値

$$ \frac{d}{dy}\tanh y = \frac{1}{(\cosh y)^2} $$

$$ |\mathrm{det} J| = \prod_{i>j}\left| \frac{d}{dz_{i,j}}x_{i,j}\right| $$

$$ \frac{d}{dz_{i,j}}x_{i,j} = \sqrt{1 - \sum_{j'<j}x_{i,j'}^2} $$

$$ p_Y(y) = p_X(f^{-1}(y))\prod_{n < \binom{K}{2}}\frac{1}{(\cosh y)^2}\prod_{i>j}\left(1 - \sum_{j'<j}x_{i,j'}^2\right)^{1/2} $$

$$ \log |\mathrm{det} J| = -2\sum_{n < \binom{K}{2}}\log\cosh y + \frac{1}{2}\sum_{i>j}\log\left(1 - \sum_{j'<j}x_{i,j'}^2\right) $$
