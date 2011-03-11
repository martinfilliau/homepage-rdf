<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
      			xmlns:bio="http://purl.org/vocab/bio/0.1/"
      			xmlns:dc="http://purl.org/dc/elements/1.1/">
   <xsl:output method="html" media-type="text/html"/>
   
   <xsl:param name="language" />	<!-- en OR fr -->
   <xsl:param name="profilesBoxName" />
   <xsl:param name="currentProjectsBoxName" />
   <xsl:param name="pastProjectsBoxName" />
   <xsl:param name="peopleIKnowBoxName" />
   <xsl:param name="interestsBoxName" />
   <xsl:param name="publicationsBoxName" />
   <xsl:param name="contactLabel" />

   <xsl:variable name="fullName" select="/rdf:RDF/foaf:Person[1]/foaf:name/text()"/>
   <xsl:variable name="bio" select="/rdf:RDF/foaf:Person[1]/bio:olb/text()" />
   <xsl:variable name="email" select="/rdf:RDF/foaf:Person[1]/foaf:mbox/text()"/>

   <xsl:template match="/">
        <html>
         <head profile="http://gmpg.org/xfn/11">
            <title><xsl:value-of select="$fullName"/></title>
			<link rel="stylesheet" type="text/css" href="mf.css" media="screen" />
            <link rel="meta" type="application/rdf+xml" title="FOAF" href="martinfilliau.rdf"/>
            <link rel="openid.server" href="https://www.myopenid.com/server" />
			<link rel="openid.delegate" href="http://martinfilliau.myopenid.com" />
            <xsl:for-each select="/rdf:RDF/foaf:Person[1]/foaf:holdsAccount">
            	<xsl:apply-templates mode="head" select="."/>
            </xsl:for-each>
         </head>
         <body><xsl:apply-templates select="/rdf:RDF/foaf:Person[1]"/></body>
      </html>
   </xsl:template>

   <xsl:template match="foaf:Person">
	<div id="global">
    	<div id="haut">
                <h1><xsl:value-of select="foaf:name" /></h1>
        </div>
       	<div id="content">
                <p><xsl:value-of select="$bio" /></p>
                <div class="groupbox">
                    <h2><xsl:value-of select="$profilesBoxName"/></h2>
                    <p>
                        <ul>
                            <xsl:for-each select="foaf:holdsAccount">
                            	<li><xsl:apply-templates mode="body" select="."/></li>
                            </xsl:for-each>
                        </ul>
                    </p>
                </div>
	                <div class="groupbox">
	                    <h2><xsl:value-of select="$currentProjectsBoxName"/></h2>
	                	<p>
			            <ul>
			               <xsl:for-each select="foaf:currentProject">
			               		<li><xsl:apply-templates select="."/></li>
			               </xsl:for-each>
			            </ul>
	                	</p>
	                </div>
	                <div class="groupbox">
	                    <h2><xsl:value-of select="$pastProjectsBoxName"/></h2>
	                	<p>
			            <ul>
			               <xsl:for-each select="foaf:pastProject">
			               		<li><xsl:apply-templates select="."/></li>
	   		               </xsl:for-each>
			            </ul>
	                	</p>
	                </div>
                <div class="groupbox">
                    <h2><xsl:value-of select="$peopleIKnowBoxName"/></h2>
                	<p>
		            <ul>
		               <xsl:for-each select="foaf:knows">
		               		<li><xsl:apply-templates select="."/></li>
   		               </xsl:for-each>
		            </ul>
                	</p>
                </div>
                <!--
                <div class="groupbox">
                    <h2><xsl:value-of select="$interestsBoxName"/></h2>
                	<p>
		            <ul>
		               <xsl:for-each select="foaf:interest">
		               		<li><xsl:apply-templates select="."/></li>
   		               </xsl:for-each>
		            </ul>
                	</p>
                </div>
                <div class="groupbox">
                    <h2><xsl:value-of select="$publicationsBoxName"/></h2>
                	<p>
		            <ul>
		               <xsl:for-each select="foaf:publication">
		               		<li><xsl:apply-templates select="."/></li>
   		               </xsl:for-each>
		            </ul>
                	</p>
                </div>
                -->
                </div>
                
                <div id="footer">
	   				<p><strong><xsl:value-of select="$contactLabel"/>: </strong><xsl:value-of select="$email" /></p>
				</div>
                </div>
   </xsl:template>

   <xsl:template match="foaf:knows">
      <a rel="friend" href="{foaf:Person/foaf:homepage/@rdf:resource}">
         <xsl:value-of select="foaf:Person/foaf:name/text()"/>
      </a>
   </xsl:template>

   <xsl:template match="foaf:currentProject">
      <p><a href="{foaf:Project/foaf:homepage/@rdf:resource}">
         <xsl:value-of select="foaf:Project/foaf:name/text()"/>
      </a> &#160;<xsl:apply-templates select="foaf:Project/dc:description"/></p>
   </xsl:template>

	<!-- TODO: make parent template for both project types -->
   <xsl:template match="foaf:pastProject">
      <p><a href="{foaf:Project/foaf:homepage/@rdf:resource}">
         <xsl:value-of select="foaf:Project/foaf:name/text()"/>
      </a> &#160;<xsl:apply-templates select="foaf:Project/dc:description"/></p>
   </xsl:template>
   
   <xsl:template match="foaf:publications">
      <a href="{foaf:publications/@rdf:resource}">
         <xsl:value-of select="foaf:publications/dc:title/text()"/>
      </a>
      <p><xsl:apply-templates select="foaf:publications/dc:description"/></p>   		
   </xsl:template>

   <xsl:template match="foaf:interest">
      <a href="{@rdf:resource}">
         <xsl:value-of select="@dc:title"/>
      </a>
   </xsl:template>	

	<xsl:template match="dc:description">
		<xsl:value-of select="self::node()[@xml:lang=$language]/text()"/>
	</xsl:template>

	<xsl:template match="dc:title">
      <xsl:value-of select="self::node()[@xml:lang=$language]/text()"/>
	</xsl:template>

   <xsl:template match="foaf:holdsAccount" mode="body">
		<xsl:variable name="link" select="./foaf:OnlineAccount/@rdf:about" />
        <xsl:variable name="accountService" select="./foaf:OnlineAccount/foaf:accountServiceHomepage/@rdf:resource" />
        <xsl:variable name="serviceName">
        	<xsl:choose>
            	<xsl:when test="$accountService = 'http://www.facebook.com/'">Facebook</xsl:when>
            	<xsl:when test="$accountService = 'http://www.github.com/'">Github</xsl:when>
            	<xsl:when test="$accountService = 'http://www.twitter.com/'">Twitter</xsl:when>
            	<xsl:when test="$accountService = 'http://www.linkedin.com/'">LinkedIn</xsl:when>
            	<xsl:when test="$accountService = 'http://www.viadeo.com/'">Viadeo</xsl:when>
            	<xsl:when test="$accountService = 'http://www.flickr.com/'">Flickr</xsl:when>
            	<xsl:when test="$accountService = 'http://www.diigo.com/'">Diigo</xsl:when>
            	<xsl:when test="$accountService = 'http://www.librarything.com/'">LibraryThing</xsl:when>
            	<xsl:when test="$accountService = 'http://www.last.fm/'">Last.fm</xsl:when>
            	<xsl:when test="$accountService = 'http://www.delicious.com/'">Delicious</xsl:when>
            	<xsl:when test="$accountService = 'http://www.google.com/'">Google</xsl:when>
            	<xsl:when test="$accountService = 'http://www.runkeeper.com/'">RunKeeper</xsl:when>   
            	<xsl:when test="$accountService = 'http://posterous.com/'">Posterous</xsl:when>                                
            	<xsl:when test="$accountService = 'http://beta.memolane.com/'">Memolane</xsl:when>                                
            	<xsl:when test="$accountService = 'http://www.viadeo.com/'">Viadeo</xsl:when>                                
            	<xsl:otherwise>
            		<xsl:value-of select="$accountService" />
            	</xsl:otherwise>
            </xsl:choose>
         </xsl:variable>

		<a rel="me" href="{$link}"><xsl:value-of select="$serviceName" /></a>
   </xsl:template>

   <xsl:template match="foaf:holdsAccount" mode="head">
      <link rel="me" type="text/html" href="{foaf:OnlineAccount/foaf:accountServiceHomepage/foaf:Document/foaf:homepage/@rdf:resource}"/>
   </xsl:template>

</xsl:stylesheet>
