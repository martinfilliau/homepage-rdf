<?php
error_reporting(E_ALL);

// configuration
$xslt_file = 'foaf-as-html.xsl';
$rdf_file = 'martinfilliau.rdf';
$available_languages = array(
        'en',
        'fr',
);
$openIdServer = 'https://www.myopenid.com/server';
$openIdDelegate = 'http://martinfilliau.myopenid.com';

/*
  determine which language out of an available set the user prefers most
 from: http://www.php.net/manual/en/function.http-negotiate-language.php
  $available_languages        array with language-tag-strings (must be lowercase) that are available
  $http_accept_language    a HTTP_ACCEPT_LANGUAGE string (read from $_SERVER['HTTP_ACCEPT_LANGUAGE'] if left out)
*/
function prefered_language ($available_languages,$http_accept_language="auto") {
    // if $http_accept_language was left out, read it from the HTTP-Header
    if ($http_accept_language == "auto") $http_accept_language = $_SERVER['HTTP_ACCEPT_LANGUAGE'];

    // standard  for HTTP_ACCEPT_LANGUAGE is defined under
    // http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4
    // pattern to find is therefore something like this:
    //    1#( language-range [ ";" "q" "=" qvalue ] )
    // where:
    //    language-range  = ( ( 1*8ALPHA *( "-" 1*8ALPHA ) ) | "*" )
    //    qvalue         = ( "0" [ "." 0*3DIGIT ] )
    //            | ( "1" [ "." 0*3("0") ] )
    preg_match_all("/([[:alpha:]]{1,8})(-([[:alpha:]|-]{1,8}))?" .
                   "(\s*;\s*q\s*=\s*(1\.0{0,3}|0\.\d{0,3}))?\s*(,|$)/i",
                   $http_accept_language, $hits, PREG_SET_ORDER);

    // default language (in case of no hits) is the first in the array
    $bestlang = $available_languages[0];
    $bestqval = 0;

    foreach ($hits as $arr) {
        // read data from the array of this hit
        $langprefix = strtolower ($arr[1]);
        if (!empty($arr[3])) {
            $langrange = strtolower ($arr[3]);
            $language = $langprefix . "-" . $langrange;
        }
        else $language = $langprefix;
        $qvalue = 1.0;
        if (!empty($arr[5])) $qvalue = floatval($arr[5]);
     
        // find q-maximal language 
        if (in_array($language,$available_languages) && ($qvalue > $bestqval)) {
            $bestlang = $language;
            $bestqval = $qvalue;
        }
        // if no direct hit, try the prefix only but decrease q-value by 10% (as http_negotiate_language does)
        else if (in_array($langprefix,$available_languages) && (($qvalue*0.9) > $bestqval)) {
            $bestlang = $langprefix;
            $bestqval = $qvalue*0.9;
        }
    }
    return $bestlang;
}

// from http://stackoverflow.com/questions/1974505/php-simple-translation-approach-your-opinion
class Translator {
    private $lang = array();
    private function findString($str,$lang) {
        if (array_key_exists($str, $this->lang[$lang])) {
            return $this->lang[$lang][$str];
        }
        return $str;
    }
    private function splitStrings($str) {
        return explode('=',trim($str));
    }
    public function __($str,$lang) {
        if (!array_key_exists($lang, $this->lang)) {
            $filePath = 'translations/' . $lang . '.txt';
            if (file_exists($filePath)) {
                $strings = array_map(array($this,'splitStrings'),file($filePath));
                foreach ($strings as $k => $v) {
                    $this->lang[$lang][$v[0]] = $v[1];
                }
                return $this->findString($str, $lang);
            }
            else {
                return $str;
            }
        }
        else {
            return $this->findString($str, $lang);
        }
    }
}

// language detection
$lang = 'en';
if(isset($_GET["lang"])) {
    if('fr' == $_GET["lang"])
	   $lang = 'fr';
} else {
    $lang = prefered_language ($available_languages);
}

// cache per lang
$cached_file = 'cache-' . $lang;

$xml_time = filemtime($rdf_file);
$xslt_time = filemtime($xslt_file);
$cache_time = @filemtime($cached_file);

if (($cache_time > $xml_time) && ($cache_time > $xslt_time))
{
    readfile($cached_file);
    echo '<!--c-->';        // returning cache content if nothing has been modified
    exit();
}

$source_xml = file_get_contents($rdf_file);

$xml = new DOMDocument;
$xml->substituteEntities = true;
if ($xml->loadXML($source_xml) == false)
    die('Failed to load RDF file');

$stylesheet = new DOMDocument;
$stylesheet->substituteEntities = true;
if ($stylesheet->load($xslt_file) == false)
    die('Failed to load XSLT file');

$t = new Translator();

// XSLT transformation
$xsl = new XSLTProcessor();
$xsl->importStyleSheet($stylesheet);
$xsl->setParameter('http://www.w3.org/1999/XSL/Transform', 'language', $lang);
$xsl->setParameter('http://www.w3.org/1999/XSL/Transform', 'profilesBoxName', $t->__('profilesBoxName', $lang));
$xsl->setParameter('http://www.w3.org/1999/XSL/Transform', 'currentProjectsBoxName', $t->__('currentProjectsBoxName', $lang));
$xsl->setParameter('http://www.w3.org/1999/XSL/Transform', 'pastProjectsBoxName', $t->__('pastProjectsBoxName', $lang));
$xsl->setParameter('http://www.w3.org/1999/XSL/Transform', 'peopleIKnowBoxName', $t->__('peopleIKnowBoxName', $lang));
$xsl->setParameter('http://www.w3.org/1999/XSL/Transform', 'interestsBoxName', $t->__('interestsBoxName', $lang));
$xsl->setParameter('http://www.w3.org/1999/XSL/Transform', 'publicationsBoxName', $t->__('publicationsBoxName', $lang));
$xsl->setParameter('http://www.w3.org/1999/XSL/Transform', 'contactLabel', $t->__('contactLabel', $lang));
$xsl->setParameter('http://www.w3.org/1999/XSL/Transform', 'cvLabel', $t->__('cvLabel', $lang));
$xsl->setParameter('http://www.w3.org/1999/XSL/Transform', 'cvUrl', $t->__('cvUrl', $lang));
$xsl->setParameter('http://www.w3.org/1999/XSL/Transform', 'openIdServer', $openIdServer);
$xsl->setParameter('http://www.w3.org/1999/XSL/Transform', 'openIdDelegate', $openIdDelegate);

$availableLanguages = '';

foreach ($available_languages as &$value) {
    $availableLanguages .= $value . ' ';
}

$xsl->setParameter('http://www.w3.org/1999/XSL/Transform', 'availableLanguages', $availableLanguages);

$output = $xsl->transformToXML($xml); // transforming

echo $output;

// caching (save processed version and display it next time)
@file_put_contents($cached_file, $output);

?>