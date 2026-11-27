# 智能压缩上下文 / Smart compaction

把较早的对话压成一条摘要，腾出上下文空间；摘要由模型自己写，插件负责安全地改历史。

Replace early history with one summary to free context; the model writes the summary, the plugin rewrites history safely.

> Local-Harness（Godot 版）的独立插件。不随主程序发布，由主程序
> 「设置 → 插件管理」从 GitHub 下载并自动部署到 `user://plugins/compact/`。

## 安装

1. 打开 Local-Harness → 设置 → 插件管理 → 刷新列表
2. 找到「智能压缩上下文」点「安装」
3. 装好后在侧栏底部点同名按钮，里面是这个插件自己的设置页

手动安装：把本仓库下载解压到 `%LOCALAPPDATA%\Godot\app_userdata\Local-Harness\plugins\compact\`

## 工具

- `compact_read` —— 取出「最近 N 轮之前」的对话原文，供你写摘要用。N 默认 4。（只读）
  - `keep`: int，可选，保留最近几轮，默认 4
- `compact_apply` —— 把摘要写进历史：用一条摘要替换掉较早的消息，只保留最近 N 轮原话。（高危）
  - `summary`: string，你写的摘要
  - `keep`: int，可选，默认 4

## 命令

（没有命令）

## 设置项

- **自动压缩阈值**（`trigger`，默认 `85`）上下文用到多少时自动压缩，off = 只手动
- **保留最近轮数**（`keep`，默认 `4`）
- **摘要详细程度**（`style`，默认 `mid`）short / mid / long

## 权限

每个工具都能在插件设置页里单独开关。关掉之后它不会出现在模型的工具清单里，
就算模型硬要调用也会被主程序拒绝。协议里用 `level` 标了风险等级：

- `read` 只读：不会改动任何东西
- `act` 会产生操作：会读写文件、联网或占用设备
- `danger` 高危：会操作你的系统

## 怎么用

装好后直接在对话里提需求，例如：“取出「最近 N 轮之前」的对话原文，供你写摘要用。N 默认 4。”

模型会输出一行 ```tool 协议块，宿主解析后执行，再把结果喂回模型。
也可以直接用斜杠命令，不经过模型。

## 许可

GPL-3.0（与主程序一致）。完整协议文本见仓库根目录的 [LICENSE](LICENSE)。

---

# Smart compaction

Replace early history with one summary to free context; the model writes the summary, the plugin rewrites history safely.

> An independent plugin for **Local-Harness (Godot edition)**. It is not bundled with the
> app; the app downloads it from this repository into `user://plugins/compact/` and hot-loads it.

## Install

1. Local-Harness → Settings → Plugins → Refresh
2. Find "Smart compaction" and click Install
3. Open it from the button at the bottom of the sidebar for its own settings page

Manual: unzip this repo into `%LOCALAPPDATA%\Godot\app_userdata\Local-Harness\plugins\compact\`

## Tools

- `compact_read` — 取出「最近 N 轮之前」的对话原文，供你写摘要用。N 默认 4。 (read-only)
  - `keep`: int，可选，保留最近几轮，默认 4
- `compact_apply` — 把摘要写进历史：用一条摘要替换掉较早的消息，只保留最近 N 轮原话。 (dangerous)
  - `summary`: string，你写的摘要
  - `keep`: int，可选，默认 4

## Commands

(no commands)

## Settings

- **自动压缩阈值** (`trigger`, default `85`) 上下文用到多少时自动压缩，off = 只手动
- **保留最近轮数** (`keep`, default `4`) 
- **摘要详细程度** (`style`, default `mid`) short / mid / long

## Permissions

Every tool can be toggled individually on the plugin settings page. A disabled tool is
removed from the model's tool list and rejected by the host even if the model still calls it.
`level` in the manifest marks the risk:

- `read` — no side effects
- `act` — reads/writes, network or devices
- `danger` — controls your system

## Usage

Just ask in the chat, e.g. “取出「最近 N 轮之前」的对话原文，供你写摘要用。N 默认 4。”

The model emits a ```tool block, the host executes it and feeds the result back.
You can also use the slash commands above, which skip the model entirely.

## License

GPL-3.0 (same as the host app). Full text: [LICENSE](LICENSE).
