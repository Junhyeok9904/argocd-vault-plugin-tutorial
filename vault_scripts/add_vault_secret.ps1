$vaultRootToken = "root" # 실제 Vault root 토큰으로 교체하세요!
$secretPath = "secret/data/busybox-messages"
$secretKey = "message"
$secretValue = "Hello from Vault!"

$body = @{
    data = @{
        ($secretKey) = $secretValue
    }
} | ConvertTo-Json -Compress

try {
    $headers = @{"X-Vault-Token" = $vaultRootToken}
    $response = Invoke-RestMethod -Uri "http://localhost:8200/v1/$secretPath" -Method Post -Headers $headers -Body $body -ContentType "application/json"
    Write-Host "Vault 시크릿 '$secretPath'에 '$secretKey' 추가/업데이트 성공: $($response | ConvertTo-Json -Depth 4)"
} catch {
    Write-Error "Vault 시크릿 '$secretPath'에 '$secretKey' 추가/업데이트 실패: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $responseBody = $reader.ReadToEnd()
        Write-Error "응답 본문: $responseBody"
    }
}