# SesKernel - Samsung Galaxy M51 (SM7150) Özel Çekirdek (Custom Kernel)

Samsung Galaxy M51 (**SM-M515F** / `m51` / `m51nxx`) için Linux 4.14 tabanlı, sıfır donanım riski (stok saat ve voltaj sınırları korunmuş), yüksek performans ve pil tasarrufu odaklı özel çekirdek derleme deposu.

---

## 🚀 Entegre Edilen Özellikler

1. **KernelSU-Next (En Son Sürüm)**:
   - Linux 4.14 (non-GKI) çekirdeklerle tam uyumlu modern çekirdek seviyesi root.
   - En güncel KernelSU Manager uygulaması ve SuSFS gizleme desteği ile bankacılık uygulamalarında %100 gizlilik.
   - *(İsteğe bağlı olarak klasik Official KSU v0.9.5 seçeneği de mevcuttur).*
2. **Yerleşik WireGuard Sürücüsü**:
   - Kullanıcı alanı (userspace) yerine doğrudan çekirdek katmanında çalışan, ultra düşük gecikmeli ve minimum pil harcayan VPN tünelleme.
3. **Boeffla Wakelock Blocker (v1.1.0)**:
   - Ekran kapalıyken Qualcomm / Wi-Fi arka plan servislerinin işlemciyi gereksiz yere uyandırmasını engeller. Cihazın derin uykuya (Deep Sleep) geçiş oranını %90+ seviyesine çıkarır.
4. **zRAM ZSTD Bellek Sıkıştırma**:
   - Klasik LZO algoritması yerine ZSTD sıkıştırma motoru aktif edilerek RAM verimliliği ve çoklu görev akıcılığı artırılmıştır.
5. **AnyKernel3 Paketleme**:
   - OrangeFox ve TWRP recovery üzerinden tek tıkla kurulabilir, mevcut sistem ve vendor bölümlerine dokunmayan temiz kurulum paketi.

---

## ☁️ GitHub Actions ile Tek Tıkla Derleme (Önerilen)

Kendi bilgisayarınızda gigabaytlarca dosya indirmeden ve işlemcinizi yormadan **GitHub'ın güçlü sunucularında 8-10 dakikada** derleme yapabilirsiniz:

### Adım 1: Depoyu Kendi GitHub Hesabınıza Yükleyin
Terminalde bu klasörün içindeyken:

```bash
git init
git add .
git commit -m "Initial SesKernel M51 setup"
git branch -M main
git remote add origin https://github.com/<KULLANICI_ADINIZ>/<REPO_ADINIZ>.git
git push -u origin main
```

### Adım 2: Derlemeyi Başlatın
1. GitHub'da deponuza gidin ve üst menüden **Actions** sekmesine tıklayın.
2. Sol tarafta **"Build Galaxy M51 Custom Kernel (SM7150)"** iş akışını seçin.
3. Sağ taraftaki **"Run workflow"** butonuna basın:
   - **KernelSU Sürümü:** `KernelSU-Next (En Son)` (veya tercihiniz)
   - **WireGuard Entegrasyonu:** `true`
   - **Boeffla Wakelock Blocker:** `true`
   - **zRAM ZSTD Sıkıştırma:** `true`
4. Yeşil **"Run workflow"** butonuna tıklayın.

### Adım 3: Flashlanabilir .zip Dosyasını İndirin
- Derleme yaklaşık 8-10 dakika içinde başarıyla tamamlanacaktır.
- Biten çalıştırmanın üzerine tıklayın ve alt kısımdaki **Artifacts** bölümünden `SesKernel-M51-SM7150-XXXXXXXX-XXXX.zip` dosyasını telefonunuza indirin.

---

## 📲 Kurulum ve Doğrulama Adımları (OrangeFox Recovery)

> [!IMPORTANT]
> Kuruluma geçmeden önce mutlaka **OrangeFox Recovery** üzerinden mevcut `Boot` ve `DTBO` bölümlerinin yedeğini (Backup) alın.

1. İndirdiğiniz `.zip` dosyasını telefon hafızasına veya SD karta atın.
2. Cihazı **OrangeFox Recovery** modunda başlatın.
3. **Yedek (Backup)** menüsüne girip `Boot` ve `DTBO` bölümlerini yedekleyin.
4. **Dosyalar (Files)** menüsünden `SesKernel-M51-SM7150-*.zip` dosyasını seçin ve çubuğu kaydırarak flaşlayın.
5. İşlem bitince **"Wipe Caches/Dalvik"** yapıp sistemi yeniden başlatın (**Reboot System**).

---

## 🔍 Kurulum Sonrası Kontroller

Cihaz açıldıktan sonra entegrasyonları doğrulamak için:

1. **KernelSU:**
   - En son [KernelSU-Next Manager APK](https://github.com/rifsxd/KernelSU-Next/releases) uygulamasını kurun.
   - Uygulamayı açtığınızda ana ekranda yeşil **"Çalışıyor" (Working)** ibaresini görmelisiniz.
2. **zRAM ZSTD Kontrolü:**
   - Terminal emülatöründe (veya ADB shell):
     ```bash
     cat /sys/block/zram0/comp_algorithm
     ```
   - Çıktıda `[zstd]` algoritmasının seçili olduğunu doğrulayın.
3. **Boeffla Wakelock Blocker:**
   - Terminal emülatöründe:
     ```bash
     cat /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker
     ```
   - Engellenen varsayılan wakelock listesini görebilirsiniz.
