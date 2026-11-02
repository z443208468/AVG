# 苍岐正式游戏开发工作区

当前框架建设以 [AVG引擎框架搭建执行计划](docs/AVG引擎框架搭建执行计划.md) 为准。该计划要求把Godot及编辑器数据部署到Project内，复用Dialogic与开源完整模板替换当前简易外壳。计划尚未执行；下列运行方式仍描述现状。

执行约束：先选定并跑通现成开源体系，再部署配置。缺功能继续查找开源实现或重新选型，不自行开发AVG模块；只允许必要的配置、兼容修补和API连接。

辅助工具已部署在 `D:/CangqiStudio/Claude-Code-Game-Studios-Codex`。其具体用法与部署步骤对应见计划第6节：按需读取外部Godot专业资料，执行实际部署；不自动启用工作室接管、审计、hooks或测试管理流程。

- `cangqi/`：已有作品仓库，原文、设计与制作合同。
- `game/`：正式Godot工程的基础外壳候选。
- `docs/正式游戏框架与开篇方案.md`：现状、开篇研究、系统划分、接入路线与验证限制。

运行 `pwsh -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File .\启动游戏.ps1`。
加 `-Editor` 打开编辑器，加 `-Smoke` 检查外壳闭环。

本机Godot复用 `D:/CangqiStudio/Godot` 的4.7.2版本。正式剧情继续从现有制作流程交接，不将AVGStudio试验输出当发布包。
