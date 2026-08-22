#!/usr/bin/env bash
set -uo pipefail
export LC_ALL=C

script_rel="experiments/gate-0/collect-system-state.sh"

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

command -v git >/dev/null 2>&1 || fail "git is required"
repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || fail "run this command from inside a local-ai checkout"
cd "$repo_root" || fail "cannot enter repository root"

[[ -f PROJECT_PROMPT.md && -f docs/ELASTIC_RESIDENT_AI_DESIGN.md ]] || fail "this does not look like the local-ai repository"
[[ -f "$script_rel" ]] || fail "expected $script_rel"

project_head="$(git rev-parse HEAD)"
short_head="$(git rev-parse --short=12 HEAD)"
timestamp_utc="$(date -u +%Y%m%dT%H%M%SZ)"
run_id="${timestamp_utc}-${short_head}"
result_rel="results/gate-0/system-state/${run_id}"
raw_rel="${result_rel}/raw"
mkdir -p "results/gate-0/system-state"
mkdir "$result_rel" || fail "result directory already exists: $result_rel"
mkdir "$raw_rel"

manifest="${result_rel}/manifest.txt"
notes="${result_rel}/notes.md"

tracked_script_sha="$(git rev-parse "HEAD:${script_rel}" 2>/dev/null || true)"
working_script_sha="$(git hash-object "$script_rel" 2>/dev/null || true)"
if [[ -n "$tracked_script_sha" && "$tracked_script_sha" == "$working_script_sha" ]]; then
  script_matches_head="yes"
else
  script_matches_head="no"
fi

if git diff --quiet --ignore-submodules -- && git diff --cached --quiet --ignore-submodules --; then
  tracked_worktree_clean="yes"
else
  tracked_worktree_clean="no"
fi

branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || printf 'DETACHED')"

{
  printf 'schema_version=1\n'
  printf 'experiment=gate-0-system-state\n'
  printf 'run_id=%s\n' "$run_id"
  printf 'timestamp_utc=%s\n' "$timestamp_utc"
  printf 'project_head=%s\n' "$project_head"
  printf 'git_branch=%s\n' "$branch"
  printf 'script_path=%s\n' "$script_rel"
  printf 'script_git_blob=%s\n' "${tracked_script_sha:-unavailable}"
  printf 'script_working_blob=%s\n' "${working_script_sha:-unavailable}"
  printf 'script_matches_head=%s\n' "$script_matches_head"
  printf 'tracked_worktree_clean_before_run=%s\n' "$tracked_worktree_clean"
  printf 'result_path=%s\n' "$result_rel"
} > "$manifest"

cat > "$notes" <<EOF_NOTES
# Gate 0 system-state run notes

Run ID: \`$run_id\`
Project HEAD: \`$project_head\`

## Operator observations

Add any relevant observations here before committing the run. Leave this section unchanged if there is nothing to add.

## Privacy inspection

Before pushing, inspect the generated files and remove the run rather than editing raw evidence if it unexpectedly contains a secret or irrelevant identifying information. Report the collection problem so the protocol can be corrected and the run repeated.
EOF_NOTES

capture() {
  local name="$1"
  shift
  local out="${raw_rel}/${name}.txt"
  {
    printf '$'
    printf ' %q' "$@"
    printf '\n\n'
    "$@"
    status=$?
    printf '\n[exit_status=%d]\n' "$status"
    return "$status"
  } >"$out" 2>&1
}

capture_shell() {
  local name="$1"
  local description="$2"
  local command_text="$3"
  local out="${raw_rel}/${name}.txt"
  {
    printf '# %s\n' "$description"
    printf '$ %s\n\n' "$command_text"
    bash -lc "$command_text"
    status=$?
    printf '\n[exit_status=%d]\n' "$status"
    return "$status"
  } >"$out" 2>&1
}

capture_optional() {
  local name="$1"
  local command_name="$2"
  shift 2
  local out="${raw_rel}/${name}.txt"
  if command -v "$command_name" >/dev/null 2>&1; then
    capture "$name" "$command_name" "$@" || true
  else
    printf 'command_unavailable=%s\n' "$command_name" > "$out"
  fi
}

capture "os-release" cat /etc/os-release || true
capture_shell "kernel" "Kernel identity without hostname" "uname -srmv" || true
capture "lscpu" lscpu || true
capture "memory" free -b || true
capture_optional "swap" swapon --show --bytes --noheadings --output=TYPE,SIZE,USED,PRIO
capture_optional "block-devices" lsblk --bytes --output NAME,TYPE,SIZE,FSTYPE,ROTA,MODEL,TRAN
capture_optional "pci" lspci -nnk
capture_optional "modules" lsmod
capture_optional "vulkan-summary" vulkaninfo --summary
capture_optional "opengl-summary" glxinfo -B
capture_optional "uptime" uptime -p
capture_optional "vmstat" vmstat -s -S B
capture_optional "root-filesystem" df -B1 --output=source,fstype,size,used,avail,pcent,target /
capture_optional "repo-filesystem" df -B1 --output=source,fstype,size,used,avail,pcent,target .

capture_shell "session" "Selected non-secret desktop session variables" \
  'printf "XDG_SESSION_TYPE=%s\\nXDG_CURRENT_DESKTOP=%s\\nXDG_SESSION_DESKTOP=%s\\n" "${XDG_SESSION_TYPE:-}" "${XDG_CURRENT_DESKTOP:-}" "${XDG_SESSION_DESKTOP:-}"' || true

capture_shell "cpu-frequency" "CPU frequency driver and governor" \
  'for f in /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor; do printf "[%s]\\n" "$f"; if [[ -r "$f" ]]; then cat "$f"; else echo unavailable; fi; done' || true

capture_shell "drm-devices" "DRM device mapping and selected AMD GPU telemetry; EDID and serial data are intentionally excluded" '
shopt -s nullglob
for card in /sys/class/drm/card[0-9]*; do
  [[ -e "$card/device" ]] || continue
  printf "== %s ==\\n" "$(basename "$card")"
  printf "device_path=%s\\n" "$(readlink -f "$card/device" 2>/dev/null || true)"
  if [[ -L "$card/device/driver" ]]; then printf "driver=%s\\n" "$(basename "$(readlink -f "$card/device/driver")")"; fi
  for f in vendor device subsystem_vendor subsystem_device revision mem_info_vram_total mem_info_vram_used mem_info_gtt_total mem_info_gtt_used gpu_busy_percent; do
    if [[ -r "$card/device/$f" ]]; then printf "%s=" "$f"; cat "$card/device/$f"; fi
  done
  hwmons=("$card/device"/hwmon/hwmon*)
  for hw in "${hwmons[@]}"; do
    [[ -d "$hw" ]] || continue
    if [[ -r "$hw/name" ]]; then printf "hwmon_name="; cat "$hw/name"; fi
    for f in temp1_input power1_average power1_cap; do
      if [[ -r "$hw/$f" ]]; then printf "%s=" "$f"; cat "$hw/$f"; fi
    done
  done
  echo
done
for connector in /sys/class/drm/card[0-9]*-*; do
  [[ -r "$connector/status" ]] || continue
  printf "%s status=" "$(basename "$connector")"
  cat "$connector/status"
  if [[ -r "$connector/modes" ]]; then
    printf "modes:\\n"
    cat "$connector/modes"
  fi
  echo
done
' || true

capture_shell "relevant-packages" "Installed versions of selected kernel, graphics, Vulkan, ROCm, and local-AI runtime packages" '
if command -v pacman >/dev/null 2>&1; then
  pacman -Q 2>/dev/null | awk '\''$1 ~ /^(linux|linux-lts|linux-zen|linux-hardened|linux-firmware|mesa|lib32-mesa|vulkan-radeon|lib32-vulkan-radeon|vulkan-icd-loader|lib32-vulkan-icd-loader|rocm-core|rocm-hip-runtime|hip-runtime-amd|ollama|llama\.cpp)$/ {print}'\''
else
  echo pacman_unavailable
fi
' || true

printf '\nCollection complete.\n'
printf 'Run ID: %s\n' "$run_id"
printf 'Result directory: %s\n' "$result_rel"
printf 'Project HEAD: %s\n' "$project_head"
printf 'Script matches HEAD: %s\n' "$script_matches_head"
printf 'Tracked worktree clean before run: %s\n' "$tracked_worktree_clean"
printf '\nInspect the result directory before committing it. Follow experiments/gate-0/README.md for the documented push workflow.\n'
