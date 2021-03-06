<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
      			xmlns:bio="http://purl.org/vocab/bio/0.1/"
      			xmlns:dc="http://purl.org/dc/elements/1.1/">
   <xsl:output method="xml" media-type="text/html" omit-xml-declaration="yes" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>
   
   <xsl:param name="language" />
   <xsl:param name="profilesBoxName" />
   <xsl:param name="currentProjectsBoxName" />
   <xsl:param name="pastProjectsBoxName" />
   <xsl:param name="peopleIKnowBoxName" />
   <xsl:param name="interestsBoxName" />
   <xsl:param name="publicationsBoxName" />
   <xsl:param name="contactLabel" />
   <xsl:param name="cvLabel" />
   <xsl:param name="cvUrl" />
   <xsl:param name="openIdServer" />
   <xsl:param name="openIdDelegate" />
   <xsl:param name="availableLanguages" />
   <xsl:param name="foafPath" />

   <xsl:variable name="fullName" select="/rdf:RDF/foaf:Person[1]/foaf:name/text()"/>
   <xsl:variable name="email" select="/rdf:RDF/foaf:Person[1]/foaf:mbox/@rdf:resource"/>
    <xsl:variable name="description" select="/rdf:RDF/foaf:Person[1]/bio:olb[@xml:lang=$language]/text()"/>

   <xsl:template match="/">
        <html>
         <head profile="http://gmpg.org/xfn/11">
            <title><xsl:value-of select="$fullName"/></title>
            <meta name="language" content="{$language}" />
			<link rel="stylesheet" type="text/css" href="mf.css" media="screen" />
            <link rel="meta" type="application/rdf+xml" title="FOAF" href="{$foafPath}"/>
            <link rel="openid.server" href="{$openIdServer}" />
			<link rel="openid.delegate" href="{$openIdDelegate}" />
			<meta name="description" content="{$description}" />
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
            <ul id="languages">
                <xsl:call-template name="output-tokens">
                        <xsl:with-param name="list" select="$availableLanguages" /> 
                </xsl:call-template>
            </ul>
                <h1><xsl:value-of select="foaf:name" /></h1>
        </div>
       	<div id="content">
       	        <div><xsl:apply-templates select="bio:biography"/></div>

                <p><a href="{$cvUrl}"><xsl:value-of select="$cvLabel"/></a></p>

	                <div class="groupbox">
	                    <h2><xsl:value-of select="$currentProjectsBoxName"/></h2>
			            <ul>
			               <xsl:for-each select="foaf:currentProject">
			               		<li><xsl:apply-templates select="."/></li>
			               </xsl:for-each>
			            </ul>
	                </div>
	                <div class="groupbox">
	                    <h2><xsl:value-of select="$pastProjectsBoxName"/></h2>
			            <ul>
			               <xsl:for-each select="foaf:pastProject">
			               		<li><xsl:apply-templates select="."/></li>
	   		               </xsl:for-each>
			            </ul>
	                </div>
	           <br />     
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
                <br />
                <div class="groupbox">
                    <h2><xsl:value-of select="$profilesBoxName"/></h2>
                    <p>
                            <xsl:for-each select="foaf:holdsAccount">
                                <xsl:apply-templates mode="body" select="." />&#160;
                            </xsl:for-each>
                    </p>
                </div>
                <br />
                <!--	                
                <div class="groupbox">
                    <h2><xsl:value-of select="$peopleIKnowBoxName"/></h2>
		            <ul>
		               <xsl:for-each select="foaf:knows">
		               		<li><xsl:apply-templates select="."/></li>
   		               </xsl:for-each>
		            </ul>
                </div>
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
                -->
                
                </div>
                <div id="footer">
	   				<p><strong><xsl:value-of select="$contactLabel"/>: </strong><a href="{$email}"><xsl:value-of select="$email" /></a></p>
				</div>
				<br />
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
   
   <xsl:template match="foaf:publication">
      <p><a href="{foaf:homepage/@rdf:resource}">
         <xsl:value-of select="dc:title/text()"/>
      </a> &#160;<xsl:apply-templates select="dc:description"/></p>   		
   </xsl:template>

   <xsl:template match="foaf:interest">
      <a href="{@rdf:resource}">
         <xsl:value-of select="@dc:title"/>
      </a>
   </xsl:template>	

<!-- TODO refactor -->

	<xsl:template match="dc:description">
		<xsl:value-of select="self::node()[@xml:lang=$language]/text()"/>
	</xsl:template>

	<xsl:template match="dc:title">
      <xsl:value-of select="self::node()[@xml:lang=$language]/text()"/>
	</xsl:template>
	
	<xsl:template match="bio:biography">
      <xsl:value-of select="self::node()[@xml:lang=$language]" disable-output-escaping="yes" />
	</xsl:template>

   <xsl:template match="foaf:holdsAccount" mode="body">
		<xsl:variable name="link" select="./foaf:OnlineAccount/@rdf:about" />
        <xsl:variable name="accountService" select="./foaf:OnlineAccount/foaf:accountServiceHomepage/@rdf:resource" />
        <xsl:variable name="serviceName">
        	<xsl:choose>
            	<xsl:when test="$accountService = 'http://www.facebook.com/'">Facebook</xsl:when>
            	<xsl:when test="$accountService = 'http://www.github.com/'">&lt;strong&gt;Github&lt;/strong&gt;</xsl:when>
            	<xsl:when test="$accountService = 'http://www.twitter.com/'">&lt;strong&gt;Twitter&lt;/strong&gt;</xsl:when>
            	<xsl:when test="$accountService = 'http://www.linkedin.com/'">&lt;strong&gt;LinkedIn&lt;/strong&gt;</xsl:when>
            	<xsl:when test="$accountService = 'http://www.viadeo.com/'">&lt;strong&gt;Viadeo&lt;/strong&gt;</xsl:when>
            	<xsl:when test="$accountService = 'http://www.flickr.com/'">&lt;strong&gt;Flickr&lt;/strong&gt;</xsl:when>
            	<xsl:when test="$accountService = 'http://www.diigo.com/'">Diigo</xsl:when>
            	<xsl:when test="$accountService = 'http://www.librarything.com/'">LibraryThing</xsl:when>
            	<xsl:when test="$accountService = 'http://www.last.fm/'">Last.fm</xsl:when>
            	<xsl:when test="$accountService = 'http://www.delicious.com/'">&lt;strong&gt;Delicious&lt;/strong&gt;</xsl:when>
            	<xsl:when test="$accountService = 'http://www.google.com/'">Google</xsl:when>
            	<xsl:when test="$accountService = 'http://www.runkeeper.com/'">RunKeeper</xsl:when>   
            	<xsl:when test="$accountService = 'http://posterous.com/'">Posterous</xsl:when>                                
            	<xsl:when test="$accountService = 'http://beta.memolane.com/'">Memolane</xsl:when>                                
            	<xsl:when test="$accountService = 'http://www.viadeo.com/'">&lt;strong&gt;Viadeo&lt;/strong&gt;</xsl:when>                                
            	<xsl:when test="$accountService = 'http://www.quora.com/'">Quora</xsl:when>                                
            	<xsl:otherwise>
            		<xsl:value-of select="$accountService" />
            	</xsl:otherwise>
            </xsl:choose>
         </xsl:variable>

		<a rel="me" href="{$link}"><xsl:value-of select="$serviceName" disable-output-escaping="yes" /></a>
   </xsl:template>

   <xsl:template match="foaf:holdsAccount" mode="head">
      <link rel="me" type="text/html" href="{./foaf:OnlineAccount/@rdf:about}"/>
   </xsl:template>
   
   <!-- from http://stackoverflow.com/questions/136500/does-xslt-have-a-split-function -->
   <xsl:template name="output-tokens">
       <xsl:param name="list" /> 
        <xsl:variable name="newlist" select="concat(normalize-space($list), ' ')" /> 
        <xsl:variable name="first" select="substring-before($newlist, ' ')" /> 
        <xsl:variable name="remaining" select="substring-after($newlist, ' ')" /> 
            <li><a href="index.html.{$first}"><xsl:value-of select="$first" /></a></li>
        <xsl:if test="$remaining">
            <xsl:call-template name="output-tokens">
                    <xsl:with-param name="list" select="$remaining" /> 
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
