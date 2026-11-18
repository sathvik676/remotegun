# Network Setup

## Why `localhost` does not work from the phone

When the backend runs on your laptop, `localhost:8000` means your laptop. When the Flutter app runs on the phone, `localhost:8000` means the phone itself. You must use the laptop’s LAN IP address.

For the Android emulator, Google provides the special host alias `10.0.2.2`, which maps to the host machine. This is why the app defaults to `http://10.0.2.2:8000`.

## 1. Bind FastAPI to all interfaces

During development your backend may use:

```powershell
uvicorn main:app --reload
```

That typically binds only to `127.0.0.1`. Change it to:

```powershell
uvicorn main:app --host 0.0.0.0 --port 8000
```

Equivalent Python code:

```python
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

## 2. Find the laptop LAN IP

```powershell
ipconfig
```

Look under your Wi-Fi adapter for:

```text
IPv4 Address . . . . . . . . . . . : 192.168.1.5
```

Enter that value in the app’s **Settings → Server IP** field, with port `8000`.

## 3. Allow port 8000 through Windows Firewall

On first run Windows may ask for permission. To add an explicit rule:

1. Open **Windows Defender Firewall with Advanced Security**.
2. Click **Inbound Rules → New Rule**.
3. Choose **Port**.
4. Select **TCP** and enter `8000`.
5. Choose **Allow the connection**.
6. Apply to **Domain** and **Private**. Do not use **Public** on untrusted networks.
7. Name it `FastAPI Cloud Car 8000`.

PowerShell alternative, run as Administrator:

```powershell
New-NetFirewallRule -DisplayName "FastAPI Cloud Car 8000" -Direction Inbound -Protocol TCP -LocalPort 8000 -Action Allow -Profile Private,Domain
```

## 4. Verify from the phone

Before opening the app, use the phone browser:

```text
http://192.168.1.5:8000/health
```

Replace the IP with your laptop IP. You should see a JSON response. If this fails in the browser, the Flutter app will not work either.

## 5. Android cleartext HTTP

Android blocks plain HTTP by default on newer versions. This project sets:

```xml
android:usesCleartextTraffic="true"
```

in `AndroidManifest.xml`, so LAN HTTP works for development. This is acceptable on a trusted home network but should not be used for public internet deployments.

## 6. Remote internet access

### Recommended: VPN / overlay network

Use Tailscale or ZeroTier. Install it on both the laptop and phone, then use the private overlay IP in the app:

```text
http://100.x.y.z:8000
```

Benefits:

- no public port forwarding,
- encrypted traffic,
- device access control,
- works across different Wi-Fi/cellular networks.

### Recommended: tunnel

Use Cloudflare Tunnel, ngrok, or a similar trusted tunnel. Example Cloudflare Tunnel command:

```powershell
cloudflared tunnel --url http://localhost:8000
```

Then enter the generated HTTPS URL in the app. For HTTPS, set **Protocol** to `https` in Settings.

Because the app’s host field expects a host and port, a tunnel URL with a nonstandard port should be entered as the hostname and the port shown by the tunnel provider. If your tunnel uses a path prefix, use the **Base path** field.

### Avoid: direct port forwarding

Do not expose `8000` directly to the internet unless you have all of the following:

- TLS/HTTPS reverse proxy,
- authentication on every command endpoint,
- authorization so only your phone can control the car,
- rate limiting,
- firewall restrictions,
- backend and ESP32 failsafes,
- certificate monitoring.

The current backend contract has no authentication. Do not rely on network obscurity for a physical vehicle.

## 7. MQTT credentials

Never enter MQTT username/password into the Flutter app. The app only calls FastAPI. Keep broker credentials on the backend and ESP32, and keep them out of source control.
