<?php
// AnyExample XSLT Site engine

// Allow PHP to report everything
error_reporting(E_ALL);

if (!isset($_SERVER['DOCUMENT_ROOT']))
    die("Web server didn't set DOCUMENT_ROOT");

// DOCUMENT_ROOT -- is a path to your
// web site's directory with your files.
$docroot = $_SERVER['DOCUMENT_ROOT'];

// some web servers pass file information
// in PATH_TRANSLATED/PATH_INFO
// others -- in
// ORIG_PATH_TRANSLATED/ORIG_PATH_INFO
// lets check:
$sapi = php_sapi_name();

if ((strpos($sapi, 'cgi') !== false)||($sapi == 'isapi')
    &&isset($_SERVER['ORIG_PATH_TRANSLATED']))
{
    $realfile = $_SERVER['ORIG_PATH_TRANSLATED'];
    $http_file = $_SERVER['ORIG_PATH_INFO'];
}
else
{
    $real_file = $_SERVER['PATH_TRANSLATED'];
    $http_file = $_SERVER['PATH_INFO'];
}


// checking if source XML file exists
if (!file_exists($real_file))
{
// File does not exist: output 404 error
header("Status: 404 Not Found"); // 404 HTTP resonse status
// 404 page below. Your may change HTML code of it.
?>
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>404 Not Found</TITLE>
</HEAD><BODY>
<H1>Not Found</H1>                                    
The requested URL (<?php echo $http_file; ?>) was not found on this
server.<P>
<!--
<?php
echo str_repeat('ie padding', 40); // extra output for Internet Exporer
?>
-->
</BODY></HTML>
<?
exit();
}

$cached_file = $docroot.'/.cache/'.str_replace('/', '-', $http_file);
// cached_file -- files that stores generated HTML code

$xslt_file = $docroot.'/mf.xsl';
$xslt_file = '/home/martin/public_html/mf.xsl';
// XSLT file -- file that contains XSLT template

$xml_time = filemtime($real_file);
$xslt_time = filemtime($xslt_file);
$cache_time = @filemtime($cached_file);
// Modification times of source XML file,
// XSLT file and cached file


// Compare file modification time
// If cache is created after last modification of
// both xml and xslt
if (($cache_time > $xml_time) && ($cache_time > $xslt_time))
{
    // than we can output cached file and stop
    readfile($cached_file);
    echo '<!--cached-->';
    exit();
}

// Loading XML file
$source_xml = file_get_contents($real_file);

if (strpos($http_file, '/sitemap.xml') !== false)
    echo $source_xml; // Do not process Google's Sitemap file
// do not process empty files
if ($source_xml == "")
    die('Empty XML file');

// creating&loading DOMDocument
$xml = new DOMDocument;
$xml->substituteEntities = true;
if ($xml->loadXML($source_xml) == false) // loadXML will fail
    die('Failed to load source XML: '.$http_file); // if document is not valid XML
                     // some tags were not closed, etc.

// Loading XSLT site
$stylesheet = new DOMDocument;
$stylesheet->substituteEntities = true;
if ($stylesheet->load($xslt_file) == false)
    die('Failed to load XSLT file');


// XSLT transformation
$xsl = new XSLTProcessor();
$xsl->importStyleSheet($stylesheet);
$output = $xsl->transformToXML($xml); // transforming

// htmlizing XML
$output = ltrim(substr($output, strpos($output, '?'.'>')+2));
// removing <?xml
$output = preg_replace("!<(div|iframe|script|textarea)([^>]*?)/>!s",
"<$1$2></$1>", $output);
// some browsers does not support empty div, iframe, script and textarea tags
$output = preg_replace("!<(meta)([^>]*?)/>!s", "<$1$2 />", $output);
// meta tag should have extra space before />
$output = preg_replace("!&#(9|10|13);!s", '', $output);
// nobody needs 9, 10, 13 chars
$output = str_replace(chr(0xc2).chr(0x97), '&mdash;', $output);
$output = str_replace(chr(0xc2).chr(0xa0), '&nbsp;', $output);
// lets substitute some UTF8 chars to HTML entities

echo $output;

// Finally! Outputting HTML to browser

// caching (save processed version and display it next time)
@file_put_contents($cached_file, $output);
?>

