#!/bin/zsh
set -euo pipefail

MIN_OBSIDIAN_VERSION="1.12.7"
TROUBLESHOOTING_URL="https://obsidian.md/help/cli#Troubleshooting"

version_ge() {
  local lhs="$1"
  local rhs="$2"
  local -a lhs_parts rhs_parts
  lhs_parts=(${(s:.:)lhs})
  rhs_parts=(${(s:.:)rhs})

  while (( ${#lhs_parts} < ${#rhs_parts} )); do
    lhs_parts+=(0)
  done
  while (( ${#rhs_parts} < ${#lhs_parts} )); do
    rhs_parts+=(0)
  done

  local i
  for (( i = 1; i <= ${#lhs_parts}; i++ )); do
    if (( lhs_parts[i] > rhs_parts[i] )); then
      return 0
    fi
    if (( lhs_parts[i] < rhs_parts[i] )); then
      return 1
    fi
  done

  return 0
}

fail() {
  echo "Dependency check failed: $1" >&2
  echo "See: $TROUBLESHOOTING_URL" >&2
  exit 1
}

if ! command -v obsidian >/dev/null 2>&1; then
  fail "'obsidian' CLI is not available in PATH. Install Obsidian Desktop 1.12.7+ and make sure the CLI binary is registered."
fi

if ! command -v qmd >/dev/null 2>&1; then
  fail "'qmd' is not available in PATH. Install qmd before using the wiki bootstrap or retrieval workflow."
fi

obsidian_version_output="$(obsidian version 2>/dev/null || true)"
obsidian_cli_runtime_ok=1

obsidian_installer_version=""
if [[ "$obsidian_version_output" =~ 'installer ([0-9]+\.[0-9]+\.[0-9]+)' ]]; then
  obsidian_installer_version="${match[1]}"
elif [[ "$obsidian_version_output" =~ '([0-9]+\.[0-9]+\.[0-9]+)' ]]; then
  obsidian_installer_version="${match[1]}"
fi

obsidian_path="$(command -v obsidian)"
case "$(uname -s)" in
  Darwin)
    if [[ -z "$obsidian_installer_version" ]] && [[ -f "/Applications/Obsidian.app/Contents/Info.plist" ]]; then
      obsidian_installer_version="$(plutil -extract CFBundleShortVersionString raw -o - /Applications/Obsidian.app/Contents/Info.plist 2>/dev/null || true)"
    fi
    if [[ "$obsidian_path" != "/usr/local/bin/obsidian" ]]; then
      echo "Warning: on macOS the official CLI registration usually installs at /usr/local/bin/obsidian. Current path: $obsidian_path" >&2
      echo "If commands behave inconsistently, re-run the Obsidian CLI registration steps from: $TROUBLESHOOTING_URL" >&2
    elif [[ -L "/usr/local/bin/obsidian" ]]; then
      obsidian_link_target="$(readlink /usr/local/bin/obsidian || true)"
      if [[ "$obsidian_link_target" != *"/Obsidian.app/Contents/MacOS/obsidian-cli" ]]; then
        echo "Warning: /usr/local/bin/obsidian does not point to the expected obsidian-cli binary: $obsidian_link_target" >&2
        echo "If commands behave inconsistently, re-run the Obsidian CLI registration steps from: $TROUBLESHOOTING_URL" >&2
      fi
    else
      echo "Warning: /usr/local/bin/obsidian is not a symlink. CLI registration may be stale or manually overridden." >&2
      echo "See: $TROUBLESHOOTING_URL" >&2
    fi
    ;;
  Linux)
    case ":$PATH:" in
      *":$HOME/.local/bin:"*) ;;
      *)
        echo "Warning: ~/.local/bin is not in PATH. Obsidian CLI registration on Linux may not be discoverable in new shells." >&2
        echo "See: $TROUBLESHOOTING_URL" >&2
        ;;
    esac
    ;;
esac

if [[ -z "$obsidian_installer_version" ]]; then
  fail "Unable to determine the Obsidian installer version. Check the app installation and CLI registration."
fi

if ! version_ge "$obsidian_installer_version" "$MIN_OBSIDIAN_VERSION"; then
  fail "Obsidian installer version $obsidian_installer_version is below the required $MIN_OBSIDIAN_VERSION."
fi

if [[ -z "$obsidian_version_output" ]]; then
  obsidian_cli_runtime_ok=0
  echo "Warning: 'obsidian version' could not reach a running Obsidian instance. Live CLI commands may fail until Obsidian Desktop is open." >&2
  echo "See: $TROUBLESHOOTING_URL" >&2
fi

echo "Dependencies OK"
echo "obsidian: $obsidian_path"
echo "obsidian installer version: $obsidian_installer_version"
echo "obsidian runtime reachable: $obsidian_cli_runtime_ok"
echo "qmd: $(command -v qmd)"
