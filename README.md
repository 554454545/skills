# 个人 Skills

个人 AI Agent Skills 集合，集中维护可复用的操作流程、参考资料和辅助脚本。每个技能通过 SKILL.md 中的名称与描述说明适用场景。

## 目录结构

```text
skills/
├── cf/
│   ├── AGENTS.md
│   └── skills/
│       ├── cloudflare-domain-registration/
│       └── cloudflare-tunnel/
├── reverse-proxy/
│   ├── AGENTS.md
│   └── skills/
│       └── magpie-public-gateway/
├── personal/
└── README.md
```

通用技能按用途放在 cf 和 reverse-proxy 中；personal 用于需要个人环境配置的技能。当前保留两个并列目录，以保证网关技能引用 Tunnel 文档的相对链接有效。

分组仅用于组织，不代表安装工具会自动排除 personal。安装前应检查实际发现的技能列表。

## 已收录技能

### Cloudflare

| 技能 | 用途 |
| --- | --- |
| [域名注册](cf/skills/cloudflare-domain-registration/SKILL.md) | 注册、续费、转出域名，说明注册人信息和价格规则。 |
| [Cloudflare Tunnel](cf/skills/cloudflare-tunnel/SKILL.md) | 创建隧道、连接本机服务、配置公网路由、排查问题和清理临时资源。 |

### 网关与反代

| 技能 | 用途 |
| --- | --- |
| [magpie 公网网关](reverse-proxy/skills/magpie-public-gateway/SKILL.md) | 通过 Tunnel 公开网关，验证密钥鉴权并导出 Base URL、指定使用者密钥和模型。 |

### 个人环境

见 [个人环境技能说明](personal/README.md)。当前没有收录个人环境技能。

## 使用方式

让支持技能的 Agent 阅读对应的 SKILL.md，并按其步骤执行。技能提供流程指导，执行仍需本机程序、服务登录和相应权限。

如使用 skills 命令行，可先列出技能，再选择安装：

```bash
npx skills add 554454545/skills --list
npx skills add 554454545/skills --skill cloudflare-tunnel
npx skills add 554454545/skills --skill magpie-public-gateway
```

上述安装命令未在本仓库发布后实测。单独安装网关技能时，需确认其引用的 Tunnel 技能也可访问；安装工具如改变目录结构，应调整引用路径，或克隆仓库保留原结构。

也可以克隆完整仓库，再让 Agent 读取入口：

```bash
git clone https://github.com/554454545/skills.git
```

## 命名与文件约定

- 技能目录名使用小写英文、数字和连字符，与入口元数据的 name 保持一致。
- SKILL.md 是必需入口，开头填写 YAML 元数据 name 和 description。
- description 写清适用任务和触发场景，正文说明操作步骤、前置条件及验证方法。
- scripts/ 放辅助脚本，references/ 放按需读取的详细资料，assets/ 放执行所需资源。
- 入口保持简洁，较长的操作说明移入参考资料，并使用相对 Markdown 链接。

```yaml
---
name: my-skill
description: 说明何时使用该技能，以及它解决的具体问题。
---
```

## 上传与维护

1. 每个技能使用独立目录，连同必需的脚本与参考资料一起维护。
2. 上传前检查凭证、个人账号、实际域名、本机路径、日志及生成文件，使用占位符编写示例。
3. 检查相对链接，并明确区分已经实测与尚未验证的步骤。
4. 新增技能后，在本页添加用途和入口链接。

## 导出连接配置

网关技能支持按本次指定的使用者密钥名称读取当前配置，不固定使用旧密钥。详见 [导出步骤](reverse-proxy/skills/magpie-public-gateway/SKILL.md#一键导出连接配置) 和 [脱敏配置示例](reverse-proxy/skills/magpie-public-gateway/references/connection-example.txt)。

实际导出文件包含完整密钥，应放在仓库之外；仓库只保留占位符模板，不上传 exports 目录。

## 验证范围

Tunnel 创建、连接、路由、DNS、公网鉴权、模型列表和一次最小对话请求已经复测；具体条件与未验证部分以各 Skill 的实测说明为准。域名购买未执行测试。