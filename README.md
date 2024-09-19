# bambu-add-ip

Shell script which sends the IP address of a BambuLab printer to port 2021/udp of a PC running BambuStudio so that the printer can be accessed across subnets.

This script is forked from [gashton's bambudiscovery.sh script](https://github.com/gashton/bambustudio_tools/blob/master/bambudiscovery.sh).

## Uages

The program emits the following help text when invoked with the `-h` or `--help` flags:

```
Usage: bambu-add-ip [-h|--help] [flags] [printer_ip]

Sends the IP address of your BambuLab printer to port 2021/udp,
where BambuStudio is listening

-h / --help   show this message
-d / --debug  print additional debugging messages

Arguments:
printer_ip    ip address of the printer

Flags:
--slicer-ip SLICER_IP
    IP address of PC running BambuStudio; default is appropriate for running bambu-add-ip on the same PC as BambuStudio
    (default: 127.0.0.1)
--printer-ip PRINTER_IP
    IP address of the BambuLab Printer (this flag can be used instead of the printer_ip positional argument)
    (default: )
--printer-dev-model PRINTER_DEV_MODEL
    set this to the printer device model, use one of the following:
    "3DPrinter-X1-Carbon",
    "3DPrinter-X1",
    "C11" (for P1P),
    "C12" (for P1S),
    "C13" (for X1E),
    "N1" (for A1 mini),
    "N2S" (for A1)"
    (default: 3DPrinter-X1-Carbon)
--printer-dev-name PRINTER_DEV_NAME
    the device name of the printer
    (default: 3DP-000-000)
--printer-usn PRINTER_USN
    Printer Serial Number
    (default: 000000000000000)
--config-file CONFIG_FILE
    path to an optional config file which can be sourced to load the above settings
    (default: $HOME/.bambu-add-ip.cfg)

Example config file content:
SLICER_IP=127.0.0.1
PRINTER_IP=192.168.1.234
PRINTER_DEV_MODEL=N1
PRINTER_DEV_NAME=tiny
PRINTER_USN=030000000000001
```
