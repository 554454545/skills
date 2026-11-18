# 在 Windows 本地跑起来

## 下载代码

```powershell
git clone --depth 1 https://github.com/<作者>/<仓库>.git %USERPROFILE%\Desktop\<工作目录>\<仓库>
```

- 不想折腾 git 代理时，可直接下载 zip：
  `Invoke-WebRequest https://codeload.github.com/<账号>/<仓库>/zip/refs/heads/main -OutFile repo.zip -UseBasicParsing`，再 `Expand-Archive`。
- 报 `Failed to connect to github.com:443 over proxy 127.0.0.1`：git 配了本地代理（`git config --global --get http.proxy`），但代理软件没开。先打开代理再试；或在别处下载好 zip 再解压。

## 用项目指定的包管理器

看 `package.json` 里的 `"packageManager"`，例如 `bun@1.3.10` 就用 Bun。用 npm 装 Bun 项目可能出现
`Cannot find package '@unocss/astro'` 这类缺包错误。

安装 Bun（走国内 npm 镜像，不需要代理）：

```powershell
npm i -g bun --registry=https://registry.npmmirror.com
```

若 npm 全局目录被改成了自定义位置（如 `%USERPROFILE%\.npm-global`，可用 `npm config get prefix` 查看）且提示找不到 `bun`，用完整路径
`<npm 全局目录>\bun.cmd`，或把该目录加进 PATH。

装依赖（走镜像）：

```powershell
cd <项目目录>
$env:BUN_CONFIG_REGISTRY = 'https://registry.npmmirror.com'
bun install
```

npm 项目同理：`npm install --registry=https://registry.npmmirror.com`。

pnpm 项目：

```powershell
npm i -g pnpm --registry=https://registry.npmmirror.com
pnpm install
```

注意：新版 pnpm 会按 `minimumReleaseAge` 校验锁文件，国内镜像的元数据有时不全，会报
`lockfile entries failed verification ... version not present in registry manifest`。这时去掉 `--registry`，直接用官方源 `pnpm install` 即可（本机直连 npmjs 可用）。

## 启动预览

```powershell
bun run dev        # Astro 默认 http://localhost:4321（pnpm 项目用 pnpm run dev）
```

停止：在终端按 `Ctrl+C`；或按端口结束进程：

```powershell
Get-NetTCPConnection -LocalPort 4321 -State Listen | % { Stop-Process -Id $_.OwningProcess -Force }
```

评论、访问统计等依赖线上服务的功能在本地可能不显示，不影响看样式。
