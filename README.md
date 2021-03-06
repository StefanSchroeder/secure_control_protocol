# Secure Control Protocol Client Library written in Dart

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## Build and run for development

Install the Dart SDK version > 2.10.

Afterwards run `pub get` to fetch all dependencies.

Now the commands below can be used.

## Build as native application

`dart compile exe ./bin/scp_client.dart`

## Run without build

See below.

## Run Tests

`dart run <path to test>`

## CLI Client

To only discovers devices:

`dart ./bin/scp_client.dart discover -i <IP address from the subnet to be scanned> -m <Subnet Mask in Prefix notation>`

To discover devices and afterwards provision them:

`dart ./bin/scp_client.dart provision -i <IP address from the subnet to be scanned> -m <Subnet Mask in Prefix notation> -s <SSID of target Wifi> -p <Password of target Wifi> -j <path to JSON>`

| Parameter | Description                                                                           |
| --------- | ------------------------------------------------------------------------------------- |
| i         | IP address from the to be scanned subnet                                              |
| m         | Subnet Mask in Prefix notation                                                        |
| s         | SSID of target Wifi                                                                   |
| p         | Password of target Wifi                                                               |
| j         | Create JSON file at the given path containing all provisioned devices for further use |

After the provisioning the CLI client has to be connected to the provisioned Wifi.

Now the update of the IP address for the provisioned device has to occur.

`dart ./bin/scp_client.dart update -i <IP address from the to be scanned subnet> -m <Subnet mask in Prefix notation> -j <path to JSON with known devices>`

After the update the devices can be controlled by addressing them with their device ID. All required data is taken from the JSON with the known devices.

`dart ./bin/scp_client.dart control -c <action> -d <device ID> -j <path to JSON with known devices>`

## License
SPDX-License-Identifier: GPL-3.0-only

The full version of the license can be found in LICENSE.
