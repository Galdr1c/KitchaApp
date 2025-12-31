# Kitcha - MCP Entegrasyon Dokümantasyonu

KitchaApp, yapay zeka özelliklerini genişletmek ve kullanıcıya özel deneyimler sunmak için **Model Context Protocol (MCP)** standardını kullanır.

## Mimari Bakış

Kitcha, birden fazla MCP sunucusuyla iletişim kurarak farklı uzmanlık alanlarını birleştirir:

1.  **Recipe MCP:** Yemek tarifleri, besin değerleri ve mutfak ipuçları.
2.  **Vision MCP (Gemini/ML Kit):** Yemek fotoğraflarını analiz etme ve içerik tespiti.
3.  **Memory MCP (Mem0):** Kullanıcı tercihlerini öğrenme ve kişiselleştirilmiş öneriler sunma.
4.  **Notification MCP:** Akıllı hatırlatıcılar ve beslenme uyarıları.

## Teknik Özellikler

### Güvenlik
-   **Local Encryption:** Yerel SQLite veritabanı `SQLCipher` ile şifrelenmiştir. Şifreleme anahtarı `Flutter Secure Storage` üzerinde güvenli bir şekilde saklanır.
-   **Certificate Pinning:** MCP sunucu iletişimleri SSL sertifikası doğrulama ile korunur (Production).

### Performans
-   **Caching:** MCP sorgu sonuçları 5 dakika boyunca bellek üzerinde önbelleğe alınır.
-   **Image Optimization:** Analiz için yüklenen görseller otomatik olarak sıkıştırılır (1024px, 80% kalite).

### İzleme
-   **Firebase Analytics:** `mcp_call_success`, `mcp_call_failure` ve model kullanım istatistikleri takip edilir.
-   **Sentry:** Tüm MCP hataları ve protokol uyuşmazlıkları gerçek zamanlı olarak raporlanır.

## Build ve Deployment

Üretim aşaması için build komutu:
```bash
./scripts/build_release.sh appbundle
```

CI/CD süreci GitHub Actions üzerinden otomatik olarak yönetilir. Tüm API anahtarları GitHub Secrets üzerinden güvenli bir şekilde inject edilir.

---
*Geleceğin Akıllı Mutfağına Hoş Geldiniz.*
