# 智能压缩上下文 / Smart compaction

把较早的对话压成一条摘要，腾出上下文空间；摘要由模型自己写，插件负责安全地改历史。

Replace early history with one summary to free context; the model writes the summary, the plugin rewrites history safely.

Local-Harness（Godot 版）的独立插件。**不随主程序发布**，由主程序「设置 → 插件管理」从 GitHub 下载并自动部署到 `user://plugins/compact/`。

## 工具

- `compact_read` —— 取出「最近 N 轮之前」的对话原文，供你写摘要用。N 默认 4。
  - `keep`: int，可选，保留最近几轮，默认 4
- `compact_apply` —— 把摘要写进历史：用一条摘要替换掉较早的消息，只保留最近 N 轮原话。
  - `summary`: string，你写的摘要
  - `keep`: int，可选，默认 4

## 安装

1. Local-Harness → 设置 → 插件管理 → 刷新列表
2. 找到「智能压缩上下文」点安装
3. 装完直接在对话里让模型调用（插件会出现在系统提示的工具清单里）

手动安装：把仓库解压到 `%LOCALAPPDATA%\Godot\app_userdata\Local-Harness\plugins\compact\`。

## 结构

```
manifest.json   清单：id / 版本 / 工具定义
main.gd         extends Node，实现 run(tool, args) -> {ok, output}
```

## 许可

GPL-3.0（与主程序一致）。
