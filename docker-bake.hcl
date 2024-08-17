# Define the PHP version to track, which includes all the necessary extensions and dependencies
variable "php-version" {
    # renovate: depName=library/php packageName=php datasource=docker
    default = "8.3.10"
}

variable "REPOS" {
    # List of repositories to tag on Docker Hub
    default = [
        "jjmoner17/litebans"
    ]
}

# Define functions for tagging
function "major" {
    params = [version]
    result = split(".", version)[0]
}

function "minor" {
    params = [version]
    result = join(".", slice(split(".", version), 0, 2))
}

function "patch" {
    params = [version]
    result = join(".", slice(split(".", version), 0, 3))
}

function "tag" {
    params = [tag]
    result = [for repo in REPOS : "${repo}:${tag}"]
}

function "vtag" {
    params = [semver, variant]
    result = concat(
        tag("${major(semver)}-${variant}-${formatdate("YYYYMMDDHHMM", timestamp())}"),
        tag("${minor(semver)}-${variant}-${formatdate("YYYYMMDDHHMM", timestamp())}"),
        tag("${patch(semver)}-${variant}-${formatdate("YYYYMMDDHHMM", timestamp())}")
    )
}

# Define the default group with the target to build the Dockerfile
group "default" {
    targets = ["litebans"]
}

# Define the base build target
target "litebans" {
    context = "."
    dockerfile = "Dockerfile"
    args = {
        PHP_VERSION = "${php-version}"
    }
    tags = concat(tag("litebans"),
        vtag("${php-version}", "litebans")
    )
}

# Add metadata and platform details for multi-architecture builds
target "docker-metadata-action" {}

target "platforms-base" {
    inherits = ["docker-metadata-action"]
    context = "."    
    platforms = ["linux/amd64", "linux/arm64/v8"]
    labels = {
        "org.opencontainers.image.source" = "https://github.com/RedoxForge/LiteBans"
    }
}

