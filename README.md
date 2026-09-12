<div align="center">

<img src="assets/brand-icon-v2.png" alt="ALQQ 新品牌图标" width="112" />

# ALQQ · AI 自媒体内容运营平台

### 一次创作，多平台分发 · Windows 桌面端 2.1.0

**图文 · 动态 · 视频** 三种内容，一处创作多平台分发 · AI 写文 · 去 AI 味 · 定时托管 · 多账号矩阵

[![使用](https://img.shields.io/badge/桌面端-免费下载-success)](#-使用与费用)
[![平台](https://img.shields.io/badge/内容平台-22_个-blue)](#-支持的平台)
[![内容](https://img.shields.io/badge/内容形态-图文%20·%20动态%20·%20视频-ff5c5c)](#-核心功能详解)
[![形态](https://img.shields.io/badge/形态-桌面%20%2B%20Web%20%2B%20Linux-orange)](#-使用方式)
[![下载](https://img.shields.io/badge/Windows_x64-2.1.0-2ea44f)](https://github.com/zhuixin8/meiti-ai/releases/tag/v2.1.0)
[![AI](https://img.shields.io/badge/AI-多模型可选-purple)](#-接入的-ai-模型)
[![授权](https://img.shields.io/badge/授权-专有软件·免费使用-lightgrey)](LICENSE)
[![官网](https://img.shields.io/badge/🌐_官网-www.alqq.cn-1E40AF)](https://www.alqq.cn/)
[![API](https://img.shields.io/badge/📖_开放_API-开发者接入-6366f1)](https://alqq.cn/api/openapi/v1/reference)

### 📥 [下载 Windows 桌面端 2.1.0](https://github.com/zhuixin8/meiti-ai/releases/download/v2.1.0/ALQQ_2.1.0_x64-setup.exe) ｜ [官网备用下载](https://www.alqq.cn/api/v1/desktop/download)

Windows 10 / 11 x64 · 约 166.7 MiB · [更新与校验说明](RELEASE-2.1.0.md)

### 🌐 [官网 www.alqq.cn](https://www.alqq.cn/) ｜ 📖 [开放 API 文档（开发者接入）](https://alqq.cn/api/openapi/v1/reference)

**👉 [扫码加微信，免费领取使用](#-免费领取--加入交流群) · 进群一起玩转自媒体自动化运营**

</div>

---

## 💡 这是什么

**ALQQ** 是一款面向自媒体创作者、工作室、矩阵号运营者的 **AI 内容生产 + 多平台自动分发** 平台。

在一个后台里完成 **图文文章、动态/微头条、视频** 的创作或上传，再选择兼容的平台和账号分发。AI 写文、配图、排版、设封面、话题和定时计划可按平台能力自动处理；账号登录、扫码验证和平台审核有时仍需人工操作。

> 💬 少做重复的复制、粘贴和上传，把精力留给内容创作。

支持 **网页端**、**Windows 桌面端**和自托管 **Linux 执行节点**。桌面端在用户电脑运行浏览器发布，并可通过本机网络处理自有 AI / 图片资源请求；AI 服务与图片服务费用、平台资源权限以实际配置及控制台显示为准。

---

## 🆕 2.1.0 更新：本地优先桌面工作区

**2.1.0** 延续 Tauri 2 桌面架构，更新品牌图标、桌面登录工作台和本地资源处理能力。官网于 **2026-09-11** 发布，GitHub 提供同一份安装包。

| 升级点 | 说明 |
|---|---|
| 🎨 **新品牌与登录工作台** | 桌面快捷方式、安装向导、启动加载与网站统一品牌标识，更新桌面登录界面 |
| ⚡ **本地优先资源处理** | 在线且兼容的桌面会话可承接自有 AI / 图片 API 请求，在本机网络执行；仍依赖相应外部服务 |
| 🖼️ **图片与草稿本地存储** | 图片缓存 / 处理、草稿恢复及定时清理；清理时保护草稿和在途任务引用的素材 |
| 👀 **本机浏览器发布** | 在用户电脑的隔离环境执行，保留同账号互斥和本机资源保护 |
| 🛡️ **可靠性加固** | 改进发布结果核查、防重复提交、生成取消、AI 试写与作品同步异常处理 |
| 🔄 **签名更新** | 支持签名内容热更新；涉及运行时与桌面壳的升级使用完整安装包 |

> 💻 **系统要求**：Windows 10 / 11 x64。安装包内置 Node 与发布浏览器；界面依赖 Microsoft WebView2，缺少时按安装器提示安装。Windows 7 / 8 请改用网页端。

**升级须知**：保存编辑并等待发布任务结束，再通过「设置 → 关于 → 检查更新」或完整安装包升级。**2.1.0 不能仅靠旧版内容热更新获得**。本地处理不等于完全离线：主站仍负责账号授权、计划调度、配额和状态记录。

### 📥 [桌面版 Release 与安装附件](https://github.com/zhuixin8/meiti-ai/releases/tag/v2.1.0)

安装包 **174,796,118 字节（约 166.7 MiB）**，solid LZMA。SHA-256：

```text
96705248a514479c364404f12bf65703a7a7e12bb9bd0c344186479ad543048b
```

详见 [2.1.0 更新日志 / 升级与校验说明](RELEASE-2.1.0.md)。普通用户只需下载 `.exe`；`.sig` 是更新器签名，不是 Windows Authenticode 证书签名。

---

## 🐳 Linux / 宝塔 Docker 无人值守节点

不想让 Windows 电脑长期挂机时，可以在自己的 Linux 服务器或宝塔 Docker 中安装 **ALQQ Linux 执行节点**。账号登录仍在 Windows 桌面端完成；Cookie 加密保存到主站后，用户可以把指定账号绑定到 Linux 节点，由服务器全天候执行定时发布。

Linux 节点没有独立管理后台，登录、账号、计划、内容、日志、节点授权和停用均在 [ALQQ 主站](https://www.alqq.cn/) 统一管理。

> 当前公开节点版为 [**Edge 1.1.5**](https://github.com/zhuixin8/meiti-ai/releases/tag/edge-v1.1.5)，提供 **amd64 / arm64** 镜像。节点版与 Windows 桌面版使用独立版本号，不要混用安装包。

### 一键安装

1. 登录主站，进入「自动化 → 执行节点」，创建一个 15 分钟有效的一次性配对码。
2. 在宝塔终端或 Linux SSH 中运行：

```bash
curl -fsSL https://github.com/zhuixin8/meiti-ai/releases/download/edge-v1.1.5/install-edge.sh | sudo bash
```

3. 按提示输入配对码，回到主站把需要托管的账号绑定到该节点。

无人值守安装也可直接传入配对码：

```bash
curl -fsSL https://github.com/zhuixin8/meiti-ai/releases/download/edge-v1.1.5/install-edge.sh \
  | sudo ALQQ_PAIRING_CODE=ABCDE-23456 bash
```

> 🔐 GitHub 仓库不包含生成、调度或发布源码。下载的是签名版本对应的加密字节码镜像；节点必须经 `alqq.cn` 授权并取得短期会话密钥才能加载发布引擎。配对成功后，一次性配对码会自动从容器配置中清除。

安装器会按架构下载并校验发布文件。仓库中的 Compose 示例配合已导入的镜像使用，不是单独执行 `docker compose up` 就能完成初次安装；请先阅读安装脚本，并仅在自己的服务器上执行。

### 常用运维

```bash
cd /opt/alqq-edge
docker compose ps
docker compose logs -f --tail 100
docker compose restart
```

---

## 🖼️ 界面预览

以下为功能界面示例，部分截图来自早期版本；图标、布局和字段以安装后的 2.1.0 实际界面为准。

<table>
<tr>
<td width="50%"><img src="screenshots/001.png" alt="仪表盘" /><br/><sub><b>📊 运营仪表盘</b> —— 总文章 / 已发布 / 成功率 / 账号状态 / 今日配额 / 定时任务，一屏掌握</sub></td>
<td width="50%"><img src="screenshots/002.png" alt="AI写作-热点选题" /><br/><sub><b>🔥 AI 写作 · 热点选题</b> —— 实时聚合全网热点，点一下就基于热点成文</sub></td>
</tr>
<tr>
<td width="50%"><img src="screenshots/004.png" alt="文章创作" /><br/><sub><b>✍️ 文章创作</b> —— 所见即所得编辑器，AI 改写 / 翻译 / 一键发布</sub></td>
<td width="50%"><img src="screenshots/005.png" alt="内容中心" /><br/><sub><b>🗂️ 内容中心</b> —— 文章集中管理与预览，一键多平台分发</sub></td>
</tr>
<tr>
<td width="50%"><img src="screenshots/008.png" alt="定时计划" /><br/><sub><b>⏰ 定时计划</b> —— 无人值守自动「抓热点 → 成文 → 多账号发布」</sub></td>
<td width="50%"><img src="screenshots/010.png" alt="多平台账号" /><br/><sub><b>🌐 多平台账号</b> —— 集中管理账号，按平台完成扫码或浏览器登录</sub></td>
</tr>
<tr>
<td width="50%"><img src="screenshots/006.png" alt="账号定位" /><br/><sub><b>🎯 账号定位</b> —— 为每个号设定人设 / 风格 / 平台适配，内容更"像人"</sub></td>
<td width="50%"><img src="screenshots/007.png" alt="知识库" /><br/><sub><b>📚 知识库</b> —— 上传 PDF / Word / Excel / TXT，AI 自动整理为写作素材</sub></td>
</tr>
<tr>
<td width="50%"><img src="screenshots/003.png" alt="产品管理" /><br/><sub><b>🛍️ 产品管理</b> —— 带货 / 品牌内容，统一管理产品素材</sub></td>
<td width="50%"><img src="screenshots/009.png" alt="系统设置-AI配置" /><br/><sub><b>⚙️ AI 配置</b> —— 接入多家 AI，可填自己的密钥；额度以控制台为准</sub></td>
</tr>
</table>

---

## 🆓 使用与费用

支持免费注册与桌面端免费下载。请区分 **软件使用** 和 **外部服务 / 平台资源消耗**：

- ✅ 可使用自己的 AI 密钥和图片 API 配置，第三方调用费用由对应服务商计费
- ✅ 平台模型池、账号数量、发布额度、执行节点与 API 权限以当前控制台套餐 / 授权为准
- ✅ 不把“免费下载”理解为无限发布、无限算力或必有免费 AI 额度
- ✅ 桌面端持续更新；账号权限与平台规则仍然适用

> 我们相信好工具应该让更多人用得起。**[加微信 / 进群](#-免费领取--加入交流群)，第一时间领取使用资格、获取更新与答疑支持。**

---

## 🚀 支持的平台

当前接入 **22 个内容平台＋2 种站点系统**。各平台支持的文章、动态、视频类型及设置不同，以发布页面可选项为准：

| 资讯图文 | 短视频 | 社区 / 问答 | 出海 |
|---|---|---|---|
| 百家号 | 抖音 | 知乎 | TikTok |
| 今日头条 | 哔哩哔哩 | 小红书 | Instagram |
| 微信公众号 | 快手 | 豆瓣 | Facebook |
| 企鹅号 | 视频号 | 简书 | YouTube |
| 搜狐号 | | CSDN | |
| 大鱼号 | | | |
| 快传号 | | | |
| 微博 | | 淘宝光合 | |

**自有站点接入**：PbootCMS、InnoShop。

> 🔌 持续接入更多平台中，欢迎在群里提需求。
>
> 🎬 当前注册 **19 个视频发布器**。其中 **YouTube 视频发布仅支持桌面端**，通过浏览器登录 YouTube Studio，可预设可见性、儿童内容、合成媒体、付费推广、标签、分类和描述；不代表所有平台支持相同设置。

---

## ✨ 核心功能详解

### 📝 AI 内容创作
- **AI 一键成文**：给出标题 / 选题生成草稿，支持编辑、审校后发布
- **热点选题**：聚合热点榜单，用于选题和内容创作
- **文风优化**：按人设、语气和平台改写，减少模板化表达；不承诺绕过检测或免除内容审核
- **账号定位 / 人设**：为每个账号设定人设、写作风格、平台调性，输出内容更贴合账号
- **知识库**：上传 PDF / Word / Excel / TXT 或粘贴文本，AI 自动整理为可引用的写作素材
- **产品库**：带货 / 品牌运营，统一管理产品资料，写作时自动调用
- **智能配图 / AI 生图**：按配置使用产品图、图片 API 或 AI 生图，并支持桌面本地处理与缓存；发布前请核对素材授权

### 🎬 视频上传分发
- **一个视频，多平台分发**：支持抖音、B站、快手、视频号、小红书、今日头条、百家号、微博、YouTube 等平台，受账号权限与平台格式限制
- **发布预设**：按平台支持范围设置标题、简介、封面、标签、可见性等
- **进度与结果核查**：查看任务阶段和平台结果；结果不明确时先核查，避免重复提交。当前不承诺在本机自动转码视频

### 📣 动态 / 微头条
- 支持 **动态、微头条、瞬间** 类短内容发布（头条、百家号、抖音、搜狐、公众号、微博）
- 适合日常种草、短资讯、互动话题等内容维护

### 📤 多平台自动发布（图文 / 动态 / 视频通用）
- **一键分发**：一条内容勾选多个平台 / 多个账号，按执行端能力并发调度；同账号任务串行执行
- **平台适配**：自动处理各平台的标题、正文、封面、话题、可见性、排版差异
- **浏览器自动化**：在相应执行端完成平台操作；需要扫码验证、登录失效或触发风控时提示人工处理
- **发布记录与防重**：记录状态和失败原因；对可能已提交的任务先核查平台结果，不盲目重发

### ⏰ 定时托管 & 矩阵运营
- **定时计划**：结合执行端设置周期、时段和计划；桌面需在线且资源可用，内容准备及平台验证可能影响实际完成时间，不承诺秒级准点成功
- **多账号矩阵**：集中管理多平台、多账号，批量调度
- **数据看板**：发布量、成功率、配额用量一目了然

### 🤖 接入的 AI 模型
DeepSeek · 硅基流动 · 智谱 AI（GLM）· 火山引擎（豆包）· Cloudflare AI · **OpenAI 兼容接口**（任意自建 / 第三方模型）

> 选择自己的服务商、密钥和模型；是否有免费额度、调用限制及价格，以服务商和平台控制台为准。

---

## 🔌 开放 API（开发者接入）

提供完整的 **REST 开放 API** —— 用 API 密钥即可程序化 **生成文章、发布图文 / 视频、查询发布记录与额度**，轻松接入 n8n / Coze / 自有系统与自动化流程。

👉 **[在线 API 文档](https://alqq.cn/api/openapi/v1/reference)**（可直接在线调试 · 一键导入 Apifox / Postman）

---

## 🖥️ 使用方式

| | 网页端 | Windows 桌面端 | Linux 执行节点 |
|---|---|---|---|
| **安装** | 浏览器打开主站 | 安装 2.1.0 x64 客户端 | 在自有服务器运行 Docker 节点 |
| **执行位置** | 按账号绑定与权限选择可用执行端；云端任务由共享资源调度 | 用户电脑执行浏览器发布和受支持的本地资源任务 | 指定账号任务在自有服务器执行 |
| **使用条件** | 平台授权、配额及执行资源可用 | 客户端在线、登录有效、本机有足够资源 | 节点在线、完成配对、平台支持该执行端 |
| **适合** | 轻量管理与内容操作 | 本机发布、自有 AI / 图片资源处理 | 长时间运行的自托管任务 |

> **账号与数据边界**：桌面端登录时打开浏览器完成扫码 / 手动登录。账号凭证加密保存在云端，授权桌面会话按需获取，在本机隔离环境执行；本地图片 / 草稿工作区不作为 Cookie、API 密钥或发布授权的持久化仓库。按账号隔离环境不等于更换网络 IP，也不保证免除平台风控。

---

## 👥 适用人群 & 常见用途

- **自媒体创作者 / 工作室**：一篇文章分发到兼容平台，减少手动复制粘贴
- **矩阵号运营 / MCN**：多平台、多账号集中管理，通过定时计划减少重复操作
- **品牌 / 电商带货**：产品库 + AI 文案 + 多平台铺量，统一种草
- **个人副业 / 流量主**：蹭热点选题、AI 成文、自动发布，低成本起号
- **希望控制成本的用户**：免费下载桌面端，按需接入自己的 AI / 图片服务

**常被用来解决这些需求**：
自媒体一键发布工具 · 多平台同步发布 · 今日头条自动发布 · 百家号批量发布 · 公众号自动发布 · 抖音图文自动发布 · 小红书批量发布工具 · 知乎 / 微博 / B站自动发布 · YouTube 视频发布 · AI 写作与文风优化 · 自媒体矩阵管理 · 热点选题工具

---

## 📲 免费领取 / 加入交流群

遇到问题、想要新功能、领取使用资格、获取最新版本，欢迎加我们：

<table>
<tr>
<td align="center" width="33%">

### 👤 加我微信

**业精于勤**

<img src="assets/wechat-personal.jpg" width="220" alt="微信号" />

加好友备注「**自媒体**」<br/>领使用资格 · 拉你进群 · 领最新版

</td>
<td align="center" width="33%">

### 👥 微信群

**自媒体自动化运营**

<img src="assets/wechat-group.png" width="220" alt="微信群" />

扫码进群（二维码定期更新）<br/>**过期请加左侧微信拉你进群**

</td>
<td align="center" width="33%">

### 🐧 QQ 群

**新媒体自动化运营 · 733861251**

<img src="assets/qq-group.jpg" width="220" alt="QQ群" />

扫码 或 [点击加群](https://qm.qq.com/q/2jRwOrOOYg)<br/>搜群号 **733861251** 也可加入

</td>
</tr>
</table>

---

## 📄 授权说明

「ALQQ」是**免费但专有**的软件:个人可免费使用,但**软件本身不开源**。

本仓库仅包含项目介绍、界面截图、二维码与安装包,**不含源代码**。未经书面授权,禁止反编译、二次分发、转售或克隆为同类产品。详见 [LICENSE](LICENSE)。如需商业授权或合作,请通过上方联系方式联系我们。

---

<div align="center">

## English

**ALQQ** — a **free** AI-powered content operation platform for social-media creators.

**Create once, distribute across compatible platforms.** Generate and edit articles with AI, then publish articles, short posts and videos using platform-specific capabilities. Current integrations cover **22 content platforms plus PbootCMS and InnoShop**, including desktop-only YouTube video publishing.

**Key features:** AI writing from trending topics · **one-click video upload to multiple platforms** · knowledge base (PDF/Word/Excel/TXT) · per-account persona & style · one-click multi-platform publishing with real-browser automation · scheduled unattended pipelines · multi-account matrix management.

**Windows desktop 2.1.0** adds a new brand identity, a redesigned login workspace, local-first AI / image requests, image caching and draft recovery. It requires a full installer upgrade, not only a content hot update. [Download and release notes](https://github.com/zhuixin8/meiti-ai/releases/tag/v2.1.0).

**Use your own AI / image service keys.** Third-party charges apply; hosted resources and quotas depend on your plan and permissions. The desktop is not fully offline: the cloud still manages authorization, scheduling and status. Platform login checks and reviews may require manual action. Also available as a **web app** and a separately versioned **Linux execution node**.

> 💬 **Scan the WeChat QR codes above to get free access and join the community.**

<br/>

**ALQQ · 让自媒体运营更轻松** — 一次创作 · 多平台分发

⭐ 觉得好用，欢迎 **Star** 支持！

</div>
