from typing import Iterable, List

import torch as th
import torch.nn as nn
from filtering import GFRFTFilterLayer, Real
from torch_gfrft.gfrft import GFRFT
from utils import mse_loss, seed_everything


def generate_bandlimited_jtv_signal(
    gfrft: GFRFT,
    signal: th.Tensor,
    order: float,
    stopband: slice,
) -> th.Tensor:
    if not (0 <= stopband.start and stopband.stop <= signal.size(0)):
        raise ValueError("Count must be between 0 and the signal size")
    transformed = gfrft.gfrft(signal, order, dim=0)
    transformed[stopband, ...] = 0
    return gfrft.igfrft(transformed, order, dim=0)


def generate_bandlimited_noise(
    gfrft: GFRFT,
    signal: th.Tensor,
    order: float,
    stopband: slice,
    mean: float = 0.0,
    sigma: float = 1.0,
) -> th.Tensor:
    noise = th.zeros_like(signal)
    th.manual_seed(0)
    noise[stopband, ...] = mean + sigma * th.randn_like(noise[stopband, ...])
    return gfrft.igfrft(noise, order, dim=0)


def generate_bandlimited_experiment_data(
    gfrft: GFRFT,
    signal: th.Tensor,
    order: float,
    stopband_count: int,
    overlap: int = 0,
    mean: float = 0.0,
    sigma: float = 1.0,
) -> tuple[th.Tensor, th.Tensor]:
    size = signal.size(0)
    signal_stopband = slice(size - stopband_count, size)
    noise_stopband = slice(size - stopband_count - overlap, size)
    bl_signal = generate_bandlimited_jtv_signal(gfrft, signal, order, signal_stopband)
    bl_noise = generate_bandlimited_noise(gfrft, signal, order, noise_stopband, mean, sigma)
    return bl_signal, bl_noise


def experiment(
    gfrft: GFRFT,
    jtv_signal: th.Tensor,
    jtv_noise: th.Tensor,
    initial_orders: List[float],
    cutoff_counts: List[int],
    *,
    lr: float = 5e-4,
    epochs: int = 1000,
    display_epochs: Iterable[int] | None = None,
    seed: int = 0,
    trainable_transform: bool = True,
    trainable_filter: bool = False,
) -> nn.Module:
    if len(initial_orders) != len(cutoff_counts):
        raise ValueError("initial_orders and cutoff_counts must have the same length")
    if display_epochs is None:
        display_epochs = (e for e in range(0, epochs, 100))
    display_epochs = set(display_epochs)

    seed_everything(seed)
    filters = [
        GFRFTFilterLayer(
            gfrft,
            cutoff,
            order,
            trainable_transform=trainable_transform,
            trainable_filter=trainable_filter,
        )
        for order, cutoff in zip(initial_orders, cutoff_counts)
    ]
    layers = [elem for pair in zip(filters, [Real()] * len(filters)) for elem in pair]
    model = nn.Sequential(*layers)
    print(model)
    print(f"learning rate: {lr}")
    optim = th.optim.Adam(model.parameters(), lr=lr)
    noisy_signal = jtv_signal + jtv_noise

    initial_loss = mse_loss(noisy_signal, jtv_signal)
    print(f"Epoch {0:4d} | Loss {initial_loss.item(): >8.4f}")
    for epoch in range(1, 1 + epochs):
        optim.zero_grad()
        output = mse_loss(model(noisy_signal), jtv_signal)
        if epoch in display_epochs:
            print(f"Epoch {epoch:4d} | Loss {output.item(): >8.4f}")
        if not (trainable_transform or trainable_filter):
            break
        output.backward()
        optim.step()
    return model
