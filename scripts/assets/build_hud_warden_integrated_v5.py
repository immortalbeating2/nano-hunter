#!/usr/bin/env python3
"""构建 02 镇妖官印 v5 一体化 HUD 运行图。

本脚本只消费官方去色键工具生成的 RGBA 候选，执行 alpha 裁切、一次等比缩小
和透明画布居中；不重绘、不分件拼装，也不改变官印和装饰的宽高比。
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
ALPHA_ROOT = ROOT / "tests/artifacts/local/hud-warden-integrated-v5/alpha"
OUTPUT_ROOT = ROOT / "assets/art/ui/hud_warden_integrated_v5"
ALPHA_CROP_THRESHOLD = 8
CANVAS_PADDING = 2


@dataclass(frozen=True)
class FrameBuild:
    alpha_name: str
    output_name: str
    target_size: tuple[int, int]


BUILDS = (
    FrameBuild(
        alpha_name="battle_alpha.png",
        output_name="battle_frame_integrated_warden_ai01.png",
        target_size=(1080, 400),
    ),
    FrameBuild(
        alpha_name="battle_expanded_alpha.png",
        output_name="battle_frame_integrated_warden_expanded_ai01.png",
        target_size=(760, 400),
    ),
    FrameBuild(
        alpha_name="tutorial_alpha.png",
        output_name="tutorial_frame_integrated_warden_ai01.png",
        target_size=(1404, 360),
    ),
    FrameBuild(
        alpha_name="element_alpha.png",
        output_name="element_frame_integrated_warden_ai01.png",
        target_size=(1012, 400),
    ),
)


def _visible_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    alpha = image.getchannel("A")
    mask = alpha.point(lambda value: 255 if value > ALPHA_CROP_THRESHOLD else 0)
    bbox = mask.getbbox()
    if bbox is None:
        raise ValueError("RGBA candidate has no visible pixels")
    return bbox


def _fit_without_distortion(image: Image.Image, target_size: tuple[int, int]) -> Image.Image:
    cropped = image.crop(_visible_bbox(image))
    available_width = target_size[0] - CANVAS_PADDING * 2
    available_height = target_size[1] - CANVAS_PADDING * 2
    scale = min(available_width / cropped.width, available_height / cropped.height)
    resized_size = (
        max(1, round(cropped.width * scale)),
        max(1, round(cropped.height * scale)),
    )
    resized = cropped.resize(resized_size, Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", target_size, (0, 0, 0, 0))
    offset = (
        (target_size[0] - resized.width) // 2,
        (target_size[1] - resized.height) // 2,
    )
    canvas.alpha_composite(resized, offset)
    return canvas


def main() -> int:
    OUTPUT_ROOT.mkdir(parents=True, exist_ok=True)
    for build in BUILDS:
        alpha_path = ALPHA_ROOT / build.alpha_name
        if not alpha_path.is_file():
            raise FileNotFoundError(
                f"Missing alpha candidate: {alpha_path}. Run the official remove_chroma_key.py first."
            )
        with Image.open(alpha_path) as opened:
            output = _fit_without_distortion(opened.convert("RGBA"), build.target_size)
        output_path = OUTPUT_ROOT / build.output_name
        output.save(output_path, format="PNG", optimize=True)
        bbox = _visible_bbox(output)
        visible_ratio = (bbox[2] - bbox[0]) / (bbox[3] - bbox[1])
        print(
            f"Wrote {output_path.relative_to(ROOT)} size={output.size} "
            f"visible_bbox={bbox} visible_ratio={visible_ratio:.3f}"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
