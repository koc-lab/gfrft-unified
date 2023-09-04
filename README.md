# Graph Fractional Fourier Transform: A Unified Theory - Experiments

![MATLAB](https://img.shields.io/badge/MATLAB-2023a-orange.svg)
[![Styling, Metrics & Linting by miss_hit](https://img.shields.io/badge/Styling,%20Metrics%20%26%20Linting-miss_hit-blue)](https://misshit.org/)
[![License](https://img.shields.io/github/license/koc-lab/gfrft-unified)](https://github.com/koc-lab/gfrft-unified/blob/main/LICENSE)

According to the feedback of the reviewers, the _Graph Fractional Fourier Transform: A Unified Theory_ paper needed updates for the experiments. This repository contains the source code and will serve as documentation for the updated experiments.

## Table of Contents

- [Graph Fractional Fourier Transform: A Unified Theory - Experiments](#graph-fractional-fourier-transform-a-unified-theory---experiments)
  - [Table of Contents](#table-of-contents)
  - [Dependencies](#dependencies)
  - [Installation](#installation)
  - [Usage](#usage)
  - [⚠️ Warnings](#️-warnings)

## Dependencies

1. EPFL's _Graph Signal Processing Toolbox_ (`gspbox`): see [GitHub](https://github.com/epfl-lts2/gspbox) and [documentation](https://epfl-lts2.github.io/gspbox-html/) pages.
    - The project assumes the `gspbox` directory is present in the root of the project, and compiled according to the directives presented in the [documentation](https://epfl-lts2.github.io/gspbox-html/download.html).
    - If you already have a way to include `gspbox` in your path, then you can ignore this. However, if you want to download the code with its `gspbox` dependency, you need to use `--recursive` option while cloning, e.g.,

        ```sh
        git clone --recursive https://github.com/koc-lab/gfrft-unified.git
        ```

        or with [GitHub CLI](https://cli.github.com/),

        ```sh
        gh repo clone koc-lab/gfrft-unified -- --recursive
        ```

2. `CVX`, which is _MATLAB Software for Disciplined Convex Programming_: see [GitHub](https://github.com/cvxr/CVX) and [documentation](http://cvxr.com/cvx/) pages.
    - The `CVX` library is needed by the `graph-arma` component of the codebase, which is an implementation of the _Autoregressive Moving Average Graph Filtering_ paper (published in _IEEE Transactions on Signal Processing_ Volume: 65, Issue: 2, 15 January 2017), and it is based on the provided source code by Andreas Loukas on his [blog](https://andreasloukas.blog/code/). `CVX` library needs to be installed in order to design ARMA graph filters, so you do not need it if you are not going to use `graph-arma` codes.
    - The best way to obtain CVX is to visit the [download page](http://cvxr.com/cvx/download/), which provides pre-built archives containing standard and professional versions of CVX tailored for specific operating systems. That is why `CVX` is not added as a submodule like `gspbox`. They advise not to manually add it to the path and use a setup script, hence it does not matter where you place the library other than some given restrictions (see [documentation](http://web.cvxr.com/cvx/doc/install.html)).

## Installation

1. Clone the repository
   - If you want the `gspbox` as a submodule, clone recursively (see [Dependencies](#dependencies) section).
2. Install `gspbox` dependency, by entering `gspbox` directory in MATLAB prompt, and running the following command (see the [documentation](https://epfl-lts2.github.io/gspbox-html/download.html) for further details):

    ```matlab
    gsp_start; gsp_make; gsp_install;
    ```

3. Install `CVX` dependency, by installing the pre-built archive for your operating system and extracting it. Then, by entering `cvx` directory in the MATLAB prompt, run the following command, and _do not try to manually add the directory to the path_ (see the [documentation](http://web.cvxr.com/cvx/doc/install.html) for further details):

    ```matlab
    cvx_setup
    ```

## Usage

First, run the [`Initialize.m`](./Initialize.m) script to resolve paths of the all files and import them for utilization.

```matlab
>>> Initialize
```

```stdout
Successfully initialized GFRFT Unified Project by Tuna Alikaşifoğlu.
```

## ⚠️ Warnings

- The [`gspbox`](https://github.com/epfl-lts2/gspbox)'s [`unlockbox`](https://github.com/epfl-lts2/unlocbox) addition overrides [`snr.m`](https://github.com/epfl-lts2/unlocbox/blob/df22b021536c0f4e0411cd07c23fa916bd9dbb6d/utils/snr.m#L1-L29) of the signal toolbox. For an original signal `x` and same size noise `n`, the original SNR is calculated with `snr(x, n)`, with the [`unlockbox`](https://github.com/epfl-lts2/unlocbox) addition, it is calculated with `snr(x, x + n)`. To provide consistency custom [`Snr.m`](./src/Snr.m) is provided to calculate in the calling convention of `Snr(x, x + n)`, but the calculation style of default MATLAB implementation, whether [`unlockbox`](https://github.com/epfl-lts2/unlocbox) is imported or not, utilizes the convention of [`unlockbox`](https://github.com/epfl-lts2/unlocbox).
