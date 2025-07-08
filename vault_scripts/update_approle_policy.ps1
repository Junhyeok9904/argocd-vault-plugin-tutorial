$vaultRootToken = "root" # 실제 Vault root 토큰으로 교체하세요!
$roleName = "my-role"
$policyName = "test-policy"

$body = @{
    policies = @("default", "my-approle-policy", $policyName)
} | ConvertTo-Json -Compress

try {
    $headers = @{"X-Vault-Token" = $vaultRootToken}
    $response = Invoke-RestMethod -Uri "http://localhost:8200/v1/auth/approle/role/$roleName" -Method Post -Headers $headers -Body $body -ContentType "application/json"
    Write-Host "AppRole '$roleName'에 정책 '$policyName' 연결 성공: $($response | ConvertTo-Json -Depth 4)"
} catch {
    Write-Error "AppRole '$roleName'에 정책 '$policyName' 연결 실패: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $responseBody = $reader.ReadToEnd()
        Write-Error "응답 본문: $responseBody"
    }
}