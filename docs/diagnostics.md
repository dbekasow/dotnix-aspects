# Audio and performance diagnostics

Collect comparable observations before changing configuration. These checks are read-only; do not change sound profiles, firmware, or power-saving settings while diagnosing. No `sudo` is needed. Share only the relevant, redacted excerpts—not a complete journal.

## Dock audio

With the dock connected, then again after unplug/replug and after resume, run the same commands and note the event and time:

```sh
wpctl status
pactl list cards
pactl list sinks
pactl get-default-sink
```

`pactl list cards` reports each card's profiles and ports; `pactl list sinks` reports output sinks and their ports. `pactl get-default-sink` reports the current default. Compare these with `wpctl status` to see which devices and sinks PipeWire exposes at each point.

Identify the route by device properties and connection, not by a friendly name alone. A USB-audio route appears as a USB device/card; a display route appears as HDMI or DisplayPort audio, which may be exposed by the dock or GPU. Record whether the monitor is connected over USB-C/Thunderbolt and which output is selected. A missing device, unavailable profile/port, or unexpected default is an observation, not proof of its cause.

Before sharing output, replace personal device/card/sink names and serial-like values with labels such as `[USB dock]` and `[display audio]`. Remove usernames, hostnames, addresses, and any unrelated private data.

## Sluggish desktop, apps, boot, resume, or battery

Record whether the machine is on AC or battery, the workload, and whether the symptom occurs at idle, under load, during boot, or after resume. Repeat measurements under comparable conditions.

```sh
powerprofilesctl get
systemd-analyze critical-chain
systemd-analyze blame
vmstat 1 5
top -b -n 1
```

The first command reports the active power profile. The `systemd-analyze` commands describe boot ordering and service startup time; they do not measure resume time. Record resume duration separately. `vmstat` and `top` provide snapshots of CPU/load and I/O pressure; note whether a workload was running. For temperatures, run `sensors` if already available. If an NVIDIA GPU and `nvidia-smi` are already available, run `nvidia-smi`; otherwise use an already-installed vendor tool or report that no GPU measurement was collected. Include units and the time/load state for each reading.

The library currently persists `.local/state/wireplumber` and enables `thermald`; these are configuration facts, not demonstrated causes of the reported audio or performance symptoms. A separate caller is pinned to `c30726e7…`, older than the library revision `ed56662a…`; that version difference alone does not establish a cause. Without comparable host measurements, audio and performance causes remain unresolved.

## Redacted example report

```text
Event: USB-C dock reconnected; tested again after resume
Audio before: [USB dock] card/profile/port present; default [display audio]
Audio after: [USB dock] card present; expected output absent; default [laptop speakers]
Route: USB-audio dock plus HDMI/DP display audio both visible
Power: battery; power profile [redacted]; workload: browser + video call
Boot: critical chain [redacted]; blame excerpt [redacted]
Load: vmstat/top excerpt [redacted]; temperatures: CPU [redacted] °C, GPU not measured
Conclusion: symptom reproduced; cause unresolved
```
