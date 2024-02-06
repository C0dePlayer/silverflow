# `image-cleaner` Module for Startingpoint

The `image-cleaner` module is a tool designed to enhance your desktop experience by efficiently managing and decluttering unnecessary shortcuts or repositories that may accumulate during image building.

To make the most of the `image-cleaner` module, you can easily specify the desktop entries you want to remove in your configuration file using the `entries:` section. If you need to remove repositories, you can do so by utilizing the `repos:` section.

## Example configuration
```yaml
type: image-cleaner
entries:
    - nvtop
    - htop
repos:
    - _copr:copr.fedorainfracloud.org:phracek:PyCharm
    - google-chrome
```
