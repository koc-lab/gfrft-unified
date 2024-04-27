import torch
import torch.nn as nn
from hypothesis import example, given, settings
from hypothesis import strategies as st
from torch_gfrft.gfrft import GFRFT
from torch_gfrft.gft import GFT

from trainable.filtering import GFRFTFilterLayer, Real

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")


def generate_rand_graph_and_signal(N: int, T: int) -> tuple[torch.Tensor, torch.Tensor]:
    adjacency = torch.rand(N, N, device=DEVICE)
    jtv_signal = torch.rand(N, T, device=DEVICE)
    return adjacency, jtv_signal


@given(st.floats(min_value=-1.0, max_value=1.0), st.integers(1, 10), st.integers(1, 10))
@settings(max_examples=100, deadline=None)
@example(0.0, 5, 7)
@example(1.0, 4, 3)
@example(-1.0, 7, 5)
def test_gfrft_filter_layer_identity(order: float, node_count: int, time_length: int):
    adjacency, jtv_signal = generate_rand_graph_and_signal(node_count, time_length)
    gft = GFT(adjacency)
    gfrft = GFRFT(gft.gft_mtx)
    identity_model = nn.Sequential(
        GFRFTFilterLayer(gfrft, cutoff_count=0, order=order),
        Real(),
    ).to(DEVICE)

    assert torch.allclose(identity_model(jtv_signal), jtv_signal, atol=1e-2)
