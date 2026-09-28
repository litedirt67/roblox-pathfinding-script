# Roblox Saved Waypoint Pathfinding

Script Roblox sederhana untuk:
- menyimpan waypoint secara manual
- menjalankan NPC/karakter menuju waypoint yang tersimpan
- memakai PathfindingService dari Roblox

File yang tersedia:
- `roblox/ServerScriptService/WaypointPathfinder.server.lua`
- `roblox/StarterPlayer/ManualWaypointSaver.client.lua`

## Cara pakai

### 1) Masukkan script server
Buka Roblox Studio, lalu paste isi file `roblox/ServerScriptService/WaypointPathfinder.server.lua` ke:
- `ServerScriptService`

Script ini akan membuat folder bernama `SavedWaypoints` di Workspace, lalu menyediakan function global:
- `SaveWaypoint(position)`
- `GetSavedWaypoints()`
- `MoveToSavedWaypoint(character, index)`
- `MoveCharacterToPosition(character, position)`
- `ClearSavedWaypoints()`

### 2) Masukkan script client
Paste isi file `roblox/StarterPlayer/ManualWaypointSaver.client.lua` ke:
- `StarterPlayerScripts`

Script ini akan menyimpan posisi karakter saat kamu menekan tombol:
- `F`

### 3) Simpan waypoint manual
Tekan tombol `F` saat karakter berada di posisi yang mau disimpan.

Setiap save akan membuat Part berwarna hijau neon di Workspace, di dalam folder `SavedWaypoints`.

### 4) Coba jalan ke waypoint
Jalankan script ini di Command Bar untuk menguji:

```lua
local character = game.Players.LocalPlayer.Character
if character then
    _G.MoveToSavedWaypoint(character, 1)
end
```

Atau kalau mau target langsung ke posisi tertentu:

```lua
local character = game.Players.LocalPlayer.Character
if character then
    _G.MoveCharacterToPosition(character, Vector3.new(0, 0, 0))
end
```

## Catatan
- Script bekerja paling baik untuk Character dengan `Humanoid`.
- Jika waypoint yang disimpan tidak ada, script akan otomatis melewati ke posisi tujuan tanpa pathfinding.
- Script ini mudah dipakai untuk prototype atau NPC sederhana.

## Contoh struktur workspace

```text
Workspace
  SavedWaypoints
    Waypoint_1
    Waypoint_2
    Waypoint_3
```
