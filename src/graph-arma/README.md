# Autoregressive Moving Average Graph Filtering

This is an implementation of the _Autoregressive Moving Average Graph Filtering_ paper (published in: IEEE _Transactions on Signal Processing_ Volume: 65, Issue: 2, 15 January 2017), and it is based on the provided source code by Andreas Loukas on his [blog](https://andreasloukas.blog/code/).

## Manuscript Links

- [IEEE Xplore](https://ieeexplore.ieee.org/abstract/document/7581108)
- [arXiv](https://arxiv.org/abs/1602.04436)

## Known Issues

- With the call of `dlsqrat.m`, [Cholesky decomposition](https://en.wikipedia.org/wiki/Cholesky_decomposition) of a matrix needs to be obtained. However, the provided code does not always generate a positive definite matrix that can be passed into `chol()`. Therefore, sometimes the `test_ARMA_low_pass.m` generates the following error. Basically, run the test, until a decomposable matrix is obtained, which will end in successful generation of the results in the paper.

  ```stdout
  Error using chol
  Matrix must be positive definite.

  Error in dlsqrat (line 87)
          R = chol(H - 1.2 * min(eig(H)) * eye(q));

  Error in agsp_design_ARMA (line 80)
      [a, b] = dlsqrat(mu, response(mu), Kb, Ka, a(2:end)); a = [1; a];

  Error in test_ARMA_low_pass (line 110)
  [b, a, rARMA] = agsp_design_ARMA(mu, response, Kb, Ka, radius);
  ```

