# Godot AVG 模板

基于 Godot 4.7.2 + Dialogic 2 的文字 AVG 开发模板。引擎、插件、导出模板全部在本目录内，复制或克隆后即可编辑、运行、导出 Windows 包，不依赖外部安装。

`game/examples/` 是完整的功能示例（人物演出、分支、鉴赏、音乐、语音、Pong 小游戏往返、存读档）；新游戏的内容放 `game/content/`。开新项目见 [新项目开工](docs/新项目开工.md)，日常制作见 [AVG 开发接入说明](docs/AVG开发接入说明.md)。

## 启动

| 用途 | 入口 |
|---|---|
| 打开编辑器 | `启动编辑器.ps1` |
| 直接运行游戏 | `启动游戏.ps1` |
| 导出 Windows 包到 `dist/windows/` | `导出Windows.ps1`，或编辑器 项目 → 导出 |

脚本用 `$PSScriptRoot` 定位，目录搬到哪里都能用。编辑器是便携模式（`engine/godot-4.7.2/_sc_`），设置与导出模板在 `engine/godot-4.7.2/editor_data/`。

首次打开（或删除 `game/.godot` 后）Godot 会重新导入；Dialogic 的时间线若在文件系统面板里不显示，执行一次 项目 → 重新加载当前项目。

## 目录

```text
engine/            Godot 4.7.2 便携版 + 匹配导出模板（SHA512 与官方一致，见 SHA512-SUMS.txt）
game/
  addons/          Dialogic alpha 20、鉴赏组件 dialogic_gallery
  DialogicFantasyMenu/   标题、菜单、存读档、设置、历史、鉴赏界面（FantasyTemplate）
  DialogicFantasyStyle/  对话框、选项、输入框样式
  Assets/          界面贴图、字体（Noto Sans SC）、界面音效
  content/         ← 你自己游戏的时间线、人物、素材、鉴赏条目
  examples/        示例内容，可整体删除（步骤见新项目开工）
licenses/          第三方代码与素材许可、署名
docs/              使用文档；history/ 为搭建阶段的计划记录
dist/windows/      导出产物（不入 Git）
archive/           旧外壳、模板原版、旧文档备份（不打包）
cangqi/            苍岐作品资料仓库，独立 Git，与模板无关（不入本仓库）
```

## 固定上游

| 来源 | 版本／提交 | 用途 |
|---|---|---|
| Godot 官方 Windows 标准版 | 4.7.2.stable.official.ed1daf0bf | 引擎与导出模板 |
| [Dialogic](https://github.com/dialogic-godot/dialogic) | alpha 20，e301e1bb | 剧情、演出、变量、历史、声音、存档 |
| [Dialogic2FantasyTemplate](https://github.com/Jowan-Spooner/Dialogic2FantasyTemplate) | 4df229d4 | 菜单、分页存读档、设置、阅读样式 |
| [DialogicTemplate](https://github.com/wtmenten/DialogicTemplate) | 9b2a5978 | 鉴赏组件 |
| [Godot demo Pong](https://github.com/godotengine/godot-demo-projects/tree/master/2d/pong) | b761b4cd | 小游戏示例 |
| Noto Sans SC | SIL OFL | 中文字体 |

插件不自动升级。对上游的修改：

- `addons/dialogic/Core/DialogicGameHandler.gd`：读档等待布局 ready、先恢复子系统再启动时间线，避免自动档捕获隐藏的文本框。
- `addons/dialogic/Editor/TimelineEditor/test_timeline_scene.gd`：预览前加载已读、关闭自动存档，不改写玩家进度。
- `addons/dialogic_gallery/gallery_menu.gd`：同时扫描 `content/gallery` 与 `examples/gallery`。
- 菜单与样式：中文字体、分轨音量、字号、快捷键、七个选项按钮、专用存档槽、历史记录适配 alpha 20 事件结构、图库布局修正。
- `examples/integration/`：Pong 与 Dialogic Background／Call 事件的连接代码（约 60 行）。

## 功能验收（2026-11-02）

均为 Windows 界面实际操作。“本轮”指示例目录重组后重新操作过；“搭建期”指重组前已验证、重组后只通过代码与资源加载检查（151 个资源全部可加载、所有时间线可启动），未逐项重测。

| 功能 | 结果 | 依据 |
|---|---|---|
| 空存档启动 | 无“继续游戏”，存档页全空，鉴赏全部锁定 | 本轮 |
| 编辑器 | 在克隆到新路径的副本里新建时间线、文本编辑、保存、Ctrl+F6 预览 | 本轮 |
| 预览隔离 | 预览时间线后，鉴赏未被解锁、继续点不变 | 本轮 |
| 条件选项 | Pong 取消时隐藏“记录结局”，胜负时显示 | 本轮 |
| 语音／音效示例 | 女声、男声、SFX 三段流程走完，循环与返回标题正常 | 本轮（界面流程；声音输出在搭建期用 WASAPI 测过） |
| 存档 | 保存带缩略图、删除确认并实际删除；F5 快捷档 + 关窗后“继续游戏”恢复到原句 | 本轮 |
| 小游戏 | 进入 Pong → 左胜／取消 → 对应分支；回标题后再进入无残留 | 本轮 |
| 鉴赏 | 结局卡跨重启保留，未获得的保持锁定 | 本轮 |
| 导出 | `dist/windows/AVGGame.exe`＋pck＋licenses，复制到别处单独运行完成 Pong 往返 | 本轮 |
| Git | 克隆后 `git lfs pull` 得到完整引擎（与原件校验一致） | 本轮 |
| 阅读 | 自动、已读快进停在选项、历史回看、隐藏 UI | 搭建期 |
| 演出 | 双人物入退场、表情、背景转场、文字输入 | 搭建期（本轮在预览中看到人物与背景正常） |
| 设置 | 窗口／全屏／分辨率、字号、速度、快进规则、五路音量、恢复默认，重启保留 | 搭建期 |
| Pong 中途存档 | 比赛中存档、冷启动读取后球与球拍状态一致 | 搭建期 |
| 音乐鉴赏 | Teller／Skye 播放、停止、返回标题 | 搭建期 |

## 已知限制

- Dialogic 2 仍是 Alpha，固定在 alpha 20；升级前先在分支上回归上表。
- 时间线编辑器右上角 Play Timeline 按钮偶尔无响应，用 **Ctrl+F6** 预览。
- 删除全部角色后，若开着 Autocolor Names，Dialogic 会在显示对白时报错（上游问题）。至少保留一个角色，或在 Dialogic 设置里关闭 Autocolor Names。
- 鉴赏页左侧书签有时显示上一个打开的页面名（模板原有的显示问题，不影响功能）。
- 无窗口导入／导出退出时有编辑器 ObjectDB 泄漏提示，不影响产物。
- 存档目录由 `project.godot` 的 `config/name` 决定；两个项目同名会共用存档，新项目务必改名。

## 许可

模板自身的配置、连接代码与文档按根目录 LICENSE（Apache-2.0）。Godot、Dialogic、FantasyTemplate、鉴赏组件、Pong 示例及各素材保持各自许可，见 `licenses/`。

## Git

仓库根即本目录，大文件（exe、pck、图片、音频、字体）走 Git LFS。克隆后：

```bash
git lfs install
git lfs pull
```

`cangqi/`、`dist/`、`staging/`、编辑器缓存与本机设置不入库。远程仓库：https://github.com/z443208468/AVG 。GitHub 免费账户的 LFS 额度为 1 GB 存储、每月 1 GB 下载，本仓库 LFS 约 440 MB，一个月大约够完整克隆两次；超出需在 GitHub 购买数据包。
