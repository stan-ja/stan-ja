## 41. 配列の演算

### 41.1 配列から1つの値の作成
次の演算子は配列をインプットとしてとり、一つの値をアウトプットとして返すものです。
サイズ0の配列の境界値は，結合する操作('min','max','sum',あるいは'product')に対応する単位になります。

#### 最小・最大
```text
real min(real x[])
```
`x`の中の最小値を返す。ただし、`x`のサイズが0の時は$+\infty$を返します。
```text
int min(int x[])
```
`x`の中の最小値を返す。ただし、`x`のサイズが0の時はエラーを返します。
```text
real max(real x[])
```
`x`の中の最大値を返す。ただし、`x`のサイズが0の時は$-\infty$を返します。
```text
int max(int x[])
```
`x`の中の最大値を返す。ただし、`x`のサイズが0の時はエラーを返します。

#### 総和・総乗・Log Sum of Exp
```text
int sum(int x[])
```
`x`の要素の総和を返します。ただし、`x`のサイズ`N`によっては以下のように返します。

![$$\mbox{\tt sum}(x) = \left\{\begin{array}{ll} \sum_{n=1}^{N}x_{n} & \mbox{if} N > 0 \\ 0 & \mbox{if} N = 0 \end{array}\right.$$](fig/fig1.png)
```text
real sum(real x[])
```
`x`の要素の総和を返します。上の定義を参照してください。
```text
real prod(real x[])
```
`x`の要素の総乗を返します。ただし、`x`のサイズが0の時は1を返します。
```text
real prod(int x[])
```
`x`の要素の総乗を返す。　　

![$$\mbox{\tt product}(x) = \left\{\begin{array}{ll} \prod_{n=1}^{N}x_{n} & \mbox{if} N > 0 \\ 1 & \mbox{if} N = 0 \end{array}\right.$$](fig/fig2.png)
```text
real log_sum_exp(real x[])
```
`x`の各要素のexpをとったものの総和の自然対数を返します。ただし、配列が空の時は$-\infty$を返します。

#### 標本平均・標本分散・標本標準偏差

標本平均，標本分散，および標準偏差は一般的な方法で計算されます。有限平均分布から互いに独立で同一の分布に従う(i.i.d.)標本を取ってくると，標本平均は分布の平均についての不偏推定量になります。同様に，有限分散分布から互いに独立で同一の分布に従う標本を取ってくると，標本分散は分散の不偏推定量になります^[$(N-1)$ではなく$N$で割ることで，分散の最尤推定値になりますが，これは分散を過少評価した偏った推定になります。]。標本標準偏差は標本分散の正の平方根として定義されますが，これはバイアスがありません。

```
real mean(real x[])
```

`x`の要素の標本平均を返します。サイズ$N>0$である配列`x`に対して，
$$ mean(x) = \bar{x} = \frac{1}{N} \sum_{n=1}^N x_n $$
で定義されます。ただし，配列のサイズが0のとき`mean`関数はエラーを返します。

```
real variance(real x[])
```

`x`の要素の標本分散を返します。サイズ$N>0$である配列`x`に対して，

![\operatorname{variance}(x)=\left\{\begin{array}{ll}{\frac{1}{\sqrt{-1}} \sum_{n=1}^{N}\left(x_{n}-\overline{x}\right)^{2}} & {\text { if } N>1} \\ {0} & {\text { if } N=1}\end{array}\right.$$](fig/fig3.png)

で定義されます。ただし，配列のサイズが0のとき`variance`関数はエラーを返します。

```
real sd(real x[])
```
`x`の要素の標本標準偏差を返します。

![$$ \operatorname{sd}(x)=\left\{\begin{array}{ll}{\sqrt{\operatorname{variance}(x)}} & {\text { if } N>1} \\ {0} & {\text { if } N=0}\end{array}\right.$$](fig/fig4.png)

配列のサイズが0のとき`sd`関数はエラーを返します。

#### ユークリッド距離と二乗距離

```
real distance(vector x, vector y)
```

`x`と`y`のユークリッド距離は，
![$$ \text{ distance }(x, y)=\sqrt{\sum_{n=1}^{N}\left(x_{n}-y_{n}\right)^{2}} $$](fig/fig5.png)

で定義されます。ここで$N$は`x`および`y`のサイズです。サイズの等しくない引数を取った場合，`distance`関数はエラーを返します。


```
real distance(vector x, row_vector y)
```

`x`と`y`のユークリッド距離を返します。

```
real distance(row_vector x, vector y)
```

`x`と`y`のユークリッド距離を返します。

```
real distance(row_vector x, row_vector y)
```

`x`と`y`のユークリッド距離を返します。

```
real squared_distance(vector x, vector y)
```

`x`と`y`の距離の二乗は，

![\text { squared distance }(x, y)=\operatorname{distance}(x, y)^{2}=\sum_{n=1}^{N}\left(x_{n}-y_{n}\right)^{2}](fig/fig6.png)

で定義されます。ここで$N$は`x`および`y`のサイズです。サイズの等しくない引数を取った場合，`squared_distance`関数はエラーを返します。


```
real distance(vector x, row_vector y[])
```

`x`と`y`のユークリッド距離の二乗を返します。

```
real distance(row_vector x, vector y[])
```

`x`と`y`のユークリッド距離の二乗を返します。

```
real distance(row_vector x, row_vector y[])
```

`x`と`y`のユークリッド距離の二乗を返します。