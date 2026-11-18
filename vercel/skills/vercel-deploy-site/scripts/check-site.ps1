# 用法：powershell -ExecutionPolicy Bypass -File check-site.ps1 -Domain blog.example.dev
param([Parameter(Mandatory = $true)][string]$Domain)

Write-Host "== DNS 解析：$Domain"
try {
    Resolve-DnsName $Domain -ErrorAction Stop |
        Select-Object Name, Type, NameHost, IPAddress | Format-Table -AutoSize | Out-String | Write-Host
    Write-Host "（若 IP 是 198.18.x.x，是本机代理的 fake-IP，属正常）"
} catch {
    Write-Host "解析失败：$($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "== HTTPS 访问"
try {
    $r = Invoke-WebRequest "https://$Domain/" -UseBasicParsing -TimeoutSec 30
    Write-Host "HTTP $($r.StatusCode)，页面大小 $($r.Content.Length) 字节" -ForegroundColor Green
    if ($r.Headers['Server']) { Write-Host "Server: $($r.Headers['Server'])" }
} catch {
    Write-Host "访问失败：$($_.Exception.Message)" -ForegroundColor Red
}
