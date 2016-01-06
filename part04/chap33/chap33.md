## 33. Array型の演算

### 33.1 Arrayから1つの値の作成
次の演算子はarrayをインプットとしてとり、一つの値をアウトプットとして返すものです。　**`The　boundary values for size 0 arrays are the unit with respect to the combination operation
(min, max, sum, or product).`**

#### 最小・最大
```text
real min(real x[])
```
`x`の中の最小値を返す。ただし、`x`のサイズが0の時は+∞を返す。
```text
int min(int x[])
```
`x`の中の最小値を返す。ただし、`x`のサイズが0の時はerrorを返す。
```text
real max(real x[])
```
`x`の中の最大値を返す。ただし、`x`のサイズが0の時は-∞を返す。
```text
int max(int x[])
```
`x`の中の最大値を返す。ただし、`x`のサイズが0の時はerrorを返す。

#### 総和・総乗・Log Sum of Exp
```text
int sum(int x[])
```
`x`の要素の総和を返す。ただし、`x`のsize`N`によっては以下のように返す。　　

![$$\mbox{\tt sum}(x) = \left\{\begin{array}{ll} \sum_{n=1}^{N}x_{n} & \mbox{if} N > 0 \\ 0 & \mbox{if} N = 0 \end{array}\right.$$](fig/fig1.png)
```text
real sum(real x[])
```
`x`の要素の総和を返す。上の定義を参照。
```text
real prod(real x[])
```
`x`の要素の総乗を返す。ただし、`x`のsizeが0の時は1を返す。
```text
real prod(int x[])
```
`x`の要素の総乗を返す。　　

![$$\mbox{\tt product}(x) = \left\{\begin{array}{ll} \prod_{n=1}^{N}x_{n} & \mbox{if} N > 0 \\ 1 & \mbox{if} N = 0 \end{array}\right.$$](fig/fig2.png)
```text
real log_sum_exp(real x[])
```
`x`の各要素のexpをとったものの総和の自然対数を返す。ただし、arrayが空の時は-∞を返す。

#### 標本平均・標本分散・標本標準偏差
