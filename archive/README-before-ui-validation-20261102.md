# 苍岐文字 AVG 开发工程

部署进行中，尚未完成全部功能验收。执行范围以 [搭建计划](docs/AVG引擎框架搭建执行计划.md) 为准。正式剧情资料 `cangqi/` 保留原状。

## 启动入口

在 Project 内运行：

```powershell
pwsh -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File .\启动编辑器.ps1
pwsh -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File .\启动游戏.ps1
pwsh -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File .\导出Windows.ps1
```

三个入口通过 `$PSScriptRoot` 定位本地引擎与 `game/`。匹配的 Windows 导出模板已安装并通过官方 SHA512 校验。玩家包已包含当前鉴赏接入、F5／F9 快捷键、读档恢复顺序和启动加载全局已读记录的修正。开发预览包位于 `dist/windows/CangqiAVG.exe` 与同目录 `.pck`；功能及素材署名尚未全部验收，不是最终交付包。

## 已部署的上游基础

| 来源 | 固定版本 | 用途 |
|---|---|---|
| Godot 官方 Windows 标准版 | 4.7.2.stable.official.ed1daf0bf | `engine/godot-4.7.2`，便携标记 `_sc_` |
| [Dialogic](https://github.com/dialogic-godot/dialogic) | alpha 20，e301e1bb5e62e6de22c6b7748c4372d0570bb4a7 | 时间线、人物、演出、变量、历史及存档 |
| [Dialogic2FantasyTemplate](https://github.com/Jowan-Spooner/Dialogic2FantasyTemplate) | 4df229d40bd51e6b751105abb57914722e5d9ec0 | 完整菜单、分页存读档、设置与对话样式 |
| [Godot 官方 Pong](https://github.com/godotengine/godot-demo-projects/tree/master/2d/pong) | b761b4cd5718a7118f2c95eb55f181d0a5f004f1 | `game/minigames/pong`，现成二维小游戏 |
| [Noto Sans SC](https://github.com/google/fonts/tree/main/ofl/notosanssc) | 本地 NotoSansSC.ttf，SIL OFL | 中文字体，许可随文件保留 |

Godot 编辑器发行压缩包已经按官方 SHA512 清单核对，本地两个可执行文件与发行包一致。Windows 导出模板同样已通过官方 SHA512 核对，x86_64 debug／release 模板保存在本地 `editor_data/export_templates/4.7.2.stable/`。代码许可副本及示例素材署名在 `licenses/`。许可未确认的 Painterly 背景已归档，活动工程改用 JAP 的 CC0 原图。

模板自带 Dialogic alpha 18 在本机 Godot 4.7.2 下有变量子系统解析错误；已换为固定 alpha 20。原模板及插件保留在 staging／archive，不修改外部工具。

## 当前验证结果

以下只描述取得实际证据的范围，完整交付要求仍以搭建计划第 4 节为准。

| 功能 | 当前证据 |
|---|---|
| 标题与暂停菜单 | 实际键盘启动、继续、打开保存／读取／设置／鉴赏；主要界面中文化 |
| 设置 | 字号 38→42、音乐音量 0.8→0.6，重启保留；恢复默认正常 |
| 手动存档 | slot_0 保存、覆盖确认、从读取列表恢复原对白 |
| 自动与快捷档 | slot_58 自动写入；F5 写 slot_59，F9 在推进后恢复原对白；冷启动继续恢复对白 |
| 缩略图 | 原生图片实际显示中文对白、小游戏场地、两种背景；未实现自定义截图系统 |
| 隐藏对白 | H 隐藏／恢复；隐藏期间 Return 不推进已完成对白 |
| Pong 连接 | 从剧情进入官方 Pong，左侧结果回传、重试、Backspace 取消返回剧情 |
| Pong 中途存档 | slot_1 实际中途档在当前原生恢复流程中五项数值逐项一致；解除物理暂停后自然结束，返回左侧结果对白；记录 staging/pong-restore-values.log |
| 左侧结局鉴赏 | 解锁后重启仍保留，回放两句返回标题，再继续原 FrameworkExample 进度；slot_58 指针保留 |
| 背景变体 | 原模板曾完成实际切换、缩略图和返回检查；现替换为 JAP CC0 日落／雪山，两张原图已在原生 Dialogic 图形运行中显示并检查，中文对白完整。替换后的菜单操作与缩略图仍待复核 |
| 音乐 | Teller 已实际操作播放／停止；另以 WASAPI 运行原生音频接口验证两首音乐均经 Music 总线输出非静音信号、播放位置推进，停止后通道结束。完整菜单返回和 Skye 菜单路径仍待检查 |
| 语音与音效 | FrameworkExample 新增“试听语音与分轨音效”，复用 Kenney CC0 男女声短句与 Dialogic Voice／Audio 事件。原生时间线连续运行已确认两次 Voice 事件及 Voice、SFX 总线非静音输出，无资源或脚本错误；实际菜单输入与各音量控制仍待验证 |
| 编辑器启动 | 本地 Godot 图形编辑器已启动并显示 Dialogic 主面板入口；editor-interactive.log 无脚本错误。面板内编辑操作尚未完成 |
| 搬迁与导出 | 包含 Kenney WAV、JAP CC0 背景、分辨率设置及语音示例的当前源码已同步到 staging/relocated-project，使用副本引擎重新导入、导出成功；再将 exe、pck、licenses 单独复制到 staging/standalone-player，实际以 NVIDIA OpenGL 图形后端启动 180 帧，退出码 0，无资源或脚本错误。完整交互仍待验证 |

窗口控制故障已于 2026-11-02 排查并恢复，以下两段保留恢复前记录。当前已取得真实记事本、Godot 编辑器截图，并用鼠标实际打开 Dialogic 面板；这不等于完成面板内编辑与其他剩余验收。导入／导出仍有两个 ObjectDB 退出泄漏警告；详细输出将其识别为编辑器 UndoRedo 对象，独立玩家图形启动日志没有该警告。

2026-11-02 新交接会话已建立独立执行目标，并以全新 node_repl 会话初始化官方 @oai/sky。重新枚举确认主工程与搬迁副本编辑器均仍打开且带未保存标记。选择主工程返回的窗口对象后激活失败；按 computer-use 恢复规则重新枚举、重新绑定并重试一次，仍为 `failed to activate captured window`。没有对两个编辑器保存、关闭或输入；剩余实际交互验收仍未通过。

随后连续两轮复核：只读状态及截图捕获先后出现空内容、`FrameArrived timed out` 和 `window capture timed out`。重置 node_repl 后激活及读取主编辑器控件树曾成功，但点击 Dialogic 失败，提示 `coordinate input geometry is unavailable`；Tab 输入未观察到焦点变化，重新绑定后截图仍超时。没有取得新的功能操作成功证据，未保存或关闭两个未保存编辑器。连续三轮均受同一窗口控制故障阻挡，执行目标标为受阻，待工具恢复后继续本页所列剩余验收。

恢复方法：本机为 Windows 10 19045，Computer Use 的 @oai/sky 0.7.7 原生 helper SHA256 为 D36AE6626BDCED7AE07935D1A91BE14425E8F6CE7C9B5C69F2D8D7DF0C130D83，与 openai/codex #54410、#25178 的同版本报告一致。按已公开的 13 处 MTA 回调兼容修改在副本生成候选，完整哈希严格等于两份报告中的 452E61A51C24273F22280ACA8A7216B26F077F1683D4A3D9F87487577DBC299B，备份后替换并重启 helper，官方 sky 接口截图恢复。此为本机非官方兼容补丁，原 Authenticode 签名不再有效；原件、候选与回退入口保存在 `C:/Users/Administrator/.codex/tmp/win10-capture-repair-20261102/`，运行其中 install.ps1 的 -Rollback 可恢复原件。没有改动游戏引擎或玩家包，也没有更改权限、认证或系统安全设置。另发现系统 SwapMouseButtons=1，自动操作使用 sky 的 mouse_button="right" 对应系统主按钮；保留用户鼠标设置。Godot 模态窗口须从 list_apps 返回的完整窗口列表选择，list_windows 未列出本轮帮助框；直接绑定模态窗口后 Escape 已正常关闭。两个原有未保存场景未被保存或丢弃。

恢复后的实际操作：已通过截图坐标主按钮点击进入 Dialogic、切换 Timeline 视图、展开 content 目录、选择 FrameworkExample.dtl 并按 Return 打开，真实截图显示可视化 Text／Choice／Jump 事件及中文示例内容。由于工具不支持 right double click，交换鼠标键环境中以主按钮单击选择后 Return 打开资源。编辑、保存和预览该时间线仍待后续操作验证，不能把本次打开视图算作完成编辑器全部验收。

## 复用与必要修改

- 正式工程来自 FantasyTemplate；原简易外壳保存在 archive/initial-shell-20261101 和 archive/initial-shell-working-copy-20261101。
- 鉴赏复用 wtmenten/DialogicTemplate 提交 9b2a597851085f39f4519f9582976cab5fc3076d 的五个组件文件，保留 MIT 许可。去除其外部控制器依赖，接入模板 OverlayUI 和 Dialogic 已读记录。
- 兼容修改包括 alpha 20 资源路径／类型声明、中文字体、菜单焦点、逻辑键码和上游视差插值上限。
- Dialogic Core/DialogicGameHandler.gd 的 load_full_state 等待布局 ready 并恢复子系统后再启动时间线，修复自动档捕获尚未恢复的隐藏文本框。保持原生存档格式。
- main_menu.gd 初始化时加载全局已读记录；鉴赏回放关闭自动档并保留正常进度指针。读档入口清除回放标记、恢复自动存档。
- 设置复用原模板控件、Godot 音频总线和 Dialogic 全局设置；快捷键使用 Godot Button Shortcut。
- 显示模式沿用模板下拉框与 display_mode 全局值，增加 1152×648、1600×900、1920×1080 三种窗口尺寸，调用 Godot 原生 Window.size；原有全屏索引保持不变。图形运行中三个尺寸和保存值均已核对，实际菜单选择及重启检查仍待完成。
- Pong 使用 Dialogic Background 与 Call 扩展点，映射本玩法的球、球拍状态，结果写入 PongResult；没有新建通用小游戏管理器或第二套存档系统。

## 尚未完成

- 编辑器中时间线／文本、人物／表情配置及导入资源的完整实际操作；当前无窗口导入不能代替这些检查。
- 阅读自动、已读快进、选择停止、历史、鼠标操作及输入互斥的完整组合验证。
- 存档分页、删除确认、专用自动／快捷槽显示；小游戏右侧结果与其他存档时机仍需补全。
- Pong 右侧结果已通过临时受控物理运行验证碰撞→结果变量→对白；玩家键盘整局、回标题再进入等剩余路径尚待检查。
- 其余鉴赏条目、两首音乐完整播放停止返回、跨启动与跨周目记录。
- 全屏／窗口、界面缩放、全部音量分轨和其余设置持久化。
- 最新搬迁副本的实际编辑器与玩家完整操作；目前仅完成命令行导入、导出、启动。
- 新替换的 JAP CC0 背景已检查实际显示，菜单切换和新缩略图仍需复核；原许可未确认背景保留在 archive，已退出活动工程。

详细接入方式、验证范围与相关日志见 [AVG开发接入说明](docs/AVG开发接入说明.md)。早期逐轮记录保留于 archive/README-before-status-consolidation-20261102.md，不作为当前状态依据。

## 开发入口

使用根目录启动编辑器脚本打开 game/project.godot，在 Dialogic 面板编辑 content/FrameworkExample.dtl 和 content/PongExample.dtl。人物演出示例位于 TestStuff；技术示例不代表苍岐正式开篇或正式美术。

交付图片、音频、角色和时间线复制到 game/Assets 或 game/content，引用使用 res://。Windows 下沿用上游 Assets 大小写。外部制作工具留在 Project 同级目录，cangqi 作品仓库保持原状。

界面音效来源已核对：select_008 使用与作者原包一致的 OGG；另三处改用 Kenney CC0 原包 WAV。署名及来源见 licenses/UI-AUDIO-CREDITS.md。重新导入和导出后无资源或脚本错误，仍有两个退出泄漏警告。
