# compose.jq
# Generate a docker compose config file
# By J. Stuart McMurray
# Created 20251130
# Last Modified 20251202

{
        "name": "ahjtp",
        "services": {
                "cicd": {
                        "attach": false,
                        "build": { "dockerfile_inline": $cicd },
                        "init": true,
                        "ports": ["443:4433"]
                },
                "print_curl": {
                        "build": { "dockerfile_inline": $print_curl },
                        "network_mode": "host"
                },
                "cloud_logger": {
                        "attach": false,
                        "build": { "dockerfile_inline": $cloud_logger },
                        "init": true,
                        "privileged": true
                },
                "passwordstore": {
                        "attach": false,
                        "build": { "dockerfile_inline": $passwordstore }
                }
        }
}

# vim: si
