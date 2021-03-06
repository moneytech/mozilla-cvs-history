<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html lang="en">

{if $smarty.get.app eq "thunderbird"}
    {assign var="app" value="thunderbird"}
{elseif $smarty.get.app eq "mozilla"}
    {assign var="app" value="mozilla"}
{elseif $smarty.get.app eq "seamonkey"}
    {assign var="app" value="mozilla"}
{elseif $smarty.get.app eq "sunbird"}
    {assign var="app" value="sunbird"}
{else}
    {assign var="app" value="firefox"}
{/if}

<head>
    <title>{if $title}{$title} :: {/if}Mozilla Add-ons :: Add Features to Mozilla Software</title>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <meta name="keywords" content="mozilla update, mozilla extensions, mozilla plugins, thunderbird themes, thunderbird extensions, firefox extensions, firefox themes">
    <link rel="stylesheet" type="text/css" href="{$config.webpath}/css/print.css" media="print">
    <link rel="stylesheet" type="text/css" href="{$config.webpath}/css/base/content.css" media="all">
    <link rel="stylesheet" type="text/css" href="{$config.webpath}/css/cavendish/content.css" title="Cavendish" media="all">
    <link rel="stylesheet" type="text/css" href="{$config.webpath}/css/base/template.css" media="screen">
    <link rel="stylesheet" type="text/css" href="{$config.webpath}/css/cavendish/template.css" title="Cavendish" media="screen">
    <link rel="stylesheet" type="text/css" href="{$config.webpath}/css/forms.css" media="screen">
    <link rel="home" title="Home" href="https://addons.mozilla.org/">
    <link rel="alternate" type="application/rss+xml" title="New {$app|escape:html:"UTF-8"} {if $currentTab eq "themes"}Themes{else}Extensions{/if}" href="{$config.webpath}/rss/{$app|escape:html:"UTF-8"}/{if $currentTab eq "themes"}themes{else}extensions{/if}/newest/">
    <link rel="icon" href="{$config.webpath}/images/favicon.ico" type="image/png">
    <script src="{$config.webpath}/js/install.js" type="text/javascript"></script>
    <script src="{$config.webpath}/js/search-plugin.js" type="text/javascript"></script>
    <script src="{$config.webpath}/js/auth.js" type="text/javascript"></script>
    {if $extraHeaders}
    {$extraHeaders}
    {/if}
</head>

<body>
<div id="container">

<p class="skipLink"><a href="#firefox-feature" accesskey="2">Skip to main content</a></p>

<div id="mozilla-com"><a href="http://www.mozilla.com/">Visit Mozilla.com</a></div>
<div id="header">

    <div id="key-title">

{if $app eq "thunderbird"}
        <h1><a href="{$config.webpath}/?app=thunderbird" title="Return to home page" accesskey="1"><img src="{$config.webpath}/images/title-thunderbird.gif" width="355" height="54" alt="Thunderbird Add-ons Beta"></a></h1>
{elseif $app eq "mozilla"}
        <h1><a href="{$config.webpath}/?app=mozilla" title="Return to home page" accesskey="1"><img src="{$config.webpath}/images/title-suite.gif" width="370" height="54" alt="Mozilla Suite Add-ons Beta"></a></h1>
{elseif $app eq "seamonkey"}
        <h1><a href="{$config.webpath}/?app=mozilla" title="Return to home page" accesskey="1"><img src="{$config.webpath}/images/title-suite.gif" width="370" height="54" alt="Mozilla Suite Add-ons Beta"></a></h1>
{elseif $app eq "sunbird"}
        <h1><a href="{$config.webpath}/?app=sunbird" title="Return to home page" accesskey="1"><img src="{$config.webpath}/images/title-sunbird.gif" width="295" height="54" alt="Sunbird Add-ons Beta"></a></h1>
{else}
        <h1><a href="{$config.webpath}/?app=firefox" title="Return to home page" accesskey="1"><img src="{$config.webpath}/images/title-firefox.gif" width="276" height="54" alt="Firefox Add-ons Beta"></a></h1>
{/if}

<script type="text/javascript">
//<![CDATA[
    addUsernameToHeader();
//]]>
</script>

		<form id="search" method="get" action="{$config.webpath}/search.php" title="Search Mozilla Update">
		<div>
		<label for="q" title="Search Mozilla Update">search:</label>
		<input type="text" id="q" name="q" accesskey="s" size="10"/>
        <input type="hidden" name="app" value="{$app}"/>
		<input type="submit" id="submit" value="Go"/>
		</div>
		</form>
	</div>

	<div id="key-menu">	
        <ul id="menu-firefox">
            <li{if $currentTab eq "home"} class="current"{/if}><a href="{$config.webpath}/{$app}/">Home</a></li>
            <li{if $currentTab eq "extensions"} class="current"{/if}><a href="{$config.webpath}/{$app}/extensions/">Extensions</a></li>
            <li{if $currentTab eq "plugins"} class="current"{/if}><a href="{$config.webpath}/{$app}/plugins/">Plugins</a></li>
            <li{if $currentTab eq "search-engines"} class="current"{/if}><a href="{$config.webpath}/{$app}/search-engines/">Search Engines</a></li>
            <li{if $currentTab eq "themes"} class="current"{/if}><a href="{$config.webpath}/{$app}/themes/">Themes</a></li>
        </ul>
    </div>
    <!-- end key-menu -->

</div>
<!-- end header -->

<hr class="hide">

{if $systemMessage}
<div class="key-point">
<h2>{$systemMesage.header}</h2>
<p>{$systemMessage.text|nl2br}</p>
</div>
{/if}

<div id="mBody">


 {* sidebar gets included if set *}
 {if $sidebar}
 <div id="side">
 {include file=$sidebar}
 </div>
 {/if}

<div id="mainContent">
