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
`x`の要素の総和を返します。ただし、`x`のsize`N`によっては以下のように返します。

![$$\mbox{\tt sum}(x) = \left\{\begin{array}{ll} \sum_{n=1}^{N}x_{n} & \mbox{if} N > 0 \\ 0 & \mbox{if} N = 0 \end{array}\right.$$](fig/fig1.png)
```text
real sum(real x[])
```
`x`の要素の総和を返します。上の定義を参照してください。
```text
real prod(real x[])
```
`x`の要素の総乗を返します。ただし、`x`のsizeが0の時は1を返します。
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
