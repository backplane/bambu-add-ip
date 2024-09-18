#!/bin/sh
# bambu-add-ip: Send the IP address of your BambuLab printer to port 2021/udp
#               where BambuStudio is listening
# 17-Sep-2024 forked from https://github.com/gashton/bambustudio_tools/blob/master/bambudiscovery.sh

set -eu
SELF=$(basename "$0" '.sh')

# set defaults (see usage below for more info)
CONFIG_FILE="${CONFIG_FILE:-$(dirname "$0")/config.env}"
SLICER_IP="${SLICER_IP:-127.0.0.1}"
PRINTER_IP="${PRINTER_IP:-}"
PRINTER_USN="${PRINTER_USN:-000000000000000}"
PRINTER_DEV_MODEL="${PRINTER_DEV_MODEL:-3DPrinter-X1-Carbon}"
PRINTER_DEV_NAME="${PRINTER_DEV_NAME:-3DP-000-000}"
PRINTER_DEV_SIGNAL="${PRINTER_DEV_SIGNAL:--44}"

usage() {
  exception="${1:-}"
  [ -n "$exception" ] && printf 'ERROR: %s\n\n' "$exception"

  printf '%s\n' \
    "Usage: $SELF [-h|--help] [flags] [printer_ip]" \
    "" \
    "Sends the IP address of your BambuLab printer to port 2021/udp," \
    "where BambuStudio is listening" \
    "" \
    "-h / --help   show this message" \
    "-d / --debug  print additional debugging messages" \
    "" \
    "Arguments:" \
    "printer_ip    ip address of the printer" \
    "" \
    "Flags:" \
    "--slicer-ip SLICER_IP" \
    "    IP address of PC running BambuStudio; default is appropriate for running $SELF on the same PC as BambuStudio" \
    "    (default: ${SLICER_IP})" \
    "--printer-ip PRINTER_IP" \
    "    IP address of the BambuLab Printer (this flag can be used instead of the printer_ip positional argument)" \
    "    (default: ${PRINTER_IP})" \
    "--printer-dev-model PRINTER_DEV_MODEL" \
    "    set this to the printer device model, use one of the following:" \
    '    "3DPrinter-X1-Carbon",' \
    '    "3DPrinter-X1",' \
    '    "C11" (for P1P),' \
    '    "C12" (for P1S),' \
    '    "C13" (for X1E),' \
    '    "N1" (for A1 mini),' \
    '    "N2S" (for A1)"' \
    "    (default: ${PRINTER_DEV_MODEL})" \
    "--printer-dev-name PRINTER_DEV_NAME" \
    "    the device name of the printer" \
    "    (default: ${PRINTER_DEV_NAME})" \
    "--printer-usn PRINTER_USN" \
    "    Printer Serial Number" \
    "    (default: ${PRINTER_USN})" \
    "--config-file CONFIG_FILE" \
    "    path to an optional config file which can be sourced to load the above settings" \
    "    (default: ${CONFIG_FILE})" \
    "" \
    "Example config file content:" \
    "SLICER_IP=127.0.0.1" \
    "PRINTER_IP=192.168.1.234" \
    "PRINTER_DEV_MODEL=N1" \
    "PRINTER_DEV_NAME=tiny" \
    "PRINTER_USN=030000000000001" \
    "" \
    "" # no trailing slash

  [ -n "$exception" ] && exit 1
  exit 0
}

log() {
  printf '%s %s %s\n' "$(date '+%FT%T%z')" "$SELF" "$*" >&2
}

die() {
  log "FATAL:" "$@"
  exit 1
}

transmit_ip() {
  printf '%s\r\n' \
    "HTTP/1.1 200 OK" \
    "Server: Buildroot/2018.02-rc3 UPnP/1.0 ssdpd/1.8" \
    "Date: $(date)" \
    "Location: ${PRINTER_IP}" \
    "ST: urn:bambulab-com:device:3dprinter:1" \
    "EXT:" \
    "USN: ${PRINTER_USN}" \
    "Cache-Control: max-age=1800" \
    "DevModel.bambu.com: ${PRINTER_DEV_MODEL}" \
    "DevName.bambu.com: ${PRINTER_DEV_NAME}" \
    "DevSignal.bambu.com: ${PRINTER_DEV_SIGNAL}" \
    "DevConnect.bambu.com: lan" \
    "DevBind.bambu.com: free" \
    "" \
    | nc -u -w 0 "${SLICER_IP}" 2021
}

main() {
  # arg-processing loop
  while [ $# -gt 0 ]; do
    arg="$1" # shift at end of loop; if you break in the loop don't forget to shift first
    case "$arg" in
      -h|-help|--help)
        usage
        ;;
      -d|--debug)
        set -x
        ;;
      --slicer-ip)
        shift || usage "$arg requires an argument"
        SLICER_IP=$1
        ;;
      --printer-ip)
        shift || usage "$arg requires an argument"
        PRINTER_IP=$1
        ;;
      --printer-usn)
        shift || usage "$arg requires an argument"
        PRINTER_USN=$1
        ;;
      --printer-dev-model)
        shift || usage "$arg requires an argument"
        PRINTER_DEV_MODEL=$1
        ;;
      --printer-dev-name)
        shift || usage "$arg requires an argument"
        PRINTER_DEV_NAME=$1
        ;;
      --config-file)
        shift || usage "$arg requires an argument"
        CONFIG_FILE="$1"
        ;;
      --)
        shift || true
        break
        ;;
      *)
        # unknown arg, leave it back in the positional params
        break
        ;;
    esac
    shift || break
  done

  # ensure required environment variables are set
  # : "${USER:?the USER environment variable must be set}"

  if [ -f "$CONFIG_FILE" ]; then
    log "sourcing config file: ${CONFIG_FILE}"
    # shellcheck source=/dev/null
    . "${CONFIG_FILE}"
  fi

  # we support one optional positional argument (the printer_ip)
  case $# in
    0)
      : # no op
      ;;
    1)
      PRINTER_IP=$1
      ;;
    *)
      usage "unexpected arguments:" "$@"
      ;;
  esac

  [ "$PRINTER_IP" = "" ] && usage "printer_ip argument is required"

  log "transmitting info about printer ${PRINTER_IP} to slicer ${SLICER_IP}"
  transmit_ip || die "nc command failed"

  exit 0
}

main "$@"
# shellcheck disable=SC2317
exit
