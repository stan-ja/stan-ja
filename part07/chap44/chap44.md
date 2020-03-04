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

```
matrix to_matrix(vector v, int m, int n, int col_major)
```

```
matrix to_matrix(row_vector v, int m, int n, int col_major)
```

```
matrix to_matrix(real[] a, int m, int n)
```

```
matrix to_matrix(int[] a, int m, int n)
```

```
matrix to_matrix(real[] a, int m, int n, int col_major)
```

```
matrix to_matrix(int[] a, int m, int n, int col_major)
```

```
matrix to_matrix(real[,] a)
```
```
matrix to_matrix(int[,] a)
```

```
vector to_vector(matrix m)
```

```
vector to_vector(vector v)
```

```
vector to_vector(row_vector v)
```

```
vector to_vector(real[] a)
```

```
vector to_vector(int[] a)
```

```
row_vector to_row_vector(matrix m)
```


```
row_vector to_row_vector(vector v)
```

```
row_vector to_row_vector(row_vector v)
```

```
row_vector to_row_vector(real[] a)
```

```
row_vector to_row_vector(int[] a)
```

```
real[,] to_array_2d(matrix m)
```

```
real[] to_array_1d(vector v)
```

```
real[] to_array_1d(row_vector v)
```

```
real[] to_array_1d(matrix m)
```

```
real to_array_1d(real[...] a)
```

```
int to_array_1d(int[...] a)
```
