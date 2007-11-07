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
 * The Original Code is Mozilla Calendar code.
 *
 * The Initial Developer of the Original Code is
 *   Philipp Kewisch <mozilla@kewis.ch>
 * Portions created by the Initial Developer are Copyright (C) 2007
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
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

/**
 * Show the filepicker and create a new calendar with a local file using the ICS
 * provider.
 */
function openLocalCalendar() {
    const nsIFilePicker = Components.interfaces.nsIFilePicker;
    var fp = Components.classes["@mozilla.org/filepicker;1"].createInstance(nsIFilePicker);
    fp.init(window, calGetString("calendar", "Open"), nsIFilePicker.modeOpen);
    var wildmat = "*.ics";
    var description = calGetString("calendar", "filterIcs", [wildmat]);
    fp.appendFilter(description, wildmat);
    fp.appendFilters(nsIFilePicker.filterAll);

    if (fp.show() != nsIFilePicker.returnOK) {
        return;
    }

    var calMgr = getCalendarManager();
    var index = calendarListTreeView.findIndexByUri(fp.fileURL);
    if (index >= 0) {
        // The calendar already exists, select it and return.
        calendarListTreeView.tree.view.selection.select(index);
        return;
    }

    var openCalendar = calMgr.createCalendar("ics", fp.fileURL);
    calMgr.registerCalendar(openCalendar);

    // Strip ".ics" from filename for use as calendar name, taken from
    // calendarCreation.js
    var fullPathRegex = new RegExp("([^/:]+)[.]ics$");
    var prettyName = fp.fileURL.spec.match(fullPathRegex);
    var name;

    if (prettyName && prettyName.length >= 1) {
        name = decodeURIComponent(prettyName[1]);
    } else {
        name = calGetString("calendar", "untitledCalendarName");
    }

    openCalendar.name = name;
}