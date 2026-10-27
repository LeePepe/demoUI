# demoUI · Strata 岩层

共享 UI 主题验证网页原型：通透 Glass 材质、圆润轮廓、明度分层与糖果强调色。自定义配色受到经典 iMac / iPhone 5C 启发，不是 Apple 官方设计系统或原生应用；当前结果尚未作为生产规范。

## 仓库入口

[开发与 PR 规范](docs/development.md) · [仓库协议、验证与交付](docs/repository-guide.md) · [架构与路径归属](docs/architecture/tech-context.md) · [Agent 目录](AGENTS.md)。

当前同时提供网页原型与原生 Strata showcase package；网页启动、截图和历史记录仍属于原型参考。

## 本地启动

在任务 worktree 内执行（需要 Python 3，无需安装应用依赖）：

```sh
python3 -m http.server 4173 --bind 127.0.0.1
```

打开 <http://127.0.0.1:4173/?color=blue&mode=light&material=glass>。

- `color=blue|green|pink|yellow|purple`
- `mode=light|dark`
- `material=glass|solid`：顶部按钮可切换；减少透明度偏好或不支持模糊的浏览器自动使用实底。
- 顶部控制会更新 URL，复制即可复现配色。
- 所有交互均为本地演示，不接账号、业务数据或远程服务。

## 文件

- `tokens.mjs`：颜色角色、五色明暗值、字体、尺寸、间距、圆角、动效、材质透明度 / 模糊 / 高光 / 阴影的集中定义；`getTheme()` 返回可下载的主题对象，包含实际生效的材质。
- `styles.css`：组件样式、响应式布局、键盘焦点与 reduced motion。
- `app.mjs`：主题、URL、模拟按钮、列表选择与 JSON 下载。
- `index.html`：单页组件工作台。
- [初始设计规则](design/north-star.md) · [验证结果](design/validation.md)。

## 真实浏览器截图

截图来自 Chromium，不是 AI 生图。桌面统一 1440×1000；手机视口为 390×844，另外保存完整滚动页面以展示所有组件。

| 主题 | 文件 |
| --- | --- |
| 蓝色浅色桌面 | [blue-light-desktop.png](design/screenshots/glass/blue-light-desktop.png) |
| 绿色浅色桌面 | [green-light-desktop.png](design/screenshots/glass/green-light-desktop.png) |
| 紫色深色桌面 | [purple-dark-desktop.png](design/screenshots/glass/purple-dark-desktop.png) |
| 蓝色浅色手机完整页 | [blue-light-mobile.png](design/screenshots/glass/blue-light-mobile.png) |
| 蓝色浅色手机首屏 | [blue-light-mobile-viewport.png](design/screenshots/glass/blue-light-mobile-viewport.png) |

当前为 v0.2 Glass。v0.1 哑光截图保留在 `design/screenshots/` 根目录，供对照。形状规则：胶囊按钮与分段开关、圆形色板、16px 普通控件 / 24px 卡片 / 32px 容器。

## 延续任务

原生 showcase：

```sh
swift test --package-path app
swift run --package-path app StrataShowcaseApp --export-screenshots /tmp/strata-showcase
```

`app/Package.swift` 固定消费 `shared-design-system` 的 exact revision，并通过 `Strata` 与 `DesignTokens` 提供五品牌、双外观、Solid/Glass 和四数据状态的组件目录。

共享设计系统同步与本地 live-link：

```sh
python3 scripts/sync-strata.py --check
python3 scripts/sync-strata.py --local-override ../shared-design-system
python3 scripts/sync-strata.py --reset-override
```

`sync-strata` workflow 会在 shared-design-system 更新或定时追赶时运行
`scripts/verify --all`，并为新的 exact revision 打开依赖 / pin PR。

TestFlight 发布：

```sh
python3 scripts/testflight-gate.py --check-contract --dry-run
fastlane ios beta
```

`testflight` workflow 在 `main` 的 CI 成功、定时触发或手动强制时运行；
它只从仓库 secrets / variables 读取签名配置，并在上传成功后更新
`testflight/last-released` tag。复制 `config/Signing.example.xcconfig` 为被
忽略的 `config/Signing.local.xcconfig` 可用于本地归档。

实现与截图保存在 `codex/strata-theme` 专用分支；主 checkout 保持未提交的初始状态，未配置 remote。后续迭代直接使用任务 worktree，先核实分支和未提交改动。博客文章使用博客仓库的独立分支 `codex/strata-theme-post`，不要在此仓库配置博客 remote。
