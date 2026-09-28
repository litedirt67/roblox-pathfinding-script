# Roblox Auto Vehicle Waypoint System

Script Roblox untuk mengendarai kendaraan otomatis ke waypoint yang tersimpan.

## Fitur
- 💾 Simpan waypoint manual dengan tombol F
- 🚗 Gerakkan kendaraan ke waypoint terakhir
- 🚀 Gerakkan kendaraan ke semua waypoint berturut-turut
- 🗑️ Hapus semua waypoint
- 🎯 Otomatis menghitung rute dan steering
- ⚡ Kompatibel dengan semua jenis kendaraan yang punya PrimaryPart/RootPart

## Instalasi

### 1. Copy server script
Paste isi file `roblox/ServerScriptService/AutoVehicleWaypoint.server.lua` ke:
```
ServerScriptService -> AutoVehicleWaypoint (server script)
```

### 2. Copy client script
Paste isi file `roblox/StarterPlayer/VehicleWaypointClient.client.lua` ke:
```
StarterPlayer -> StarterPlayerScripts -> VehicleWaypointClient (local script)
```

## Cara Pakai

### Menyimpan Waypoint
1. Naik ke kendaraan
2. Tekan tombol **F** di posisi yang ingin disimpan
3. Marker hijau neon akan muncul di Workspace sebagai penanda waypoint

### Mengarahkan Kendaraan

**Ke Waypoint Terakhir:**
```
Tekan G
```

**Ke Semua Waypoint (Berturut-turut):**
```
Tekan H
```

**Hapus Semua Waypoint:**
```
Tekan X
```

## Kontrol Keyboard

| Tombol | Fungsi |
|--------|--------|
| **F** | Simpan waypoint di posisi saat ini |
| **G** | Gerakkan kendaraan ke waypoint terakhir |
| **H** | Gerakkan kendaraan ke semua waypoint |
| **X** | Hapus semua waypoint |

## Struktur Waypoint

Setiap waypoint disimpan sebagai Part di folder `SavedWaypoints` di Workspace:
```
Workspace
  SavedWaypoints
    Waypoint_1 (Part - Neon Cylinder)
    Waypoint_2 (Part - Neon Cylinder)
    Waypoint_3 (Part - Neon Cylinder)
```

## Spesifikasi Teknis

- **Kecepatan Kendaraan:** 25 studs/detik
- **Jarak Berhenti:** 5 studs dari target
- **Timeout:** 5 menit per waypoint
- **Kontrol:** BodyGyro (rotation) + BodyVelocity (movement)

## Kompatibilitas

✅ Kendaraan dengan `PrimaryPart`
✅ Kendaraan dengan `RootPart`
✅ Kendaraan dengan `VehicleSeat`
✅ Custom vehicle model
✅ Semua kendaraan Roblox standar

## Catatan Penting

- Script bekerja saat player **sedang naik kendaraan**
- Kendaraan harus punya `PrimaryPart` atau `RootPart` untuk bisa bergerak
- Jika kendaraan tidak bisa bergerak, cek apakah `PrimaryPart` sudah diset di properties
- Marker waypoint tidak collision, hanya visual
- Script otomatis menghitung steering dan arah berjalan

## Customization

Ubah parameter di script server untuk menyesuaikan:

```lua
local reached = 5          -- Jarak berhenti (studs)
local speed = 25           -- Kecepatan kendaraan (studs/detik)
local maxTime = 300        -- Timeout (detik)
```

## Troubleshooting

**Kendaraan tidak bergerak:**
- Pastikan `PrimaryPart` sudah diset di properties kendaraan
- Cek apakah `BodyGyro` dan `BodyVelocity` sudah dibuat
- Pastikan player benar-benar naik di kendaraan

**Kendaraan bergerak tapi tidak ke target:**
- Cek apakah waypoint tersimpan dengan benar (lihat marker hijau)
- Naikkan nilai `speed` atau sesuaikan `reached` distance
- Pastikan tidak ada obstacle yang menghalangi

**Script error:**
- Pastikan `Workspace` dapat diakses
- Pastikan `VehicleWaypointEvent` berhasil dibuat
- Cek console untuk error message
