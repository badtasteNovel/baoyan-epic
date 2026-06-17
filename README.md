# baoyan-epic

Laravel + k3s 本地開發環境。

## 從舊專案複製建立新專案的注意事項

將 k3s deploy 部分從既有專案搬移過來時，以下幾個地方容易漏掉：

- `docker/` 目錄（Dockerfile 集合）需要一起搬，`push-images` 才能跑
- `bootstrap/app.php` 需要設定 `trustProxies`，否則 Laravel 無法正確識別 cluster 內部的 proxy IP

```php
->withMiddleware(function (Middleware $middleware): void {
    $middleware->trustProxies(at: '10.0.0.0/8');
    // ...
})
```

---

## 新專案部署順序

### 1. 修改 hostname

編輯以下兩個檔案，把舊的 hostname 換成新專案的 hostname：

- `deploy/helm/infra/gateways/charts/external/templates/gateway-ingress.yaml`
- `deploy/helm/infra/gateways/charts/internal/templates/gateway-ingress.yaml`

### 2. 部署 Traefik ingress

```bash
task bootstrap-dev:ingress
```

跑完後確認兩邊的 host 是否同步（交集才算真的可連線）：

```bash
task host
```

輸出範例：
```
=== external-gateway ===
  ✓ argo.local
  ✓ baoyan-epic.local
  ...

=== internal-gateway ===
  ✓ argo.local
  ✓ baoyan-epic.local
  ...

=== ✅ 可連線的 host（兩邊都有）===
  ✓ argo.local
  ✓ baoyan-epic.local
  ...
```

若 `可連線的 host` 沒有出現新 hostname，代表 ingress 沒更新成功，需要重新確認檔案內容並重跑。

### 3. 建置並推送基底 image

```bash
task bootstrap-dev:push-static-images
```

建置 `my-php-base`、`my-ops-toolbox`、`my-ci-runner` 等基底 image 並推至 local registry。下一步的 `push-images` 依賴 `my-php-base`，必須先跑。

### 4. 建置並推送應用 image

```bash
task bootstrap-dev:push-images
```

依賴上一步的 `my-php-base`。建置 `my-dev-php-fpm`、`my-vite-server`、`my-inner-unprivileged-nginx` 並推至 local registry。

### 5. 部署應用程式

```bash
task bootstrap-dev:app
```

---

## 常用指令

| 指令 | 說明 |
|------|------|
| `task host` | 比對 external/internal gateway 實際部署的 host |
| `task bootstrap-dev:ingress` | 重新部署 Traefik ingress |
| `task bootstrap-dev:push-static-images` | 建置並推送基底 image（my-php-base 等） |
| `task bootstrap-dev:push-images` | 建置並推送應用 image（依賴 push-static-images） |
| `task bootstrap-dev:app` | 部署應用程式 |
| `task php -- php artisan <cmd>` | 在 php-fpm 容器執行 artisan 指令 |
