# pwsh-github-action-base
Base support for implementing GitHub Actions in PowerShell Core

---

[![GitHub Workflow - CI](https://github.com/ebekker/pwsh-github-action-base/workflows/CI/badge.svg)](https://github.com/ebekker/pwsh-github-action-base/actions?workflow=CI)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/ebekker/pwsh-github-action-base)](https://github.com/ebekker/pwsh-github-action-base/releases/latest/download/pwsh-github-action-base-dist.zip)
[![Pester Tests](https://gist.githubusercontent.com/ebekker/bbe0eabece0e4e9c4c8d9e962ed93ea4/raw/pwsh-github-action-base_tests.md_badge.svg)](https://gist.github.com/ebekker/bbe0eabece0e4e9c4c8d9e962ed93ea4)

---

This repository contains a bundle of files to support creating GitHub Actions
in PowerShell Core that can be executed across all the supported platforms
where GitHub Workflows are executed.

The [distribution](https://github.com/ebekker/pwsh-github-action-base/releases/latest/download/pwsh-github-action-base-dist.zip)
 includes a number of base components:

* **[`_init/index.js`](_init/index.js)** -
  The entry point into invoking the Action.
* **[`SAMPLE-action.ps1`](SAMPLE-action.ps1)** -
  A sample script implementing a simple Action script demonstrating some
  of the features made available from the Core  library.
* **[`SAMPLE-action.yml`](SAMPLE-action.yml)** -
  A sample Action metadata file that describes various attributes such as a
  description, licensing, branding and formal input and output values.

Additionally, the sample Action shows how to make use of the
[GitHubActions module](https://www.powershellgallery.com/packages/GitHubActions)
to get access to the GH Actions/Workflow environment for input, output
and messaging.  More details can be found [below](#optional-support-module)

## Required Components

### `action.ps1` - The PowerShell Entry Point

You create an Action by creating a PowerShell script named `action.ps1`, this the
the main entry point into your Action logic.  From here you can inspect for, and
assemble inputs and environment variables, call into other processes in the local
environment context, and issue commands to the Action/Workflow context to perform
logging and adjust the state of the job as seen by subsequent Actions and Steps.

You can also make calls out to external services via APIs, including calling into
the GitHub API.

### `action.yml` - The Action Metadata

As per the GitHub Actions mechanism, you must provide a
[metadata file](https://help.github.com/en/articles/metadata-syntax-for-github-actions)
that describes various attributes about your Action, including any formal inputs
and outputs. You use this metadata file to enumerate any _required_ inputs that
must be provided by a Workflow definition.

#### `runs` Entry Point Attribute

The most important attribute in this file for our purposes is the `runs`
setting which has two child settings, `using` and `main`.  This attribute
indicates what is the
[_type_](https://help.github.com/en/articles/about-actions#types-of-actions)
of your Action and how to run it.

There are two main types of Actions, one based on Docker containers and
one based on JavaScript (NodeJS).  While Docker Actions give you the ability
to define and _carry_ the entire runtime with you, they are slower to start
and limited to only executing in Linux environments.

JavaScript Actions however are simpler and more lightweight, and therefore
quicker to start, and they can run on any of the supported platforms
(Linux, Windows, MacOS).  They also execute directly in the hosted virtual
machine where the Workflow runs instead of a dedicated container.

Because of these advantages, this repo hosts a solution that is based on
JavaScript-type Actions.  A stub JavaScript script is provided to bootstrap
the Action entry point and then immediately switches over to your provided
PowerShell script.  To use this bootstrap script, you need to specify the
following `runs` attribute in your `actions.yml` metadata file:

```yaml
runs:
  using: node12
  main: _init_/index.js
```

This configuration assumes you have placed the bootstrap JavaScript file
in a `_init` subdirectory within your Action root directory.  The bootstrap
code also assumes this subdirectory location.  If you decide to place it
elsewhere or otherwise rename it, make sure to adjust the metadata file
appropriately, _and_ update the bootstrap script logic to accommodate any
path changes.

### `_init/index.js`

As mentioned above the `_init/index.js` file is a bootstrap JavaScript
file that is used as the initial main entry point into your custom
Action.  After starting, it immediately transfers control to your
PowerShell script by invoking the file `action.ps1` in the directory
immediately above the `_init` subdirectory.  The invocation is equivalent
to the following command-line call:

```pwsh
pwsh -f /full/path/to/action.ps1
```

The working directory is the same as at the start of the bootstrap
script which is the root of the cloned repository of the Workflow
in which the action is being invoked.

## Optional Support Module

In addition to the required components above, you may choose to make use of the
**[`GitHubActions` PowerShell module](https://www.powershellgallery.com/packages/GitHubActions)**
utility script that defines a number of cmdlets that help interact with the
Worklfow/Action environment context in a more natural way for PowerShell
scripts. These cmdlets are adaptations of the JavaScript Actions
[core package](https://github.com/actions/toolkit/tree/master/packages/core) provided in the
[Actions Toolkit](https://github.com/actions/toolkit).  See that package
description for details about what it provides

For details about the counterpart cmdlets, go to the
[docs](https://github.com/ebekker/pwsh-github-action-tools/blob/master/docs/GitHubActions/README.md).
