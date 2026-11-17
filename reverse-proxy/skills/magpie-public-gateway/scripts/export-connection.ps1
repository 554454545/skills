param(
  [Parameter(Mandatory = $true)][string]$BaseUrl,
  [Parameter(Mandatory = $true)][string]$KeyName,
  [Parameter(Mandatory = $true)][string]$OutputPath,
  [string]$Model,
  [string]$KeysPath = (Join-Path $env:USERPROFILE '.config/magpie/caller-keys.json')
)

$ErrorActionPreference = 'Stop'
$base = $BaseUrl.TrimEnd('/')
$uri = [Uri]$base
if (-not $uri.IsAbsoluteUri -or $uri.Scheme -ne 'https' -or $uri.AbsolutePath -ne '/v1' -or $uri.Query -or $uri.Fragment -or $uri.UserInfo) {
  throw 'Base URL 必须是明确授权的 HTTPS 地址，路径为 /v1，不含查询参数或凭证。'
}
$output = [IO.Path]::GetFullPath($OutputPath)
if (Test-Path -LiteralPath $output) { throw '导出文件已存在，请选择新文件名，避免覆盖。' }
$keys = Get-Content -LiteralPath $KeysPath -Raw -Encoding UTF8 | ConvertFrom-Json
$matches = @($keys | Where-Object { $_.name -ceq $KeyName })
if ($matches.Count -ne 1 -or -not $matches[0].secret) { throw '指定名称必须匹配唯一的有效网关密钥。' }
$selectedKey = $matches[0]
if ($selectedKey.name -eq 'Magpie') { throw '默认总密钥不用于分享，请选择独立使用者密钥。' }
try {
  $response = Invoke-RestMethod -Uri "$base/models" -Headers @{ Authorization = "Bearer $($selectedKey.secret)" } -TimeoutSec 25
} catch { throw '模型列表请求失败，请检查域名、Tunnel、共享状态和密钥。' }
$modelIds = @($response.data | ForEach-Object { $_.id } | Where-Object { $_ } | Sort-Object -Unique)
if ($modelIds.Count -eq 0) { throw '网关没有返回可用模型。' }
if ($Model -and $Model -cnotin $modelIds) { throw '指定模型不在当前可用模型列表中。' }
if (-not $Model) { $Model = $modelIds[0] }
$lines = @('# 网关连接配置', '', "Base URL: $base", "API Key: $($selectedKey.secret)", "模型: $Model", '', '可用模型:')
$lines += $modelIds | ForEach-Object { "- $_" }
$parent = [IO.Path]::GetDirectoryName($output)
if (-not (Test-Path -LiteralPath $parent)) { throw '导出目录不存在，请先指定已有的本地私密目录。' }
$bytes = [Text.UTF8Encoding]::new($true).GetBytes(($lines -join "`r`n"))
$stream = [IO.File]::Open($output, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
try { $stream.Write($bytes, 0, $bytes.Length) } finally { $stream.Dispose() }
Write-Output "已导出连接配置：$output"
Write-Output "已验证模型列表，包含 $($modelIds.Count) 个模型；密钥未输出到终端。"
