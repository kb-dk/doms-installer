<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:pb="http://www.pbcore.org/PBCore/PBCoreNamespace.html"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

    <xsl:output indent="yes" method="xml" cdata-section-elements="true"/>


    <xsl:template match="program">
        <xsl:copy>
            <xsl:attribute name="xsi:noNamespaceSchemaLocation">../exportedRadioTVProgram.xsd</xsl:attribute>



            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="ritzau_original">
        <ritzau_original xmlns="http://doms.statsbiblioteket.dk/types/ritzau_original/0/1/#">

            <xsl:apply-templates/>
        </ritzau_original>
    </xsl:template>

    <xsl:template match="gallup_original">
        <gallup_original xmlns="http://doms.statsbiblioteket.dk/types/gallup_original/0/1/#">

            <xsl:apply-templates/>
        </gallup_original>
    </xsl:template>


    <xsl:template match="originals">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
        <xsl:call-template name="createProgramBroadcast"/>
        <xsl:call-template name="createFileUrls"/>

    </xsl:template>

    <xsl:template name="createProgramBroadcast">
        <programBroadcast xmlns="http://doms.statsbiblioteket.dk/types/program_broadcast/0/1/#">
            <timeStart>

                <xsl:value-of select="substring(/program/pbcore/pb:PBCoreDescriptionDocument/pb:pbcoreInstantiation/pb:pbcoreDateAvailable/pb:dateAvailableStart,0,23)"/>:00</timeStart>
            <timeStop><xsl:value-of select="substring(/program/pbcore/pb:PBCoreDescriptionDocument/pb:pbcoreInstantiation/pb:pbcoreDateAvailable/pb:dateAvailableEnd,0,23)"/>:00</timeStop>
            <channelId><xsl:value-of select="/program/pbcore/pb:PBCoreDescriptionDocument/pb:pbcorePublisher[pb:publisherRole = 'channel_name']/pb:publisher"/></channelId>
        </programBroadcast>
    </xsl:template>

    <xsl:template name="createFileUrls">
        <fileUrls>
            <xsl:apply-templates select="/program/program_recording_files/file"/>
        </fileUrls>
    </xsl:template>


    <xsl:template match="/program/program_recording_files/file">
        <fileUrl><xsl:value-of select="file_url"/></fileUrl>
    </xsl:template>

    <xsl:template match="program_recording_files"/>

</xsl:stylesheet>

