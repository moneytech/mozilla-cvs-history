/* -*- Mode: C++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is TransforMiiX XSLT Processor.
 *
 * The Initial Developer of the Original Code is
 * Axel Hecht.
 * Portions created by the Initial Developer are Copyright (C) 2001
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *  Axel Hecht <axel@pike.org>
 *  Peter Van der Beken <peterv@netscape.com>
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either the GNU General Public License Version 2 or later (the "GPL"), or
 * the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 *
 * ***** END LICENSE BLOCK ***** */

var xalan_field;

function onLoad()
{
    view.tests_run = document.getElementById("tests_run");
    view.tests_passed = document.getElementById("tests_passed");
    view.tests_failed = document.getElementById("tests_failed");
    view.tests_selected = document.getElementById("tests_selected");
    view.tree = document.getElementById('out');
    view.boxObject = view.tree.boxObject.QueryInterface(Components.interfaces.nsITreeBoxObject);
    enablePrivilege('UniversalXPConnect');
    // prune the spurious children of the iframe doc
    {  
        var iframe = document.getElementById('hiddenHtml').contentDocument;
        var children = iframe.childNodes;
        var cn = children.length;
        for (var i = cn-1; i >=0 ; i--) {
            if (children[i] != iframe.documentElement)
                iframe.removeChild(children[i]);
        }
    }
    view.database = view.tree.database;
    view.builder = view.tree.builder.QueryInterface(nsIXULTemplateBuilder);
    view.builder.QueryInterface(nsIXULTreeBuilder);
    runItem.prototype.kDatabase = view.database;
    xalan_field = document.getElementById("xalan_rdf");
    var persistedUrl = xalan_field.getAttribute('url');
    if (persistedUrl) {
        view.xalan_url = persistedUrl;
        xalan_field.value = persistedUrl;
    }
    view.setDataSource();
    return true;
}

function onUnload()
{
    if (xalan_field)
        xalan_field.setAttribute('url', xalan_field.value);
}
