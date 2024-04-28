import torch
from hypothesis import example, given, settings
from hypothesis import strategies as st

from trainable.utils import complex_round

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")


@given(st.integers(1, 100), st.integers(1, 100), st.integers(0, 15))
@settings(max_examples=100, deadline=None)
@example(1, 100, 5)
@example(100, 1, 7)
def test_complex_round(dim1: int, dim2: int, decimals: int) -> None:
    torch.manual_seed(0)
    real = torch.rand(dim1, dim2, device=DEVICE, dtype=torch.float64).squeeze()
    imag = torch.rand(dim1, dim2, device=DEVICE, dtype=torch.float64).squeeze()

    real_rounded = real.round(decimals=decimals)
    imag_rounded = imag.round(decimals=decimals)

    assert torch.allclose(real_rounded, complex_round(real, decimals), atol=1e-7)
    assert torch.allclose(imag_rounded, complex_round(imag, decimals), atol=1e-7)

    manuel_rounded = real_rounded + 1j * imag_rounded
    assert torch.allclose(manuel_rounded, complex_round(real + 1j * imag, decimals), atol=1e-7)
