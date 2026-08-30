#!/usr/bin/env python3
'''Generate configuration files for Mikrotik routers (RouterOS 7)

> python3 gen_mt_config.py mt-template-l2tp.txt mt-config11.py -o output.rsc

Source:
https://github.com/2a-stra/mt-config
'''
import argparse
import importlib.util
import re


VARIABLES = {
    "SITE",
    "SITE_NAME",
    "NET_PRE",
    "MNGT_PRE",
    "CORE_PRE",
    "SIP_PRE",
    "SIP_NET",
    "DHCP_START",
    "DHCP_END",
    "CODE43",
    "CODE66",
    "L2TP_PASS"
}


def load_config(filename):
    spec = importlib.util.spec_from_file_location("config", filename)
    config = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(config)

    return {name: getattr(config, name) for name in VARIABLES}


def render(template, config):
    return re.sub(
        r"\{(SITE|SITE_NAME|NET_PRE|MNGT_PRE|CORE_PRE|SIP_PRE|SIP_NET|"
        r"DHCP_START|DHCP_END|CODE43|CODE66|L2TP_PASS)\}",
        lambda m: str(config[m.group(1)]),
        template,
    )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("template")
    parser.add_argument("config")
    parser.add_argument("-o", "--output")
    args = parser.parse_args()

    config = load_config(args.config)

    with open(args.template, encoding="utf-8") as f:
        print("Router config: %s" % args.config)
        print("Using template: %s" % args.template)
        template = f.read()

    result = render(template, config)

    if args.output:
        print("Writing script: %s" % args.output)
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(result)
    else:
        print(result, end="")


if __name__ == "__main__":
    print(__doc__)
    main()
    print('''
# Startup

# 1. Create the new admin user
/user add name="sec" password="Secure-Password123" group=full

# 2. (Optional) Disable the default admin user for security
/user disable admin

# 3. Import the SSH key from a file
# Note: The public key file must already be uploaded to the router
/user ssh-keys import user=sec public-key-file=sec.pub

/system reset-configuration no-defaults=yes run-after-reset=output.rsc'''
)
