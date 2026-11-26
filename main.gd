extends Node
## 智能压缩上下文插件 · local-harness
## 工具：compact_read（取早期原文） / compact_apply（用摘要替换早期消息）
##
## 两步走：模型先读早期原文，自己写一段摘要，再调 apply 把历史改掉。
## 插件本身不调用模型，只做数据操作，所以任何 GGUF 都能配合使用。

func _app() -> Node:
	var ml := Engine.get_main_loop()
	return ml.root.get_node_or_null("/root/App") if ml != null else null


func _chat() -> Dictionary:
	var a := _app()
	if a == null or a.chats.is_empty() or a.current_chat < 0:
		return {}
	return a.chats[a.current_chat]


func run(tool: String, args: Dictionary) -> Dictionary:
	match tool:
		"compact_read":
			return _read(args)
		"compact_apply":
			return _apply(args)
	return {"ok": false, "output": "未知工具：%s" % tool}


func _read(args: Dictionary) -> Dictionary:
	var chat := _chat()
	if chat.is_empty():
		return {"ok": false, "output": "还没有对话"}
	var keep: int = int(args.get("keep", 4))
	var msgs: Array = chat.get("messages", [])
	var cut: int = max(0, msgs.size() - keep * 2)
	if cut <= 0:
		return {"ok": true, "output": "对话还不够长（%d 条），不需要压缩" % msgs.size()}
	var lines: PackedStringArray = []
	for i in cut:
		var m: Dictionary = msgs[i]
		var role: String = "用户" if str(m.get("role", "")) == "user" else "助手"
		var t := str(m.get("content", ""))
		if t.length() > 200:
			t = t.substr(0, 200) + "…"
		lines.append("%d. %s：%s" % [i + 1, role, t])
	return {"ok": true, "output": "这里有 %d 条早期消息，请把它们压缩成一段 200 字以内的摘要，" % cut +
		"然后用 compact_apply 提交：\n" + "\n".join(lines)}


func _apply(args: Dictionary) -> Dictionary:
	var chat := _chat()
	if chat.is_empty():
		return {"ok": false, "output": "还没有对话"}
	var summary := str(args.get("summary", "")).strip_edges()
	if summary == "":
		return {"ok": false, "output": "summary 不能为空"}
	var keep: int = int(args.get("keep", 4))
	var msgs: Array = chat.get("messages", [])
	var cut: int = max(0, msgs.size() - keep * 2)
	if cut <= 0:
		return {"ok": true, "output": "对话还不够长，没有改动"}
	var tail: Array = msgs.slice(cut, msgs.size())
	var head: Array = [{"role": "system", "content": "[早期对话摘要] " + summary}]
	head.append_array(tail)
	chat["messages"] = head
	var a := _app()
	if a != null:
		a.save_current()
	return {"ok": true, "output": "已压缩：%d 条 → %d 条（保留最近 %d 轮原话，早期内容变成一条摘要）" % [
		msgs.size(), head.size(), keep]}
