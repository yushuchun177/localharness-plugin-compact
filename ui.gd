extends VBoxContainer
## 智能压缩上下文 —— 这个页面是插件自己提供的界面。
## 界面全部由插件自己拼，主程序只提供积木。

func build(plugin_id: String) -> void:
	add_theme_constant_override("separation", 12)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var app: Node = Engine.get_main_loop().root.get_node_or_null("/root/App")
	var msgs: int = 0
	var est: int = 0
	if app != null and app.chats.size() > 0:
		var chat: Dictionary = app.chats[app.current_chat]
		var arr: Array = chat.get("messages", [])
		msgs = arr.size()
		for m in arr:
			est += int(str(m.get("content", "")).length() / 1.5)

	add_child(PluginUI.section("现在的情况"))
	add_child(PluginUI.stats_row([
		{"label": "消息条数", "value": str(msgs)},
		{"label": "估算占用", "value": "%d 字" % est},
		{"label": "压缩阈值", "value": str(PluginPrefs.get_value(plugin_id, "trigger", "85")) + "%"},
	]))

	add_child(PluginUI.section("什么时候自动压缩"))
	add_child(PluginUI.choice_row(plugin_id, "trigger", "触发条件",
		[{"value": "off", "label": "不自动，只手动"},
		 {"value": "50", "label": "上下文用到 50%"},
		 {"value": "70", "label": "上下文用到 70%"},
		 {"value": "85", "label": "上下文用到 85%（推荐）"}],
		"85", "平时不用管；到了阈值助手会先把早期内容压成摘要"))
	add_child(PluginUI.slider_row(plugin_id, "keep", "最近几轮保留原话", 1, 12, 1, "轮", 4,
		"越少越省空间，但最近聊的内容也可能被压缩进去"))
	add_child(PluginUI.choice_row(plugin_id, "style", "摘要详细程度",
		[{"value": "short", "label": "简短（一句话）"},
		 {"value": "mid", "label": "适中（要点列表）"},
		 {"value": "long", "label": "详细（保留细节）"}],
		"mid", ""))

	add_child(PluginUI.section("现在就压"))
	add_child(PluginUI.action_row("立刻压缩当前对话",
		"把早期消息换成一段要点摘要，立刻生效（可在对话里看到结果）",
		"现在压缩", func(): return _do_compact(plugin_id)))
	add_child(PluginUI.overview(plugin_id))
	add_child(PluginUI.permissions_section(plugin_id))
	add_child(PluginUI.doc_section(plugin_id))


## 用规则生成摘要（不调用模型，点了就有结果）
func _do_compact(plugin_id: String) -> Dictionary:
	var app: Node = Engine.get_main_loop().root.get_node_or_null("/root/App")
	if app == null or app.chats.size() == 0:
		return {"ok": false, "output": "还没有对话"}
	var chat: Dictionary = app.chats[app.current_chat]
	var msgs: Array = chat.get("messages", [])
	var keep: int = int(PluginPrefs.get_value(plugin_id, "keep", 4))
	var cut: int = maxi(0, msgs.size() - keep * 2)
	if cut <= 0:
		return {"ok": false, "output": "对话还不够长（%d 条），不用压缩" % msgs.size()}
	var style := str(PluginPrefs.get_value(plugin_id, "style", "mid"))
	var limit := 60 if style == "short" else (120 if style == "mid" else 220)
	var lines: PackedStringArray = []
	for i in cut:
		var m: Dictionary = msgs[i]
		var who := "用户" if str(m.get("role", "")) == "user" else "助手"
		var t := str(m.get("content", "")).strip_edges().replace("\n", " ")
		if t == "":
			continue
		if t.length() > limit:
			t = t.substr(0, limit) + "…"
		lines.append("- %s：%s" % [who, t])
	var summary := "\n".join(lines)
	var head: Array = [{"role": "system", "content": "[早期对话摘要]\n" + summary}]
	var tail: Array = msgs.slice(cut, msgs.size())
	head.append_array(tail)
	chat["messages"] = head
	app.save_current()
	return {"ok": true, "output": "已压缩：%d 条 → %d 条（保留最近 %d 轮原话）" % [msgs.size(), head.size(), keep]}
