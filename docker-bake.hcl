# Define variables for the apt packages and PHP extensions
variable "php-version" {
    # renovate: depName=php packageName=php datasource=docker
    default = "latest"
}

variable "libicu-dev-version" {
    # renovate: depName=libicu-dev packageName=libicu-dev datasource=github-releases
    default = "74.2"
}

variable "pdo_mysql-version" {
    # renovate: depName=pdo_mysql packageName=pdo_mysql datasource=github-releases
    default = "latest"
}

variable "intl-version" {
    # renovate: depName=intl packageName=intl datasource=github-releases
    default = "latest"
}

variable "REPOS" {
    # List of repositories to tag on Docker Hub
    default = [
        "redoxforge/litebans"
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
        LIBICU_DEV_VERSION = "${libicu-dev-version}"
        PDO_MYSQL_VERSION = "${pdo_mysql-version}"
        INTL_VERSION = "${intl-version}"
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
