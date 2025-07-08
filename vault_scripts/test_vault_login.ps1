$roleId = "836689b9-65f2-6057-fee7-37d3279cb361"
$secretId = "c46ab723-2822-c494-41e6-6b0ae53c7bfc"

$body = @{
    role_id = $roleId
    secret_id = $secretId
} | ConvertTo-Json -Compress

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8200/v1/auth/approle/login" -Method Post -Body $body -ContentType "application/json"
    Write-Host "Vault 로그인 성공: $($response | ConvertTo-Json -Depth 4)"
} catch {
    Write-Error "Vault 로그인 실패: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $responseBody = $reader.ReadToEnd()
        Write-Error "응답 본문: $responseBody"
    }
}