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

## 部署

### 全新安裝（cluster 內沒有任何資源）

```bash
task bootstrap-dev
```

### 已有其他專案在跑（共用 Traefik、registry、service namespace）

```bash
task bootstrap-dev:base
```

包含：建立 namespace → 建置並推送 image → 建立 secrets → 部署應用。

---

## 常用指令

| 指令 | 說明 |
|------|------|
| `task bootstrap-dev` | 全新安裝（含 Traefik、registry 等基礎設施） |
| `task bootstrap-dev:base` | 已有共用資源時，只部署本專案 |
| `task bootstrap-dev:app` | 重新部署應用（不重建 image） |
| `task bootstrap-dev:push-images` | 建置並推送應用 image |
| `task php -- php artisan <cmd>` | 在 php-fpm 容器執行 artisan 指令 |
| `task host` | 比對 external/internal gateway 實際部署的 host |
