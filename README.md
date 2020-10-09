# dotnet-tests-report

GitHub Action to run .NET tests and generate reports and badges.

---

[![GitHub Workflow - CI](https://github.com/zyborg/dotnet-tests-report/workflows/test-action/badge.svg)](https://github.com/zyborg/dotnet-tests-report/actions?workflow=test-action)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/zyborg/dotnet-tests-report)](https://github.com/zyborg/dotnet-tests-report/releases/latest)

---

This Action can be used to execute .NET tests using unit testing frameworks such as
[xUnit](https://xunit.net/), [NUnit](https://nunit.org/) and
[MSTest](https://docs.microsoft.com/en-us/dotnet/core/testing/unit-testing-with-mstest)
within a GitHub Workflow, as well as generate a Report from the tests results and attach
it to the Workflow Run as a Check Run.

Check out the [usage](#usage) below.

## Samples

Here we see some badges generated along with some _Gist-based_ Tests Reports as part
of a GitHub Workflow associated with this project.

* [![XUnit Tests](https://gist.github.com/ebekker/49933657cea4f772aef0320c94850f47/raw/dotnet-tests-report_xunit.md_badge.svg)](https://gist.github.com/ebekker/49933657cea4f772aef0320c94850f47)
* [![NUnit Tests](https://gist.github.com/ebekker/35d1803fbae717e5115bd58a5aa0f939/raw/dotnet-tests-report_nunit.md_badge.svg)](https://gist.github.com/ebekker/35d1803fbae717e5115bd58a5aa0f939)
* [![MSTest Tests](https://gist.github.com/ebekker/8c412f16593919d785696b2bc37f2d69/raw/dotnet-tests-report_mstest.md_badge.svg)](https://gist.github.com/ebekker/8c412f16593919d785696b2bc37f2d69)


And here are some samples of the actual generated reports:

Badges:
<table border="2">
  <tr>
    <td><img width="450" src="docs/sample-badges1.png"/></td>
    <td><img width="450" src="docs/sample-badges2.png"/></td>
  </tr>
</table>
Workflow Reports:
<table border="2">
  <tr><td><img width="300" src="docs/sample-checkrun-report1.png" /></td>
  <td><img width="300" src="docs/sample-checkrun-report2.png" /></td>
  <td><img width="300" src="docs/sample-checkrun-report3.png" /></td></tr>
</table>
Gist Reports:
<table border="2">
  <tr>
    <td><img width="450" src="docs/sample-gist-report1.png" /></td>
    <td><img width="450" src="docs/sample-failure1.png" /></td>
  </tr>
</table>

## Usage

Check out [action.yml](action.yml) for full usage details.  Here are some samples.

This is a basic example, that just provides a path to a single test project, and
specifies the report name and title.

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: use this action, test solution dir
        uses: zyborg/dotnet-tests-report@v1.0.0
        with:
          project_path: tests/My.Project.Tests
          report_name: my_project_tests
          report_title: My Project Tests
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

In this example, a _Gist-based_ report is generated along with the one that is
attached to the Workflow Run.  Additionally, we request a Badge be generated
that shows the number of passed tests out of the total number of tests found.
We do this for each of two separate unit test projects.

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:

      - name: unit tests for Contoso Business Layer
        uses: zyborg/dotnet-tests-report@v1.0.0
        with:
          project_path: tests/Contoso.Business.Tests
          report_name: contoso_business_tests
          report_title: Contos Business Tests
          github_token: ${{ secrets.GITHUB_TOKEN }}
          gist_name: contoso_business_tests.md
          gist_badge_label: 'Contoso Business: %Counters_passed%/%Counters_total%'
          gist_token: ${{ secrets.GIST_TOKEN }}

      - name: unit tests for Contoso Service Layer
        uses: zyborg/dotnet-tests-report@v1.0.0
        with:
          project_path: tests/Contoso.Service.Tests
          report_name: contoso_service_tests
          report_title: Contos Service Tests
          github_token: ${{ secrets.GITHUB_TOKEN }}
          gist_name: contoso_service_tests.md
          gist_badge_label: 'Contoso Service: %Counters_passed%/%Counters_total%'
          gist_token: ${{ secrets.GIST_TOKEN }}
```

---

### Set check status based on test outcome
By default the [check status](https://docs.github.com/en/free-pro-team@latest/rest/reference/checks#create-a-check-run--parameters) is set to 'neutral'. Set the flag `set_check_status_from_test_outcome: true`.
Note that setting this flag to `true` will fail the check on pull requests if at least one test fails in your project.

### PowerShell GitHub Action

This Action is implemented as a [PowerShell GitHub Action](https://github.com/ebekker/pwsh-github-action-base).
