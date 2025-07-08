$vaultToken = "hvs.CAESID0Rn97ygnycahprMG_FplGA5YV85cYjBdENxiSlaE8RGh4KHGh2cy5XdzZ5ZnNQR1Y4MnE0bUozdHJTS09mZFc"

try {
    $headers = @{"X-Vault-Token" = $vaultToken}
    $response = Invoke-RestMethod -Uri "http://localhost:8200/v1/secret/data/busybox-messages" -Method Get -Headers $headers
    Write-Host "Vault 시크릿 가져오기 성공: $($response | ConvertTo-Json -Depth 4)"
} catch {
    Write-Error "Vault 시크릿 가져오기 실패: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $responseBody = $reader.ReadToEnd()
        Write-Error "응답 본문: $responseBody"
    }
}