# 个人 Skills

用于集中维护自己的 AI Agent Skills，后续逐步上传和整理。

## 目录结构

```text
skills/
├── <skill-name>/
│   ├── SKILL.md
│   ├── scripts/
│   ├── references/
│   └── assets/
├── personal/
│   └── README.md
└── README.md
```

根目录存放可复用的通用 Skill；[个人环境说明](personal/README.md)介绍依赖本机配置的 Skill 应如何存放。当前尚未收录实际 Skill。

## 上传自己的 Skill

1. 为每个 Skill 创建独立目录，目录名使用小写英文和连字符。
2. 将入口文件命名为 SKILL.md，保留原有的必要配套文件。
3. 在入口文件开头填写 YAML 元数据，例如：

```yaml
---
name: my-skill
description: 说明该技能适用的任务，以及何时应使用它。
---
```

4. 在正文写清执行步骤、输入输出和必要依赖；详细参考资料放入 references/。
5. 上传前移除密钥、令牌、账号凭证、日志、会话和本地依赖目录。
6. 收录后在下方目录添加用途及相对链接。

## Skill 目录

待上传自己的 Skill 后补充。
