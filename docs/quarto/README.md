Source: https://docs.posit.co/resources/install-quarto.html

# Install Quarto

How to install Quarto on a Linux server.

These instructions describe how to install Quarto on a Linux server. Find all available Quarto versions on the [Quarto downloads page](https://quarto.org/docs/download/).

## What is Quarto?

Quarto is an open-source scientific and technical publishing system built on Pandoc, and allows users to create dynamic content with Python, R, Julia, and Observable. Additional information about Quarto is available at <https://quarto.org/>.

> **IMPORTANT:**
>
> Quarto is included in Third Party Materials (as defined in our [EULA](https://posit.co/about/eula/)) and not covered under the [Posit Support Agreement](https://posit.co/about/support-agreement/). If you download Quarto, you are agreeing to their [license](https://quarto.org/license.html) and acknowledge Posit is not responsible for Quarto and you are downloading Quarto at your sole risk.

## Specify Quarto version

Review the list of available Quarto versions on the [release page](https://github.com/quarto-dev/quarto-cli/releases/).

Now, set the `QUARTO_VERSION` environment variable to the version number you wish to install:

``` bash
export QUARTO_VERSION="1.9.37"
```

## Download and install Quarto

Detect the system architecture and download the matching version of Quarto:

``` bash
if [ "$(uname -m)" = "aarch64" ]; then
  QUARTO_ARCH="arm64"
else
  QUARTO_ARCH="amd64"
fi

sudo mkdir -p /opt/quarto/${QUARTO_VERSION}

sudo curl -o quarto.tar.gz -L \
    "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${QUARTO_ARCH}.tar.gz"

sudo tar -zxvf quarto.tar.gz \
    -C "/opt/quarto/${QUARTO_VERSION}" \
    --strip-components=1

sudo rm quarto.tar.gz
```

## Verify Quarto installation

Verify that your Quarto installation was successful:

``` bash
/opt/quarto/"${QUARTO_VERSION}"/bin/quarto check install
```

### (Optional) Add symlink for Quarto

*Applicable to Posit Workbench, only. Not required for Connect.*

> **IMPORTANT:**
>
> This section only applies to the first installation of Quarto on a given system. For subsequent installations, skip this section.

In Posit Workbench, RStudio Pro sessions have Quarto available by default. To use Quarto in VSCode or JupyterLab, you need to either symlink or install Quarto into a location on the `PATH` for those editors.

``` bash
# If using the default Quarto bundled with RStudio Pro
# sudo ln -s /usr/lib/rstudio-server/bin/quarto/bin/quarto /usr/local/bin/quarto

# If you have installed a non-default Quarto using the above instructions
sudo ln -s /opt/quarto/${QUARTO_VERSION}/bin/quarto /usr/local/bin/quarto
```

### (Optional) Install multiple versions of Quarto

To install multiple versions of Quarto on the same server, repeat the [steps above](#set-version), setting `QUARTO_VERSION` to a different version number each time.

This:

- Places different versions of Quarto in parallel folders.
- Allows you to support multiple Quarto versions in some Posit professional products.

## Additional resources

### Configuring Quarto with Connect

Installing Quarto on your system before configuring Connect to allow support for Quarto content is required. Complete the installation procedures above and then review the following sections of the Posit Connect Admin Guide:

- [Quarto](https://docs.posit.co/connect/admin/quarto/)
- [Enabling Quarto Support](https://docs.posit.co/connect/admin/quarto/#enabling-quarto-support)

Back to top

## Next steps
建议安装
```
quarto install tinytex
quarto install chrome-headless-shell
quarto check install
```
