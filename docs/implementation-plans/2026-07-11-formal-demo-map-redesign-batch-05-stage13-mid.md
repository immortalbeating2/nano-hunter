# Formal Demo Map Redesign Batch 05 - Stage13 Mid

## 目标

把 Stage13 Gate、Crossfire、Checkpoint、Pressure 四房从同规格单层模板重做为职责明确的连续中段，并补齐反向连接、安全出生点和房间级运行态验收。

## 房间蓝图

- Gate `22x9`：两级上行触发镇妖印，再返回下层通过封印门。
- Crossfire `26x10`：三层平台与两名远程敌形成交叉火力 arena。
- Checkpoint `18x8`：连续安全地面、可见恢复点和单个观察平台，承担降压缓冲。
- Pressure `24x9`：地面瘴气危险、上层明确绕行和右侧远程压制。

## 关键改动

- 四房改用显式 64px 蓝图生成正式 TileMap collision / surface，旧 Floor / Wall 与随机 decor 退出运行态。
- 补齐 previous room、previous spawn、LeftExitZone、start / return spawn 和独立相机边界。
- Gate 的纯逻辑 `SealNode` 复用现有 `talisman_stake_idle` AtlasTexture，玩家现在能看见解门目标。
- Checkpoint 首轮截图出现背景空白边，拒绝签收后扩大背景覆盖再复核。
- `miasma_marsh_tileset_ai01` 继续只作隐藏来源引用；本批无新增 Image Gen。

## 验证

- Batch5 `4/4` tests，`197` asserts。
- Stage13 `13/13` / `355` asserts；manual closure `1/1` / `22` asserts。
- Stage14 `16/16` / `389` asserts；Stage16 `20/20` / `529` asserts；formal remap `8/8` / `184` asserts。
- 七张运行态截图报告 `ok=true`，覆盖锁门、符印激活、门前安全区、交叉火力、checkpoint、危险路和绕行平台。
- Godot import 与目标文件 `git diff --check` 通过。

## 下一步

继续 Stage13 Branch Hub、Resource Branch、Challenge Branch、Return、Goal 五房，完成瘴泽区域剩余支路、回环和区域终点。
