#!/usr/bin/env python3
"""审计 v5 一体化 HUD 的尺寸、透明边缘与色键残留。"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
ASSET_ROOT = ROOT / "assets/art/ui/hud_warden_integrated_v5"
ALPHA_VISIBLE_THRESHOLD = 8
ALPHA_OPAQUE_THRESHOLD = 247
MAX_SEMI_RATIO = 0.28
MAX_VISIBLE_RATIO_ERROR = 0.10
MAX_GREEN_RESIDUE_RATIO = 0.001


@dataclass(frozen=True)
class FrameContract:
    filename: str
    size: tuple[int, int]

    @property
    def ratio(self) -> float:
        return self.size[0] / self.size[1]


CONTRACTS = (
    FrameContract("battle_frame_integrated_warden_ai01.png", (1080, 400)),
    FrameContract("battle_frame_integrated_warden_expanded_ai01.png", (760, 400)),
    FrameContract("tutorial_frame_integrated_warden_ai01.png", (1404, 360)),
    FrameContract("element_frame_integrated_warden_ai01.png", (1012, 400)),
)


def _visible_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    alpha = image.getchannel("A")
    mask = alpha.point(lambda value: 255 if value > ALPHA_VISIBLE_THRESHOLD else 0)
    return mask.getbbox()


def _audit(contract: FrameContract) -> list[str]:
    failures: list[str] = []
    path = ASSET_ROOT / contract.filename
    if not path.is_file():
        return [f"missing runtime PNG: {path.relative_to(ROOT)}"]

    with Image.open(path) as opened:
        image = opened.convert("RGBA")

    if image.size != contract.size:
        failures.append(f"size={image.size}, expected={contract.size}")

    alpha_values = list(image.getchannel("A").get_flattened_data())
    if not alpha_values or min(alpha_values) != 0 or max(alpha_values) < ALPHA_OPAQUE_THRESHOLD:
        failures.append("alpha must contain fully transparent and substantially opaque pixels")

    corners = (
        image.getpixel((0, 0))[3],
        image.getpixel((image.width - 1, 0))[3],
        image.getpixel((0, image.height - 1))[3],
        image.getpixel((image.width - 1, image.height - 1))[3],
    )
    if any(value > ALPHA_VISIBLE_THRESHOLD for value in corners):
        failures.append(f"transparent canvas corners required, got alpha={corners}")

    bbox = _visible_bbox(image)
    if bbox is None:
        failures.append("no visible frame pixels")
        return failures
    visible_ratio = (bbox[2] - bbox[0]) / (bbox[3] - bbox[1])
    visible_ratio_error = abs(visible_ratio - contract.ratio) / contract.ratio
    if visible_ratio_error > MAX_VISIBLE_RATIO_ERROR:
        failures.append(
            f"visible frame ratio={visible_ratio:.3f}, canvas ratio={contract.ratio:.3f}, "
            f"relative error={visible_ratio_error:.3f}"
        )

    visible_count = sum(value > ALPHA_VISIBLE_THRESHOLD for value in alpha_values)
    semi_count = sum(
        ALPHA_VISIBLE_THRESHOLD < value < ALPHA_OPAQUE_THRESHOLD for value in alpha_values
    )
    semi_ratio = semi_count / max(1, visible_count)
    if semi_ratio > MAX_SEMI_RATIO:
        failures.append(f"semi-transparent ratio={semi_ratio:.3f} exceeds {MAX_SEMI_RATIO:.3f}")

    green_residue = 0
    for red, green, blue, alpha in image.get_flattened_data():
        if (
            alpha > ALPHA_VISIBLE_THRESHOLD
            and green > 160
            and green > red + 60
            and green > blue + 60
        ):
            green_residue += 1
    green_ratio = green_residue / max(1, visible_count)
    if green_ratio > MAX_GREEN_RESIDUE_RATIO:
        failures.append(
            f"green-key residue ratio={green_ratio:.5f} exceeds {MAX_GREEN_RESIDUE_RATIO:.5f}"
        )

    if not failures:
        print(
            f"PASS {contract.filename}: size={image.size} visible_ratio={visible_ratio:.3f} "
            f"semi_ratio={semi_ratio:.3f} green_residue_ratio={green_ratio:.5f}"
        )
    return failures


def main() -> int:
    failure_count = 0
    for contract in CONTRACTS:
        failures = _audit(contract)
        for failure in failures:
            print(f"FAIL {contract.filename}: {failure}")
            failure_count += 1
    if failure_count:
        print(f"HUD integrated frame alpha audit failed: failures={failure_count}")
        return 1
    print(f"HUD integrated frame alpha audit passed: assets={len(CONTRACTS)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
