<?php
error_reporting(E_ALL);

// find param language = en or fr
// if not present, check http request for language
// else: english

/*
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
<html><head><title>Not Found</title></head>
<body><h1>Not Found</h1>
<p>The requested URL (<?php echo $http_file; ?>) was not found on this server.<p>
</body></html>
<?
exit();
}

$cached_file = $docroot.'/.cache/'.str_replace('/', '-', $http_file);
// cached_file -- files that stores generated HTML code

*/

$xslt_file = 'foaf-as-html.xsl';

/*
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
*/

// Loading XML file
//$source_xml = file_get_contents($real_file);

$source_xml = file_get_contents('martinfilliau.rdf');

// creating&loading DOMDocument
$xml = new DOMDocument;
$xml->substituteEntities = true;
if ($xml->loadXML($source_xml) == false) // loadXML will fail
    die('Failed to load source XML: '.$http_file); // if document is not valid XML

// Loading XSLT site
$stylesheet = new DOMDocument;
$stylesheet->substituteEntities = true;
if ($stylesheet->load($xslt_file) == false)
    die('Failed to load XSLT file');

// language
$lang = 'en';
if(isset($_GET["lang"])) {
    if('fr' == $_GET["lang"])
	   $lang = 'fr';
}

// XSLT transformation
$xsl = new XSLTProcessor();
$xsl->importStyleSheet($stylesheet);
$xsl->setParameter('http://www.w3.org/1999/XSL/Transform', 'language', $lang);
$xsl->setParameter('http://www.w3.org/1999/XSL/Transform', 'profilesBoxName', 'Profils');
$xsl->setParameter('http://www.w3.org/1999/XSL/Transform', 'currentProjectsBoxName', 'Projets');
$xsl->setParameter('http://www.w3.org/1999/XSL/Transform', 'pastProjectsBoxName', 'Anciens projets');
$xsl->setParameter('http://www.w3.org/1999/XSL/Transform', 'peopleIKnowBoxName', 'Gens');
$xsl->setParameter('http://www.w3.org/1999/XSL/Transform', 'interestsBoxName', 'Intérêts');
$xsl->setParameter('http://www.w3.org/1999/XSL/Transform', 'publicationsBoxName', 'Publications');
$xsl->setParameter('http://www.w3.org/1999/XSL/Transform', 'contactLabel', 'Contact');

$output = $xsl->transformToXML($xml); // transforming

/*
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

*/

echo $output;

// Finally! Outputting HTML to browser

// caching (save processed version and display it next time)
//@file_put_contents($cached_file, $output);
?>

