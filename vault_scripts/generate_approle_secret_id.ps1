$vaultRootToken = "root" # 실제 Vault root 토큰으로 교체하세요!
$roleName = "my-approle"
$outputFile = "secret_id.txt"

$body = @{}

try {
    $headers = @{"X-Vault-Token" = $vaultRootToken}
    $response = Invoke-RestMethod -Uri "http://localhost:8200/v1/auth/approle/role/$roleName/secret-id" -Method Post -Headers $headers -Body ($body | ConvertTo-Json -Compress) -ContentType "application/json"
    $secretId = $response.data.secret_id
    Write-Host "AppRole '$roleName'의 Secret ID 생성 성공: $secretId"
    Set-Content -Path $outputFile -Value $secretId
    Write-Host "Secret ID가 '$outputFile' 파일에 기록되었습니다."
} catch {
    Write-Error "AppRole '$roleName'의 Secret ID 생성 실패: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $responseBody = $reader.ReadToEnd()
        Write-Error "응답 본문: $responseBody"
    }
}