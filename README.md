# Skills

个人 Agent Skills 集合，为 AI 编程助手提供可复用的操作流程、参考资料和工具脚本。适用于支持 SKILL.md 约定的 Codex、Claude Code、Cursor、pi 等 Agent。

## 目录结构

每个 Skill 是一个独立目录，以 SKILL.md 为入口。按需添加配套文件：

```text
<skill-name>/
├── SKILL.md
├── scripts/
├── references/
└── assets/
```

- `SKILL.md`：技能名称、适用场景和执行步骤。
- `scripts/`：可执行的辅助脚本。
- `references/`：按需读取的详细文档。
- `assets/`：模板、图片等执行所需资源。

技能可以放在仓库根目录，也可以按主题分组。依赖个人机器路径、账号或本地服务的技能放入 [personal/](personal/README.md)。分组用于维护，不代表安装工具会自动排除个人技能。

## 命名与编写约定

- 目录名与 SKILL.md 中的 name 一致，使用小写英文、数字和连字符。
- 入口必须包含 name 和 description；description 说明适用任务和触发场景。
- 正文保留关键流程，较长说明放入 references/，通过相对 Markdown 链接引用。
- 通用技能使用参数和占位符，避免依赖作者的绝对路径或固定账号。
- 脚本与参考资料随技能一起维护，跨技能依赖需明确说明。

```yaml
---
name: my-skill
description: 说明该技能解决什么任务，以及何时应使用。
---
```

## 安装与使用

使用 skills CLI 查看仓库中可发现的技能，并按名称选择安装：

```bash
# 查看技能
npx skills add 554454545/skills --list

# 安装指定技能
npx skills add 554454545/skills --skill <skill-name>
```

安装工具的目录发现规则和目标 Agent 支持情况，以所用版本为准。包含跨目录引用的技能应同时提供所需依赖，或保留仓库原有相对结构。

也可以克隆仓库，让 Agent 读取相应的 SKILL.md：

```bash
git clone https://github.com/554454545/skills.git
```

Skill 提供执行方法；本地程序、服务授权和凭证由使用者自行配置。

## Skills

### Cloudflare

| Skill | 用途 |
| --- | --- |
| [cloudflare-domain-registration](cf/skills/cloudflare-domain-registration/SKILL.md) | 在 Cloudflare Registrar 注册、续费和转出域名。 |
| [cloudflare-tunnel](cf/skills/cloudflare-tunnel/SKILL.md) | 使用 cloudflared 将本地服务公开到自定义域名，配置路由并排查连接问题。 |

### 网关与反代

| Skill | 用途 |
| --- | --- |
| [magpie-public-gateway](reverse-proxy/skills/magpie-public-gateway/SKILL.md) | 通过 Cloudflare Tunnel 公开 magpie 网关，配置使用者密钥、验证接口并导出连接信息。 |

### Vercel

| Skill | 用途 |
| --- | --- |
| [vercel-deploy-site](vercel/skills/vercel-deploy-site/SKILL.md) | Fork 网站项目，本地预览后免费部署到 Vercel，并绑定 Cloudflare 上的自有子域名。 |
| [vercel-remove-site](vercel/skills/vercel-remove-site/SKILL.md) | 撤掉已部署的网站：删除 Cloudflare 子域名记录和 Vercel 项目，按需清理仓库与本地副本，并验证结果。 |

## 添加技能

创建独立技能目录，编写 SKILL.md，并加入必要的脚本或参考资料。验证执行流程及文档链接后，在上方目录添加入口和用途。

凭证、会话、日志、本地依赖及包含真实密钥的导出结果不进入仓库。示例使用占位符；实际配置保存在仓库之外。