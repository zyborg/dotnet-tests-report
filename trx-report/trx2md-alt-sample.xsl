<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:ms="urn:schemas-microsoft-com:xslt"
                xmlns:dt="urn:schemas-microsoft-com:datatypes"
                xmlns:trxfn="urn:trxfn"
                xmlns:trx="http://microsoft.com/schemas/VisualStudio/TeamTest/2010"
                >

    <xsl:output method="text"/>
    <xsl:strip-space elements="*"/>

    <xsl:param name="reportTitle" select="/trx:TestRun/@name" />

    <xsl:template match="/">
        <xsl:variable name="startTime" select="/trx:TestRun/trx:Times/@start" as="xs:date" />
        <xsl:variable name="finishTime" select="/trx:TestRun/trx:Times/@finish" as="xs:date" />
# Test Results - <xsl:value-of select="$reportTitle" />

* Duration: <xsl:value-of select="trxfn:DiffSeconds($startTime, $finishTime)" /> seconds
* Outcome: <xsl:value-of select="/trx:TestRun/trx:ResultSummary/@outcome"
        /> | Total Tests: <xsl:value-of select="/trx:TestRun/trx:ResultSummary/trx:Counters/@total"
        /> | Passed: <xsl:value-of select="/trx:TestRun/trx:ResultSummary/trx:Counters/@passed"
        /> | Failed: <xsl:value-of select="/trx:TestRun/trx:ResultSummary/trx:Counters/@failed" />

## Tests:

        <xsl:apply-templates select="/trx:TestRun/trx:TestDefinitions"/>
    </xsl:template>

    <xsl:template match="trx:UnitTest">
        <xsl:variable name="testId"
                      select="@id" />
        <xsl:variable name="testResult"
                      select="/trx:TestRun/trx:Results/trx:UnitTestResult[@testId=$testId]" />
        <xsl:variable name="testOutcomeIcon">
            <xsl:choose>
                <xsl:when test="$testResult/@outcome = 'Passed'">:heavy_check_mark:</xsl:when>
                <xsl:when test="$testResult/@outcome = 'Failed'">:x:</xsl:when>
                <xsl:when test="$testResult/@outcome = 'NotExecuted'">:radio_button:</xsl:when>
                <xsl:otherwise>:grey_question:</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

&lt;details&gt;
    &lt;summary&gt;
<xsl:value-of select="$testOutcomeIcon" />
<xsl:text> </xsl:text>
<xsl:value-of select="@name" />
    &lt;/summary&gt;

| | |
|-|-|
| **Name:**          | `<xsl:value-of select="@name" />`
| **Code Base:**     | `<xsl:value-of select="trx:TestMethod/@codeBase" />`
| **Outcome:**       | `<xsl:value-of select="$testResult/@outcome" />` <xsl:value-of select="$testOutcomeIcon" />
| **Computer Name:** | `<xsl:value-of select="$testResult/@computerName" />`
| **Duration:**      | `<xsl:value-of select="$testResult/@duration" />`


<xsl:if test="$testResult/@outcome = 'Failed'">

&lt;details&gt;
    &lt;summary&gt;Error Message:&lt;/summary&gt;

```text
<xsl:value-of select="$testResult/trx:Output/trx:ErrorInfo/trx:Message" />
```
&lt;/details&gt;

&lt;details&gt;
    &lt;summary&gt;Error Stack Trace:&lt;/summary&gt;

```text
<xsl:value-of select="$testResult/trx:Output/trx:ErrorInfo/trx:StackTrace" />
```
&lt;/details&gt;

</xsl:if>

-----

&lt;/details&gt;

    </xsl:template>

</xsl:stylesheet>
