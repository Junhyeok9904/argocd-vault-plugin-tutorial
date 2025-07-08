$vaultRootToken = "root" # 실제 Vault root 토큰으로 교체하세요!
$policyName = "my-approle-policy"
$policyContent = @'
path "secret/data/test" {
  capabilities = ["read"]
}
path "secret/data/busybox-messages" {
  capabilities = ["read"]
}
'@

$body = @{
    policy = $policyContent
} | ConvertTo-Json -Compress

try {
    $headers = @{"X-Vault-Token" = $vaultRootToken}
    $response = Invoke-RestMethod -Uri "http://localhost:8200/v1/sys/policy/$policyName" -Method Put -Headers $headers -Body $body -ContentType "application/json"
    Write-Host "Vault 정책 '$policyName' 업데이트 성공: $($response | ConvertTo-Json -Depth 4)"
} catch {
    Write-Error "Vault 정책 '$policyName' 업데이트 실패: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $responseBody = $reader.ReadToEnd()
        Write-Error "응답 본문: $responseBody"
    }
}