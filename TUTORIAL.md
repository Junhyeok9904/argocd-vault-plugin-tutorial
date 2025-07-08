# Argo CD Vault Plugin 테스트 튜토리얼 🚀

이 튜토리얼은 Kind Kubernetes 환경에서 Vault와 Argo CD를 설정하고, `argocd-vault-plugin`을 사용하여 Vault 시크릿이 Argo CD 애플리케이션에 올바르게 주입되는지 테스트하는 과정을 안내합니다. 함께 GitOps의 마법을 경험해 볼까요? ✨

## 1. 환경 구현 (Windows) 💻

Windows 환경에서 필요한 도구들을 Winget을 사용하여 간편하게 설치합니다. 마치 마법 지팡이를 휘두르듯! 🪄

### 1.1 Docker Desktop 설치 🐳

Kind 클러스터를 실행하기 위해 Docker Desktop이 필요해요. Winget을 사용하여 설치하기 전에 먼저 검색해서 정확한 패키지 ID를 확인하는 센스! 😉

```bash
winget search "Docker Desktop"
```

**검색 결과 예시:**
```
이름                장치 ID                  버전        원본
----------------------------------------------------------------
Docker Desktop      Docker.DockerDesktop     4.43.0      winget
Docker Desktop Edge Docker.DockerDesktopEdge 2.5.4.50534 winget
```

위 검색 결과에서 `Docker.DockerDesktop` ID를 사용하여 설치합니다.

```bash
winget install Docker.DockerDesktop
```

**💡 팁:** 설치 후 Docker Desktop을 실행하고, **반드시 Kubernetes를 활성화**해야 해요! 잊지 마세요! 🔔 Docker Desktop 설정에서 Kubernetes 탭을 찾아 체크하고 적용하면 됩니다. 시간이 좀 걸릴 수 있으니 커피 한 잔의 여유를 즐겨보세요. ☕

### 1.2 Kind 설치 👶

Kind (Kubernetes in Docker)는 로컬 Kubernetes 클러스터를 Docker 컨테이너 내에서 실행할 수 있게 해주는 아주 유용한 도구입니다. Winget으로 설치하기 전에 역시 검색으로 확인해볼까요?

```bash
winget search Kubernetes.Kind
```

**검색 결과 예시:**
```
이름 장치 ID         버전   원본
-----------------------------------
kind Kubernetes.kind 0.29.0 winget
```

위 검색 결과에서 `Kubernetes.Kind` ID를 사용하여 설치합니다.

```bash
winget install Kubernetes.Kind
```

**💡 팁:** Kind는 Docker 위에 Kubernetes를 띄우는 방식이라 가볍고 빠르게 클러스터를 만들 수 있어요. 로컬 개발 환경에 딱이죠! 👍

### 1.3 Helm 설치 ⛑️

Helm은 Kubernetes 애플리케이션을 관리하는 패키지 매니저, 일명 Kubernetes의 `apt`나 `brew` 같은 존재입니다. Winget으로 설치하기 전에 검색은 필수! 🔍

```bash
winget search Helm.Helm
```

**검색 결과 예시:**
```
이름 장치 ID   버전   원본
-----------------------------
Helm Helm.Helm 3.18.3 winget
```

위 검색 결과에서 `Helm.Helm` ID를 사용하여 설치합니다.

```bash
winget install Helm.Helm
```

**💡 팁:** Helm은 복잡한 Kubernetes 애플리케이션을 한 번에 배포하고 관리하는 데 정말 편리해요. 마치 레고 블록처럼요! 🧱

## 2. Kind 클러스터 생성 및 확인 🏗️

이제 로컬에서 나만의 Kubernetes 클러스터를 만들어 볼 시간입니다! 🚀

### 2.1 Kind 클러스터 생성

Kind 클러스터를 생성합니다. 기본적으로 `kind create cluster` 명령어를 사용하면 `kind`라는 이름의 클러스터가 생성됩니다. 만약 다른 이름으로 만들고 싶다면 `--name` 옵션을 사용하세요. (예: `kind create cluster --name my-awesome-cluster`)

```bash
kind create cluster
```

**💡 팁:** 클러스터 생성에는 몇 분 정도 소요될 수 있어요. Docker 이미지를 다운로드하고 Kubernetes 컴포넌트들을 초기화하는 과정이 필요하기 때문이죠. 인내심을 가지고 기다려주세요! 🧘

### 2.2 클러스터 상태 확인

클러스터가 잘 생성되었는지 확인해봐야겠죠? `kubectl` 명령어를 사용하여 클러스터의 노드 상태 및 클러스터 정보를 확인합니다.

```bash
kubectl get nodes
kubectl cluster-info
```

**💡 팁:** `kubectl get nodes` 명령으로 `Ready` 상태의 노드를 확인하고, `kubectl cluster-info`로 클러스터 API 서버 주소를 확인할 수 있어요. 모든 것이 초록불이라면 성공! ✅

## 3. Vault 배포 및 초기 설정 🔐

이제 우리의 비밀을 안전하게 지켜줄 Vault를 배포하고 초기 설정을 해볼까요? 여기서는 HashiCorp에서 제공하는 공식 Helm 차트를 사용합니다.

### 3.1 Helm Repository 추가

먼저 HashiCorp Helm Repository를 추가합니다. 마치 보물 지도를 얻는 것과 같아요! 🗺️

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
```

**💡 팁:** `helm repo update`는 추가된 모든 Helm Repository의 최신 차트 정보를 가져옵니다. 주기적으로 실행해주면 좋아요! 👍

### 3.2 Vault 설치

Vault를 개발 모드로 설치하여 빠르게 테스트 환경을 구성합니다. 실제 운영 환경에서는 더 복잡하고 안전한 설정이 필요하다는 점, 잊지 마세요! ⚠️

```bash
helm install vault hashicorp/vault --set server.dev.enabled=true --set server.dev.devRootToken=root
```

`--set server.dev.enabled=true`는 개발 모드를 활성화하고, `--set server.dev.devRootToken=root`는 개발용 root 토큰을 `root`로 설정합니다. 이 토큰은 **절대 프로덕션 환경에서 사용하면 안 됩니다!** 🚨

설치 후 Vault Pod가 실행될 때까지 기다립니다. `kubectl get pods` 명령으로 `STATUS`가 `Running`이 될 때까지 지켜보세요. 마치 새싹이 자라나는 것처럼요! 🌱

```bash
kubectl get pods -l app.kubernetes.io/name=vault
```

**💡 팁:** Pod가 `Running` 상태가 되지 않는다면 `kubectl describe pod <VAULT_POD_NAME>`이나 `kubectl logs <VAULT_POD_NAME>` 명령으로 원인을 파악할 수 있어요. 당황하지 마세요! 🕵️‍♀️

### 3.3 Vault 로그인 테스트

Vault가 정상적으로 작동하는지 확인하기 위해 `kubectl exec`를 사용하여 Vault Pod에 접속하고 root 토큰으로 로그인 테스트를 진행합니다. 마치 비밀 금고의 문을 여는 열쇠를 확인하는 과정이죠! 🔑

```bash
kubectl exec -it vault-0 -- vault login root
```

**예시 출력:**
```
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                root
token_accessor       AACsnvUu6FGIMWQc94SCxFFd
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
```

`Success! You are now authenticated.` 메시지가 출력되면 Vault에 root 토큰으로 성공적으로 로그인한 것입니다. 축하합니다! 🎉

## 4. Vault 고급 설정 및 시크릿 관리 🔑

이제 Vault에 시크릿을 저장하고, Argo CD Vault Plugin이 사용할 AppRole을 설정하는 중요한 단계입니다. 마치 비밀 요원이 임무를 수행하기 위해 필요한 도구들을 준비하는 것과 같아요! 🕵️‍♀️

### 4.1 Vault 서비스 포트 포워딩

별도의 터미널에서 Vault 서비스에 접근하기 위해 포트 포워딩을 설정합니다. 이 명령은 터미널이 닫히기 전까지 계속 실행되니, 새로운 터미널 창을 열어서 실행하는 것을 추천해요! 🚪

```bash
kubectl port-forward service/vault 8200:8200
```

**💡 팁:** 포트 포워딩은 Kubernetes 클러스터 내부의 서비스에 로컬 머신에서 접근할 수 있도록 터널을 열어주는 역할을 합니다. 개발 및 테스트 환경에서 유용하게 사용돼요. 🌐

### 4.2 Vault 시크릿 생성

`vault_scripts/add_vault_secret.ps1` 스크립트를 사용하여 Vault에 시크릿을 저장합니다. 이 시크릿은 나중에 Argo CD 애플리케이션에서 참조할 우리의 소중한 비밀 정보가 될 거예요! 🤫

```powershell
./vault_scripts/add_vault_secret.ps1
```

**예시 출력:**
```
Vault 시크릿 'secret/data/busybox-messages'에 'message' 추가/업데이트 성공: ...
```

**💡 팁:** `secret/data/busybox-messages` 경로는 Vault의 KV Secret Engine v2에서 데이터를 저장하는 방식입니다. `data` 아래에 실제 시크릿 데이터가 저장돼요. 📁

### 4.3 AppRole 활성화

`vault_scripts/enable_approle.ps1` 스크립트를 사용하여 Vault에 AppRole 인증 방법을 활성화합니다. AppRole은 애플리케이션이 Vault에 안전하게 인증할 수 있도록 도와주는 방법이에요. 🤝

```powershell
./vault_scripts/enable_approle.ps1
```

**예시 출력:**
```
AppRole 인증 방법 활성화 성공
```

**💡 팁:** AppRole은 Role ID와 Secret ID를 사용하여 인증하는 방식입니다. 마치 사용자 이름과 비밀번호처럼요! 🆔🔑

### 4.4 AppRole 생성

`vault_scripts/create_approle.ps1` 스크립트를 사용하여 `my-approle`이라는 이름의 AppRole을 생성합니다. 이 AppRole이 나중에 Argo CD Reposerver가 Vault에 접근할 때 사용될 거예요. 🤖

```powershell
./vault_scripts/create_approle.ps1
```

**예시 출력:**
```
AppRole 'my-approle' 생성 성공
```

### 4.5 AppRole 정책 설정

`vault_scripts/update_my_approle_policy.ps1` 스크립트를 사용하여 `my-approle-policy`를 설정하고, 이 정책이 `secret/data/busybox-messages` 경로의 시크릿을 읽을 수 있도록 허용합니다. 권한을 부여하는 중요한 단계죠! 🛡️

```powershell
./vault_scripts/update_my_approle_policy.ps1
```

**예시 출력:**
```
Vault 정책 'my-approle-policy' 업데이트 성공: ...
```

### 4.6 AppRole에 정책 연결

`vault_scripts/update_approle_policy.ps1` 스크립트를 사용하여 생성한 AppRole (`my-approle`)에 `my-approle-policy`를 연결합니다. 이제 `my-approle`은 `my-approle-policy`가 가진 권한을 행사할 수 있게 됩니다. 🔗

```powershell
./vault_scripts/update_approle_policy.ps1
```

**예시 출력:**
```
AppRole 'my-role'에 정책 'test-policy' 연결 성공: ...
```

### 4.7 AppRole Role ID 확보

`vault_scripts/get_approle_role_id.ps1` 스크립트를 사용하여 `my-approle`의 Role ID를 확보합니다. 이 ID는 AppRole 인증의 공개적인 부분입니다. 📋

```powershell
./vault_scripts/get_approle_role_id.ps1
```

**예시 출력:**
```
AppRole 'my-approle'의 Role ID: 836689b9-65f2-6057-fee7-37d3279cb361
```

### 4.8 AppRole Secret ID 확보

`my-approle`의 Secret ID를 생성하고 확보하는 방법은 두 가지가 있습니다. 스크립트를 사용하거나 Vault CLI를 직접 사용하는 방법입니다. 이 ID는 비밀스러운 부분이니 잘 보관해야 해요! 🤫

#### 4.8.1 PowerShell 스크립트 사용

`vault_scripts/generate_approle_secret_id.ps1` 스크립트를 사용하여 Secret ID를 생성하고 `secret_id.txt` 파일에 기록합니다.

```powershell
./vault_scripts/generate_approle_secret_id.ps1
```

**예시 출력:**
```
AppRole 'my-approle'의 Secret ID 생성 성공: c46ab723-2822-c494-41e6-6b0ae53c7bfc
Secret ID가 'secret_id.txt' 파일에 기록되었습니다.
```

#### 4.8.2 Vault CLI 직접 사용

Vault CLI를 사용하여 Secret ID를 직접 생성할 수도 있습니다. 이 방법은 `vault_scripts/generate_approle_secret_id.ps1` 스크립트가 내부적으로 수행하는 작업과 동일합니다.

먼저 Vault Pod에 접속하여 `vault login root`로 로그인합니다. (이미 로그인되어 있다면 생략 가능)

```bash
kubeclt exec -it vault-0 -- vault login root
```

그 다음, 다음 명령어를 실행하여 Secret ID를 생성합니다.

```bash
kubeclt exec -it vault-0 -- vault write -f auth/approle/role/my-approle/secret-id
```

**예시 출력:**
```
Key                   Value
---                   -----
secret_id             c46ab723-2822-c494-41e6-6b0ae53c7bfc
secret_id_accessor    ... (생략)
secret_id_ttl         0s
```

여기서 `secret_id` 값을 기록해 두세요. 이 값은 `secret_id.txt` 파일에 기록되는 값과 동일합니다. 📝

**💡 팁:** `vault write -f` 명령은 새로운 Secret ID를 강제로 생성합니다. 기존에 생성된 Secret ID가 있다면 새로운 ID가 발급됩니다. 🔄

### 4.9 AppRole로 시크릿 데이터 확인

확보한 Role ID와 Secret ID를 사용하여 AppRole로 로그인하고, `get_vault_secret.ps1` 스크립트를 통해 시크릿 데이터를 가져올 수 있는지 확인합니다. 모든 설정이 잘 되었는지 최종 점검하는 단계입니다! ✅

먼저 `env/actual_avp_env.sh` 파일을 생성하여 환경 변수를 설정합니다. 이 파일은 `vault_scripts/generate_actual_avp_env.ps1` 스크립트를 실행하여 생성됩니다.

```powershell
./vault_scripts/generate_actual_avp_env.ps1
```

**예시 출력:**
```
AppRole 'my-approle'의 Role ID: 836689b9-65f2-6057-fee7-37d3279cb361
AppRole 'my-approle'의 Secret ID 생성 성공: c46ab723-2822-c494-41e6-6b0ae53c7bfc
'../env/actual_avp_env.sh' 파일이 성공적으로 생성되었습니다.
```

이제 `env/actual_avp_env.sh` 파일을 소싱하여 환경 변수를 설정하고, `get_vault_secret.ps1` 스크립트를 실행하여 시크릿을 가져옵니다.

```bash
source ./env/actual_avp_env.sh
./vault_scripts/get_vault_secret.ps1
```

**예시 출력:**
```
Vault 시크릿 가져오기 성공: {
    "request_id": "...",
    "lease_id": "",
    "renewable": false,
    "lease_duration": 2764800,
    "data": {
        "data": {
            "message": "Hello from Vault!"
        },
        "metadata": {
            "created_time": "2024-07-08T12:00:00.000000Z",
            "custom_metadata": null,
            "deleted_time": "",
            "destroyed": false,
            "version": 1
        }
    },
    "wrap_info": null,
    "warnings": null,
    "auth": null
}
```

`"message": "Hello from Vault!"`와 같은 내용이 출력되면 AppRole을 통해 시크릿 데이터에 성공적으로 접근한 것입니다. 완벽해요! 🎉

## 5. Argo CD 배포 및 설정 🚢

이제 GitOps의 핵심 도구인 Argo CD를 배포하고 `argocd-vault-plugin`을 사용하도록 설정할 차례입니다. 마치 지휘관이 함대를 배치하는 것과 같아요! ⚓

### 5.1 Argo CD Helm Repository 추가

Argo CD Helm Repository를 추가하고 업데이트합니다. 최신 Argo CD 버전을 사용하기 위한 필수 단계입니다. 🔄

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

**💡 팁:** `helm repo update`는 모든 추가된 Helm Repository의 최신 차트 정보를 가져옵니다. 새로운 차트나 업데이트된 차트를 사용하려면 꼭 실행해주세요! 🚀

### 5.2 Argo CD 설치

`argocd/argocd-values.yaml` 파일을 사용하여 Argo CD를 설치합니다. 이 `values.yaml` 파일에는 `argocd-vault-plugin`을 위한 CMP(Config Management Plugin) 설정이 포함되어 있어요. 이 설정 덕분에 Argo CD가 Vault에서 시크릿을 가져올 수 있게 됩니다. 🪄

```bash
helm install argocd argo/argo-cd -n argocd --create-namespace -f argocd/argocd-values.yaml
```

설치 후 Argo CD Pod들이 실행될 때까지 기다립니다. `kubectl get pods -n argocd` 명령으로 모든 Pod의 `STATUS`가 `Running`이 될 때까지 지켜보세요. 🚦

```bash
kubectl get pods -n argocd
```

**💡 팁:** Argo CD는 여러 컴포넌트로 구성되어 있어요 (API 서버, 컨트롤러, 리포 서버 등). 모든 컴포넌트가 정상적으로 실행되어야 Argo CD가 제대로 작동합니다. 🛠️

### 5.3 Argo CD CLI 설치

Winget을 사용하여 Argo CD CLI를 설치합니다. CLI를 사용하면 터미널에서 Argo CD를 편리하게 관리할 수 있어요. 💻

```bash
winget search Argo.ArgoCD
```

**검색 결과 예시:**
```
이름       장치 ID      버전   원본
-----------------------------------
Argo CD    Argo.ArgoCD  2.11.2 winget
```

위 검색 결과에서 `Argo.ArgoCD` ID를 사용하여 설치합니다.

```bash
winget install Argo.ArgoCD
```

**💡 팁:** Argo CD CLI는 `argocd` 명령어로 실행됩니다. 설치 후 `argocd version`을 입력하여 설치를 확인해 보세요! ✅

### 5.4 Argo CD CLI 로그인

Argo CD CLI를 사용하여 Argo CD에 로그인합니다. 먼저 Argo CD 서버의 초기 비밀번호를 가져와야 해요. 이 비밀번호는 한 번만 사용하고 변경하는 것이 좋습니다. 🔒

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

위 명령어로 얻은 비밀번호를 사용하여 로그인합니다. Argo CD 서버의 주소는 `localhost:8080`으로 포트 포워딩하여 접근할 수 있어요. 별도의 터미널에서 Argo CD 서버 포트 포워딩을 실행합니다.

```bash
kubectl port-forward service/argocd-server -n argocd 8080:80
```

이제 로그인합니다.

```bash
argocd login localhost:8080
```

프롬프트가 나타나면 `admin` 사용자 이름과 위에서 얻은 비밀번호를 입력합니다.

**예시 출력:**
```
Username: admin
Password: <초기 비밀번호 입력>
'localhost:8080' added successfully
```

로그인에 성공하면 Argo CD CLI를 사용할 준비가 된 것입니다. 이제 GitOps의 세계로 떠날 준비 완료! 🗺️

## 7. Argo CD Reposerver에서 Vault Plugin 테스트 🧪

`argocd-vault-plugin`이 Argo CD Reposerver에서 올바르게 작동하는지 확인하기 위해, Reposerver 컨테이너에 직접 접속하여 테스트를 진행합니다. 마치 현장 조사를 나가는 탐정처럼요! 🕵️

### 7.1 Reposerver Pod 이름 확인

먼저 `argocd-reposerver` Pod의 이름을 확인합니다. 이 Pod가 바로 `argocd-vault-plugin`이 실행되는 곳이에요. 📍

```bash
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-reposerver
```

**예시 출력:**
```
NAME                                READY   STATUS    RESTARTS   AGE
argocd-reposerver-xxxxxxxxxx-yyyyy   1/1     Running   0          5m
```

**💡 팁:** `argocd-reposerver` Pod는 Git 리포지토리에서 애플리케이션 매니페스트를 가져와 렌더링하는 역할을 합니다. `argocd-vault-plugin`은 이 과정에서 Vault 시크릿을 주입하죠. 🔄

### 7.2 Reposerver 컨테이너 접속 및 환경 변수 설정

확인된 Reposerver Pod에 `kubectl exec`로 접속합니다. 그리고 `env/reposerver_env.sh` 파일의 내용을 환경 변수로 설정합니다. 이 파일은 `VAULT_ADDR`, `AVP_TYPE`, `AVP_AUTH_TYPE`, `AVP_ROLE_ID`, `AVP_SECRET_ID`와 같은 중요한 환경 변수를 포함하고 있어요. 🌍

```bash
REPOSERVER_POD_NAME=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-reposerver -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $REPOSERVER_POD_NAME -n argocd -- bash
```

컨테이너 내부에 접속한 후, `env/reposerver_env.sh` 파일의 내용을 소싱하여 환경 변수를 설정합니다. (실제 환경에서는 Argo CD Reposerver Pod에 이 환경 변수들이 설정되어 있어야 합니다.)

```bash
source /app/config/reposerver_env.sh # Reposerver 컨테이너 내의 경로에 따라 다를 수 있습니다.
```

**💡 팁:** `source` 명령은 스크립트 파일을 현재 쉘에서 실행하여 스크립트 내의 환경 변수를 현재 쉘에 적용합니다. `kubectl exec`로 접속한 쉘에서 이 환경 변수들이 설정되어야 `argocd-vault-plugin`이 Vault에 접근할 수 있어요. 🎯

### 7.3 `argocd-vault-plugin generate` 테스트

이제 `argocd-vault-plugin generate` 명령어를 사용하여 Helm 차트 (`helm/busybox-chart-test`)와 Kubernetes 매니페스트 (`kubernetes/test-app.yaml`)가 Vault 시크릿을 포함하여 올바르게 렌더링되는지 테스트합니다. 두근두근! 결과는? 🥁

**Helm 차트 테스트:**

```bash
argocd-vault-plugin generate helm/busybox-chart-test
```

**예시 출력 (일부):**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: Hello from Vault!
  labels:
    app: busybox-pod
spec:
  containers:
    - name: busybox-container
      image: busybox
      imagePullPolicy: IfNotPresent
      command: ["/bin/sh", "-c"]
      args: ["while true; do echo hi; sleep 5; done"]
```

`metadata.name` 필드에 Vault에서 가져온 시크릿 값인 `Hello from Vault!`가 올바르게 주입되었는지 확인합니다. 성공! 🎉

**Kubernetes 매니페스트 테스트:**

```bash
argocd-vault-plugin generate kubernetes/test-app.yaml
```

**예시 출력 (일부):**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-app
  labels:
    app: test-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-app
  template:
    metadata:
      labels:
        app: test-app
    spec:
      containers:
      - name: test-container
        image: alpine/git
        command: ["sh", "-c", "echo Hello from test-app && sleep 3600"]
        env:
        - name: VAULT_PASSWORD
          value: Hello from Vault!
```

`VAULT_PASSWORD` 환경 변수에 Vault에서 가져온 시크릿 값인 `Hello from Vault!`가 올바르게 주입되었는지 확인합니다. 이것도 성공! 🥳

테스트가 완료되면 `exit` 명령어를 사용하여 Reposerver 컨테이너에서 나옵니다. 수고하셨습니다! 👋

```bash
exit
```


## 8. Argo CD 애플리케이션 배포 및 시크릿 확인 🚀

이제 모든 준비가 끝났습니다! Argo CD CLI를 사용하여 애플리케이션을 배포하고, 배포된 Pod의 로그를 확인하여 Vault 시크릿이 올바르게 주입되었는지 최종 검증하는 단계입니다. GitOps의 힘을 느껴보세요! 💪

### 8.1 Argo CD 애플리케이션 생성

`kubernetes/test-app.yaml` 파일을 참조하는 Argo CD 애플리케이션을 생성합니다. 이 애플리케이션은 `argocd-vault-plugin`을 사용하도록 설정되어 있어, Vault에서 시크릿을 안전하게 가져올 수 있습니다. 🛡️

```bash
argocd app create test-app --repo <YOUR_GIT_REPO_URL> --path kubernetes --dest-server https://kubernetes.default.svc --dest-namespace default --plugin argocd-vault-plugin
```

*   `<YOUR_GIT_REPO_URL>`: **이 튜토리얼 파일들이 위치한 Git Repository의 URL로 변경해야 합니다.** (예: `https://github.com/your-username/argocd-vault-plugin-test.git`) 이 부분을 꼭! 수정해주세요. 📝

**💡 팁:** `argocd app create` 명령은 Argo CD에 애플리케이션을 등록하는 역할을 합니다. 실제 배포는 동기화 과정을 통해 이루어져요. 🔗

### 8.2 애플리케이션 동기화

생성된 애플리케이션을 동기화하여 Kubernetes 클러스터에 배포합니다. Argo CD가 Git의 상태를 클러스터에 반영하는 마법 같은 순간입니다! ✨

```bash
argocd app sync test-app
```

**💡 팁:** `argocd app sync` 명령은 Git 리포지토리의 최신 상태를 클러스터에 적용합니다. 변경 사항이 있을 때마다 이 명령을 실행하여 클러스터를 업데이트할 수 있어요. 🔄

### 8.3 배포된 Pod 로그 확인

애플리케이션이 성공적으로 배포되면, `test-app` Pod의 로그를 확인하여 Vault 시크릿이 환경 변수로 올바르게 주입되었는지 검증합니다. 우리의 비밀이 잘 전달되었는지 확인하는 마지막 단계! 🕵️‍♀️

먼저 `test-app` Pod의 이름을 확인합니다.

```bash
kubectl get pods -l app=test-app
```

**예시 출력:**
```
NAME                       READY   STATUS    RESTARTS   AGE
test-app-xxxxxxxxxx-yyyyy   1/1     Running   0          2m
```

확인된 Pod의 로그를 확인합니다.

```bash
kubectl logs <TEST_APP_POD_NAME>
```

**예시 출력:**
```
Hello from test-app
```

이 로그는 `test-app.yaml`에 정의된 `command`와 `args`에 따라 출력됩니다. `VAULT_PASSWORD` 환경 변수가 제대로 주입되었는지 확인하려면, Pod 내에서 환경 변수를 출력하는 명령을 실행해야 합니다.

```bash
kubectl exec <TEST_APP_POD_NAME> -- printenv VAULT_PASSWORD
```

**예시 출력:**
```
Hello from Vault!
```

`Hello from Vault!`가 출력되면 `argocd-vault-plugin`을 통해 Vault 시크릿이 애플리케이션에 성공적으로 주입된 것입니다. 🎉🎉🎉

**축하합니다!** 이제 Argo CD와 Vault를 연동하여 시크릿을 안전하게 관리하고 배포하는 방법을 완벽하게 익히셨습니다! 🥳
