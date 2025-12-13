<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/">
        <PRACOWNICY>
            <xsl:for-each select="//PRACOWNICY/ROW">
                <xsl:sort select="ID_PRAC" data-type="number"/>

                <PRACOWNIK ID_PRAC="{ID_PRAC}" ID_SZEFA="{ID_SZEFA}" ID_ZESP="{../../ID_ZESP}">
                    <xsl:copy-of select="*[name() != 'ID_PRAC' and name() != 'ID_SZEFA' and name() != 'ID_ZESP']"/>
                </PRACOWNIK>
            </xsl:for-each>
        </PRACOWNICY>
    </xsl:template>
</xsl:stylesheet>