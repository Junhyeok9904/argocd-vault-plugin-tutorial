$vaultRootToken = "root" # 실제 Vault root 토큰으로 교체하세요!
$roleName = "my-approle"
$outputFile = "../env/actual_avp_env.sh"

# Role ID 가져오기
try {
    $headers = @{"X-Vault-Token" = $vaultRootToken}
    $response = Invoke-RestMethod -Uri "http://localhost:8200/v1/auth/approle/role/$roleName/role-id" -Method Get -Headers $headers
    $roleId = $response.data.role_id
    Write-Host "AppRole '$roleName'의 Role ID: $roleId"
} catch {
    Write-Error "AppRole '$roleName'의 Role ID 가져오기 실패: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $responseBody = $reader.ReadToEnd()
        Write-Error "응답 본문: $responseBody"
    }
    exit 1
}

# Secret ID 생성
try {
    $headers = @{"X-Vault-Token" = $vaultRootToken}
    $response = Invoke-RestMethod -Uri "http://localhost:8200/v1/auth/approle/role/$roleName/secret-id" -Method Post -Headers $headers -Body (@{} | ConvertTo-Json -Compress) -ContentType "application/json"
    $secretId = $response.data.secret_id
    Write-Host "AppRole '$roleName'의 Secret ID 생성 성공: $secretId"
} catch {
    Write-Error "AppRole '$roleName'의 Secret ID 생성 실패: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $responseBody = $reader.ReadToEnd()
        Write-Error "응답 본문: $responseBody"
    }
    exit 1
}

# env/actual_avp_env.sh 파일 생성
$content = "export VAULT_ADDR=\"http://10.244.0.10:8200\"`nexport AVP_TYPE=\"vault\"`nexport AVP_AUTH_TYPE=\"approle\"`nexport AVP_ROLE_ID=\"$roleId\"`nexport AVP_SECRET_ID=\"$secretId\""
Set-Content -Path $outputFile -Value $content
Write-Host "'$outputFile' 파일이 성공적으로 생성되었습니다."
