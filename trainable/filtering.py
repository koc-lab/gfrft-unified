import torch
import torch.nn as nn
from torch_gfrft.gfrft import GFRFT


class Real(nn.Module):
    def __init__(self) -> None:
        super().__init__()

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return x.real


class TrainableDiagonalFilter(nn.Module):
    def __init__(self, size: int) -> None:
        super().__init__()
        self.size = size
        self.device = None
        self.filter = nn.Parameter(torch.randn(size, dtype=torch.float32))

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        if self.device is None:
            self.device = x.device
            self.filter.data = self.filter.data.type(x.dtype).to(self.device)
        return torch.matmul(torch.diag(self.filter), x)

    def __repr__(self) -> str:
        return f"LearnableDiagonalFilter(size={self.size})"


class IdealLowpassFilter(nn.Module):
    def __init__(self, size: int, cutoff_count: int) -> None:
        if cutoff_count >= size or cutoff_count < 0:
            raise ValueError("Cutoff count, C, must 0 <= C < N for size N.")
        super().__init__()
        self.cutoff_count = cutoff_count
        self.size = size
        self.filter = torch.cat((torch.ones(size - cutoff_count), torch.zeros(cutoff_count)))
        self.device = None

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        if self.device is None:
            self.device = x.device
            self.filter = self.filter.to(self.device)
        return torch.mul(self.filter.unsqueeze(0).T, x)

    def __repr__(self) -> str:
        return f"IdealLowpassFilter(cutoff={self.cutoff})"


class GFRFTFilterLayer(nn.Module):
    def __init__(
        self,
        gfrft: GFRFT,
        cutoff_count: int,
        order: float = 1.0,
        *,
        trainable_transform: bool = True,
        trainable_filter: bool = False,
    ) -> None:
        super().__init__()
        self.gfrft = gfrft
        self.cutoff_count = cutoff_count
        self.trainable_filter = trainable_filter
        self.order = nn.Parameter(
            torch.tensor(order, dtype=torch.float32),
            requires_grad=trainable_transform,
        )
        if trainable_filter:
            self.filter = TrainableDiagonalFilter(gfrft._eigvals.size(0))
        else:
            self.filter = IdealLowpassFilter(gfrft._eigvals.size(0), cutoff_count)

    def __repr__(self) -> str:
        filter_info = "trainable" if self.trainable_filter else f"cutoff={self.cutoff_count}"
        return f"GFRFTFilter(order={self.order.item()}, filter={filter_info})"

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        out = self.gfrft.gfrft(x, self.order, dim=0)
        out = self.filter(out)
        out = self.gfrft.igfrft(out, self.order, dim=0)
        return out
