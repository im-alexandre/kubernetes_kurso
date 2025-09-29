#!/usr/bin/env bash
set -euo pipefail

VM="${1:-}"
if [ -z "$VM" ]; then
  echo "Uso: $0 <VM_NAME_OR_UUID>"
  exit 1
fi

echo "==> Alvo: $VM"

# 1) Feche processos que podem manter lock (GUI, VBoxSVC, headless)
pkill -f -x VirtualBox 2>/dev/null || true
pkill -f VBoxHeadless 2>/dev/null || true
pkill -f VBoxSVC 2>/dev/null || true
rm -rf /tmp/.vbox-*-ipc 2>/dev/null || true

# 2) Se estiver rodando, desligue
if VBoxManage list runningvms | grep -q "\"$VM\"" || VBoxManage list runningvms | grep -q "$VM"; then
  echo "==> VM em execução. Desligando..."
  VBoxManage controlvm "$VM" poweroff || true
  sleep 2
fi

# 3) Se houver estado salvo, descarte
echo "==> Descartando estado salvo (se houver)..."
VBoxManage discardstate "$VM" 2>/dev/null || true

# 4) Remover locks antigos no diretório da VM (se conseguirmos descobrir o caminho)
CFG=$(VBoxManage showvminfo "$VM" --machinereadable 2>/dev/null | awk -F\" '/^CfgFile=/{print $2}' || true)
if [ -n "${CFG:-}" ] && [ -f "$CFG" ]; then
  VMDIR="$(dirname "$CFG")"
  echo "==> Limpando locks em: $VMDIR"
  find "$VMDIR" -type d -name '*.lck' -print -exec rm -rf {} + 2>/dev/null || true
fi

# 5) Tentar desregistrar e apagar
echo "==> Unregister + delete..."
VBoxManage unregistervm "$VM" --delete
echo "✔️  Removida: $VM"
