#!/usr/bin/env python3
import json
from pathlib import Path

path = Path(__file__).parents[1] / "UPEMA" / "Resources" / "discografia.json"
catalog = json.loads(path.read_text(encoding="utf-8"))
albums = catalog.get("albumes", [])
songs = [song for album in albums for song in album.get("canciones", [])]
playable = [song for song in songs if song.get("download_url") or song.get("pingui_mp3_url") or song.get("mp3_128_url_temporal") or song.get("enlaces_audio")]

EXPECTED_ALBUMS = 18
EXPECTED_SONGS = 258

assert len(albums) == EXPECTED_ALBUMS, (
    f"Se esperaban {EXPECTED_ALBUMS} álbumes; hay {len(albums)}"
)
assert len(songs) == EXPECTED_SONGS, (
    f"Se esperaban {EXPECTED_SONGS} canciones; hay {len(songs)}"
)
assert all(album.get("titulo") for album in albums)
assert all(song.get("titulo") for song in songs)
print(f"Catálogo válido: {len(albums)} álbumes, {len(songs)} canciones, {len(playable)} con audio.")
