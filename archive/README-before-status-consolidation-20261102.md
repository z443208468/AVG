# 苍岐文字 AVG 开发工程

部署进行中，尚未完成全部功能验收。执行范围以 [搭建计划](docs/AVG引擎框架搭建执行计划.md) 为准。正式剧情资料 `cangqi/` 保留原状。

## 启动入口

在 Project 内运行：

```powershell
pwsh -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File .\启动编辑器.ps1
pwsh -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File .\启动游戏.ps1
pwsh -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File .\导出Windows.ps1
```

三个入口通过 `$PSScriptRoot` 定位本地引擎与 `game/`。匹配的 Windows 导出模板已安装并通过官方 SHA512 校验。玩家包已更新到包含鉴赏接入、继续游戏指针修正及 H 键隐藏对白的当前源码。开发预览包位于 `dist/windows/CangqiAVG.exe` 与同目录 `.pck`；功能及素材署名尚未全部验收，不是最终交付包。

## 已部署的上游基础

| 来源 | 固定版本 | 用途 |
|---|---|---|
| Godot 官方 Windows 标准版 | 4.7.2.stable.official.ed1daf0bf | `engine/godot-4.7.2`，便携标记 `_sc_` |
| [Dialogic](https://github.com/dialogic-godot/dialogic) | alpha 20，e301e1bb5e62e6de22c6b7748c4372d0570bb4a7 | 时间线、人物、演出、变量、历史及存档 |
| [Dialogic2FantasyTemplate](https://github.com/Jowan-Spooner/Dialogic2FantasyTemplate) | 4df229d40bd51e6b751105abb57914722e5d9ec0 | 完整菜单、分页存读档、设置与对话样式 |
| [Godot 官方 Pong](https://github.com/godotengine/godot-demo-projects/tree/master/2d/pong) | b761b4cd5718a7118f2c95eb55f181d0a5f004f1 | `game/minigames/pong`，现成二维小游戏 |
| [Noto Sans SC](https://github.com/google/fonts/tree/main/ofl/notosanssc) | 本地 NotoSansSC.ttf，SIL OFL | 中文字体，许可随文件保留 |

Godot 编辑器发行压缩包已经按官方 SHA512 清单核对，本地两个可执行文件与发行包一致。Windows 导出模板同样已通过官方 SHA512 核对，x86_64 debug／release 模板保存在本地 `editor_data/export_templates/4.7.2.stable/`。代码许可副本及两首示例音乐署名在 `licenses/`；模板图片、音频及原字体的各自许可尚待补全，当前不是已完成署名的发行包。

模板自带 Dialogic alpha 18 在本机 Godot 4.7.2 下有变量子系统解析错误；已换为固定 alpha 20。原模板及插件保留在 staging／archive，不修改外部工具。

## 本轮已落地与验证范围

- 原简易外壳归档于 `archive/initial-shell-20261101` 和 `archive/initial-shell-working-copy-20261101`。
- `game/` 使用 FantasyTemplate 原菜单与样式，不再使用旧翻页器。
- 已配置本地中文字体、主要静态菜单文字、独立游戏名称和基于资源路径的 Dialogic autoload。
- 主菜单实际使用 OpenGL 渲染，已修正中文标题重叠。画面为上游模板技术主题，非苍岐正式美术。
- 正式工程无窗口运行 120 帧无脚本错误；再次导入没有资源／解析错误。编辑器退出仍有上游 2 个 ObjectDB 实例未释放警告，导出时为 5 个，尚未定位。
- `content/FrameworkExample.dtl` 提供中文入口、上游演出示例和 Pong 选项；`PongExample.dtl` 提供结果分支与重试。
- Pong 已通过 Dialogic 自带时间线预览运行 900 帧，无脚本错误，首帧实际渲染显示场地、球拍和说明。尚未以玩家操作证明完整往返与保存恢复。
- Windows UI 捕获返回 `FrameArrived timed out`，重选时目标窗口消失。后续无截图的 UI Automation 能读取标题栏，但不能读取游戏内部控件。没有将界面操作和冷启动恢复标记通过。

## 必要兼容与连接修改

- `project.godot`：插件替换后的本地 autoload 路径、项目名称、官方 Pong 输入映射、示例时间线及变量。
- `DialogicFantasyMenu`／`DialogicFantasyStyle` 场景：原字体替换为本地 Noto Sans SC，静态文字中文化，标题字号调整。`Assets/Fonts/NotoSansSC-Regular.tres` 是 Godot 原生字体资源。
- `DialogicFantasyMenu/main_menu.gd`：默认开始时间线改为 FrameworkExample；菜单逻辑沿用上游。
- `minigames/pong/pong.tscn`：资源路径加目录前缀，去掉原项目 UID；四个玩法脚本保持上游版本。
- `integration/pong_background.gd`：继承 DialogicBackground，用 `_get_state`／`_load_state` 映射球位置、方向、速度及球拍位置；状态仍由 Dialogic 同一份进度保存。连接原墙体信号回传胜负，并提供 Backspace 取消。
- `integration/example_bridge.gd`：用 Dialogic Call 事件等待 Pong 结果，写回 PongResult 变量并恢复文本框。没有新增通用小游戏管理器或存档文件格式。

- `addons/dialogic_gallery` 兼容修改：画廊继承模板 OverlayUI_Tab；移除原项目 SceneManager／GameController 依赖，转发上游卡片 pressed 信号；替换资源路径；释放上游临时测宽卡片；卡片增加键盘确认与焦点。未引入第二个剧情引擎。
- `main_menu.gd`：连接鉴赏打开／选中事件；GAME_END 时调用 Dialogic 原生已读记录保存接口。

- 存档配置与接线：自动档使用 Dialogic 原生文字事件触发；原分页 UI 保留，最后两槽用于自动／快捷；模板 `Save.saved` 信号填写展示元数据。鉴赏回放期间关闭自动档，开始／继续／读取进度时恢复。动态覆盖、删除、返回标题提示已中文化。

- 音量控件：原 MusicVolume 场景块和处理函数分别配置为 Master／Voice，继续用 Dialogic 全局设置持久化；新增 Godot Voice 音频总线。没有新增音频管理系统。

- 音乐／结局接入只增加原生 `.dtl` 和 TimelineMeta 数据，不新增播放器或解锁管理器。音乐预览从 Audio 事件运行，录制 WAV 有非零音频输出，60 FPS 下播放／停止选项渲染正常；强制退出预览仍有资源未释放提示。
- 修正模板一条旧 Helpers 资源路径，并将上游视差插值权重限制到 1：2 FPS 录制已复现插值外推导致按钮跑出边缘，正常 60 FPS 无此布局问题。

- 无缓存导入兼容修补：Glossary 的 meta_info 与存档卡片的 info 标为 Dictionary，菜单存档位置 location 标为 String。三处修改均对应迁移测试中的实际解析错误。
- 许可补充：Godot 4.7.2 官方 LICENSE／COPYRIGHT、GUI 作者授权来源、Dialogic 自带打字音效许可。TestStuff 角色／背景及模板按钮音效的来源仍待核实。

- 实际键盘运行进展：以 Godot `--accessibility always` 启动后可读取主菜单及选择按钮，Return 开始、方向键选择 Pong、推进对白进入场地，随后返回结果对白。自动档已实际生成 state.txt／info.txt／thumbnail.png，位置字段为 PongExample。
- 本次完整往返暴露 Pong 胜负信号中的物理回调限制：已将场景停用和结果回传移到 deferred 调用，避免在碰撞回调中停用 CollisionObject；修正后仍需重跑该路径。
- Windows 操作限制细化：鼠标点击报 coordinate input geometry is unavailable；键盘可以驱动部分流程，但暂停后 UIA 树未可靠更新。不能把冷启动读取或菜单操作全部标为通过。

- 冷启动实测（范围限定）：终止原游戏进程并重新启动，标题出现并聚焦“继续游戏”；按 Return 后恢复到“左侧获胜。结果已…”对白，位置为 PongExample。证明本次小游戏结束后的自动档可跨进程恢复；尚未证明小游戏进行中的球／球拍状态恢复，也未替代手动槽和快捷槽检查。

- 暂停输入问题已定位并部分验证：原模板 Esc／Tab 使用 physical_keycode，当前输入注入无法触发；改为 keycode 后，实际 UIA 树出现暂停／读档／保存／历史／设置按钮。菜单初始焦点缺失另已补到现有标签按钮和确认框，待重启复测。运行画面已确认先前 Esc 未生效并非纯观测故障。

- 手动存档与覆盖已实测：重启后 Continue → Esc → Tab 导航到保存标签 → 首槽保存；UI 显示“存档 1 · PongExample”及时间，日志写入 slot_0。再次选择同槽出现中文覆盖／取消框，焦点位于覆盖按钮，确认后再次写入 slot_0。暂停标签与确认框的初始焦点修正有效。
- 本次关闭菜单后 UIA 返回空 accessibility，重新选择窗口仍为空；游戏进程继续运行且无新错误。手动槽读取、删除与小游戏中存档仍未通过本次检查，不能从写入成功推断读取成功。

## 仍需完成

重试／取消实测：结果页用方向键明确选择“再玩一次”，推进说明后重新出现 Pong 场地。原 physical_keycode 取消检查未得到 cancel 结果；现改用 Godot InputMap 的 cancel_minigame 动作（Backspace）。重新导入／导出、重启后重复重试并按 Backspace，场地退出，原生自动档中的 PongResult 为 cancel，运行日志无脚本错误。两条路径已取得实际键盘和存档证据；右侧胜利、完整设置与鉴赏回放仍待验证。

小游戏中途冷启动实测取得进展：从 FrameworkExample 选择 Pong，推进两页说明进入场地，Esc 暂停，再通过保存页写入 slot_1（界面“存档 2 · PongExample”）。原生缩略图显示场地、球和球拍，确认不是结果对白存档。终止游戏进程后重新启动，Continue 恢复到 Pong 场景；随后自然结束并回到包含“再玩一次／返回示例选单／记录结局”的剧情选项，运行日志无脚本错误并产生自动档。证明中途档可跨进程恢复并继续返回剧情；球与球拍数值的逐项一致性、右侧胜利及取消仍未完成验证。slot_1 保留用于后续读取复核。

输入与快进配置核对：Return、Space、X 都已映射到 dialogic_default_action；“遇到未读文字停止快进”默认开启，调用的是 Dialogic.auto_skip.disable_on_unread_text，并非开启跳过未读。无需反转该设置。本次回放复测中窗口先处于最小化，恢复后焦点在两次读取间出现额外变化，未将此次不稳定观测作为回放返回验证通过的证据。

回放启动顺序已修正：先隐藏标题，再等待模板关闭动画完成、解除 SceneTree 暂停，最后启动 Dialogic；避免原 close() 重开标题而清除 gallery_replay。重新导入导出通过，重启实际进入左侧结局，可推进到第二句。结束回放时又观察到空格穿透并进入 FrameworkExample，已在 GAME_END 消费当前输入并延迟打开标题，此项修正尚需重启复测，不能计作完整回放通过。

鉴赏冷启动发现并修复了真实解锁错误：上游卡片固定查询事件 0，但本工程事件 0 是背景，Dialogic 只记录文字／选择的已读状态。卡片改为经 Dialogic 原生解析定位第一条文字事件；刷新条件改为文字事件类型。修改后重新启动并进入鉴赏，左侧结局已解锁，右侧及其余未读条目仍显示“未解锁”，焦点落在左侧卡片。按 Return 已进入阅读布局，但本次 UIA 未取得完整回放对白，完整回放返回与原继续指针保持仍未验证。该修正已包含在重新导出的包中。

鉴赏实测与修补：从 Pong 结果实际进入 EndingLeft（通过自动档时间线路径确认），推进结局对白后返回标题，随后用方向键打开鉴赏，UIA 列出六张卡片。发现焦点仍停留在标题按钮；现已在卡片构建后延迟聚焦首个已解锁条目（全锁时首卡），将现有悬停动画连接键盘焦点，并补“未解锁”文字和确认输入消费。导入／导出通过；修改后的卡片回放与冷启动解锁仍待实测。本次不能算作“再玩一次”通过，因为实际跳转的是结局记录。

存档页连接补齐：所有空槽显示编号，最后两槽明确标为自动／快捷；保存页禁用这两槽的手动覆盖，读取页保持可读。已有档位的删除按钮常显并允许键盘聚焦，仍使用上游删除确认框。此前删除按钮仅鼠标悬停可见，键盘无法选到。完整导入／导出通过，实际第 15 页显示、读取和键盘删除仍待验证。

制作人员页已替换上游英文占位提示，列明 Godot、Dialogic、FantasyTemplate、Skolaztika、鉴赏组件、官方 Pong、中文字体及两首音乐署名。导出规则排除未被场景／资源／脚本引用的 CaslonAntique、MorrisRomanAlternate 字体及编辑器 `.tmp` 文件，源码保留原件。重新导出通过，PCK 中两个旧字体名称不再出现，NotoSansSC 仍在；人物、背景、界面音效的许可核对仍未完成。

H 键键盘实测：重新启动当前源码，继续游戏恢复到 Pong 结果对白；按 H 后 UIA 中对白及七个底部按钮消失，隐藏期间按 Return，再按 H 恢复后仍是同一句结果对白。证明该路径可隐藏、恢复且不漏推进输入。Windows 截图仍报 FrameArrived timed out，画面外观未据此宣称通过。随后推进到结果选项并打开暂停菜单，帮助页中文和 H 键说明可读取；小游戏进行中保存尚未取得证据。

阅读界面连接：对白显示完毕、等待推进时，H 隐藏／恢复模板文本框和底部按钮，隐藏期间使用 Dialogic.paused 暂停推进；打开覆盖菜单时恢复。帮助页四个剩余英文标题已中文化并写明 H 操作。完整导入发现并修正了 DialogicLayoutLayer 基类为 Node 导致的直接可见性调用解析错误；重新导入／导出成功，只剩 2 个 ObjectDB 退出警告。H 键、自动推进暂停及菜单恢复尚待实际交互验证。

鉴赏结束连接修正：`main_menu.gd` 现在区分鉴赏回放与正常剧情结束，鉴赏的 GAME_END 不再清空原进度的“继续游戏”指针；打开标题时重置回放标记。修改后主场景无窗口运行 120 帧退出码 0，无脚本错误。尚需实际完成一次鉴赏回放并点击“继续游戏”核对恢复位置。

1. Windows 预览包已导出，原目录及复制到 `staging/standalone-preview` 后均无窗口运行 120 帧、退出码 0。另已复制 engine／game／入口脚本／文档／许可到 `staging/relocated-project`，排除 `.godot` 缓存。首次导入发现三处类型推断问题，补明确类型后再次无缓存导入及导出成功；该路径的工程与玩家包均启动 120 帧、退出码 0。实际编辑器操作及完整玩家操作循环仍待验证。
2. 核对主菜单／暂停菜单实际交互、键盘输入互斥、中文设置与动态提示。
3. 已从 `staging/DialogicTemplate`（wtmenten，9b2a597851085f39f4519f9582976cab5fc3076d）引入五个时间线鉴赏组件文件，位于 `game/addons/dialogic_gallery`，附 MIT 许可。标题入口连接模板 OverlayUI；提供人物演出／背景变体两张卡片，解锁沿用 Dialogic 已读记录。导入及主场景 120 帧运行无脚本错误；卡片点击、键盘操作、跨启动解锁尚待实际验证，音乐与结局条目已经配置：MusicTeller／MusicSkye 使用 Dialogic 原生 Audio 与 Choice 事件提供播放、停止、返回；EndingLeft／EndingRight 由 Pong 结果分支进入，使用同一已读卡片记录解锁。完整点击、跨启动持久化仍待验证。备选 `staging/godot-vn-engine` 尚未采用，不能将候选能力计为本工程已有。
4. 自动档已配置为 Dialogic 原生 ON_TEXT_EVENT 模式（slot_58），快捷存读档改为独立 slot_59；两者位于现有第15页。通过 Save.saved 接入模板名称／日期／时间线位置元信息，覆盖和删除仍用原有确认框。主场景导入、启动无脚本错误；自动触发、缩略图、元信息与冷启动读取仍待实际验证。主／语音音量已经复用模板 MusicVolume 控件及保存回调接入，新增 Voice 总线并调用 Dialogic.Voice.set_bus；启动无脚本错误，实际音量变化与重启保留待验证。对白字号已接入 Dialogic.Settings 的持久化及变更通知，字号应用复用 Dialogic 默认文本框代码；恢复默认按钮调用现有设置回调。导入与主场景启动通过，实际显示布局、操作与重启保留仍待验证。
5. 通过实际操作验证小游戏进入、两种结果、取消、重试、暂停、回标题和重新进入。
6. 在剧情前、小游戏中和结束后保存，再冷启动读取，确认统一恢复；API 已连接不等于验证通过。
7. 补全各素材许可、搬迁运行与最终功能记录。已有操作说明见 [AVG开发接入说明](docs/AVG开发接入说明.md)，其中明确区分当前接口和未验证能力。

- 字号连接来源：`addons/dialogic/Modules/Settings/subsystem_settings.gd` 的 connect_to_change 与持久化；`Modules/DefaultLayoutParts/Layer_VN_Textbox/vn_textbox_layer.gd` 的字号覆盖调用。设置页滑块复用模板现有控件，恢复默认复用现有回调。

## 示例编辑

用本地编辑器打开 `game/project.godot`，进入 Dialogic 面板编辑 `content/FrameworkExample.dtl` 与 `content/PongExample.dtl`；人物与表情示例保留于 TestStuff。剧情调用场景使用 Dialogic Background 事件，异步等待使用 Call 事件。可从 Dialogic 时间线预览单独运行 PongExample；该预览使用插件自己的暂停界面，与正式主场景菜单不同。

所有导入资源应复制到 `game/`，使用 `res://` 引用。Windows 不区分大小写，模板的 `Assets/` 与计划中的 `assets/` 实际会合并，现阶段统一沿用上游 `Assets/` 拼写。工作室工具继续留在 Project 同级目录，不是游戏运行依赖。
