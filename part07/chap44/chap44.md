## 44.Mixed Operations

これらの関数は，Stanのコンテナである行列，ベクトル，行ベクトル，配列間の変換をするものです。

```
matrix to_matrix(matrix m)
```

行列$m$そのものを返します。

```
matrix to_matrix(vector v)
```

列ベクトル$v$を`size(v)`行1列の行列に変換します。

```
matrix to_matrix(row_vector v)
```

行ベクトル$v$を1行`size(v)`列の行列に変換します。

```
matrix to_matrix(matrix m, int m, int n)
```

行列$m$を$m$行$n$列の行列に列優先順で変換します。

```
matrix to_matrix(vector v, int m, int n)
```

ベクトル$v$をm$行$n$列の行列に列優先順で変換します。

```
matrix to_matrix(row_vector v, int m, int n)
```

行ベクトル$v$をm$行$n$列の行列に列優先順で変換します。

```
matrix to_matrix(matrix m, int m, int n, int col_major)
```
行列$m$を$m$行$n$列の行列に，`col_major`が0であれば行優先で埋めながら変換します(0でなければ，列優先順で埋めます)。

```
matrix to_matrix(vector v, int m, int n, int col_major)
```
ベクトル$v$を$m$行$n$列の行列に，`col_major`が0であれば行優先で埋めながら変換します(0でなければ，列優先順で埋めます)。

```
matrix to_matrix(row_vector v, int m, int n, int col_major)
```
行ベクトル$v$を$m$行$n$列の行列に，`col_major`が0であれば行優先で埋めながら変換します(0でなければ，列優先順で埋めます)。

```
matrix to_matrix(real[] a, int m, int n)
```
一次元配列$a$を$m$行$n$列の行列に，列優先順で埋めながら変換します。

```
matrix to_matrix(int[] a, int m, int n)
```
一次元配列$a$を$m$行$n$列の行列に，列優先順で埋めながら変換します。

```
matrix to_matrix(real[] a, int m, int n, int col_major)
```
一次元配列$a$を$m$行$n$列の行列に，`col_major`が0であれば行優先で埋めながら変換します(0でなければ，列優先順で埋めます)。列優先順で埋めながら変換します。

```
matrix to_matrix(int[] a, int m, int n, int col_major)
```
一次元配列$a$を$m$行$n$列の行列に，`col_major`が0であれば行優先で埋めながら変換します(0でなければ，列優先順で埋めます)。列優先順で埋めながら変換します。

```
matrix to_matrix(real[,] a)
```
二次元配列$a$を，次元もインデックス順もそのままに行列に変換します。

```
matrix to_matrix(int[,] a)
```
二次元配列$a$を，次元もインデックス順もそのままに行列に変換します。もし$a$のどこかの次元がゼロであれば，結果は$0 \times 0$行列になります。

```
vector to_vector(matrix m)
```
行列$m$を列ベクトルに，列優先順で変換します。

```
vector to_vector(vector v)
```
ベクトル$v$そのものを返します。

```
vector to_vector(row_vector v)
```
行ベクトル$v$を列ベクトルにして返します。

```
vector to_vector(real[] a)
```
一次元配列$a$を列ベクトルに変換します。

```
vector to_vector(int[] a)
```

一次元整数配列$a$を列ベクトルに変換します。

```
row_vector to_row_vector(matrix m)
```
行列$m$を行ベクトルに列優先順で変換します。

```
row_vector to_row_vector(vector v)
```
列ベクトル$v$を行ベクトルに変換します。

```
row_vector to_row_vector(row_vector v)
```
列ベクトル$v$そのものを返します。

```
row_vector to_row_vector(real[] a)
```
一次元配列$a$を行ベクトルに変換します。

```
row_vector to_row_vector(int[] a)
```
一次元配列$a$を行ベクトルに変換します。

```
real[,] to_array_2d(matrix m)
```
行列$m$を，次元もインデックス順もそのままに，配列に変換します

```
real[] to_array_1d(vector v)
```
列ベクトル$v$を一次元配列に変換します。

```
real[] to_array_1d(row_vector v)
```
行ベクトル$v$を一次元配列に変換します。

```
real[] to_array_1d(matrix m)
```
行列$m$を一次元配列に，列優先順で変換します。

```
real to_array_1d(real[...] a)
```
配列$a$(次元の上限は10です)を一次元配列に，行優先順で変換します。

```
int to_array_1d(int[...] a)
```
配列$a$(次元の上限は10です)を一次元配列に，行優先順で変換します。
